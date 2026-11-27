// Open Imaging Slots — single-page front end. No build step, no dependencies.

// ---------- tiny templating with automatic escaping ----------
class Raw { constructor(s) { this.s = s; } toString() { return this.s; } }
const raw = (s) => new Raw(s);
const esc = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const part = (v) => (v instanceof Raw ? v.s : Array.isArray(v) ? v.map(part).join('') : v === false || v == null ? '' : esc(v));
const html = (strings, ...vals) => raw(strings.reduce((out, s, i) => out + part(vals[i - 1]) + s));

const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
const main = $('#main');

// ---------- API ----------
// Each navigation bumps routeSeq. A response that arrives after the user has moved
// on never resolves, so a slow earlier page can't overwrite the current one.
let routeSeq = 0;
async function api(method, url, body) {
  const seq = routeSeq;
  const res = await fetch(url, {
    method, credentials: 'same-origin',
    headers: body !== undefined ? { 'Content-Type': 'application/json' } : {},
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  if (seq !== routeSeq) return new Promise(() => {});
  if (!res.ok) { const e = new Error(data.error || 'Request failed'); e.details = data.details; e.status = res.status; throw e; }
  return data;
}

const state = { me: null, meta: null };

// ---------- formatting ----------
const money = (cents) => (cents == null ? '' : (cents / 100).toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }));
const fmtDay = (iso, tz) => new Date(iso).toLocaleDateString('en-US', { timeZone: tz, weekday: 'short', month: 'short', day: 'numeric' });
const fmtTime = (iso, tz) => new Date(iso).toLocaleTimeString('en-US', { timeZone: tz, hour: 'numeric', minute: '2-digit' });
const fmtDateTime = (iso, tz) => `${fmtDay(iso, tz)}, ${fmtTime(iso, tz)}`;
const dayKey = (iso, tz) => new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date(iso));
const today = () => new Date().toLocaleDateString('en-CA');
const modalityName = (m) => (state.meta.modalities[m] || {}).name || m;
const examsFor = (m) => state.meta.exams.filter((e) => e.modality === m);
const examBy = (code) => state.meta.exams.find((e) => e.code === code);

function statusBadge(status, label) { return html`<span class="badge status-${status}">${label || state.meta.statusLabels[status]}</span>`; }
function errorBox(e) {
  return html`<div class="alert error" role="alert"><strong>${e.message}</strong>${e.details && e.details.length ? html`<ul>${e.details.map((d) => html`<li>${d}</li>`)}</ul>` : ''}</div>`;
}
function setPath(obj, pathStr, value, push) {
  const keys = pathStr.split('.');
  let o = obj;
  for (const k of keys.slice(0, -1)) o = o[k] ??= {};
  const last = keys[keys.length - 1];
  if (push) (o[last] ??= []).push(value); else o[last] = value;
}
function formToObject(form) {
  const out = {};
  for (const el of form.elements) {
    if (!el.name || el.disabled || el.type === 'file') continue;
    if (el.type === 'checkbox') {
      if (el.name.endsWith('[]')) { if (el.checked) setPath(out, el.name.slice(0, -2), el.value, true); }
      else setPath(out, el.name, el.checked);
    } else if (el.type === 'radio') { if (el.checked) setPath(out, el.name, el.value); }
    else setPath(out, el.name, el.value);
  }
  return out;
}
function parseHash() {
  const h = location.hash.replace(/^#/, '') || '/';
  const [p, qs] = h.split('?');
  return { path: p, query: new URLSearchParams(qs || '') };
}
function go(hash) { if (location.hash === hash) route(); else location.hash = hash; }
function setTitle(t) { document.title = t ? `${t} · Open Imaging Slots` : 'Open Imaging Slots'; }
function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(String(r.result).split(',')[1]);
    r.onerror = () => reject(r.error);
    r.readAsDataURL(file);
  });
}

// ---------- nav ----------
function renderNav() {
  const me = state.me;
  const links = [html`<a href="#/search">Find a scan</a>`];
  if (me) {
    links.push(html`<a href="#/portal">${me.role === 'practice' ? 'Practice portal' : 'My requests'}</a>`);
    if (me.role === 'physician') links.push(html`<a href="#/refer">New referral</a>`);
    if (me.role === 'practice') links.push(html`<a href="#/practice/slots">Slots</a>`, html`<a href="#/practice/profile">Profile &amp; prices</a>`);
    links.push(html`<span class="who" title="${me.email}">${me.name} <small>(${me.role})</small></span>`, html`<button class="link" id="logout">Sign out</button>`);
  } else {
    links.push(html`<a href="#/for/physicians">Physicians</a>`, html`<a href="#/for/legal">Medical-legal</a>`, html`<a href="#/for/practices">Imaging centers</a>`, html`<a class="btn small" href="#/login">Sign in</a>`);
  }
  $('#nav').innerHTML = part(links);
  const lo = $('#logout');
  if (lo) lo.onclick = async () => { await api('POST', '/api/auth/logout', {}); state.me = null; renderNav(); go('#/'); };
}

// ---------- pages ----------
function modalityOptions(selected, includeBlank) {
  return html`${includeBlank ? html`<option value="">Choose…</option>` : ''}${Object.entries(state.meta.modalities).map(([k, m]) => html`<option value="${k}" ${k === selected ? 'selected' : ''}>${m.name}</option>`)}`;
}
function paymentOptions(selected) {
  return html`<option value="">Any payment option</option>${Object.entries(state.meta.payments).map(([k, v]) => html`<option value="${k}" ${k === selected ? 'selected' : ''}>${v}</option>`)}`;
}

function pageHome() {
  setTitle('');
  main.innerHTML = part(html`
    <section class="hero">
      <h1>Find an open imaging appointment</h1>
      <p class="lead">See real open times for MRI, CT, ultrasound, DEXA and X-ray at radiology practices near you, then request the slot with your doctor's order, as self-pay, or as a medical-legal case.</p>
      <form id="quick" class="quick card">
        <label>Scan type<select name="modality" required>${modalityOptions('MRI')}</select></label>
        <label>ZIP code<input name="zip" inputmode="numeric" pattern="\\d{5}" maxlength="5" placeholder="e.g. 75201"></label>
        <label>How will you pay?<select name="payment">${paymentOptions('')}</select></label>
        <button class="btn">Show open times</button>
      </form>
    </section>
    <section class="portals">
      <a class="card portal" href="#/for/patients"><h2>Patients</h2><p>Book with your doctor's prescription and insurance, or pay a published cash price. No prescription? Some centers offer physician order review for self-pay scans.</p><span class="cta">Patient portal →</span></a>
      <a class="card portal" href="#/for/physicians"><h2>Physicians</h2><p>Send an electronic order with ICD-10 codes and clinical indication, pick an open slot for your patient or let the center schedule, and track status.</p><span class="cta">Physician portal →</span></a>
      <a class="card portal" href="#/for/legal"><h2>Medical-legal</h2><p>Personal injury and workers' comp imaging on a letter of protection or lien, with expedited reads, narrative reports and certified records.</p><span class="cta">Attorney &amp; case manager portal →</span></a>
      <a class="card portal" href="#/for/practices"><h2>Imaging centers</h2><p>Publish open slots, set self-pay prices and medical-legal terms, and work your referral queue in one place.</p><span class="cta">Practice portal →</span></a>
    </section>
    <section class="card">
      <h2>Three ways to pay</h2>
      <div class="grid3">
        <div><h3>Insurance</h3><p>Needs a physician order. Some plans also need prior authorization, which the ordering office or the center obtains before your scan.</p></div>
        <div><h3>Self-pay</h3><p>A published all-in cash price for the scan and radiologist read. Bring an order, or choose a center that offers physician order review.</p></div>
        <div><h3>Medical-legal</h3><p>For injury cases: billed on a letter of protection (LOP), lien or workers' comp claim. A treating physician's order is still required.</p></div>
      </div>
    </section>`);
  $('#quick').onsubmit = (e) => {
    e.preventDefault();
    const q = new URLSearchParams(Object.entries(formToObject(e.target)).filter(([, v]) => v));
    go('#/search?' + q);
  };
}

