'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const D = require('./domain');
const { tx } = require('./db');
const auth = require('./auth');

const MAX_BODY = 8 * 1024 * 1024;
const MAX_UPLOAD = 5 * 1024 * 1024;
const UPLOAD_TYPES = { 'application/pdf': '%PDF', 'image/png': '\x89PNG', 'image/jpeg': '\xFF\xD8\xFF', 'image/heic': null, 'image/webp': 'RIFF' };
const STATIC_TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.svg': 'image/svg+xml', '.ico': 'image/x-icon' };

class HttpError extends Error { constructor(status, message, details) { super(message); this.status = status; this.details = details; } }
const bad = (msg, details) => new HttpError(400, msg, details);

// ---------- small helpers ----------
const str = (v, max = 200) => (v === undefined || v === null ? '' : String(v).trim().slice(0, max));
const bool = (v) => v === true || v === 'true' || v === 1;
const json = (v, fallback) => { try { return v ? JSON.parse(v) : fallback; } catch { return fallback; } };
const nowIso = () => new Date().toISOString();

function practiceRow(row) {
  if (!row) return null;
  return {
    ...row,
    modalities: json(row.modalities, []), equipment: json(row.equipment, []), legal_services: json(row.legal_services, []),
    accepts_insurance: !!row.accepts_insurance, accepts_self_pay: !!row.accepts_self_pay,
    accepts_medical_legal: !!row.accepts_medical_legal, offers_order_review: !!row.offers_order_review,
  };
}

function cleanPatient(p = {}) {
  return {
    firstName: str(p.firstName, 80), lastName: str(p.lastName, 80), dob: str(p.dob, 10), sex: str(p.sex, 20),
    phone: str(p.phone, 30), email: str(p.email, 120), address: str(p.address, 200), weightLb: str(p.weightLb, 5),
    language: str(p.language, 40), notes: str(p.notes, 1000),
  };
}
function cleanOrder(o = {}) {
  return {
    physicianName: str(o.physicianName, 120), npi: str(o.npi, 10), practiceName: str(o.practiceName, 160),
    phone: str(o.phone, 30), fax: str(o.fax, 30), indication: str(o.indication, 2000), reason: str(o.reason, 2000),
    icd10: (Array.isArray(o.icd10) ? o.icd10 : String(o.icd10 || '').split(/[,\s]+/)).map((c) => str(c, 10).toUpperCase()).filter(Boolean).slice(0, 8),
    priorImaging: str(o.priorImaging, 500), sendReportTo: str(o.sendReportTo, 200),
  };
}
function cleanInsurance(i = {}) {
  return { carrier: str(i.carrier, 120), memberId: str(i.memberId, 60), groupNumber: str(i.groupNumber, 60), subscriber: str(i.subscriber, 120), authNumber: str(i.authNumber, 60) };
}
function cleanLegal(l = {}) {
  return {
    caseType: str(l.caseType, 30), injuryDate: str(l.injuryDate, 10), attorneyName: str(l.attorneyName, 120), firm: str(l.firm, 160),
    attorneyPhone: str(l.attorneyPhone, 30), attorneyEmail: str(l.attorneyEmail, 120), caseNumber: str(l.caseNumber, 60),
    claimNumber: str(l.claimNumber, 60), carrier: str(l.carrier, 120), adjuster: str(l.adjuster, 160),
    services: (Array.isArray(l.services) ? l.services : []).filter((s) => D.LEGAL_SERVICES[s]),
    notes: str(l.notes, 1000),
  };
}

function refCode() {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const bytes = crypto.randomBytes(6);
  return 'IMG-' + Array.from(bytes, (b) => alphabet[b % alphabet.length]).join('');
}

function parseCookies(header) {
  const out = {};
  for (const part of String(header || '').split(';')) {
    const i = part.indexOf('=');
    if (i > 0) out[part.slice(0, i).trim()] = decodeURIComponent(part.slice(i + 1).trim());
  }
  return out;
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let size = 0; const chunks = [];
    req.on('data', (c) => { size += c.length; if (size > MAX_BODY) { reject(new HttpError(413, 'Request too large.')); req.destroy(); } else chunks.push(c); });
    req.on('end', () => {
      if (!chunks.length) return resolve({});
      try { resolve(JSON.parse(Buffer.concat(chunks).toString('utf8'))); } catch { reject(bad('Invalid JSON.')); }
    });
    req.on('error', reject);
  });
}

