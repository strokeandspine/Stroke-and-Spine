'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const os = require('node:os');
const fs = require('node:fs');
const path = require('node:path');
const { openDb, seed, DEMO_PASSWORD } = require('../server/db');
const { createApp } = require('../server/app');

const PDF = Buffer.from('%PDF-1.4\n% test order\n').toString('base64');
let server, base, db, tmp;

test.before(async () => {
  tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'imaging-test-'));
  db = openDb(':memory:');
  seed(db, { days: 10 });
  server = http.createServer(createApp({ db, uploadDir: path.join(tmp, 'uploads'), publicDir: path.join(__dirname, '..', 'public') }));
  await new Promise((r) => server.listen(0, r));
  base = `http://127.0.0.1:${server.address().port}`;
});
test.after(() => { server.close(); fs.rmSync(tmp, { recursive: true, force: true }); });

function client() {
  let cookie = '';
  return async function call(method, url, body) {
    const res = await fetch(base + url, {
      method, headers: { ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}), ...(cookie ? { Cookie: cookie } : {}) },
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
    const set = res.headers.get('set-cookie');
    if (set) cookie = set.split(';')[0];
    const type = res.headers.get('content-type') || '';
    return { status: res.status, body: type.includes('json') ? await res.json() : await res.text() };
  };
}
async function login(email) {
  const c = client();
  const r = await c('POST', '/api/auth/login', { email, password: DEMO_PASSWORD });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  return c;
}
async function findSlot(c, modality, filter = () => true, query = '', minutes = modality === 'MRI' ? 45 : 15) {
  const r = await c('GET', `/api/slots/search?modality=${modality}${query}`);
  assert.equal(r.status, 200);
  for (const res of r.body.results) {
    if (!filter(res.practice)) continue;
    const s = res.slots.find((x) => x.duration_min >= minutes);
    if (s) return { practice: res.practice, slot: s };
  }
  throw new Error('no slot found');
}
const patient = { firstName: 'Ann', lastName: 'Lee', dob: '1980-02-03', phone: '555-0100' };
const yesNoNo = { pacemaker: false, implant: false, metal: false, surgery6w: false, claustro: true, pregnant: false };

test('public search lists open slots with prices and filters by payment and distance', async () => {
  const c = client();
  const all = await c('GET', '/api/slots/search?modality=MRI&exam=MRI-LSPINE');
  assert.equal(all.status, 200);
  assert.ok(all.body.results.length >= 3);
  assert.ok(all.body.results.every((r) => r.price > 0 && r.slots.length > 0));
  const legal = await c('GET', '/api/slots/search?modality=MRI&payment=medical_legal');
  assert.ok(legal.body.results.every((r) => r.practice.accepts_medical_legal));
  const near = await c('GET', '/api/slots/search?modality=MRI&zip=76011&radius=5');
  assert.ok(near.body.results.length >= 1 && near.body.results.every((r) => r.distance <= 5));
  const priced = await c('GET', '/api/slots/search?modality=MRI&exam=MRI-LSPINE&sort=price');
  const p = priced.body.results.map((r) => r.price);
  assert.deepEqual(p, [...p].sort((a, b) => a - b));
  const bad = await c('GET', '/api/slots/search?modality=PET');
  assert.equal(bad.status, 400);
});

test('physician books a slot; practice confirms; slot becomes booked', async () => {
  const doc = await login('doctor@demo.test');
  const { practice, slot } = await findSlot(doc, 'MRI', (p) => p.name.startsWith('Uptown'));
  const r = await doc('POST', '/api/referrals', {
    pathway: 'physician', payment: 'insurance', examCode: 'MRI-LSPINE', practiceId: practice.id, slotId: slot.id, priority: 'urgent',
    patient, order: { icd10: ['M54.16'], indication: 'Left L5 radiculopathy, 8 weeks, failed PT' },
    insurance: { carrier: 'BCBS TX', memberId: 'XYZ123' }, screening: yesNoNo,
  });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  assert.match(r.body.referral.refCode, /^IMG-/);
  const id = r.body.referral.id;

  // Slot is held and no longer searchable
  const again = await doc('GET', '/api/slots/' + slot.id);
  assert.equal(again.body.slot.status, 'held');

  // Another practice cannot see it
  const other = await login('clearprice@demo.test');
  assert.equal((await other('GET', '/api/referrals/' + id)).status, 404);

  const prac = await login('uptown@demo.test');
  const detail = await prac('GET', '/api/referrals/' + id);
  assert.equal(detail.status, 200);
  assert.equal(detail.body.referral.order.npi, '1234567893');
  assert.ok(detail.body.referral.flags.some((f) => /URGENT/.test(f)));
  assert.ok(detail.body.referral.flags.some((f) => /Claustrophobia/.test(f)));
  assert.deepEqual(detail.body.referral.allowedTransitions.sort(), ['confirmed', 'declined', 'needs_info']);

  // Submitter cannot confirm
  assert.equal((await doc('POST', `/api/referrals/${id}/status`, { status: 'confirmed' })).status, 400);
  assert.equal((await prac('POST', `/api/referrals/${id}/status`, { status: 'confirmed', note: 'See you then' })).status, 200);
  assert.equal((await doc('GET', '/api/slots/' + slot.id)).body.slot.status, 'booked');
  assert.equal((await prac('POST', `/api/referrals/${id}/status`, { status: 'completed' })).status, 200);
});