const AUDIENCE = {
  patients: { title: 'For patients', role: 'patient', body: [
    'Search open times at nearby centers and compare self-pay prices side by side.',
    'Have a prescription? Upload a photo or PDF of it and choose insurance, self-pay or medical-legal billing.',
    'No prescription? Choose "Self-pay" at a center that offers physician order review: a licensed physician reviews your request and writes the order if the scan is appropriate. Texas and most states require a physician order for diagnostic imaging.',
    'Answer the safety questions (implants, pregnancy, kidney health) so the center can prepare.',
    'Track your request and message the center from your portal.'] },
  physicians: { title: 'For physicians', role: 'physician', body: [
    'Sign up with your NPI. Orders you send are tied to your NPI and include ICD-10 codes and clinical indication.',
    'Pick an open slot for your patient while they are still in the room, or send the order and let the center call them.',
    'Mark orders routine, urgent or STAT.',
    'Bill insurance, quote the patient a self-pay price, or flag the case as medical-legal (LOP / lien / workers’ comp).',
    'See every referral’s status: pending, confirmed, needs info, completed.'] },
  legal: { title: 'For attorneys and case managers', role: 'attorney', body: [
    'Request imaging for injured clients at centers that accept letters of protection, liens and workers’ comp.',
    'Upload the treating physician’s order and your LOP; the center reviews and confirms.',
    'Ask for expedited reads, narrative reports, certified records and images, and radiologist deposition availability.',
    'Physicians and patients can also choose medical-legal billing from their own portals.'] },
  practices: { title: 'For imaging centers', role: 'practice', body: [
    'Publish open slots in bulk by modality and scanner (e.g. 3T, open, wide-bore).',
    'Set self-pay prices per exam (CPT), insurance and medical-legal policies, and whether you offer physician order review.',
    'Work a referral queue with safety-screening flags, attached orders and LOPs; confirm, decline or ask for more information.',
    'Slots are held when requested and released automatically if you decline or the requester cancels.'] },
};
function pageAudience(key) {
  const a = AUDIENCE[key];
  if (!a) return pageNotFound();
  setTitle(a.title);
  const signedInAs = state.me && state.me.role === a.role;
  main.innerHTML = part(html`
    <div class="card narrow">
      <h1>${a.title}</h1>
      <ul class="checks">${a.body.map((b) => html`<li>${b}</li>`)}</ul>
      <div class="row">
        ${signedInAs ? html`<a class="btn" href="#/portal">Open my portal</a>` : html`
          <a class="btn" href="#/register?role=${a.role}">Create a ${a.role === 'practice' ? 'practice' : a.role} account</a>
          <a class="btn ghost" href="#/login">I already have an account</a>`}
        ${a.role !== 'practice' ? html`<a class="btn ghost" href="#/search${a.role === 'attorney' ? '?payment=medical_legal' : ''}">Browse open times</a>` : ''}
      </div>
    </div>`);
}

// ----- search -----
async function pageSearch(query) {
  setTitle('Find a scan');
  const modality = query.get('modality') || 'MRI';
  const f = {
    modality, exam: query.get('exam') || '', zip: query.get('zip') || '', radius: query.get('radius') || '25',
    payment: query.get('payment') || '', equipment: query.get('equipment') || '', from: query.get('from') || '', sort: query.get('sort') || 'soonest',
  };
  main.innerHTML = part(html`
    <h1>Open times</h1>
    <form id="filters" class="card filters">
      <label>Scan type<select name="modality">${modalityOptions(f.modality)}</select></label>
      <label>Exam<select name="exam"><option value="">Any ${modalityName(f.modality)} exam</option>
        ${examsFor(f.modality).map((e) => html`<option value="${e.code}" ${e.code === f.exam ? 'selected' : ''}>${e.name} (CPT ${e.cpt})</option>`)}</select></label>
      <label>ZIP<input name="zip" value="${f.zip}" inputmode="numeric" pattern="\\d{5}" maxlength="5" placeholder="Any"></label>
      <label>Within<select name="radius">${['5', '10', '25', '50', '100'].map((r) => html`<option value="${r}" ${r === f.radius ? 'selected' : ''}>${r} miles</option>`)}</select></label>
      <label>Payment<select name="payment">${paymentOptions(f.payment)}</select></label>
      ${f.modality === 'MRI' ? html`<label>Scanner<select name="equipment">
        ${[['', 'Any'], ['open', 'Open MRI'], ['wide', 'Wide-bore'], ['3t', '3T']].map(([v, l]) => html`<option value="${v}" ${v === f.equipment ? 'selected' : ''}>${l}</option>`)}</select></label>` : ''}
      <label>From<input type="date" name="from" value="${f.from}" min="${today()}"></label>
      <label>Sort by<select name="sort">${[['soonest', 'Soonest'], ['price', 'Lowest self-pay price'], ['distance', 'Nearest']].map(([v, l]) => html`<option value="${v}" ${v === f.sort ? 'selected' : ''}>${l}</option>`)}</select></label>
    </form>
    <div id="results" aria-live="polite"><p class="muted">Searching…</p></div>`);
  const form = $('#filters');
  form.onchange = (e) => {
    const o = formToObject(form);
    if (e.target.name === 'modality') { o.exam = ''; o.equipment = ''; }
    go('#/search?' + new URLSearchParams(Object.entries(o).filter(([, v]) => v)));
  };
  try {
    const params = new URLSearchParams(Object.entries(f).filter(([, v]) => v));
    const data = await api('GET', '/api/slots/search?' + params);
    renderResults(data, f);
  } catch (e) { $('#results').innerHTML = part(errorBox(e)); }
}

function renderResults(data, f) {
  const box = $('#results');
  if (!data.results.length) {
    box.innerHTML = part(html`<div class="card"><p>No open ${modalityName(f.modality)} times match those filters. Try a wider distance, a later date or a different payment option.</p></div>`);
    return;
  }
  const exam = f.exam ? examBy(f.exam) : null;
  box.innerHTML = part(html`
    <p class="muted">${data.results.length} practice${data.results.length === 1 ? '' : 's'} with open ${modalityName(f.modality)} times${data.origin ? html` near ${data.origin.city} ${data.origin.zip}` : ''}.
      ${!exam ? 'Choose an exam to see self-pay prices.' : ''}</p>
    ${data.results.map((r) => {
      const p = r.practice;
      const byDay = {};
      for (const s of r.slots) (byDay[dayKey(s.starts_at, p.tz)] ??= []).push(s);
      const days = Object.entries(byDay);
      return html`
      <article class="card result">
        <div class="result-head">
          <div>
            <h2><a href="#/practice/${p.id}">${p.name}</a></h2>
            <p class="muted">${p.address}, ${p.city}, ${p.state} ${p.zip}${r.distance != null ? html` · <strong>${r.distance} mi</strong>` : ''} · ${p.phone}</p>
            <p class="badges">
              ${p.accepts_insurance ? html`<span class="badge">Insurance</span>` : ''}
              ${p.accepts_self_pay ? html`<span class="badge">Self-pay</span>` : ''}
              ${p.accepts_medical_legal ? html`<span class="badge legal">Medical-legal / LOP</span>` : ''}
              ${p.offers_order_review ? html`<span class="badge review">Physician order review</span>` : ''}
              ${p.equipment.map((e) => html`<span class="badge plain">${e}</span>`)}
            </p>
          </div>
          <div class="price">${r.price != null ? html`<span class="muted small">Self-pay</span><strong>${money(r.price)}</strong>` : ''}
            <span class="muted small">Next: ${fmtDateTime(r.nextAvailable, p.tz)}</span></div>
        </div>
        <div class="days">
          ${days.map(([, slots], i) => html`
            <div class="day ${i >= 3 ? 'extra' : ''}" ${i >= 3 ? 'hidden' : ''}>
              <h3>${fmtDay(slots[0].starts_at, p.tz)}</h3>
              <div class="chips">${slots.map((s) => html`<a class="chip" href="#/book/${s.id}?${new URLSearchParams(Object.entries({ exam: f.exam, payment: f.payment }).filter(([, v]) => v))}"
                title="${s.duration_min} min${s.equipment ? ' · ' + s.equipment : ''}">${fmtTime(s.starts_at, p.tz)}${s.duration_min >= 60 ? html`<small>60m</small>` : ''}</a>`)}</div>
            </div>`)}
          ${days.length > 3 ? html`<button class="link more" type="button">Show ${days.length - 3} more day${days.length - 3 === 1 ? '' : 's'}</button>` : ''}
        </div>
      </article>`;
    })}`);
  $$('.more', box).forEach((b) => (b.onclick = () => { $$('.extra', b.parentElement).forEach((d) => (d.hidden = false)); b.remove(); }));
}

