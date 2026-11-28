const $ = (s, el = document) => el.querySelector(s);
const $$ = (s, el = document) => [...el.querySelectorAll(s)];
const money = (n) => n.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);
const day = (d) => new Date(d + 'T12:00:00Z').toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', timeZone: 'UTC' });

// Allow ?now=2026-12-20T15:00:00Z in dev to preview later dates.
const timeTravel = new URLSearchParams(location.search).get('now');
const api = (path) => fetch(path + (timeTravel ? (path.includes('?') ? '&' : '?') + 'now=' + encodeURIComponent(timeTravel) : '')).then((r) => r.json());

let META = null;
const shown = new Map(); // product id -> product, for adding to cart

// ---------- Cart (kept in this browser only)
const store = {
  get() { try { return JSON.parse(localStorage.getItem('cart') || '[]'); } catch { return []; } },
  set(v) { try { localStorage.setItem('cart', JSON.stringify(v)); } catch {} },
};
let cart = store.get();

function addToCart(p) {
  const line = cart.find((l) => l.id === p.id);
  if (line) line.qty = Math.min(10, line.qty + 1);
  else cart.push({ id: p.id, title: p.title, emoji: p.emoji, price: p.price, retailerName: p.retailerName, qty: 1 });
  store.set(cart);
  renderCart();
  const btn = $(`[data-add="${CSS.escape(p.id)}"]`);
  if (btn) { btn.textContent = '✓ Added'; setTimeout(() => (btn.textContent = 'Add to list'), 1200); }
}

function renderCart() {
  $('#cartCount').textContent = cart.reduce((s, l) => s + l.qty, 0);
  $('#cartTotal').textContent = money(cart.reduce((s, l) => s + l.qty * l.price, 0));
  $('#checkoutBtn').disabled = !cart.length;
  $('#cartItems').innerHTML = cart.length
    ? cart.map((l) => `
      <div class="line">
        <span class="emoji">${esc(l.emoji)}</span>
        <div class="line-main"><div class="line-title">${esc(l.title)}</div><div class="muted">${esc(l.retailerName)} · ${money(l.price)}</div></div>
        <div class="qty">
          <button data-dec="${esc(l.id)}" aria-label="Fewer">−</button><span>${l.qty}</span><button data-inc="${esc(l.id)}" aria-label="More">+</button>
        </div>
      </div>`).join('')
    : '<p class="empty">No gifts yet. Tap “Add to list” on anything you like.</p>';
}

$('#cartItems').addEventListener('click', (e) => {
  const inc = e.target.dataset.inc, dec = e.target.dataset.dec;
  const id = inc || dec;
  if (!id) return;
  const line = cart.find((l) => l.id === id);
  if (!line) return;
  line.qty += inc ? 1 : -1;
  if (line.qty <= 0) cart = cart.filter((l) => l !== line);
  line.qty = Math.min(10, line.qty);
  store.set(cart);
  renderCart();
});

const drawer = $('#drawer');
const openDrawer = (open) => { drawer.classList.toggle('open', open); drawer.setAttribute('aria-hidden', String(!open)); };
$('#cartBtn').onclick = () => openDrawer(true);
$('#closeDrawer').onclick = () => openDrawer(false);
drawer.addEventListener('click', (e) => { if (e.target === drawer) openDrawer(false); });

$('#checkoutBtn').onclick = async () => {
  const res = await fetch('/api/checkout' + (timeTravel ? '?now=' + encodeURIComponent(timeTravel) : ''), {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ items: cart.map(({ id, qty }) => ({ id, qty })) }),
  }).then((r) => r.json());
  if (res.error) return alert(res.error);
  $('#checkoutBody').innerHTML = `
    <p class="hint">${esc(res.note)}</p>
    ${res.retailers.map((r) => `
      <div class="co-group">
        <div class="co-head"><strong>${esc(r.name)}</strong><span>${money(r.subtotal)}</span></div>
        ${r.items.map((i) => `
          <div class="co-line">
            <div><div>${esc(i.title)} × ${i.qty}</div>${i.delivery ? `<div class="muted">Arrives ${day(i.delivery.arrives)} · ${esc(i.delivery.label)}</div>` : ''}</div>
            ${r.checkoutUrl ? '' : `<a class="btn" href="${esc(i.buyUrl)}?src=checkout" target="_blank" rel="noopener sponsored">Buy at ${esc(r.name)}</a>`}
          </div>`).join('')}
        ${r.checkoutUrl ? `<a class="primary block" href="${esc(r.checkoutUrl)}" target="_blank" rel="noopener sponsored">Add ${r.items.length === 1 ? 'it' : `all ${r.items.length} items`} to my ${esc(r.name)} cart</a>` : ''}
      </div>`).join('')}
    <div class="co-total"><span>Gift total</span><strong>${money(res.total)}</strong></div>`;
  $('#checkoutDialog').showModal();
};
$('#closeCheckout').onclick = () => $('#checkoutDialog').close();