test('a slot cannot be requested twice', async () => {
  const doc = await login('doctor@demo.test');
  const { practice, slot } = await findSlot(doc, 'MRI', (p) => p.name.startsWith('North'));
  const body = { pathway: 'physician', payment: 'self_pay', selfPayAcknowledged: true, examCode: 'MRI-KNEE', practiceId: practice.id, slotId: slot.id,
    patient, order: { icd10: ['M23.91'], indication: 'Knee locking' }, screening: {} };
  assert.equal((await doc('POST', '/api/referrals', body)).status, 200);
  const second = await doc('POST', '/api/referrals', body);
  assert.equal(second.status, 400);
  assert.ok(second.body.details.some((d) => /just taken/.test(d)));
});

test('patient self-pay without an order at a practice offering order review; cancel releases slot', async () => {
  const pt = await login('patient@demo.test');
  const { practice, slot } = await findSlot(pt, 'MRI', (p) => p.offers_order_review, '&payment=self_pay');
  const r = await pt('POST', '/api/referrals', {
    pathway: 'patient_selfpay', payment: 'self_pay', selfPayAcknowledged: true, examCode: 'MRI-LSPINE', practiceId: practice.id, slotId: slot.id,
    patient, order: { reason: 'Low back pain for 4 months' }, screening: yesNoNo,
  });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  const d = await pt('GET', '/api/referrals/' + r.body.referral.id);
  assert.ok(d.body.referral.priceCents > 0);
  assert.ok(d.body.referral.flags.some((f) => /order review/.test(f)));
  assert.equal((await pt('POST', `/api/referrals/${r.body.referral.id}/status`, { status: 'cancelled' })).status, 200);
  assert.equal((await pt('GET', '/api/slots/' + slot.id)).body.slot.status, 'open');
});

test('patient self-pay without an order is refused where order review is not offered', async () => {
  const pt = await login('patient@demo.test');
  const { practice, slot } = await findSlot(pt, 'MRI', (p) => !p.offers_order_review && p.accepts_self_pay);
  const r = await pt('POST', '/api/referrals', {
    pathway: 'patient_selfpay', payment: 'self_pay', selfPayAcknowledged: true, examCode: 'MRI-LSPINE', practiceId: practice.id, slotId: slot.id,
    patient, order: { reason: 'x' }, screening: {},
  });
  assert.equal(r.status, 400);
  assert.ok(r.body.details.some((d) => /needs a physician order/.test(d)));
  assert.equal((await pt('GET', '/api/slots/' + slot.id)).body.slot.status, 'open');
});

test('patient with prescription upload; documents only visible to parties', async () => {
  const pt = await login('patient@demo.test');
  const up = await pt('POST', '/api/uploads', { kind: 'rx', filename: 'order.pdf', contentType: 'application/pdf', data: PDF });
  assert.equal(up.status, 200);
  const fake = await pt('POST', '/api/uploads', { kind: 'rx', filename: 'x.pdf', contentType: 'application/pdf', data: Buffer.from('<html>').toString('base64') });
  assert.equal(fake.status, 400);
  const { practice, slot } = await findSlot(pt, 'CT', () => true);
  const r = await pt('POST', '/api/referrals', {
    pathway: 'patient_rx', payment: 'insurance', examCode: 'CT-HEAD', practiceId: practice.id, slotId: slot.id,
    patient, order: { physicianName: 'Dr. Smith' }, insurance: { carrier: 'Aetna', memberId: 'A1' }, uploads: { rx: up.body.upload.id }, screening: { pregnant: false },
  });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  const fileUrl = '/api/uploads/' + up.body.upload.id;
  assert.equal((await pt('GET', fileUrl)).status, 200);
  const doc = await login('doctor@demo.test');
  assert.equal((await doc('GET', fileUrl)).status, 404);
  const anon = client();
  assert.equal((await anon('GET', fileUrl)).status, 401);
  // Upload cannot be reused on a second referral
  const r2 = await pt('POST', '/api/referrals', { pathway: 'patient_rx', payment: 'insurance', examCode: 'CT-HEAD', practiceId: practice.id, slotId: slot.id, patient, uploads: { rx: up.body.upload.id } });
  assert.equal(r2.status, 400);
});