async function pagePractice(id) {
  const { practice: p, prices } = await api('GET', '/api/practices/' + id);
  setTitle(p.name);
  main.innerHTML = part(html`
    <div class="card">
      <h1>${p.name}</h1>
      <p>${p.address}, ${p.city}, ${p.state} ${p.zip} · ${p.phone} · ${p.hours || ''}</p>
      ${p.description ? html`<p>${p.description}</p>` : ''}
      <p class="muted">${p.accreditation || ''}</p>
      <p class="badges">${p.modalities.map((m) => html`<a class="badge" href="#/search?modality=${m}">${modalityName(m)}</a>`)}</p>
      <dl class="facts">
        <dt>Insurance</dt><dd>${p.accepts_insurance ? p.insurance_notes || 'Accepted' : 'Not billed'}</dd>
        <dt>Self-pay</dt><dd>${p.accepts_self_pay ? 'Yes' : 'No'}${p.offers_order_review ? ' · physician order review available' : ''}</dd>
        <dt>Medical-legal</dt><dd>${p.accepts_medical_legal ? p.legal_services.map((s) => state.meta.legalServices[s]).join('; ') || 'Accepted' : 'Not accepted'}</dd>
      </dl>
    </div>
    <div class="card"><h2>Self-pay prices</h2><p class="muted">All-inclusive cash price for the scan and radiologist read.</p>
      <table class="table"><thead><tr><th>Exam</th><th>CPT</th><th class="num">Price</th></tr></thead><tbody>
      ${state.meta.exams.filter((e) => prices[e.code]).map((e) => html`<tr><td>${e.name}</td><td>${e.cpt}</td><td class="num">${money(prices[e.code])}</td></tr>`)}
      </tbody></table></div>`);
}

// ----- auth pages -----
function pageLogin(query) {
  setTitle('Sign in');
  const next = query.get('next') || '#/portal';
  main.innerHTML = part(html`
    <form id="login" class="card narrow">
      <h1>Sign in</h1>
      <div id="err"></div>
      <label>Email<input type="email" name="email" autocomplete="username" required></label>
      <label>Password<input type="password" name="password" autocomplete="current-password" required></label>
      <button class="btn">Sign in</button>
      <p class="muted">New here? <a href="#/register?next=${encodeURIComponent(next)}">Create an account</a></p>
      <details class="demo"><summary>Demo accounts</summary>
        <p>Password for all: <code>demo1234</code></p>
        <ul>${[['patient@demo.test', 'Patient'], ['doctor@demo.test', 'Physician'], ['attorney@demo.test', 'Attorney'], ['uptown@demo.test', 'Practice: Uptown Imaging'], ['clearprice@demo.test', 'Practice: ClearPrice Imaging']]
          .map(([e, l]) => html`<li><button type="button" class="link fill" data-email="${e}">${l}</button> <code>${e}</code></li>`)}</ul>
      </details>
    </form>`);
  $$('.fill').forEach((b) => (b.onclick = () => { $('[name=email]').value = b.dataset.email; $('[name=password]').value = 'demo1234'; }));
  $('#login').onsubmit = async (e) => {
    e.preventDefault();
    try {
      const { user } = await api('POST', '/api/auth/login', formToObject(e.target));
      state.me = user; renderNav(); go(next);
    } catch (err) { $('#err').innerHTML = part(errorBox(err)); }
  };
}

function pageRegister(query) {
  setTitle('Create account');
  const role = query.get('role') || 'patient';
  const next = query.get('next') || '#/portal';
  const roleLabels = { patient: 'Patient', physician: 'Physician / ordering provider', attorney: 'Attorney / case manager', practice: 'Imaging center staff' };
  main.innerHTML = part(html`
    <form id="reg" class="card narrow">
      <h1>Create an account</h1>
      <div id="err"></div>
      <fieldset><legend>I am a…</legend><div class="segmented">
        ${Object.entries(roleLabels).map(([k, l]) => html`<label><input type="radio" name="role" value="${k}" ${k === role ? 'checked' : ''}> ${l}</label>`)}</div></fieldset>
      <label>Full name<input name="name" required autocomplete="name"></label>
      <label>Email<input type="email" name="email" required autocomplete="email"></label>
      <label>Phone<input name="phone" autocomplete="tel"></label>
      <label>Password (8+ characters)<input type="password" name="password" minlength="8" required autocomplete="new-password"></label>
      <div data-role="physician"><label>NPI<input name="npi" inputmode="numeric" pattern="\\d{10}" maxlength="10"></label>
        <label>Practice / clinic<input name="organization"></label></div>
      <div data-role="attorney"><label>Firm / company<input name="organization"></label></div>
      <div data-role="practice">
        <label>Imaging center name<input name="practice.name"></label>
        <label>Street address<input name="practice.address"></label>
        <div class="row3"><label>City<input name="practice.city"></label><label>State<input name="practice.state" maxlength="2"></label><label>ZIP<input name="practice.zip" maxlength="5"></label></div>
        <label>Front desk phone<input name="practice.phone"></label>
        <fieldset><legend>Modalities offered</legend><div class="checkrow">
          ${Object.entries(state.meta.modalities).map(([k, m]) => html`<label><input type="checkbox" name="practice.modalities[]" value="${k}"> ${m.name}</label>`)}</div></fieldset>
        <p class="muted small">Your center starts with default self-pay prices. Review them under Profile &amp; prices before publishing slots.</p>
      </div>
      <label class="check"><input type="checkbox" name="terms" required> I agree to the terms of use and privacy policy.</label>
      <button class="btn">Create account</button>
      <p class="muted">Already registered? <a href="#/login?next=${encodeURIComponent(next)}">Sign in</a></p>
    </form>`);
  const form = $('#reg');
  const sync = () => {
    const r = formToObject(form).role;
    $$('[data-role]', form).forEach((d) => { const on = d.dataset.role === r; d.hidden = !on; $$('input', d).forEach((i) => (i.disabled = !on)); });
    $('[name=npi]').required = r === 'physician';
  };
  form.onchange = sync; sync();
  form.onsubmit = async (e) => {
    e.preventDefault();
    try {
      const { user } = await api('POST', '/api/auth/register', formToObject(form));
      state.me = user; renderNav(); go(next);
    } catch (err) { $('#err').innerHTML = part(errorBox(err)); window.scrollTo(0, 0); }
  };
}

// ----- booking / referral form -----
async function pageBook(slotId, query) {
  setTitle('Request appointment');
  if (!state.me) {
    const next = location.hash;
    main.innerHTML = part(html`<div class="card narrow"><h1>Sign in to request this time</h1>
      <p>Requests include health information, so we need an account to keep it private and send you updates.</p>
      <div class="row"><a class="btn" href="#/login?next=${encodeURIComponent(next)}">Sign in</a>
      <a class="btn ghost" href="#/register?role=patient&next=${encodeURIComponent(next)}">I'm a patient</a>
      <a class="btn ghost" href="#/register?role=physician&next=${encodeURIComponent(next)}">I'm a physician</a>
      <a class="btn ghost" href="#/register?role=attorney&next=${encodeURIComponent(next)}">I'm an attorney</a></div></div>`);
    return;
  }
  if (state.me.role === 'practice') {
    main.innerHTML = part(html`<div class="card narrow"><p>Practice accounts can't request appointments. Use your practice portal to manage slots.</p></div>`);
    return;
  }
  const { slot } = await api('GET', '/api/slots/' + slotId);
  const { practice, prices } = await api('GET', '/api/practices/' + slot.practice_id);
  if (slot.status !== 'open') {
    main.innerHTML = part(html`<div class="card narrow"><h1>That time was just taken</h1><p><a class="btn" href="#/search?modality=${slot.modality}">See other open times</a></p></div>`);
    return;
  }
  renderReferralForm({ practice, prices, slot, modality: slot.modality, exam: query.get('exam'), payment: query.get('payment') });
}

