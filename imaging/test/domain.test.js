'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const D = require('../server/domain');

const practice = { id: 1, name: 'Test Imaging', modalities: ['MRI', 'CT', 'XRAY'], accepts_insurance: true, accepts_self_pay: true, accepts_medical_legal: true, offers_order_review: false };
const future = new Date(Date.now() + 86400000).toISOString();
const slot = { id: 9, practice_id: 1, modality: 'MRI', status: 'open', duration_min: 45, starts_at: future };
const patient = { firstName: 'Ann', lastName: 'Lee', dob: '1980-02-03', phone: '555-0100' };
const exam = D.EXAM_BY_CODE['MRI-LSPINE'];

test('NPI check digit', () => {
  assert.equal(D.isValidNpi('1234567893'), true);
  assert.equal(D.isValidNpi('1234567890'), false);
  assert.equal(D.isValidNpi('12345'), false);
});

test('ICD-10 format', () => {
  for (const c of ['M54.16', 'M5416', 'S33.5XXA', 'R10.9']) assert.ok(D.isValidIcd10(c), c);
  for (const c of ['54.16', 'U', 'hello', '']) assert.ok(!D.isValidIcd10(c), c);
});

test('physician referral needs NPI, ICD-10 and indication', () => {
  const base = { pathway: 'physician', payment: 'insurance', patient, insurance: { carrier: 'BCBS', memberId: 'X1' } };
  const errs = D.validateReferral({ ...base, order: {} }, { role: 'physician', exam, practice, slot });
  assert.ok(errs.some((e) => /NPI/.test(e)));
  assert.ok(errs.some((e) => /ICD-10/.test(e)));
  assert.ok(errs.some((e) => /indication/.test(e)));
  const ok = D.validateReferral({ ...base, order: { npi: '1234567893', icd10: ['M54.16'], indication: 'Radiculopathy 8 weeks' } }, { role: 'physician', exam, practice, slot });
  assert.deepEqual(ok, []);
});

test('physician referral may omit a slot; patients may not', () => {
  const order = { npi: '1234567893', icd10: ['M54.16'], indication: 'x' };
  assert.deepEqual(D.validateReferral({ pathway: 'physician', payment: 'insurance', patient, order, insurance: { carrier: 'A', memberId: 'B' } }, { role: 'physician', exam, practice, slot: null }), []);
  const errs = D.validateReferral({ pathway: 'patient_rx', payment: 'self_pay', patient, order: { physicianName: 'Dr X' }, selfPayAcknowledged: true }, { role: 'patient', exam, practice, slot: null, price: 100, uploads: { rx: {} } });
  assert.ok(errs.some((e) => /appointment time/.test(e)));
});

test('patient with prescription must upload it', () => {
  const input = { pathway: 'patient_rx', payment: 'self_pay', patient, order: { physicianName: 'Dr X' }, selfPayAcknowledged: true };
  assert.ok(D.validateReferral(input, { role: 'patient', exam, practice, slot, price: 45000, uploads: {} }).some((e) => /Upload the physician prescription/.test(e)));
  assert.deepEqual(D.validateReferral(input, { role: 'patient', exam, practice, slot, price: 45000, uploads: { rx: {} } }), []);
});

test('self-pay without an order needs a practice that offers order review', () => {
  const input = { pathway: 'patient_selfpay', payment: 'self_pay', patient, order: { reason: 'Back pain for 3 months' }, selfPayAcknowledged: true };
  assert.ok(D.validateReferral(input, { role: 'patient', exam, practice, slot, price: 45000 }).some((e) => /order review/.test(e)));
  assert.deepEqual(D.validateReferral(input, { role: 'patient', exam, practice: { ...practice, offers_order_review: true }, slot, price: 45000 }), []);
});

test('self-pay requires a published price and acknowledgement', () => {
  const input = { pathway: 'patient_selfpay', payment: 'self_pay', patient, order: { reason: 'x' } };
  const errs = D.validateReferral(input, { role: 'patient', exam, practice: { ...practice, offers_order_review: true }, slot, price: null });
  assert.ok(errs.some((e) => /self-pay price/.test(e)));
  assert.ok(errs.some((e) => /acknowledge/.test(e)));
});

test('self-pay pathway cannot bill insurance', () => {
  const errs = D.validateReferral({ pathway: 'patient_selfpay', payment: 'insurance', patient, order: { reason: 'x' } }, { role: 'patient', exam, practice, slot });
  assert.ok(errs.some((e) => /not available/.test(e)));
});