test('attorney medical-legal request requires order and LOP and a practice that accepts medical-legal', async () => {
  const att = await login('attorney@demo.test');
  const rx = (await att('POST', '/api/uploads', { kind: 'rx', filename: 'rx.pdf', contentType: 'application/pdf', data: PDF })).body.upload.id;
  const lop = (await att('POST', '/api/uploads', { kind: 'lop', filename: 'lop.pdf', contentType: 'application/pdf', data: PDF })).body.upload.id;
  const { practice, slot } = await findSlot(att, 'MRI', (p) => p.accepts_medical_legal, '&payment=medical_legal');
  const legal = { caseType: 'auto', injuryDate: '2026-09-14', attorneyName: 'Casey Morgan', attorneyPhone: '214-555-0103', caseNumber: 'PI-2231', services: ['expedited_read', 'narrative', 'bogus'] };
  const missing = await att('POST', '/api/referrals', { pathway: 'attorney', payment: 'medical_legal', examCode: 'MRI-CSPINE', practiceId: practice.id, slotId: slot.id, patient, order: { physicianName: 'Dr. Treat' }, legal, uploads: { rx } });
  assert.equal(missing.status, 400);
  assert.ok(missing.body.details.some((d) => /letter of protection/.test(d)));
  const ok = await att('POST', '/api/referrals', { pathway: 'attorney', payment: 'medical_legal', examCode: 'MRI-CSPINE', practiceId: practice.id, slotId: slot.id, patient, order: { physicianName: 'Dr. Treat' }, legal, uploads: { rx, lop }, screening: {} });
  assert.equal(ok.status, 200, JSON.stringify(ok.body));
  const d = await att('GET', '/api/referrals/' + ok.body.referral.id);
  assert.deepEqual(d.body.referral.legal.services, ['expedited_read', 'narrative']);
  assert.equal(d.body.referral.files.length, 2);
  // Attorneys cannot use patient pathways
  const wrong = await att('POST', '/api/referrals', { pathway: 'patient_selfpay', payment: 'self_pay', examCode: 'MRI-CSPINE', practiceId: practice.id, slotId: slot.id, patient });
  assert.equal(wrong.status, 400);
});

test('physician referral without a slot; practice schedules it into an open slot', async () => {
  const doc = await login('doctor@demo.test');
  const prac = await login('clearprice@demo.test');
  const profile = (await prac('GET', '/api/practice/profile')).body.practice;
  const r = await doc('POST', '/api/referrals', {
    pathway: 'physician', payment: 'self_pay', selfPayAcknowledged: true, examCode: 'DEXA-AXIAL', practiceId: profile.id, patient,
    order: { icd10: ['M81.0'], indication: 'Osteoporosis screening, postmenopausal' }, screening: { pregnant: false, recentContrast: false },
  });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  assert.equal(r.body.referral.status, 'awaiting_scheduling');
  const slots = (await prac('GET', '/api/practice/slots?modality=DEXA&days=14')).body.slots.filter((s) => s.status === 'open');
  assert.ok(slots.length);
  assert.equal((await prac('POST', `/api/referrals/${r.body.referral.id}/status`, { status: 'confirmed' })).status, 400);
  assert.equal((await prac('POST', `/api/referrals/${r.body.referral.id}/status`, { status: 'confirmed', slotId: slots[0].id })).status, 200);
  const d = await doc('GET', '/api/referrals/' + r.body.referral.id);
  assert.equal(d.body.referral.status, 'confirmed');
  assert.equal(d.body.referral.slot.id, slots[0].id);
});