async function pageRefer(query) {
  setTitle('New referral');
  if (!state.me || state.me.role !== 'physician') return go('#/login?next=' + encodeURIComponent('#/refer'));
  const modality = query.get('modality') || 'MRI';
  const { practices } = await api('GET', '/api/practices');
  const list = practices.filter((p) => p.modalities.includes(modality));
  const practiceId = Number(query.get('practice')) || (list[0] && list[0].id);
  main.innerHTML = part(html`
    <h1>New referral</h1>
    <p class="muted">Send an order without choosing a time; the imaging center will call the patient to schedule. To pick a time now, <a href="#/search?modality=${modality}">search open times</a> instead.</p>
    <form id="pick" class="card filters">
      <label>Scan type<select name="modality">${modalityOptions(modality)}</select></label>
      <label>Imaging center<select name="practice">${list.map((p) => html`<option value="${p.id}" ${p.id === practiceId ? 'selected' : ''}>${p.name} (${p.city})</option>`)}</select></label>
    </form>
    <div id="formhost"></div>`);
  $('#pick').onchange = (e) => {
    const o = formToObject(e.currentTarget);
    go(`#/refer?modality=${o.modality}${e.target.name === 'practice' ? '&practice=' + o.practice : ''}`);
  };
  if (!practiceId) { $('#formhost').innerHTML = part(html`<div class="card"><p>No centers offer ${modalityName(modality)} yet.</p></div>`); return; }
  const { practice, prices } = await api('GET', '/api/practices/' + practiceId);
  renderReferralForm({ practice, prices, slot: null, modality, exam: query.get('exam'), host: $('#formhost') });
}

