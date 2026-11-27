'use strict';
// Pure business rules: exam catalog, referral pathways, payment rules,
// safety screening and status transitions. No I/O here so it is easy to test.

const MODALITIES = {
  MRI: { name: 'MRI', slotMinutes: 45 },
  CT: { name: 'CT', slotMinutes: 30 },
  US: { name: 'Ultrasound', slotMinutes: 30 },
  DEXA: { name: 'DEXA (bone density)', slotMinutes: 20 },
  XRAY: { name: 'X-ray', slotMinutes: 15 },
};

// code: internal exam code. cpt: CPT code most commonly billed for the exam.
// Prices are default self-pay (cash) prices in cents; practices override them.
const EXAMS = [
  // MRI
  { code: 'MRI-BRAIN', modality: 'MRI', name: 'MRI brain without contrast', cpt: '70551', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-BRAIN-C', modality: 'MRI', name: 'MRI brain with and without contrast', cpt: '70553', minutes: 60, contrast: true, price: 75000 },
  { code: 'MRI-CSPINE', modality: 'MRI', name: 'MRI cervical spine without contrast', cpt: '72141', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-TSPINE', modality: 'MRI', name: 'MRI thoracic spine without contrast', cpt: '72146', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-LSPINE', modality: 'MRI', name: 'MRI lumbar spine without contrast', cpt: '72148', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-LSPINE-C', modality: 'MRI', name: 'MRI lumbar spine with and without contrast', cpt: '72158', minutes: 60, contrast: true, price: 75000 },
  { code: 'MRI-SHOULDER', modality: 'MRI', name: 'MRI shoulder (upper extremity joint) without contrast', cpt: '73221', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-KNEE', modality: 'MRI', name: 'MRI knee/hip/ankle (lower extremity joint) without contrast', cpt: '73721', minutes: 45, contrast: false, price: 45000 },
  { code: 'MRI-PELVIS', modality: 'MRI', name: 'MRI pelvis without contrast', cpt: '72195', minutes: 45, contrast: false, price: 55000 },
  // CT
  { code: 'CT-HEAD', modality: 'CT', name: 'CT head without contrast', cpt: '70450', minutes: 15, contrast: false, price: 25000 },
  { code: 'CT-CSPINE', modality: 'CT', name: 'CT cervical spine without contrast', cpt: '72125', minutes: 15, contrast: false, price: 30000 },
  { code: 'CT-LSPINE', modality: 'CT', name: 'CT lumbar spine without contrast', cpt: '72131', minutes: 15, contrast: false, price: 30000 },
  { code: 'CT-CHEST', modality: 'CT', name: 'CT chest without contrast', cpt: '71250', minutes: 15, contrast: false, price: 30000 },
  { code: 'CT-LUNG-SCREEN', modality: 'CT', name: 'Low-dose CT lung cancer screening', cpt: '71271', minutes: 15, contrast: false, price: 15000 },
  { code: 'CT-ABDPEL', modality: 'CT', name: 'CT abdomen and pelvis without contrast', cpt: '74176', minutes: 20, contrast: false, price: 40000 },
  { code: 'CT-ABDPEL-C', modality: 'CT', name: 'CT abdomen and pelvis with contrast', cpt: '74177', minutes: 30, contrast: true, price: 50000 },
  // Ultrasound
  { code: 'US-ABD', modality: 'US', name: 'Ultrasound abdomen, complete', cpt: '76700', minutes: 30, contrast: false, price: 20000 },
  { code: 'US-PELVIS', modality: 'US', name: 'Ultrasound pelvis (non-OB), complete', cpt: '76856', minutes: 30, contrast: false, price: 20000 },
  { code: 'US-THYROID', modality: 'US', name: 'Ultrasound thyroid / soft tissue neck', cpt: '76536', minutes: 30, contrast: false, price: 17500 },
  { code: 'US-RENAL', modality: 'US', name: 'Ultrasound kidneys (retroperitoneal)', cpt: '76770', minutes: 30, contrast: false, price: 20000 },
  { code: 'US-CAROTID', modality: 'US', name: 'Carotid duplex ultrasound, bilateral', cpt: '93880', minutes: 30, contrast: false, price: 25000 },
  { code: 'US-VENOUS-LE', modality: 'US', name: 'Venous duplex ultrasound, legs, bilateral', cpt: '93970', minutes: 30, contrast: false, price: 25000 },
  // DEXA
  { code: 'DEXA-AXIAL', modality: 'DEXA', name: 'DEXA bone density, hips and spine', cpt: '77080', minutes: 20, contrast: false, price: 10000 },
  // X-ray
  { code: 'XR-CHEST', modality: 'XRAY', name: 'X-ray chest, 2 views', cpt: '71046', minutes: 15, contrast: false, price: 5000 },
  { code: 'XR-CSPINE', modality: 'XRAY', name: 'X-ray cervical spine, 2–3 views', cpt: '72040', minutes: 15, contrast: false, price: 7500 },
  { code: 'XR-LSPINE', modality: 'XRAY', name: 'X-ray lumbar spine, 2–3 views', cpt: '72100', minutes: 15, contrast: false, price: 7500 },
  { code: 'XR-SHOULDER', modality: 'XRAY', name: 'X-ray shoulder, 2+ views', cpt: '73030', minutes: 15, contrast: false, price: 6000 },
  { code: 'XR-KNEE', modality: 'XRAY', name: 'X-ray knee, 3 views', cpt: '73562', minutes: 15, contrast: false, price: 6000 },
  { code: 'XR-HIP', modality: 'XRAY', name: 'X-ray hip, 2–3 views', cpt: '73502', minutes: 15, contrast: false, price: 6000 },
  { code: 'XR-HAND', modality: 'XRAY', name: 'X-ray hand, 3+ views', cpt: '73130', minutes: 15, contrast: false, price: 5000 },
  { code: 'XR-FOOT', modality: 'XRAY', name: 'X-ray foot, 3+ views', cpt: '73630', minutes: 15, contrast: false, price: 5000 },
];
const EXAM_BY_CODE = Object.fromEntries(EXAMS.map((e) => [e.code, e]));

const PREP = {
  'US-ABD': 'Nothing to eat or drink for 8 hours before the exam. Take usual medicines with a sip of water.',
  'US-PELVIS': 'Drink 32 oz of water 1 hour before the exam and do not empty your bladder.',
  'US-RENAL': 'Drink 24 oz of water 1 hour before the exam.',
  'CT-ABDPEL-C': 'Nothing to eat for 4 hours before. You may be asked to drink oral contrast on arrival. Bring a recent kidney function (creatinine) result if you have one.',
  'MRI-BRAIN-C': 'Remove all metal. Bring a recent kidney function (creatinine) result if you have kidney disease.',
  'MRI-LSPINE-C': 'Remove all metal. Bring a recent kidney function (creatinine) result if you have kidney disease.',
  'DEXA-AXIAL': 'Do not take calcium supplements for 24 hours before. Wear clothes without metal zippers or buttons.',
};
const MODALITY_PREP = {
  MRI: 'Arrive 20 minutes early for safety screening. Leave jewelry at home. Tell staff about any implants, devices or metal in your body.',
  CT: 'Arrive 15 minutes early. Tell staff if you might be pregnant.',
  US: 'Arrive 10 minutes early. Wear comfortable, loose clothing.',
  DEXA: 'Arrive 10 minutes early. Tell staff if you had a barium study, CT contrast or nuclear medicine scan in the past 2 weeks.',
  XRAY: 'Arrive 10 minutes early. Tell staff if you might be pregnant.',
};
function prepFor(examCode) {
  const exam = EXAM_BY_CODE[examCode];
  if (!exam) return '';
  return [MODALITY_PREP[exam.modality], PREP[examCode]].filter(Boolean).join(' ');
}

// Safety screening questions. Answers are true/false. A "yes" never blocks a
// request on its own: it flags the request for the practice's technologist or
// radiologist to review before the scan, which is how screening works in practice.
const SCREENING = {
  MRI: [
    { id: 'pacemaker', q: 'Do you have a pacemaker, defibrillator (ICD) or loop recorder?', flag: 'Cardiac device: practice must confirm make/model is MR-conditional before scanning.' },
    { id: 'implant', q: 'Do you have any other implanted device (neurostimulator, cochlear implant, drug pump, aneurysm clip)?', flag: 'Implanted device: device card and MR-conditional status needed.' },
    { id: 'metal', q: 'Have you ever had metal in your eyes or body (metalwork, shrapnel, bullet)?', flag: 'Possible metal foreign body: may need screening X-ray of orbits.' },
    { id: 'surgery6w', q: 'Have you had surgery in the past 6 weeks?', flag: 'Recent surgery: confirm implant compatibility.' },
    { id: 'claustro', q: 'Are you claustrophobic?', flag: 'Claustrophobia: consider open or wide-bore MRI, or ask the ordering physician about anxiety medication.' },
    { id: 'pregnant', q: 'Are you pregnant or could you be pregnant?', flag: 'Possible pregnancy: radiologist review required.' },
    { id: 'kidney', q: 'Do you have kidney disease or dialysis?', flag: 'Kidney disease: creatinine/eGFR needed before gadolinium contrast.', contrastOnly: true },
    { id: 'gadoAllergy', q: 'Have you had a reaction to MRI contrast (gadolinium)?', flag: 'Prior contrast reaction: premedication review needed.', contrastOnly: true },
  ],
  CT: [
    { id: 'pregnant', q: 'Are you pregnant or could you be pregnant?', flag: 'Possible pregnancy: radiologist review required.' },
    { id: 'iodineAllergy', q: 'Have you had a reaction to CT/iodine contrast?', flag: 'Prior contrast reaction: premedication review needed.', contrastOnly: true },
    { id: 'kidney', q: 'Do you have kidney disease, or diabetes treated with metformin?', flag: 'Kidney risk: creatinine/eGFR needed before iodinated contrast.', contrastOnly: true },
  ],
  XRAY: [
    { id: 'pregnant', q: 'Are you pregnant or could you be pregnant?', flag: 'Possible pregnancy: confirm before exposure.' },
  ],
  DEXA: [
    { id: 'pregnant', q: 'Are you pregnant or could you be pregnant?', flag: 'Possible pregnancy: confirm before exposure.' },
    { id: 'recentContrast', q: 'Have you had a barium study, CT contrast or nuclear medicine scan in the past 2 weeks?', flag: 'Recent contrast/isotope: may interfere with results; consider rescheduling.' },
  ],
  US: [],
};
function screeningQuestions(modality, contrast) {
  return (SCREENING[modality] || []).filter((s) => !s.contrastOnly || contrast);
}
function evaluateScreening(modality, contrast, answers) {
  const flags = [];
  for (const s of screeningQuestions(modality, contrast)) {
    if (answers && answers[s.id] === true) flags.push(s.flag);
  }
  return flags;
}

const PATHWAYS = {
  physician: { label: 'Physician referral', roles: ['physician'], payments: ['insurance', 'self_pay', 'medical_legal'] },
  patient_rx: { label: 'Patient with a physician prescription', roles: ['patient'], payments: ['insurance', 'self_pay', 'medical_legal'] },
  patient_selfpay: { label: 'Patient self-pay', roles: ['patient'], payments: ['self_pay'] },
  attorney: { label: 'Medical-legal request', roles: ['attorney'], payments: ['medical_legal'] },
};
const PAYMENTS = { insurance: 'Insurance', self_pay: 'Self-pay (cash price)', medical_legal: 'Medical-legal (LOP / lien / workers’ comp)' };
const CASE_TYPES = {
  auto: 'Auto accident (personal injury)',
  premises: 'Slip and fall / premises liability',
  personal_injury: 'Other personal injury',
  workers_comp: 'Workers’ compensation',
  ime: 'Independent medical exam (IME) imaging',
};
const LEGAL_SERVICES = {
  lop: 'Letters of protection (LOP) / liens accepted',
  expedited_read: 'Expedited radiologist read (24–48 h)',
  narrative: 'Narrative report for counsel',
  records: 'Certified records and images on disc/portal',
  deposition: 'Radiologist available for deposition / testimony',
};

// NPI check digit: Luhn over "80840" + first 9 digits.
function isValidNpi(npi) {
  if (!/^\d{10}$/.test(String(npi || ''))) return false;
  const digits = ('80840' + npi.slice(0, 9)).split('').map(Number);
  let sum = 0;
  for (let i = digits.length - 1, dbl = true; i >= 0; i--, dbl = !dbl) {
    let d = digits[i];
    if (dbl) { d *= 2; if (d > 9) d -= 9; }
    sum += d;
  }
  return (10 - (sum % 10)) % 10 === Number(npi[9]);
}
function isValidIcd10(code) {
  return /^[A-TV-Z][0-9][0-9A-Z](\.?[0-9A-Z]{1,4})?$/i.test(String(code || '').trim());
}

function blank(v) { return v === undefined || v === null || String(v).trim() === ''; }

// Validate a referral request. ctx: { role, exam, practice, slot, price, uploads, today }
// Returns an array of human-readable errors (empty = valid).
function validateReferral(input, ctx) {
  const errors = [];
  const pathway = PATHWAYS[input.pathway];
  if (!pathway) return ['Choose how this scan is being requested.'];
  if (!pathway.roles.includes(ctx.role)) errors.push(`A ${ctx.role} account cannot submit a "${pathway.label}".`);
  if (!pathway.payments.includes(input.payment)) errors.push(`${PAYMENTS[input.payment] || 'That payment option'} is not available for a ${pathway.label.toLowerCase()}.`);

  const exam = ctx.exam;
  if (!exam) errors.push('Choose an exam.');
  const practice = ctx.practice;
  if (!practice) errors.push('Choose an imaging practice.');

  if (exam && practice && !practice.modalities.includes(exam.modality)) errors.push(`${practice.name} does not offer ${MODALITIES[exam.modality].name}.`);
  if (ctx.slot) {
    if (ctx.slot.status !== 'open') errors.push('That time was just taken. Please choose another time.');
    if (exam && ctx.slot.modality !== exam.modality) errors.push('That time is for a different type of scan.');
    if (exam && ctx.slot.duration_min < exam.minutes) errors.push('That time is too short for this exam. Choose a longer slot.');
    if (practice && ctx.slot.practice_id !== practice.id) errors.push('That time belongs to a different practice.');
    if (new Date(ctx.slot.starts_at) < (ctx.now || new Date())) errors.push('That time has already passed.');
  } else if (input.pathway !== 'physician') {
    errors.push('Choose an appointment time.');
  }

  const p = input.patient || {};
  if (blank(p.firstName) || blank(p.lastName)) errors.push('Patient first and last name are required.');
  if (blank(p.dob) || isNaN(Date.parse(p.dob)) || new Date(p.dob) > (ctx.now || new Date())) errors.push('A valid patient date of birth is required.');
  if (blank(p.phone)) errors.push('Patient phone number is required.');

  const o = input.order || {};
  const uploads = ctx.uploads || {};
  if (input.pathway === 'physician') {
    if (!isValidNpi(o.npi)) errors.push('A valid 10-digit ordering physician NPI is required.');
    if (blank(o.indication)) errors.push('Clinical indication is required.');
    const codes = (o.icd10 || []).filter((c) => !blank(c));
    if (codes.length === 0) errors.push('At least one ICD-10 diagnosis code is required.');
    for (const c of codes) if (!isValidIcd10(c)) errors.push(`"${c}" is not a valid ICD-10 code format.`);
  } else if (input.pathway === 'patient_rx' || input.pathway === 'attorney') {
    if (!uploads.rx) errors.push('Upload the physician prescription (order) for this scan.');
    if (blank(o.physicianName)) errors.push('Ordering physician name is required.');
    if (!blank(o.npi) && !isValidNpi(o.npi)) errors.push('The ordering physician NPI is not valid.');
  } else if (input.pathway === 'patient_selfpay') {
    if (!uploads.rx) {
      if (practice && !practice.offers_order_review) errors.push(`${practice.name} needs a physician order for self-pay scans. Upload an order or choose a practice that offers physician order review.`);
      if (blank(o.reason)) errors.push('Describe why you want this scan so the reviewing physician can approve it.');
    }
  }

  if (input.payment === 'insurance') {
    const ins = input.insurance || {};
    if (practice && !practice.accepts_insurance) errors.push(`${practice.name} does not bill insurance.`);
    if (blank(ins.carrier) || blank(ins.memberId)) errors.push('Insurance carrier and member ID are required.');
  } else if (input.payment === 'self_pay') {
    if (practice && !practice.accepts_self_pay) errors.push(`${practice.name} does not offer self-pay.`);
    if (exam && practice && !(ctx.price > 0)) errors.push('This practice has not published a self-pay price for that exam.');
    if (!input.selfPayAcknowledged) errors.push('Please acknowledge the self-pay price and terms.');
  } else if (input.payment === 'medical_legal') {
    const l = input.legal || {};
    if (practice && !practice.accepts_medical_legal) errors.push(`${practice.name} does not accept medical-legal cases.`);
    if (!CASE_TYPES[l.caseType]) errors.push('Choose the case type.');
    if (blank(l.injuryDate) || isNaN(Date.parse(l.injuryDate)) || new Date(l.injuryDate) > (ctx.now || new Date())) errors.push('A valid date of injury is required.');
    if (blank(l.attorneyName) && l.caseType !== 'workers_comp') errors.push('Attorney name is required.');
    if (l.caseType === 'workers_comp') {
      if (blank(l.claimNumber) || blank(l.carrier)) errors.push('Workers’ comp claim number and carrier are required.');
    } else {
      if (blank(l.attorneyPhone) && blank(l.attorneyEmail)) errors.push('Attorney phone or email is required.');
      if (!uploads.lop) errors.push('Upload the letter of protection (LOP) or lien agreement.');
    }
  }
  return errors;
}

// Status machine. Each entry: target -> roles allowed.
const STATUS_LABELS = {
  awaiting_scheduling: 'Awaiting scheduling',
  pending_review: 'Pending practice review',
  needs_info: 'More information needed',
  confirmed: 'Confirmed',
  declined: 'Declined',
  cancelled: 'Cancelled',
  completed: 'Completed',
  no_show: 'No-show',
};
const TRANSITIONS = {
  awaiting_scheduling: { confirmed: ['practice'], needs_info: ['practice'], declined: ['practice'], cancelled: ['submitter'] },
  pending_review: { confirmed: ['practice'], needs_info: ['practice'], declined: ['practice'], cancelled: ['submitter'] },
  needs_info: { pending_review: ['submitter', 'practice'], declined: ['practice'], cancelled: ['submitter'] },
  confirmed: { completed: ['practice'], no_show: ['practice'], cancelled: ['submitter', 'practice'] },
  declined: {}, cancelled: {}, completed: {}, no_show: {},
};
function canTransition(from, to, actor) {
  return !!(TRANSITIONS[from] && TRANSITIONS[from][to] && TRANSITIONS[from][to].includes(actor));
}

function haversineMiles(a, b) {
  const R = 3958.8, rad = Math.PI / 180;
  const dLat = (b.lat - a.lat) * rad, dLon = (b.lon - a.lon) * rad;
  const x = Math.sin(dLat / 2) ** 2 + Math.cos(a.lat * rad) * Math.cos(b.lat * rad) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(x));
}

// Convert a wall-clock date/time in an IANA time zone to a UTC Date.
function zonedToUtc(date, time, tz) {
  const [y, m, d] = date.split('-').map(Number);
  const [hh, mm] = time.split(':').map(Number);
  const target = Date.UTC(y, m - 1, d, hh, mm);
  let guess = target;
  for (let i = 0; i < 3; i++) {
    const parts = Object.fromEntries(new Intl.DateTimeFormat('en-US', {
      timeZone: tz, hourCycle: 'h23', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',
    }).formatToParts(new Date(guess)).map((p) => [p.type, p.value]));
    const asWall = Date.UTC(+parts.year, +parts.month - 1, +parts.day, +parts.hour, +parts.minute);
    guess += target - asWall;
  }
  return new Date(guess);
}

module.exports = {
  MODALITIES, EXAMS, EXAM_BY_CODE, SCREENING, PATHWAYS, PAYMENTS, CASE_TYPES, LEGAL_SERVICES, STATUS_LABELS, TRANSITIONS,
  prepFor, screeningQuestions, evaluateScreening, isValidNpi, isValidIcd10, validateReferral, canTransition,
  haversineMiles, zonedToUtc,
};