test('medical-legal: LOP for injury cases, claim details for workers comp', () => {
  const base = { pathway: 'attorney', payment: 'medical_legal', patient, order: { physicianName: 'Dr X' } };
  const ctx = { role: 'attorney', exam, practice, slot, uploads: { rx: {} } };
  const pi = { caseType: 'auto', injuryDate: '2026-01-05', attorneyName: 'Casey', attorneyPhone: '555' };
  assert.ok(D.validateReferral({ ...base, legal: pi }, ctx).some((e) => /letter of protection/.test(e)));
  assert.deepEqual(D.validateReferral({ ...base, legal: pi }, { ...ctx, uploads: { rx: {}, lop: {} } }), []);
  const wc = { caseType: 'workers_comp', injuryDate: '2026-01-05' };
  assert.ok(D.validateReferral({ ...base, legal: wc }, ctx).some((e) => /claim number/.test(e)));
  assert.deepEqual(D.validateReferral({ ...base, legal: { ...wc, claimNumber: 'WC-1', carrier: 'Texas Mutual' } }, ctx), []);
  assert.ok(D.validateReferral({ ...base, legal: pi }, { ...ctx, uploads: { rx: {}, lop: {} }, practice: { ...practice, accepts_medical_legal: false } }).some((e) => /does not accept medical-legal/.test(e)));
});

test('medical-legal rejects future injury dates', () => {
  const errs = D.validateReferral({ pathway: 'attorney', payment: 'medical_legal', patient, order: { physicianName: 'Dr' }, legal: { caseType: 'auto', injuryDate: '2999-01-01', attorneyName: 'A', attorneyPhone: '1' } },
    { role: 'attorney', exam, practice, slot, uploads: { rx: {}, lop: {} } });
  assert.ok(errs.some((e) => /date of injury/.test(e)));
});

test('roles are limited to their pathways', () => {
  const errs = D.validateReferral({ pathway: 'physician', payment: 'insurance', patient, order: {} }, { role: 'patient', exam, practice, slot });
  assert.ok(errs.some((e) => /cannot submit/.test(e)));
});

test('slot checks: taken, wrong modality, too short, past', () => {
  const input = { pathway: 'patient_rx', payment: 'self_pay', patient, order: { physicianName: 'Dr' }, selfPayAcknowledged: true };
  const ctx = { role: 'patient', practice, price: 1, uploads: { rx: {} } };
  assert.ok(D.validateReferral(input, { ...ctx, exam, slot: { ...slot, status: 'held' } }).some((e) => /just taken/.test(e)));
  assert.ok(D.validateReferral(input, { ...ctx, exam, slot: { ...slot, modality: 'CT' } }).some((e) => /different type/.test(e)));
  assert.ok(D.validateReferral(input, { ...ctx, exam: D.EXAM_BY_CODE['MRI-LSPINE-C'], slot }).some((e) => /too short/.test(e)));
  assert.ok(D.validateReferral(input, { ...ctx, exam, slot: { ...slot, starts_at: '2000-01-01T00:00:00Z' } }).some((e) => /passed/.test(e)));
});

test('screening flags only for yes answers and only contrast questions when contrast is used', () => {
  assert.deepEqual(D.evaluateScreening('MRI', false, { pacemaker: false, claustro: false }), []);
  assert.equal(D.evaluateScreening('MRI', false, { pacemaker: true }).length, 1);
  assert.equal(D.screeningQuestions('MRI', false).some((q) => q.id === 'kidney'), false);
  assert.equal(D.screeningQuestions('MRI', true).some((q) => q.id === 'kidney'), true);
  assert.deepEqual(D.screeningQuestions('US', false), []);
});

test('status transitions', () => {
  assert.ok(D.canTransition('pending_review', 'confirmed', 'practice'));
  assert.ok(!D.canTransition('pending_review', 'confirmed', 'submitter'));
  assert.ok(D.canTransition('pending_review', 'cancelled', 'submitter'));
  assert.ok(!D.canTransition('completed', 'cancelled', 'practice'));
  assert.ok(D.canTransition('needs_info', 'pending_review', 'submitter'));
});

test('zonedToUtc handles daylight saving time', () => {
  assert.equal(D.zonedToUtc('2026-07-01', '09:00', 'America/Chicago').toISOString(), '2026-07-01T14:00:00.000Z');
  assert.equal(D.zonedToUtc('2026-12-01', '09:00', 'America/Chicago').toISOString(), '2026-12-01T15:00:00.000Z');
});