function renderReferralForm({ practice, prices, slot, modality, exam: examCode, payment: prePayment, host }) {
  const me = state.me;
  const role = me.role;
  const exams = examsFor(modality).filter((e) => !slot || e.minutes <= slot.duration_min);
  const pathwayChoices = role === 'physician' ? ['physician'] : role === 'attorney' ? ['attorney'] : ['patient_rx', 'patient_selfpay'];
  const pathwayText = {
    physician: ['Physician referral', 'You are the ordering provider. The order is tied to your NPI.'],
    patient_rx: ['I have a prescription from my doctor', 'Upload a photo or PDF of the order. Bill insurance, self-pay or a medical-legal case.'],
    patient_selfpay: ['Self-pay, no prescription', practice.offers_order_review
      ? 'A licensed physician working with this center reviews your request and writes the order if the scan is appropriate. You pay the cash price.'
      : 'This center needs a physician order for every scan. You can still pay the self-pay price: choose the option above and upload your order.'],
    attorney: ['Medical-legal request', 'Upload the treating physician’s order and your letter of protection or claim details.'],
  };
  const defaultPathway = role === 'patient' && prePayment === 'self_pay' && practice.offers_order_review ? 'patient_selfpay' : pathwayChoices[0];
  const [first, ...rest] = role === 'patient' ? me.name.split(' ') : ['', ''];
  const target = host || main;
  const nameParts = { first, last: rest.join(' ') };

  target.innerHTML = part(html`
    ${host ? '' : html`<h1>Request this appointment</h1>`}
    <form id="ref" class="booking" novalidate>
      <div id="err"></div>
      <section class="card summary">
        <div><h2>${practice.name}</h2><p class="muted">${practice.address}, ${practice.city}, ${practice.state} ${practice.zip} · ${practice.phone}</p></div>
        <div class="when">${slot ? html`<strong>${fmtDateTime(slot.starts_at, practice.tz)}</strong><span class="muted">${modalityName(modality)} · ${slot.duration_min} min${slot.equipment ? ' · ' + slot.equipment : ''}</span>`
          : html`<strong>No time chosen</strong><span class="muted">The center will contact the patient to schedule.</span>`}</div>
        ${slot ? html`<p class="muted small">This time is held for you once you submit, until the center confirms it.</p>` : ''}
      </section>

      <section class="card">
        <h2>1. Exam</h2>
        <label>Exam<select name="examCode" required>${exams.map((e) => html`<option value="${e.code}" ${e.code === examCode ? 'selected' : ''}>${e.name} (CPT ${e.cpt})</option>`)}</select></label>
        <p id="examInfo" class="muted"></p>
      </section>

      <section class="card">
        <h2>2. How is this scan being requested?</h2>
        <div class="options">
          ${pathwayChoices.map((k) => {
            const disabled = k === 'patient_selfpay' && !practice.accepts_self_pay;
            return html`<label class="option"><input type="radio" name="pathway" value="${k}" ${k === defaultPathway ? 'checked' : ''} ${disabled ? 'disabled' : ''}>
              <span><strong>${pathwayText[k][0]}</strong><small>${pathwayText[k][1]}</small></span></label>`;
          })}
        </div>
        <h3>Payment</h3>
        <div class="options" id="payments">
          ${Object.entries(state.meta.payments).map(([k, v]) => {
            const accepted = (k === 'insurance' && practice.accepts_insurance) || (k === 'self_pay' && practice.accepts_self_pay) || (k === 'medical_legal' && practice.accepts_medical_legal);
            return html`<label class="option" data-payment="${k}"><input type="radio" name="payment" value="${k}" ${!accepted ? 'disabled' : ''} ${k === prePayment && accepted ? 'checked' : ''}>
              <span><strong>${v}</strong><small>${accepted ? { insurance: 'We send your insurance details to the center. Prior authorization may be needed.', self_pay: 'Pay the published cash price at check-in.', medical_legal: 'For injury cases: LOP, lien or workers’ comp.' }[k] : 'Not offered by this center.'}</small></span></label>`;
          })}
        </div>
      </section>

      <section class="card">
        <h2>3. Patient</h2>
        <div class="row2"><label>First name<input name="patient.firstName" required value="${nameParts.first}" autocomplete="${role === 'patient' ? 'given-name' : 'off'}"></label>
          <label>Last name<input name="patient.lastName" required value="${nameParts.last}" autocomplete="${role === 'patient' ? 'family-name' : 'off'}"></label></div>
        <div class="row3"><label>Date of birth<input type="date" name="patient.dob" required max="${today()}"></label>
          <label>Sex<select name="patient.sex"><option value="">—</option><option>Female</option><option>Male</option><option>Other</option></select></label>
          <label>Weight (lb)<input name="patient.weightLb" inputmode="numeric" maxlength="4"></label></div>
        <div class="row2"><label>Phone<input name="patient.phone" required value="${role === 'patient' ? me.phone || '' : ''}"></label>
          <label>Email<input type="email" name="patient.email" value="${role === 'patient' ? me.email : ''}"></label></div>
        <label>Preferred language / accessibility needs<input name="patient.language" placeholder="e.g. Spanish interpreter, wheelchair transfer"></label>
      </section>

      <section class="card" data-show="pathway:physician">
        <h2>4. Order</h2>
        <div class="row2"><label>Ordering physician<input name="order.physicianName" value="${me.name}"></label>
          <label>NPI<input name="order.npi" value="${me.npi || ''}" inputmode="numeric" maxlength="10"></label></div>
        <div class="row2"><label>ICD-10 code(s)<input name="order.icd10" placeholder="e.g. M54.16, M51.26"></label>
          <label>Priority<select name="priority"><option value="routine">Routine</option><option value="urgent">Urgent (within 48 h)</option><option value="stat">STAT (same day)</option></select></label></div>
        <label>Clinical indication / history<textarea name="order.indication" rows="3" placeholder="Symptoms, duration, relevant exam findings, question to answer"></textarea></label>
        <div class="row2"><label>Prior relevant imaging<input name="order.priorImaging" placeholder="Modality, date, location"></label>
          <label>Send report to (fax or email)<input name="order.sendReportTo"></label></div>
      </section>

      <section class="card" data-show="pathway:patient_rx,attorney,patient_selfpay">
        <h2>4. Physician order</h2>
        <div data-show="pathway:patient_selfpay"><p class="muted">Optional. If you have an order, upload it. If not, describe why you want the scan; a physician will review it.</p></div>
        <label class="upload">Prescription / order (PDF or photo)<input type="file" data-upload="rx" accept="application/pdf,image/*"><span class="upstatus" data-for="rx"></span></label>
        <input type="hidden" name="uploads.rx">
        <div data-show="pathway:patient_rx,attorney"><div class="row3"><label>Ordering physician<input name="order.physicianName"></label>
          <label>NPI (if known)<input name="order.npi" inputmode="numeric" maxlength="10"></label>
          <label>Office phone<input name="order.phone"></label></div></div>
        <div data-show="pathway:patient_selfpay"><label>Why do you want this scan?<textarea name="order.reason" rows="3" placeholder="Your symptoms, how long you've had them, and any treatment so far"></textarea></label></div>
      </section>

      <section class="card" data-show="payment:insurance">
        <h2>5. Insurance</h2>
        <div class="row2"><label>Insurance carrier<input name="insurance.carrier" placeholder="e.g. BCBS TX PPO"></label>
          <label>Member ID<input name="insurance.memberId"></label></div>
        <div class="row3"><label>Group number<input name="insurance.groupNumber"></label>
          <label>Subscriber name (if not the patient)<input name="insurance.subscriber"></label>
          <label>Prior authorization # (if obtained)<input name="insurance.authNumber"></label></div>
      </section>

      <section class="card" data-show="payment:self_pay">
        <h2>5. Self-pay</h2>
        <p class="price-line">Cash price at ${practice.name}: <strong id="selfPrice"></strong></p>
        <p class="muted">Includes the scan and the radiologist's report. Contrast, if needed, is included for exams listed "with contrast". Your insurance will not be billed for this visit, and the payment may not count toward your deductible.</p>
        <label class="check"><input type="checkbox" name="selfPayAcknowledged"> I understand the price and will pay it at check-in.</label>
      </section>

      <section class="card" data-show="payment:medical_legal">
        <h2>5. Medical-legal case</h2>
        <div class="row2"><label>Case type<select name="legal.caseType"><option value="">Choose…</option>${Object.entries(state.meta.caseTypes).map(([k, v]) => html`<option value="${k}">${v}</option>`)}</select></label>
          <label>Date of injury<input type="date" name="legal.injuryDate" max="${today()}"></label></div>
        <div data-show="caseType:!workers_comp">
          <div class="row2"><label>Attorney<input name="legal.attorneyName" value="${role === 'attorney' ? me.name : ''}"></label>
            <label>Firm<input name="legal.firm" value="${role === 'attorney' ? me.organization || '' : ''}"></label></div>
          <div class="row3"><label>Attorney phone<input name="legal.attorneyPhone" value="${role === 'attorney' ? me.phone || '' : ''}"></label>
            <label>Attorney email<input type="email" name="legal.attorneyEmail" value="${role === 'attorney' ? me.email : ''}"></label>
            <label>Case / file number<input name="legal.caseNumber"></label></div>
          <label class="upload">Letter of protection (LOP) or lien agreement<input type="file" data-upload="lop" accept="application/pdf,image/*"><span class="upstatus" data-for="lop"></span></label>
          <input type="hidden" name="uploads.lop">
        </div>
        <div data-show="caseType:workers_comp">
          <div class="row3"><label>Claim number<input name="legal.claimNumber"></label><label>Carrier<input name="legal.carrier"></label><label>Adjuster name &amp; phone<input name="legal.adjuster"></label></div>
          <label>Attorney (if represented)<input name="legal.attorneyName"></label>
        </div>
        ${practice.legal_services.length ? html`<fieldset><legend>Requested services</legend><div class="checkcol">
          ${practice.legal_services.filter((s) => s !== 'lop').map((s) => html`<label><input type="checkbox" name="legal.services[]" value="${s}"> ${state.meta.legalServices[s]}</label>`)}</div></fieldset>` : ''}
        <label>Notes for the center<textarea name="legal.notes" rows="2"></textarea></label>
      </section>

      <section class="card" id="screening">
        <h2>6. Safety screening</h2>
        <div id="screenQs"></div>
      </section>

      <section class="card">
        <label class="check"><input type="checkbox" id="consent"> The information above is accurate, and I authorize sharing it with ${practice.name} to schedule and perform this exam.</label>
        <button class="btn big" id="submit">${slot ? 'Request this time' : 'Send referral'}</button>
      </section>
    </form>`);

  const form = $('#ref', target);
  const uploadState = {};

  function sync() {
    const v = formToObject(form);
    const pathway = v.pathway;
    const allowed = state.meta.pathways[pathway].payments;
    const payInputs = $$('[data-payment]', form).map((l) => {
      const input = $('input', l);
      l.hidden = !allowed.includes(l.dataset.payment);
      input.disabled = l.hidden || !isAccepted(input.value);
      if (input.disabled) input.checked = false;
      return input;
    });
    let payment = (payInputs.find((i) => i.checked) || {}).value;
    if (!payment) {
      const firstOk = payInputs.find((i) => !i.disabled);
      if (firstOk) { firstOk.checked = true; payment = firstOk.value; }
    }
    const caseType = (form.elements['legal.caseType'] || {}).value || '';
    const vals = { pathway, payment, caseType };
    // Show/hide conditional sections; disable inputs in hidden sections so they are not submitted.
    const sections = $$('[data-show]', form);
    for (const s of sections) {
      const [key, list] = s.dataset.show.split(':');
      const neg = list.startsWith('!');
      const opts = (neg ? list.slice(1) : list).split(',');
      s.hidden = neg ? opts.includes(vals[key]) : !opts.includes(vals[key]);
    }
    for (const el of form.elements) if (el.name && el.name !== 'payment') el.disabled = !!el.closest('[hidden]');
    const exam = examBy(form.elements.examCode.value);
    $('#examInfo', form).textContent = exam ? `${exam.minutes} min${exam.contrast ? ' · uses contrast' : ''}. Preparation: ${exam.prep}` : '';
    $('#selfPrice', form).textContent = exam && prices[exam.code] ? money(prices[exam.code]) : 'not published';
    renderScreening(exam);
  }
  const isAccepted = (k) => (k === 'insurance' && practice.accepts_insurance) || (k === 'self_pay' && practice.accepts_self_pay) || (k === 'medical_legal' && practice.accepts_medical_legal);

  let lastScreenExam = null;
  function renderScreening(exam) {
    if (!exam || lastScreenExam === exam.code) return;
    lastScreenExam = exam.code;
    const box = $('#screenQs', form);
    if (!exam.screening.length) { box.innerHTML = part(html`<p class="muted">No safety questions for this exam.</p>`); return; }
    box.innerHTML = part(html`<p class="muted">Answer for the patient. A "yes" doesn't cancel the request; it tells the center to check before the scan.</p>
      ${exam.screening.map((s) => html`<fieldset class="yn"><legend>${s.q}</legend>
        <label><input type="radio" name="screening.${s.id}" value="yes"> Yes</label><label><input type="radio" name="screening.${s.id}" value="no"> No</label></fieldset>`)}`);
  }

  form.addEventListener('change', (e) => { if (!e.target.dataset.upload) sync(); });
  $$('[data-upload]', form).forEach((input) => {
    input.addEventListener('change', async () => {
      const kind = input.dataset.upload;
      const status = $(`.upstatus[data-for=${kind}]`, form);
      const file = input.files[0];
      form.elements[`uploads.${kind}`].value = '';
      if (!file) { status.textContent = ''; return; }
      if (file.size > 5 * 1024 * 1024) { status.textContent = 'Files must be 5 MB or smaller.'; return; }
      status.textContent = 'Uploading…';
      try {
        const { upload } = await api('POST', '/api/uploads', { kind, filename: file.name, contentType: file.type || 'application/octet-stream', data: await fileToBase64(file) });
        form.elements[`uploads.${kind}`].value = upload.id;
        uploadState[kind] = upload;
        status.textContent = `✓ ${upload.filename} uploaded`;
      } catch (err) { status.textContent = err.message; }
    });
  });

  form.onsubmit = async (e) => {
    e.preventDefault();
    const err = $('#err', form);
    if (!$('#consent', form).checked) { err.innerHTML = part(errorBox(new Error('Please confirm the information is accurate and authorize sharing it.'))); err.scrollIntoView(); return; }
    const v = formToObject(form);
    const exam = examBy(v.examCode);
    const unanswered = exam.screening.filter((s) => !v.screening || !v.screening[s.id]);
    if (unanswered.length) { err.innerHTML = part(errorBox(new Error('Please answer every safety screening question.'))); err.scrollIntoView(); return; }
    const body = {
      ...v, practiceId: practice.id, slotId: slot ? slot.id : null,
      screening: Object.fromEntries(Object.entries(v.screening || {}).map(([k, a]) => [k, a === 'yes'])),
      order: { ...(v.order || {}), icd10: String((v.order || {}).icd10 || '').split(/[,\s]+/).filter(Boolean) },
      uploads: v.uploads || {},
    };
    $('#submit', form).disabled = true;
    try {
      const { referral } = await api('POST', '/api/referrals', body);
      go(`#/referral/${referral.id}?new=1`);
    } catch (ex) {
      err.innerHTML = part(errorBox(ex)); err.scrollIntoView();
      $('#submit', form).disabled = false;
    }
  };
  sync();
}