test('practice needs-info loop, decline releases slot, messages', async () => {
  const pt = await login('patient@demo.test');
  const { practice, slot } = await findSlot(pt, 'MRI', (p) => p.name.startsWith('ClearPrice'), '&payment=self_pay');
  const r = await pt('POST', '/api/referrals', { pathway: 'patient_selfpay', payment: 'self_pay', selfPayAcknowledged: true, examCode: 'MRI-KNEE', practiceId: practice.id, slotId: slot.id, patient, order: { reason: 'Knee pain' }, screening: { pacemaker: true } });
  assert.equal(r.status, 200, JSON.stringify(r.body));
  const id = r.body.referral.id;
  const prac = await login('clearprice@demo.test');
  assert.equal((await prac('POST', `/api/referrals/${id}/status`, { status: 'needs_info' })).status, 400); // note required
  assert.equal((await prac('POST', `/api/referrals/${id}/status`, { status: 'needs_info', note: 'Please send your pacemaker card' })).status, 200);
  assert.equal((await pt('POST', `/api/referrals/${id}/messages`, { text: 'Medtronic Azure MRI SureScan' })).status, 200);
  assert.equal((await pt('POST', `/api/referrals/${id}/status`, { status: 'pending_review' })).status, 200);
  assert.equal((await prac('POST', `/api/referrals/${id}/status`, { status: 'declined', note: 'Device needs hospital MRI' })).status, 200);
  assert.equal((await pt('GET', '/api/slots/' + slot.id)).body.slot.status, 'open');
  const d = await pt('GET', '/api/referrals/' + id);
  assert.ok(d.body.referral.events.some((e) => e.kind === 'message'));
  const list = await prac('GET', '/api/referrals?status=declined');
  assert.ok(list.body.referrals.some((x) => x.id === id));
});

test('practice publishes and removes slots, updates profile and prices', async () => {
  const prac = await login('uptown@demo.test');
  const d = new Date(Date.now() + 20 * 86400000).toISOString().slice(0, 10);
  const r = await prac('POST', '/api/practice/slots', { modality: 'CT', fromDate: d, toDate: d, startTime: '08:00', endTime: '10:00', intervalMin: 30, weekdays: [0, 1, 2, 3, 4, 5, 6] });
  assert.equal(r.status, 200);
  assert.equal(r.body.created, 4);
  const dup = await prac('POST', '/api/practice/slots', { modality: 'CT', fromDate: d, toDate: d, startTime: '08:00', endTime: '10:00', intervalMin: 30, weekdays: [0, 1, 2, 3, 4, 5, 6] });
  assert.equal(dup.body.created, 0);
  assert.equal((await prac('POST', '/api/practice/slots', { modality: 'DEXA', fromDate: d, startTime: '08:00', endTime: '09:00' })).status, 400);
  const list = (await prac('GET', `/api/practice/slots?from=${d}&days=1&modality=CT`)).body.slots;
  assert.equal(list.length, 4);
  assert.equal((await prac('DELETE', '/api/practice/slots/' + list[0].id, {})).status, 200);

  const prof = (await prac('GET', '/api/practice/profile')).body;
  const upd = await prac('PUT', '/api/practice/profile', { ...prof.practice, accepts_medical_legal: false, prices: { 'CT-HEAD': 19900 } });
  assert.equal(upd.status, 200);
  const after = (await prac('GET', '/api/practice/profile')).body;
  assert.equal(after.practice.accepts_medical_legal, false);
  assert.equal(after.prices['CT-HEAD'], 19900);
  // patients cannot use practice endpoints
  const pt = await login('patient@demo.test');
  assert.equal((await pt('GET', '/api/practice/slots')).status, 403);
});

test('registration validates NPI and creates practices; CSRF guard requires JSON', async () => {
  const c = client();
  const bad = await c('POST', '/api/auth/register', { role: 'physician', name: 'Dr Z', email: 'z@example.test', password: 'longenough', npi: '1234567890' });
  assert.equal(bad.status, 400);
  const ok = await c('POST', '/api/auth/register', { role: 'practice', name: 'Desk', email: 'new@example.test', password: 'longenough', practice: { name: 'New Imaging', zip: '75201', modalities: ['XRAY', 'US'] } });
  assert.equal(ok.status, 200, JSON.stringify(ok.body));
  assert.ok(ok.body.user.practice_id);
  const res = await fetch(base + '/api/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'email=a&password=b' });
  assert.equal(res.status, 415);
});

test('static files are served with security headers', async () => {
  const res = await fetch(base + '/');
  assert.equal(res.status, 200);
  assert.match(res.headers.get('content-security-policy'), /default-src 'self'/);
  assert.equal((await fetch(base + '/../server/db.js')).status, 404);
});