// ---------- the app ----------
function createApp({ db, uploadDir, publicDir, secureCookies = false }) {
  fs.mkdirSync(uploadDir, { recursive: true });
  const loginFailures = new Map(); // ip -> { count, until }

  const audit = (user, action, entity, id, ip) =>
    db.prepare('INSERT INTO audit (user_id, action, entity, entity_id, ip, at) VALUES (?,?,?,?,?,?)').run(user ? user.id : null, action, entity, id == null ? null : String(id), ip || null, nowIso());

  const getPractice = (id) => practiceRow(db.prepare('SELECT * FROM practices WHERE id = ?').get(id));
  const getPrice = (practiceId, code) => {
    const r = db.prepare('SELECT price_cents FROM prices WHERE practice_id = ? AND exam_code = ?').get(practiceId, code);
    return r ? r.price_cents : null;
  };

  function requireUser(ctx, ...roles) {
    if (!ctx.user) throw new HttpError(401, 'Please sign in.');
    if (roles.length && !roles.includes(ctx.user.role)) throw new HttpError(403, 'Your account type cannot do that.');
    return ctx.user;
  }

  // Who is this user relative to a referral? 'practice' | 'submitter' | null
  function actorFor(user, ref) {
    if (!user) return null;
    if (user.role === 'practice' && user.practice_id === ref.practice_id) return 'practice';
    if (ref.created_by === user.id) return 'submitter';
    return null;
  }
  function loadReferral(id, user) {
    const ref = db.prepare('SELECT * FROM referrals WHERE id = ?').get(Number(id));
    if (!ref) throw new HttpError(404, 'Referral not found.');
    const actor = actorFor(user, ref);
    if (!actor) throw new HttpError(404, 'Referral not found.');
    return { ref, actor };
  }

  function referralSummary(r) {
    const exam = D.EXAM_BY_CODE[r.exam_code] || {};
    const patient = json(r.patient_json, {});
    return {
      id: r.id, refCode: r.ref_code, status: r.status, statusLabel: D.STATUS_LABELS[r.status], pathway: r.pathway,
      pathwayLabel: D.PATHWAYS[r.pathway].label, payment: r.payment, paymentLabel: D.PAYMENTS[r.payment], priority: r.priority,
      examCode: r.exam_code, examName: exam.name, modality: r.modality,
      patientName: `${patient.firstName || ''} ${patient.lastName || ''}`.trim(),
      practiceId: r.practice_id, practiceName: r.practice_name, practiceTz: r.practice_tz, startsAt: r.starts_at || null,
      flags: json(r.flags_json, []), createdAt: r.created_at, updatedAt: r.updated_at,
    };
  }

  function releaseSlot(slotId) {
    if (!slotId) return;
    db.prepare("UPDATE slots SET status = 'open' WHERE id = ? AND starts_at > ?").run(slotId, nowIso());
  }

  // ---------- route handlers ----------
  const routes = [];
  const route = (method, pattern, handler) => routes.push({ method, re: new RegExp('^' + pattern.replace(/:(\w+)/g, '(?<$1>[^/]+)') + '$'), handler });

  route('GET', '/api/meta', () => ({
    modalities: D.MODALITIES,
    exams: D.EXAMS.map((e) => ({ ...e, prep: D.prepFor(e.code), screening: D.screeningQuestions(e.modality, e.contrast).map(({ id, q }) => ({ id, q })) })),
    pathways: D.PATHWAYS, payments: D.PAYMENTS, caseTypes: D.CASE_TYPES, legalServices: D.LEGAL_SERVICES, statusLabels: D.STATUS_LABELS,
  }));

  route('GET', '/api/slots/search', (ctx) => {
    const q = ctx.query;
    const modality = str(q.get('modality'), 10).toUpperCase();
    if (!D.MODALITIES[modality]) throw bad('Choose a scan type.');
    const exam = q.get('exam') ? D.EXAM_BY_CODE[q.get('exam')] : null;
    if (exam && exam.modality !== modality) throw bad('That exam does not match the scan type.');
    const payment = str(q.get('payment'), 20);
    const equipment = str(q.get('equipment'), 40).toLowerCase();
    const radius = Math.min(Math.max(Number(q.get('radius')) || 25, 1), 250);
    const days = Math.min(Math.max(Number(q.get('days')) || 14, 1), 60);
    const sort = str(q.get('sort'), 20) || 'soonest';
    const zip = str(q.get('zip'), 5);
    const origin = zip ? db.prepare('SELECT lat, lon, city FROM zips WHERE zip = ?').get(zip) : null;
    if (zip && !origin) throw bad(`We don't have location data for ZIP ${zip} yet. Try a nearby ZIP or leave it blank.`);
    const fromDate = q.get('from') && !isNaN(Date.parse(q.get('from'))) ? new Date(q.get('from') + 'T00:00:00') : new Date();
    const start = new Date(Math.max(fromDate.getTime(), Date.now())).toISOString();
    const end = new Date(fromDate.getTime() + days * 86400000).toISOString();

    const practices = db.prepare('SELECT * FROM practices').all().map(practiceRow).filter((p) => {
      if (!p.modalities.includes(modality)) return false;
      if (payment === 'insurance' && !p.accepts_insurance) return false;
      if (payment === 'self_pay' && !p.accepts_self_pay) return false;
      if (payment === 'medical_legal' && !p.accepts_medical_legal) return false;
      if (origin) {
        if (p.lat == null) return false;
        p.distance = Math.round(D.haversineMiles(origin, p) * 10) / 10;
        if (p.distance > radius) return false;
      }
      return true;
    });
    const slotStmt = db.prepare(`SELECT id, starts_at, duration_min, equipment FROM slots WHERE practice_id = ? AND modality = ? AND status = 'open'
      AND starts_at >= ? AND starts_at < ? AND duration_min >= ? ORDER BY starts_at`);
    const results = [];
    for (const p of practices) {
      let slots = slotStmt.all(p.id, modality, start, end, exam ? exam.minutes : 0).map((s) => ({ ...s }));
      if (equipment) slots = slots.filter((s) => (s.equipment || '').toLowerCase().includes(equipment) || (!s.equipment && p.equipment.some((e) => e.toLowerCase().includes(equipment))));
      if (!slots.length) continue;
      results.push({
        practice: { id: p.id, name: p.name, address: p.address, city: p.city, state: p.state, zip: p.zip, phone: p.phone, tz: p.tz, hours: p.hours,
          accreditation: p.accreditation, equipment: p.equipment, accepts_insurance: p.accepts_insurance, accepts_self_pay: p.accepts_self_pay,
          accepts_medical_legal: p.accepts_medical_legal, offers_order_review: p.offers_order_review, legal_services: p.legal_services, insurance_notes: p.insurance_notes },
        distance: p.distance ?? null,
        price: exam ? getPrice(p.id, exam.code) : null,
        nextAvailable: slots[0].starts_at, openCount: slots.length, slots: slots.slice(0, 60),
      });
    }
    const by = {
      soonest: (a, b) => a.nextAvailable.localeCompare(b.nextAvailable),
      price: (a, b) => (a.price ?? Infinity) - (b.price ?? Infinity),
      distance: (a, b) => (a.distance ?? Infinity) - (b.distance ?? Infinity),
    }[sort] || ((a, b) => a.nextAvailable.localeCompare(b.nextAvailable));
    results.sort(by);
    return { origin: origin ? { zip, city: origin.city } : null, results };
  });

  route('GET', '/api/practices', () => ({
    practices: db.prepare('SELECT * FROM practices ORDER BY name').all().map(practiceRow).map((p) => ({
      id: p.id, name: p.name, city: p.city, modalities: p.modalities, accepts_medical_legal: p.accepts_medical_legal, offers_order_review: p.offers_order_review,
      accepts_insurance: p.accepts_insurance, accepts_self_pay: p.accepts_self_pay,
    })),
  }));

  route('GET', '/api/practices/:id', (ctx) => {
    const p = getPractice(Number(ctx.params.id));
    if (!p) throw new HttpError(404, 'Practice not found.');
    const prices = db.prepare('SELECT exam_code, price_cents FROM prices WHERE practice_id = ?').all(p.id);
    return { practice: p, prices: Object.fromEntries(prices.map((r) => [r.exam_code, r.price_cents])) };
  });

  route('GET', '/api/slots/:id', (ctx) => {
    const s = db.prepare('SELECT * FROM slots WHERE id = ?').get(Number(ctx.params.id));
    if (!s) throw new HttpError(404, 'That time is no longer available.');
    return { slot: { id: s.id, practice_id: s.practice_id, modality: s.modality, equipment: s.equipment, starts_at: s.starts_at, duration_min: s.duration_min, status: s.status } };
  });

  // ----- auth -----
  route('POST', '/api/auth/register', (ctx) => {
    const b = ctx.body;
    const role = str(b.role, 20);
    if (!['patient', 'physician', 'attorney', 'practice'].includes(role)) throw bad('Choose an account type.');
    const email = str(b.email, 120).toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw bad('Enter a valid email address.');
    if (String(b.password || '').length < 8) throw bad('Password must be at least 8 characters.');
    const name = str(b.name, 120);
    if (!name) throw bad('Name is required.');
    if (db.prepare('SELECT 1 FROM users WHERE email = ?').get(email)) throw bad('An account with that email already exists.');
    const npi = str(b.npi, 10);
    if (role === 'physician' && !D.isValidNpi(npi)) throw bad('Enter a valid 10-digit NPI.');
    const user = tx(db, () => {
      let practiceId = null;
      if (role === 'practice') {
        const p = b.practice || {};
        const modalities = (Array.isArray(p.modalities) ? p.modalities : []).filter((m) => D.MODALITIES[m]);
        if (!str(p.name) || !str(p.zip, 5) || !modalities.length) throw bad('Practice name, ZIP and at least one modality are required.');
        const z = db.prepare('SELECT lat, lon FROM zips WHERE zip = ?').get(str(p.zip, 5));
        const r = db.prepare(`INSERT INTO practices (name,address,city,state,zip,lat,lon,phone,email,modalities,equipment,accepts_insurance,accepts_self_pay,accepts_medical_legal,offers_order_review)
          VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`).run(str(p.name, 160), str(p.address), str(p.city, 80), str(p.state, 2).toUpperCase(), str(p.zip, 5),
          z ? z.lat : null, z ? z.lon : null, str(p.phone, 30), email, JSON.stringify(modalities), '[]', 1, 1, 0, 0);
        practiceId = Number(r.lastInsertRowid);
        const priceIns = db.prepare('INSERT INTO prices (practice_id, exam_code, price_cents) VALUES (?,?,?)');
        for (const e of D.EXAMS) if (modalities.includes(e.modality)) priceIns.run(practiceId, e.code, e.price);
      }
      const r = db.prepare('INSERT INTO users (email,password_hash,role,name,phone,npi,organization,practice_id,created_at) VALUES (?,?,?,?,?,?,?,?,?)')
        .run(email, auth.hashPassword(String(b.password)), role, name, str(b.phone, 30) || null, role === 'physician' ? npi : null, str(b.organization, 160) || null, practiceId, nowIso());
      return { id: Number(r.lastInsertRowid) };
    });
    const s = auth.createSession(db, user.id);
    ctx.setCookie(s);
    audit(user, 'register', 'user', user.id, ctx.ip);
    return { user: auth.userForToken(db, s.token) };
  });

  route('POST', '/api/auth/login', (ctx) => {
    const f = loginFailures.get(ctx.ip);
    if (f && f.count >= 10 && f.until > Date.now()) throw new HttpError(429, 'Too many attempts. Try again in a few minutes.');
    const email = str(ctx.body.email, 120).toLowerCase();
    const row = db.prepare('SELECT id, password_hash FROM users WHERE email = ?').get(email);
    if (!row || !auth.verifyPassword(String(ctx.body.password || ''), row.password_hash)) {
      const cur = f && f.until > Date.now() ? f : { count: 0, until: Date.now() + 15 * 60000 };
      cur.count++; loginFailures.set(ctx.ip, cur);
      throw new HttpError(401, 'Email or password is incorrect.');
    }
    loginFailures.delete(ctx.ip);
    const s = auth.createSession(db, row.id);
    ctx.setCookie(s);
    audit({ id: row.id }, 'login', 'user', row.id, ctx.ip);
    return { user: auth.userForToken(db, s.token) };
  });

  route('POST', '/api/auth/logout', (ctx) => { auth.destroySession(db, ctx.token); ctx.clearCookie(); return { ok: true }; });
  route('GET', '/api/auth/me', (ctx) => ({ user: ctx.user || null }));

  // ----- uploads -----
  route('POST', '/api/uploads', (ctx) => {
    const user = requireUser(ctx);
    const b = ctx.body;
    const type = str(b.contentType, 60).toLowerCase();
    if (!(type in UPLOAD_TYPES)) throw bad('Upload a PDF, JPG, PNG, HEIC or WEBP file.');
    const data = Buffer.from(String(b.data || ''), 'base64');
    if (!data.length) throw bad('The file is empty.');
    if (data.length > MAX_UPLOAD) throw bad('Files must be 5 MB or smaller.');
    const magic = UPLOAD_TYPES[type];
    if (magic && data.subarray(0, magic.length).toString('latin1') !== magic) throw bad('The file contents do not match its type.');
    const id = crypto.randomBytes(16).toString('hex');
    fs.writeFileSync(path.join(uploadDir, id), data, { mode: 0o600 });
    const kind = ['rx', 'lop', 'other'].includes(b.kind) ? b.kind : 'other';
    const filename = str(b.filename, 120).replace(/[^\w.\- ()]/g, '_') || 'document';
    db.prepare('INSERT INTO uploads (id, owner_id, kind, filename, content_type, size, created_at) VALUES (?,?,?,?,?,?,?)').run(id, user.id, kind, filename, type, data.length, nowIso());
    return { upload: { id, kind, filename, size: data.length } };
  });

  route('GET', '/api/uploads/:id', (ctx) => {
    const user = requireUser(ctx);
    const up = db.prepare('SELECT * FROM uploads WHERE id = ?').get(str(ctx.params.id, 64));
    if (!up) throw new HttpError(404, 'File not found.');
    let allowed = up.owner_id === user.id;
    if (!allowed && up.referral_id) {
      const ref = db.prepare('SELECT * FROM referrals WHERE id = ?').get(up.referral_id);
      allowed = !!actorFor(user, ref);
    }
    if (!allowed) throw new HttpError(404, 'File not found.');
    audit(user, 'download', 'upload', up.id, ctx.ip);
    return { file: { path: path.join(uploadDir, up.id), type: up.content_type, name: up.filename } };
  });

  // ----- referrals -----
  route('POST', '/api/referrals', (ctx) => {
    const user = requireUser(ctx, 'patient', 'physician', 'attorney');
    const b = ctx.body;
    const exam = D.EXAM_BY_CODE[b.examCode];
    const input = {
      pathway: str(b.pathway, 20), payment: str(b.payment, 20), patient: cleanPatient(b.patient), order: cleanOrder(b.order),
      insurance: cleanInsurance(b.insurance), legal: cleanLegal(b.legal), selfPayAcknowledged: bool(b.selfPayAcknowledged),
    };
    if (input.pathway === 'physician') {
      // The ordering physician is the signed-in physician unless they enter a colleague's NPI.
      input.order.physicianName = input.order.physicianName || user.name;
      input.order.npi = input.order.npi || user.npi || '';
      input.order.practiceName = input.order.practiceName || user.organization || '';
    }
    const priority = ['routine', 'urgent', 'stat'].includes(b.priority) ? b.priority : 'routine';

    const uploadIds = { rx: str(b.uploads && b.uploads.rx, 64), lop: str(b.uploads && b.uploads.lop, 64) };
    const uploads = {};
    for (const [k, id] of Object.entries(uploadIds)) {
      if (!id) continue;
      const up = db.prepare('SELECT * FROM uploads WHERE id = ? AND owner_id = ? AND referral_id IS NULL').get(id, user.id);
      if (!up) throw bad('One of the uploaded documents could not be found. Please upload it again.');
      uploads[k] = up;
    }

    return tx(db, () => {
      const practice = getPractice(Number(b.practiceId));
      const slot = b.slotId ? db.prepare('SELECT * FROM slots WHERE id = ?').get(Number(b.slotId)) : null;
      if (b.slotId && !slot) throw bad('That time is no longer available.');
      const price = exam && practice ? getPrice(practice.id, exam.code) : null;
      const errors = D.validateReferral(input, { role: user.role, exam, practice, slot, price, uploads });
      if (errors.length) throw bad('Please fix the following:', errors);

      const screeningAnswers = {};
      for (const s of D.screeningQuestions(exam.modality, exam.contrast)) screeningAnswers[s.id] = bool(b.screening && b.screening[s.id]);
      const flags = D.evaluateScreening(exam.modality, exam.contrast, screeningAnswers);
      if (input.pathway === 'patient_selfpay' && !uploads.rx) flags.unshift('No order uploaded: physician order review required before scheduling is final.');
      if (priority !== 'routine') flags.unshift(`Priority: ${priority.toUpperCase()}`);

      const status = slot ? 'pending_review' : 'awaiting_scheduling';
      const now = nowIso();
      const r = db.prepare(`INSERT INTO referrals (ref_code, created_by, pathway, payment, status, priority, practice_id, slot_id, exam_code, modality,
        patient_json, order_json, insurance_json, legal_json, screening_json, flags_json, price_cents, created_at, updated_at)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`).run(
        refCode(), user.id, input.pathway, input.payment, status, priority, practice.id, slot ? slot.id : null, exam.code, exam.modality,
        JSON.stringify(input.patient), JSON.stringify(input.order),
        input.payment === 'insurance' ? JSON.stringify(input.insurance) : null,
        input.payment === 'medical_legal' ? JSON.stringify(input.legal) : null,
        JSON.stringify(screeningAnswers), JSON.stringify(flags), input.payment === 'self_pay' ? price : null, now, now);
      const id = Number(r.lastInsertRowid);
      if (slot) {
        const held = db.prepare("UPDATE slots SET status = 'held' WHERE id = ? AND status = 'open'").run(slot.id);
        if (held.changes !== 1) throw bad('That time was just taken. Please choose another time.');
      }
      for (const up of Object.values(uploads)) db.prepare('UPDATE uploads SET referral_id = ? WHERE id = ?').run(id, up.id);
      db.prepare('INSERT INTO referral_events (referral_id, user_id, kind, status, text, created_at) VALUES (?,?,?,?,?,?)')
        .run(id, user.id, 'status', status, `Submitted as ${D.PATHWAYS[input.pathway].label.toLowerCase()} (${D.PAYMENTS[input.payment]}).`, now);
      audit(user, 'create', 'referral', id, ctx.ip);
      const row = db.prepare('SELECT ref_code FROM referrals WHERE id = ?').get(id);
      return { referral: { id, refCode: row.ref_code, status } };
    });
  });

  route('GET', '/api/referrals', (ctx) => {
    const user = requireUser(ctx);
    const status = str(ctx.query.get('status'), 30);
    const base = `SELECT r.*, p.name AS practice_name, p.tz AS practice_tz, s.starts_at FROM referrals r
      JOIN practices p ON p.id = r.practice_id LEFT JOIN slots s ON s.id = r.slot_id`;
    let rows;
    if (user.role === 'practice') {
      rows = status
        ? db.prepare(`${base} WHERE r.practice_id = ? AND r.status = ? ORDER BY r.updated_at DESC`).all(user.practice_id, status)
        : db.prepare(`${base} WHERE r.practice_id = ? ORDER BY r.updated_at DESC`).all(user.practice_id);
    } else {
      rows = db.prepare(`${base} WHERE r.created_by = ? ORDER BY r.updated_at DESC`).all(user.id);
    }
    return { referrals: rows.map(referralSummary) };
  });

  route('GET', '/api/referrals/:id', (ctx) => {
    const user = requireUser(ctx);
    const { ref, actor } = loadReferral(ctx.params.id, user);
    const practice = getPractice(ref.practice_id);
    const slot = ref.slot_id ? db.prepare('SELECT * FROM slots WHERE id = ?').get(ref.slot_id) : null;
    const events = db.prepare(`SELECT e.kind, e.status, e.text, e.created_at, u.name AS user_name, u.role AS user_role
      FROM referral_events e LEFT JOIN users u ON u.id = e.user_id WHERE e.referral_id = ? ORDER BY e.id`).all(ref.id).map((e) => ({ ...e }));
    const files = db.prepare('SELECT id, kind, filename, content_type, size FROM uploads WHERE referral_id = ?').all(ref.id).map((f) => ({ ...f }));
    const submitter = db.prepare('SELECT name, role, email, phone, organization, npi FROM users WHERE id = ?').get(ref.created_by);
    const allowed = Object.keys(D.TRANSITIONS[ref.status] || {}).filter((to) => D.canTransition(ref.status, to, actor));
    audit(user, 'view', 'referral', ref.id, ctx.ip);
    return {
      referral: {
        ...referralSummary({ ...ref, practice_name: practice.name, practice_tz: practice.tz, starts_at: slot && slot.starts_at }),
        patient: json(ref.patient_json, {}), order: json(ref.order_json, {}), insurance: json(ref.insurance_json, null), legal: json(ref.legal_json, null),
        screening: json(ref.screening_json, {}), priceCents: ref.price_cents,
        slot: slot ? { id: slot.id, starts_at: slot.starts_at, duration_min: slot.duration_min, equipment: slot.equipment } : null,
        practice: { id: practice.id, name: practice.name, address: practice.address, city: practice.city, state: practice.state, zip: practice.zip, phone: practice.phone, tz: practice.tz },
        prep: D.prepFor(ref.exam_code), cpt: (D.EXAM_BY_CODE[ref.exam_code] || {}).cpt,
        submitter: { ...submitter }, events, files, actor, allowedTransitions: allowed,
      },
    };
  });

  route('POST', '/api/referrals/:id/status', (ctx) => {
    const user = requireUser(ctx);
    return tx(db, () => {
      const { ref, actor } = loadReferral(ctx.params.id, user);
      const to = str(ctx.body.status, 30);
      const note = str(ctx.body.note, 2000);
      if (!D.canTransition(ref.status, to, actor)) throw bad(`You can't change this request from "${D.STATUS_LABELS[ref.status]}" to "${D.STATUS_LABELS[to] || to}".`);
      if ((to === 'needs_info' || to === 'declined') && !note) throw bad('Add a note explaining what is needed or why.');
      let slotId = ref.slot_id;
      if (to === 'confirmed' && !slotId) {
        const exam = D.EXAM_BY_CODE[ref.exam_code];
        const slot = db.prepare('SELECT * FROM slots WHERE id = ?').get(Number(ctx.body.slotId));
        if (!slot || slot.practice_id !== ref.practice_id || slot.status !== 'open' || slot.modality !== ref.modality || slot.duration_min < exam.minutes || slot.starts_at <= nowIso())
          throw bad('Choose an open, future time for this exam at your practice.');
        slotId = slot.id;
      }
      if (to === 'confirmed') db.prepare("UPDATE slots SET status = 'booked' WHERE id = ?").run(slotId);
      if (to === 'declined' || to === 'cancelled') releaseSlot(ref.slot_id);
      const now = nowIso();
      db.prepare('UPDATE referrals SET status = ?, slot_id = ?, updated_at = ? WHERE id = ?').run(to, slotId, now, ref.id);
      db.prepare('INSERT INTO referral_events (referral_id, user_id, kind, status, text, created_at) VALUES (?,?,?,?,?,?)').run(ref.id, user.id, 'status', to, note || null, now);
      audit(user, `status:${to}`, 'referral', ref.id, ctx.ip);
      return { ok: true, status: to };
    });
  });

  route('POST', '/api/referrals/:id/messages', (ctx) => {
    const user = requireUser(ctx);
    const { ref } = loadReferral(ctx.params.id, user);
    const text = str(ctx.body.text, 2000);
    if (!text) throw bad('Write a message first.');
    const now = nowIso();
    db.prepare('INSERT INTO referral_events (referral_id, user_id, kind, text, created_at) VALUES (?,?,?,?,?)').run(ref.id, user.id, 'message', text, now);
    db.prepare('UPDATE referrals SET updated_at = ? WHERE id = ?').run(now, ref.id);
    return { ok: true };
  });

  // ----- practice portal -----
  route('GET', '/api/practice/profile', (ctx) => {
    const user = requireUser(ctx, 'practice');
    const p = getPractice(user.practice_id);
    const prices = db.prepare('SELECT exam_code, price_cents FROM prices WHERE practice_id = ?').all(p.id);
    return { practice: p, prices: Object.fromEntries(prices.map((r) => [r.exam_code, r.price_cents])) };
  });

  route('PUT', '/api/practice/profile', (ctx) => {
    const user = requireUser(ctx, 'practice');
    const b = ctx.body;
    const modalities = (Array.isArray(b.modalities) ? b.modalities : []).filter((m) => D.MODALITIES[m]);
    if (!str(b.name) || !modalities.length) throw bad('Practice name and at least one modality are required.');
    const zip = str(b.zip, 5);
    const z = db.prepare('SELECT lat, lon FROM zips WHERE zip = ?').get(zip);
    const equipment = (Array.isArray(b.equipment) ? b.equipment : String(b.equipment || '').split(',')).map((e) => str(e, 60)).filter(Boolean).slice(0, 12);
    const legal = (Array.isArray(b.legal_services) ? b.legal_services : []).filter((s) => D.LEGAL_SERVICES[s]);
    tx(db, () => {
      db.prepare(`UPDATE practices SET name=?, address=?, city=?, state=?, zip=?, lat=COALESCE(?, lat), lon=COALESCE(?, lon), phone=?, email=?, hours=?, accreditation=?, description=?,
        modalities=?, equipment=?, accepts_insurance=?, insurance_notes=?, accepts_self_pay=?, accepts_medical_legal=?, legal_services=?, offers_order_review=? WHERE id=?`).run(
        str(b.name, 160), str(b.address), str(b.city, 80), str(b.state, 2).toUpperCase(), zip, z ? z.lat : null, z ? z.lon : null, str(b.phone, 30), str(b.email, 120),
        str(b.hours, 120), str(b.accreditation, 200), str(b.description, 1000), JSON.stringify(modalities), JSON.stringify(equipment),
        bool(b.accepts_insurance) ? 1 : 0, str(b.insurance_notes, 300), bool(b.accepts_self_pay) ? 1 : 0, bool(b.accepts_medical_legal) ? 1 : 0,
        JSON.stringify(legal), bool(b.offers_order_review) ? 1 : 0, user.practice_id);
      const up = db.prepare('INSERT INTO prices (practice_id, exam_code, price_cents) VALUES (?,?,?) ON CONFLICT(practice_id, exam_code) DO UPDATE SET price_cents = excluded.price_cents');
      for (const [code, cents] of Object.entries(b.prices || {})) {
        const n = Math.round(Number(cents));
        if (D.EXAM_BY_CODE[code] && n > 0 && n < 10000000) up.run(user.practice_id, code, n);
      }
    });
    audit(user, 'update', 'practice', user.practice_id, ctx.ip);
    return { ok: true };
  });

  route('GET', '/api/practice/slots', (ctx) => {
    const user = requireUser(ctx, 'practice');
    const p = getPractice(user.practice_id);
    const from = ctx.query.get('from') && !isNaN(Date.parse(ctx.query.get('from'))) ? D.zonedToUtc(ctx.query.get('from'), '00:00', p.tz) : new Date();
    const days = Math.min(Math.max(Number(ctx.query.get('days')) || 7, 1), 31);
    const to = new Date(from.getTime() + days * 86400000);
    const modality = str(ctx.query.get('modality'), 10);
    const rows = db.prepare(`SELECT s.*, r.id AS referral_id, r.ref_code, r.status AS referral_status FROM slots s
      LEFT JOIN referrals r ON r.slot_id = s.id AND r.status IN ('pending_review','needs_info','confirmed','completed','no_show')
      WHERE s.practice_id = ? AND s.starts_at >= ? AND s.starts_at < ? ${modality ? 'AND s.modality = ?' : ''} ORDER BY s.starts_at`)
      .all(...[p.id, from.toISOString(), to.toISOString(), ...(modality ? [modality] : [])]).map((r) => ({ ...r }));
    return { tz: p.tz, slots: rows };
  });

  route('POST', '/api/practice/slots', (ctx) => {
    const user = requireUser(ctx, 'practice');
    const p = getPractice(user.practice_id);
    const b = ctx.body;
    if (!p.modalities.includes(b.modality)) throw bad('Choose a modality your practice offers.');
    const re = /^\d{4}-\d{2}-\d{2}$/, te = /^\d{2}:\d{2}$/;
    if (!re.test(b.fromDate) || !re.test(b.toDate || b.fromDate)) throw bad('Choose a start and end date.');
    if (!te.test(b.startTime) || !te.test(b.endTime) || b.startTime >= b.endTime) throw bad('Choose a start time before the end time.');
    const interval = Math.round(Number(b.intervalMin) || D.MODALITIES[b.modality].slotMinutes);
    const duration = Math.round(Number(b.durationMin) || interval);
    if (interval < 5 || interval > 240 || duration < 5 || duration > 240) throw bad('Interval and length must be between 5 and 240 minutes.');
    const weekdays = Array.isArray(b.weekdays) && b.weekdays.length ? b.weekdays.map(Number) : [1, 2, 3, 4, 5];
    const equipment = str(b.equipment, 60) || null;
    const [sh, sm] = b.startTime.split(':').map(Number), [eh, em] = b.endTime.split(':').map(Number);
    const startMin = sh * 60 + sm, endMin = eh * 60 + em;
    const exists = db.prepare('SELECT 1 FROM slots WHERE practice_id = ? AND modality = ? AND starts_at = ? AND COALESCE(equipment, \'\') = ?');
    const ins = db.prepare('INSERT INTO slots (practice_id, modality, equipment, starts_at, duration_min, status, created_at) VALUES (?,?,?,?,?,?,?)');
    let created = 0, skipped = 0;
    const now = new Date();
    tx(db, () => {
      for (let d = new Date(b.fromDate + 'T12:00:00Z'), i = 0; d <= new Date((b.toDate || b.fromDate) + 'T12:00:00Z'); d = new Date(d.getTime() + 86400000), i++) {
        if (i > 92) throw bad('Create at most 3 months of slots at a time.');
        if (!weekdays.includes(d.getUTCDay())) continue;
        const date = d.toISOString().slice(0, 10);
        for (let m = startMin; m + duration <= endMin; m += interval) {
          const t = `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
          const start = D.zonedToUtc(date, t, p.tz);
          if (start <= now) { skipped++; continue; }
          if (exists.get(p.id, b.modality, start.toISOString(), equipment || '')) { skipped++; continue; }
          if (created >= 3000) throw bad('That would create more than 3,000 slots. Use a shorter date range.');
          ins.run(p.id, b.modality, equipment, start.toISOString(), duration, 'open', now.toISOString());
          created++;
        }
      }
    });
    audit(user, 'create_slots', 'practice', p.id, ctx.ip);
    return { created, skipped };
  });

  route('DELETE', '/api/practice/slots/:id', (ctx) => {
    const user = requireUser(ctx, 'practice');
    const r = db.prepare("DELETE FROM slots WHERE id = ? AND practice_id = ? AND status = 'open' AND NOT EXISTS (SELECT 1 FROM referrals WHERE slot_id = slots.id)")
      .run(Number(ctx.params.id), user.practice_id);
    if (r.changes !== 1) throw bad('Only open slots with no requests attached can be removed.');
    return { ok: true };
  });

  // ---------- request dispatch ----------
  function securityHeaders(res) {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('Content-Security-Policy', "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'");
    if (secureCookies) res.setHeader('Strict-Transport-Security', 'max-age=31536000');
  }

  function serveStatic(req, res, pathname) {
    const rel = pathname === '/' ? 'index.html' : pathname.slice(1);
    const file = path.normalize(path.join(publicDir, rel));
    if (!file.startsWith(publicDir + path.sep)) { res.writeHead(404); return res.end('Not found'); }
    fs.readFile(file, (err, data) => {
      if (err) { res.writeHead(404, { 'Content-Type': 'text/plain' }); return res.end('Not found'); }
      res.writeHead(200, { 'Content-Type': STATIC_TYPES[path.extname(file)] || 'application/octet-stream', 'Cache-Control': 'no-cache' });
      res.end(data);
    });
  }

  return async function handler(req, res) {
    securityHeaders(res);
    const url = new URL(req.url, 'http://localhost');
    if (!url.pathname.startsWith('/api/')) {
      if (req.method !== 'GET' && req.method !== 'HEAD') { res.writeHead(405); return res.end(); }
      return serveStatic(req, res, url.pathname);
    }
    const send = (status, body) => {
      res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
      res.end(JSON.stringify(body));
    };
    try {
      const match = routes.find((r) => r.method === req.method && r.re.test(url.pathname));
      if (!match) throw new HttpError(404, 'Not found.');
      // CSRF defence: state-changing requests must be JSON (cannot be sent cross-site by a plain form) and cookies are SameSite=Strict.
      if (req.method !== 'GET' && !String(req.headers['content-type'] || '').startsWith('application/json')) throw new HttpError(415, 'Send JSON.');
      const token = parseCookies(req.headers.cookie).sid;
      const cookieBase = `Path=/; HttpOnly; SameSite=Strict${secureCookies ? '; Secure' : ''}`;
      const ctx = {
        params: url.pathname.match(match.re).groups || {}, query: url.searchParams, token,
        user: auth.userForToken(db, token), ip: req.socket.remoteAddress,
        body: req.method === 'GET' ? {} : await readBody(req),
        setCookie: (s) => res.setHeader('Set-Cookie', `sid=${s.token}; ${cookieBase}; Max-Age=${auth.SESSION_DAYS * 86400}`),
        clearCookie: () => res.setHeader('Set-Cookie', `sid=; ${cookieBase}; Max-Age=0`),
      };
      const out = await match.handler(ctx);
      if (out && out.file) {
        res.writeHead(200, { 'Content-Type': out.file.type, 'Content-Disposition': `attachment; filename="${out.file.name.replace(/"/g, '')}"`, 'Cache-Control': 'no-store' });
        return fs.createReadStream(out.file.path).pipe(res);
      }
      send(200, out);
    } catch (e) {
      if (e instanceof HttpError) return send(e.status, { error: e.message, details: e.details });
      console.error(e);
      send(500, { error: 'Something went wrong. Please try again.' });
    }
  };
}

module.exports = { createApp };