// ----- portals -----
async function pagePortal(query) {
  if (!state.me) return go('#/login?next=' + encodeURIComponent('#/portal'));
  const me = state.me;
  if (me.role === 'practice') return pagePracticeQueue(query);
  setTitle('My requests');
  const { referrals } = await api('GET', '/api/referrals');
  const heading = { patient: 'My imaging requests', physician: 'My referrals', attorney: 'Medical-legal cases' }[me.role];
  main.innerHTML = part(html`
    <div class="row between"><h1>${heading}</h1>
      <div class="row">
        <a class="btn" href="#/search${me.role === 'attorney' ? '?payment=medical_legal' : ''}">Find an open time</a>
        ${me.role === 'physician' ? html`<a class="btn ghost" href="#/refer">Send referral without a time</a>` : ''}
      </div></div>
    ${referrals.length ? referralTable(referrals, me.role !== 'patient') : html`<div class="card"><p>No requests yet.</p>
      <p>${{ patient: 'Search open times, choose one, and upload your prescription or choose self-pay.',
        physician: 'Search open times to book for a patient, or send an order and let the center schedule.',
        attorney: 'Search centers that accept medical-legal cases, then upload the treating physician’s order and your LOP.' }[me.role]}</p></div>`}`);
}

function referralTable(rows, showPatient) {
  return html`<div class="card"><table class="table clickable"><thead><tr><th>Ref</th>${showPatient ? html`<th>Patient</th>` : ''}<th>Exam</th><th>Center</th><th>Appointment</th><th>Payment</th><th>Status</th></tr></thead><tbody>
    ${rows.map((r) => html`<tr data-href="#/referral/${r.id}"><td><a href="#/referral/${r.id}">${r.refCode}</a></td>${showPatient ? html`<td>${r.patientName}</td>` : ''}
      <td>${r.examName}</td><td>${r.practiceName}</td><td>${r.startsAt ? fmtDateTime(r.startsAt, r.practiceTz) : html`<span class="muted">To be scheduled</span>`}</td>
      <td>${r.paymentLabel}</td><td>${statusBadge(r.status, r.statusLabel)}${r.flags.length ? html` <span class="flag" title="${r.flags.join('\n')}">⚑ ${r.flags.length}</span>` : ''}</td></tr>`)}
  </tbody></table></div>`;
}
function wireRowLinks() { $$('tr[data-href]').forEach((tr) => (tr.onclick = (e) => { if (e.target.tagName !== 'A') go(tr.dataset.href); })); }

async function pagePracticeQueue(query) {
  setTitle('Referral queue');
  const status = query.get('status') || '';
  const { referrals } = await api('GET', '/api/referrals' + (status ? '?status=' + status : ''));
  const all = status ? (await api('GET', '/api/referrals')).referrals : referrals;
  const counts = all.reduce((c, r) => ((c[r.status] = (c[r.status] || 0) + 1), c), {});
  const tabs = ['', 'awaiting_scheduling', 'pending_review', 'needs_info', 'confirmed', 'completed', 'declined', 'cancelled'];
  main.innerHTML = part(html`
    <div class="row between"><h1>Referral queue</h1><div class="row"><a class="btn ghost" href="#/practice/slots">Manage slots</a><a class="btn ghost" href="#/practice/profile">Profile &amp; prices</a></div></div>
    <nav class="tabs">${tabs.map((t) => html`<a href="#/portal${t ? '?status=' + t : ''}" class="${t === status ? 'active' : ''}">${t ? state.meta.statusLabels[t] : 'All'} <small>${t ? counts[t] || 0 : all.length}</small></a>`)}</nav>
    ${referrals.length ? referralTable(referrals, true) : html`<div class="card"><p>Nothing here.</p></div>`}`);
  wireRowLinks();
}