// ---------- Product cards
function card(p) {
  shown.set(p.id, p);
  const d = p.delivery;
  const fast = d && (d.method === 'overnight' || d.method === 'same_day');
  const byXmas = d && META && d.arrives <= META.christmasEve;
  return `
    <article class="card">
      <div class="thumb">${p.image ? `<img src="${esc(p.image)}" alt="" loading="lazy">` : `<span>${esc(p.emoji)}</span>`}</div>
      ${p.deal?.isDeal ? `<div class="badges">${p.deal.badges.map((b) => `<span class="badge deal">${esc(b)}</span>`).join('')}</div>` : ''}
      <h3>${esc(p.title)}</h3>
      <div class="muted">${esc(p.retailerName)}${p.rating ? ` · ${p.rating}★ (${p.reviews.toLocaleString('en-US')})` : ''}</div>
      <div class="price-line"><strong>${money(p.price)}</strong>${p.listPrice > p.price ? `<s>${money(p.listPrice)}</s>` : ''}</div>
      ${d ? `<div class="ship ${fast ? 'fast' : ''}">${fast ? '⚡' : '📦'} Arrives <b>${day(d.arrives)}</b> · ${esc(d.label)}${d.price ? ` (+${money(d.price)})` : ''}</div>` : ''}
      ${d && META ? `<div class="xmas ${byXmas ? 'ok' : 'late'}">${byXmas ? '🎄 In time for Christmas' : '⚠️ May arrive after Christmas'}</div>` : ''}
      ${p.reasons?.length ? `<ul class="reasons">${p.reasons.slice(0, 3).map((r) => `<li>${esc(r)}</li>`).join('')}</ul>` : ''}
      <div class="actions">
        <button class="secondary" data-add="${esc(p.id)}">Add to list</button>
        <a class="primary" href="${esc(p.buyUrl)}" target="_blank" rel="noopener sponsored">Buy at ${esc(p.retailerName)}</a>
      </div>
    </article>`;
}

document.addEventListener('click', (e) => {
  const id = e.target.dataset?.add;
  if (id && shown.has(id)) addToCart(shown.get(id));
});

function render(el, results, empty) {
  el.innerHTML = results.length ? results.map(card).join('') : `<p class="empty">${empty}</p>`;
}

// ---------- Gift finder
const form = $('#finder');
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const fd = new FormData(form);
  const params = new URLSearchParams();
  for (const [k, v] of fd) if (v) params.set(k, v);
  const interests = $$('#interestChips .on').map((b) => b.dataset.value);
  if (interests.length) params.set('interests', interests.join(','));
  const out = $('#finderResults');
  out.innerHTML = '<p class="empty">Finding gifts…</p>';
  const data = await api('/api/recommendations?' + params);
  render(out, data.results, 'No gifts match yet. Try widening the price range, removing interests, or a later arrival date.');
});

$('#budgetChips').addEventListener('click', (e) => {
  const b = e.target.closest('button');
  if (!b) return;
  form.minPrice.value = b.dataset.min;
  form.maxPrice.value = b.dataset.max;
  $$('#budgetChips button').forEach((x) => x.classList.toggle('on', x === b));
});
$('#interestChips').addEventListener('click', (e) => {
  const b = e.target.closest('button');
  if (b) b.classList.toggle('on');
});

// ---------- Deals / fast
async function loadDeals() {
  const r = $('#dealRetailer').value;
  const data = await api('/api/deals' + (r ? '?retailer=' + r : ''));
  render($('#dealResults'), data.results, 'No deals right now. Check back soon.');
}
async function loadFast() {
  const p = new URLSearchParams();
  if ($('#overnightOnly').checked) p.set('overnight', '1');
  if ($('#fastBy').value) p.set('by', $('#fastBy').value);
  const data = await api('/api/fast?' + p);
  render($('#fastResults'), data.results, 'Nothing can arrive by that date. Try a later date.');
}
$('#dealRetailer').onchange = loadDeals;
$('#overnightOnly').onchange = loadFast;
$('#fastBy').onchange = loadFast;

// ---------- Tabs
const loaded = {};
function showTab(name) {
  $$('[role=tab]').forEach((t) => t.setAttribute('aria-selected', String(t.dataset.tab === name)));
  $$('.panel').forEach((p) => (p.hidden = p.id !== 'tab-' + name));
  if (!loaded[name]) { loaded[name] = true; if (name === 'deals') loadDeals(); if (name === 'fast') loadFast(); }
  try { localStorage.setItem('tab', name); } catch {}
}
$$('[role=tab]').forEach((t) => (t.onclick = () => showTab(t.dataset.tab)));

// ---------- Start
(async function init() {
  META = await api('/api/meta');
  const days = META.daysToChristmas;
  $('#countdown').textContent = days > 0 ? `${days} day${days === 1 ? '' : 's'} to Christmas` : 'Merry Christmas!';
  $('#deadlines').innerHTML = `<div class="wrap">Order by for Christmas Eve: ${META.deadlines
    .map((d) => `<span><b>${esc(d.label)}</b> ${esc(d.lastOrderDayLabel)}</span>`).join('')}</div>`;
  $('#disclosure').textContent = META.disclosure;
  $('#sampleNote').hidden = !META.sampleData;
  $('#relationship').insertAdjacentHTML('beforeend', META.relationships.map((r) => `<option value="${esc(r)}">${esc(r[0].toUpperCase() + r.slice(1))}</option>`).join(''));
  $('#interestChips').innerHTML = META.interests.map((i) => `<button type="button" data-value="${esc(i)}">${esc(i)}</button>`).join('');
  $('#dealRetailer').insertAdjacentHTML('beforeend', META.retailers.map((r) => `<option value="${esc(r.id)}">${esc(r.name)}</option>`).join(''));
  $('#fastBy').value = META.christmasEve;
  $('#needBy').max = META.christmasEve.slice(0, 4) + '-12-31';
  renderCart();
  let tab = 'finder';
  try { tab = localStorage.getItem('tab') || 'finder'; } catch {}
  showTab(tab);
  form.requestSubmit();
})();