async function pageReferral(id, query) {
  if (!state.me) return go('#/login?next=' + encodeURIComponent(location.hash));
  const { referral: r } = await api('GET', '/api/referrals/' + id);
  setTitle(r.refCode);
  const tz = r.practice.tz;
  const isPractice = r.actor === 'practice';
  const actions = {
    confirmed: ['Confirm appointment', 'btn'], needs_info: ['Ask for more information', 'btn ghost'], declined: ['Decline', 'btn danger'],
    cancelled: ['Cancel request', 'btn danger'], completed: ['Mark completed', 'btn'], no_show: ['Mark no-show', 'btn ghost'], pending_review: ['Resubmit for review', 'btn'],
  };
  const p = r.patient, o = r.order;
  main.innerHTML = part(html`
    ${query.get('new') ? html`<div class="alert success" role="status"><strong>Request sent.</strong> Reference <strong>${r.refCode}</strong>. ${r.slot ? 'Your time is held while the center reviews the request.' : 'The center will contact the patient to schedule.'} You'll see updates here.</div>` : ''}
    <div class="row between"><h1>${r.examName}</h1><div class="row">${statusBadge(r.status, r.statusLabel)}<button class="btn ghost small" id="print">Print</button></div></div>
    <p class="muted">${r.refCode} · ${r.pathwayLabel} · ${r.paymentLabel} · CPT ${r.cpt}${r.priority !== 'routine' ? html` · <strong class="danger-text">${r.priority.toUpperCase()}</strong>` : ''}</p>
    ${r.flags.length ? html`<div class="alert warn"><strong>Needs attention before the scan</strong><ul>${r.flags.map((f) => html`<li>${f}</li>`)}</ul></div>` : ''}
    <div class="grid2">
      <section class="card"><h2>Appointment</h2>
        <p><strong>${r.practice.name}</strong><br>${r.practice.address}, ${r.practice.city}, ${r.practice.state} ${r.practice.zip}<br>${r.practice.phone}</p>
        <p>${r.slot ? html`<strong>${fmtDateTime(r.slot.starts_at, tz)}</strong> · ${r.slot.duration_min} min${r.slot.equipment ? ' · ' + r.slot.equipment : ''}` : html`<span class="muted">Not yet scheduled</span>`}</p>
        <p class="muted small">Preparation: ${r.prep}</p>
        ${r.priceCents ? html`<p>Self-pay price: <strong>${money(r.priceCents)}</strong></p>` : ''}
      </section>
      <section class="card"><h2>Patient</h2>
        <dl class="facts"><dt>Name</dt><dd>${p.firstName} ${p.lastName}</dd><dt>Date of birth</dt><dd>${p.dob}</dd>${p.sex ? html`<dt>Sex</dt><dd>${p.sex}</dd>` : ''}
          <dt>Phone</dt><dd>${p.phone}</dd>${p.email ? html`<dt>Email</dt><dd>${p.email}</dd>` : ''}${p.weightLb ? html`<dt>Weight</dt><dd>${p.weightLb} lb</dd>` : ''}
          ${p.language ? html`<dt>Language / access</dt><dd>${p.language}</dd>` : ''}</dl></section>
      <section class="card"><h2>Order</h2>
        <dl class="facts">
          ${o.physicianName ? html`<dt>Ordering physician</dt><dd>${o.physicianName}${o.npi ? html` · NPI ${o.npi}` : ''}${o.practiceName ? html`<br>${o.practiceName}` : ''}${o.phone ? html`<br>${o.phone}` : ''}</dd>` : ''}
          ${o.icd10 && o.icd10.length ? html`<dt>ICD-10</dt><dd>${o.icd10.join(', ')}</dd>` : ''}
          ${o.indication ? html`<dt>Indication</dt><dd>${o.indication}</dd>` : ''}
          ${o.reason ? html`<dt>Patient's reason</dt><dd>${o.reason}</dd>` : ''}
          ${o.priorImaging ? html`<dt>Prior imaging</dt><dd>${o.priorImaging}</dd>` : ''}
          ${o.sendReportTo ? html`<dt>Send report to</dt><dd>${o.sendReportTo}</dd>` : ''}
          ${r.pathway === 'patient_selfpay' && !r.files.some((f) => f.kind === 'rx') ? html`<dt>Order source</dt><dd>Physician order review requested</dd>` : ''}
        </dl>
        ${r.files.length ? html`<h3>Documents</h3><ul>${r.files.map((f) => html`<li><a href="/api/uploads/${f.id}">${{ rx: 'Prescription / order', lop: 'Letter of protection / lien', other: 'Document' }[f.kind]}: ${f.filename}</a> <span class="muted small">(${Math.ceil(f.size / 1024)} KB)</span></li>`)}</ul>` : ''}
      </section>
      ${r.insurance ? html`<section class="card"><h2>Insurance</h2><dl class="facts"><dt>Carrier</dt><dd>${r.insurance.carrier}</dd><dt>Member ID</dt><dd>${r.insurance.memberId}</dd>
        ${r.insurance.groupNumber ? html`<dt>Group</dt><dd>${r.insurance.groupNumber}</dd>` : ''}${r.insurance.subscriber ? html`<dt>Subscriber</dt><dd>${r.insurance.subscriber}</dd>` : ''}
        ${r.insurance.authNumber ? html`<dt>Prior auth #</dt><dd>${r.insurance.authNumber}</dd>` : html`<dt>Prior auth</dt><dd class="muted">Not provided</dd>`}</dl></section>` : ''}
      ${r.legal ? html`<section class="card legal-card"><h2>Medical-legal</h2><dl class="facts">
        <dt>Case type</dt><dd>${state.meta.caseTypes[r.legal.caseType]}</dd><dt>Date of injury</dt><dd>${r.legal.injuryDate}</dd>
        ${r.legal.attorneyName ? html`<dt>Attorney</dt><dd>${r.legal.attorneyName}${r.legal.firm ? ', ' + r.legal.firm : ''}<br>${r.legal.attorneyPhone || ''} ${r.legal.attorneyEmail || ''}</dd>` : ''}
        ${r.legal.caseNumber ? html`<dt>Case #</dt><dd>${r.legal.caseNumber}</dd>` : ''}
        ${r.legal.claimNumber ? html`<dt>WC claim</dt><dd>${r.legal.claimNumber} · ${r.legal.carrier}${r.legal.adjuster ? html`<br>Adjuster: ${r.legal.adjuster}` : ''}</dd>` : ''}
        ${r.legal.services.length ? html`<dt>Services</dt><dd>${r.legal.services.map((s) => state.meta.legalServices[s]).join('; ')}</dd>` : ''}
        ${r.legal.notes ? html`<dt>Notes</dt><dd>${r.legal.notes}</dd>` : ''}</dl></section>` : ''}
      <section class="card"><h2>Safety screening</h2>
        ${(examBy(r.examCode).screening.length) ? html`<ul class="screen">${examBy(r.examCode).screening.map((s) => html`<li class="${r.screening[s.id] ? 'yes' : ''}"><span>${s.q}</span><strong>${r.screening[s.id] ? 'Yes' : 'No'}</strong></li>`)}</ul>` : html`<p class="muted">None required.</p>`}
      </section>
      ${isPractice ? html`<section class="card"><h2>Submitted by</h2><p>${r.submitter.name} (${r.submitter.role})${r.submitter.organization ? html`<br>${r.submitter.organization}` : ''}<br>${r.submitter.email}${r.submitter.phone ? html` · ${r.submitter.phone}` : ''}${r.submitter.npi ? html`<br>NPI ${r.submitter.npi}` : ''}</p></section>` : ''}
    </div>

    ${r.allowedTransitions.length ? html`<section class="card no-print"><h2>Actions</h2>
      <form id="act">
        <div id="acterr"></div>
        ${r.allowedTransitions.includes('confirmed') && !r.slot ? html`<label>Appointment time for confirmation<select name="slotId" id="slotPick"><option value="">Loading open times…</option></select></label>` : ''}
        <label>Note ${isPractice ? '(visible to the requester)' : '(visible to the center)'}<textarea name="note" rows="2"></textarea></label>
        <div class="row">${r.allowedTransitions.map((t) => html`<button class="${actions[t][1]}" name="status" value="${t}">${actions[t][0]}</button>`)}</div>
      </form></section>` : ''}

    <section class="card no-print"><h2>Activity</h2>
      <ol class="timeline">${r.events.map((e) => html`<li><span class="muted small">${new Date(e.created_at).toLocaleString('en-US', { timeZone: tz })} · ${e.user_name || 'System'}</span>
        <div>${e.kind === 'status' ? html`${statusBadge(e.status)} ` : ''}${e.text || ''}</div></li>`)}</ol>
      <form id="msg" class="row"><input name="text" placeholder="Message the ${isPractice ? 'requester' : 'imaging center'}" aria-label="Message"><button class="btn ghost">Send</button></form>
    </section>`);

  $('#print').onclick = () => window.print();
  const slotPick = $('#slotPick');
  if (slotPick) {
    const { slots } = await api('GET', `/api/practice/slots?modality=${r.modality}&days=31`);
    const exam = examBy(r.examCode);
    const open = slots.filter((s) => s.status === 'open' && s.duration_min >= exam.minutes && new Date(s.starts_at) > new Date());
    slotPick.innerHTML = part(open.length ? open.map((s) => html`<option value="${s.id}">${fmtDateTime(s.starts_at, tz)} · ${s.duration_min} min${s.equipment ? ' · ' + s.equipment : ''}</option>`)
      : html`<option value="">No open ${modalityName(r.modality)} slots in the next 31 days; add slots first</option>`);
  }
  const act = $('#act');
  if (act) act.onsubmit = async (e) => {
    e.preventDefault();
    const status = e.submitter && e.submitter.value;
    if (status === 'cancelled' && !confirm('Cancel this request? The held time will be released.')) return;
    try {
      await api('POST', `/api/referrals/${r.id}/status`, { status, note: act.elements.note.value, slotId: slotPick ? slotPick.value : undefined });
      route();
    } catch (ex) { $('#acterr').innerHTML = part(errorBox(ex)); }
  };
  $('#msg').onsubmit = async (e) => {
    e.preventDefault();
    try { await api('POST', `/api/referrals/${r.id}/messages`, { text: e.target.elements.text.value }); route(); } catch (ex) { alert(ex.message); }
  };
}

// ----- practice: slots -----
async function pagePracticeSlots(query) {
  if (!state.me || state.me.role !== 'practice') return go('#/login');
  setTitle('Manage slots');
  const { practice } = await api('GET', '/api/practice/profile');
  const from = query.get('from') || today();
  const modality = query.get('modality') || '';
  const { slots, tz } = await api('GET', `/api/practice/slots?from=${from}&days=7${modality ? '&modality=' + modality : ''}`);
  const byDay = {};
  for (const s of slots) (byDay[dayKey(s.starts_at, tz)] ??= []).push(s);
  const shift = (d, n) => { const x = new Date(d + 'T12:00:00'); x.setDate(x.getDate() + n); return x.toLocaleDateString('en-CA'); };
  const counts = slots.reduce((c, s) => ((c[s.status] = (c[s.status] || 0) + 1), c), {});
  main.innerHTML = part(html`
    <h1>Open slots · ${practice.name}</h1>
    <details class="card" ${slots.length ? '' : 'open'}><summary><strong>Publish new slots</strong></summary>
      <form id="bulk">
        <div id="bulkmsg"></div>
        <div class="row3"><label>Modality<select name="modality">${practice.modalities.map((m) => html`<option value="${m}">${modalityName(m)}</option>`)}</select></label>
          <label>Scanner / room (optional)<input name="equipment" list="equip" placeholder="e.g. 3T MRI"><datalist id="equip">${practice.equipment.map((e) => html`<option value="${e}">`)}</datalist></label>
          <label>Slot length (min)<input type="number" name="durationMin" min="5" max="240" placeholder="Default for modality"></label></div>
        <div class="row3"><label>From date<input type="date" name="fromDate" value="${today()}" min="${today()}" required></label>
          <label>To date<input type="date" name="toDate" value="${shift(today(), 6)}" min="${today()}" required></label>
          <label>Every (min)<input type="number" name="intervalMin" min="5" max="240" placeholder="Same as length"></label></div>
        <div class="row3"><label>First start<input type="time" name="startTime" value="08:00" required></label>
          <label>Last end<input type="time" name="endTime" value="17:00" required></label>
          <fieldset><legend>Days</legend><div class="checkrow">${['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d, i) => html`<label><input type="checkbox" name="weekdays[]" value="${i}" ${i >= 1 && i <= 5 ? 'checked' : ''}> ${d}</label>`)}</div></fieldset></div>
        <button class="btn">Publish slots</button>
      </form>
    </details>
    <div class="row between">
      <div class="row"><a class="btn ghost small" href="#/practice/slots?from=${shift(from, -7)}${modality ? '&modality=' + modality : ''}">← Previous week</a>
        <strong>${fmtDay(new Date(from + 'T12:00:00').toISOString(), tz)} – ${fmtDay(new Date(shift(from, 6) + 'T12:00:00').toISOString(), tz)}</strong>
        <a class="btn ghost small" href="#/practice/slots?from=${shift(from, 7)}${modality ? '&modality=' + modality : ''}">Next week →</a></div>
      <form id="mfilter"><select name="modality" aria-label="Filter by modality"><option value="">All modalities</option>${practice.modalities.map((m) => html`<option value="${m}" ${m === modality ? 'selected' : ''}>${modalityName(m)}</option>`)}</select></form>
    </div>
    <p class="muted">${counts.open || 0} open · ${counts.held || 0} held for review · ${counts.booked || 0} booked</p>
    <div class="week">${Object.entries(byDay).map(([, list]) => html`<div class="card day-col"><h3>${fmtDay(list[0].starts_at, tz)}</h3>
      <ul class="slotlist">${list.map((s) => html`<li class="slot-${s.status}"><span>${fmtTime(s.starts_at, tz)}</span><span class="muted small">${modalityName(s.modality)}${s.equipment ? ' · ' + s.equipment : ''} · ${s.duration_min}m</span>
        ${s.referral_id ? html`<a href="#/referral/${s.referral_id}" class="small">${s.ref_code}</a>` : s.status === 'open' ? html`<button class="link small del" data-id="${s.id}" aria-label="Remove slot">Remove</button>` : html`<span class="small">${s.status}</span>`}</li>`)}</ul></div>`)}
      ${!slots.length ? html`<div class="card"><p>No slots this week.</p></div>` : ''}</div>`);
  $('#mfilter').onchange = (e) => go(`#/practice/slots?from=${from}${e.target.value ? '&modality=' + e.target.value : ''}`);
  $('#bulk').onsubmit = async (e) => {
    e.preventDefault();
    const v = formToObject(e.target);
    try {
      const r = await api('POST', '/api/practice/slots', { ...v, weekdays: (v.weekdays || []).map(Number) });
      $('#bulkmsg').innerHTML = part(html`<div class="alert success">Published ${r.created} slot${r.created === 1 ? '' : 's'}${r.skipped ? ` (${r.skipped} skipped: already exist or in the past)` : ''}.</div>`);
      setTimeout(route, 900);
    } catch (ex) { $('#bulkmsg').innerHTML = part(errorBox(ex)); }
  };
  $$('.del').forEach((b) => (b.onclick = async () => { try { await api('DELETE', '/api/practice/slots/' + b.dataset.id, {}); route(); } catch (ex) { alert(ex.message); } }));
}

// ----- practice: profile -----
async function pagePracticeProfile() {
  if (!state.me || state.me.role !== 'practice') return go('#/login');
  setTitle('Profile & prices');
  const { practice: p, prices } = await api('GET', '/api/practice/profile');
  const L = state.meta.legalServices;
  main.innerHTML = part(html`
    <h1>Profile &amp; prices</h1>
    <form id="prof">
      <div id="msg"></div>
      <section class="card"><h2>Practice</h2>
        <label>Name<input name="name" value="${p.name}" required></label>
        <label>Street address<input name="address" value="${p.address || ''}"></label>
        <div class="row3"><label>City<input name="city" value="${p.city || ''}"></label><label>State<input name="state" value="${p.state || ''}" maxlength="2"></label><label>ZIP<input name="zip" value="${p.zip || ''}" maxlength="5"></label></div>
        <div class="row3"><label>Phone<input name="phone" value="${p.phone || ''}"></label><label>Scheduling email<input name="email" value="${p.email || ''}"></label><label>Hours<input name="hours" value="${p.hours || ''}"></label></div>
        <label>Accreditation<input name="accreditation" value="${p.accreditation || ''}" placeholder="e.g. ACR accredited: MRI, CT"></label>
        <label>Description<textarea name="description" rows="2">${p.description || ''}</textarea></label>
        <fieldset><legend>Modalities</legend><div class="checkrow">${Object.entries(state.meta.modalities).map(([k, m]) => html`<label><input type="checkbox" name="modalities[]" value="${k}" ${p.modalities.includes(k) ? 'checked' : ''}> ${m.name}</label>`)}</div></fieldset>
        <label>Equipment (comma separated)<input name="equipment" value="${p.equipment.join(', ')}" placeholder="3T MRI, Open MRI, 64-slice CT"></label>
      </section>
      <section class="card"><h2>Payment and referral policies</h2>
        <label class="check"><input type="checkbox" name="accepts_insurance" ${p.accepts_insurance ? 'checked' : ''}> We bill insurance</label>
        <label>Insurance notes<input name="insurance_notes" value="${p.insurance_notes || ''}" placeholder="Plans accepted"></label>
        <label class="check"><input type="checkbox" name="accepts_self_pay" ${p.accepts_self_pay ? 'checked' : ''}> We offer self-pay pricing</label>
        <label class="check"><input type="checkbox" name="offers_order_review" ${p.offers_order_review ? 'checked' : ''}> A physician working with us reviews self-pay requests without an order and writes the order when appropriate</label>
        <label class="check"><input type="checkbox" name="accepts_medical_legal" ${p.accepts_medical_legal ? 'checked' : ''}> We accept medical-legal cases</label>
        <fieldset><legend>Medical-legal services</legend><div class="checkcol">${Object.entries(L).map(([k, v]) => html`<label><input type="checkbox" name="legal_services[]" value="${k}" ${p.legal_services.includes(k) ? 'checked' : ''}> ${v}</label>`)}</div></fieldset>
      </section>
      <section class="card"><h2>Self-pay prices</h2><p class="muted">All-in price shown to patients (scan + read), in dollars.</p>
        <table class="table"><thead><tr><th>Exam</th><th>CPT</th><th class="num">Price ($)</th></tr></thead><tbody>
        ${state.meta.exams.filter((e) => p.modalities.includes(e.modality)).map((e) => html`<tr><td>${e.name}</td><td>${e.cpt}</td>
          <td class="num"><input class="price-in" type="number" min="1" step="1" data-code="${e.code}" value="${prices[e.code] ? prices[e.code] / 100 : ''}" aria-label="Price for ${e.name}"></td></tr>`)}
        </tbody></table></section>
      <button class="btn big">Save changes</button>
    </form>`);
  $('#prof').onsubmit = async (e) => {
    e.preventDefault();
    const v = formToObject(e.target);
    v.prices = Object.fromEntries($$('.price-in').filter((i) => i.value).map((i) => [i.dataset.code, Math.round(Number(i.value) * 100)]));
    v.modalities ||= []; v.legal_services ||= [];
    try { await api('PUT', '/api/practice/profile', v); $('#msg').innerHTML = part(html`<div class="alert success">Saved.</div>`); window.scrollTo(0, 0); }
    catch (ex) { $('#msg').innerHTML = part(errorBox(ex)); window.scrollTo(0, 0); }
  };
}

function pageNotFound() { main.innerHTML = part(html`<div class="card narrow"><h1>Page not found</h1><p><a href="#/">Go home</a></p></div>`); }

// ---------- router ----------
async function route() {
  routeSeq++;
  const { path, query } = parseHash();
  const seg = path.split('/').filter(Boolean);
  try {
    if (!seg.length) pageHome();
    else if (seg[0] === 'search') await pageSearch(query);
    else if (seg[0] === 'for') pageAudience(seg[1]);
    else if (seg[0] === 'login') pageLogin(query);
    else if (seg[0] === 'register') pageRegister(query);
    else if (seg[0] === 'book' && seg[1]) await pageBook(seg[1], query);
    else if (seg[0] === 'refer') await pageRefer(query);
    else if (seg[0] === 'portal') await pagePortal(query);
    else if (seg[0] === 'referral' && seg[1]) await pageReferral(seg[1], query);
    else if (seg[0] === 'practice' && seg[1] === 'slots') await pagePracticeSlots(query);
    else if (seg[0] === 'practice' && seg[1] === 'profile') await pagePracticeProfile();
    else if (seg[0] === 'practice' && seg[1]) await pagePractice(seg[1]);
    else pageNotFound();
    if (!query.get('new')) window.scrollTo(0, 0);
    wireRowLinks();
  } catch (e) {
    if (e.status === 401) { state.me = null; renderNav(); return go('#/login?next=' + encodeURIComponent(location.hash)); }
    main.innerHTML = part(errorBox(e));
  }
}

(async function start() {
  [state.meta, { user: state.me }] = await Promise.all([api('GET', '/api/meta'), api('GET', '/api/auth/me')]);
  renderNav();
  window.addEventListener('hashchange', () => { route(); main.focus({ preventScroll: true }); });
  route();
})();
