'use strict';
const path = require('node:path');
const fs = require('node:fs');
const { DatabaseSync } = require('node:sqlite');
const { EXAMS, MODALITIES, zonedToUtc } = require('./domain');
const { hashPassword } = require('./auth');

const SCHEMA = `
CREATE TABLE IF NOT EXISTS practices (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL, address TEXT, city TEXT, state TEXT, zip TEXT,
  lat REAL, lon REAL, tz TEXT NOT NULL DEFAULT 'America/Chicago',
  phone TEXT, email TEXT, hours TEXT, accreditation TEXT, description TEXT,
  modalities TEXT NOT NULL DEFAULT '[]',     -- JSON array of modality keys
  equipment TEXT NOT NULL DEFAULT '[]',      -- JSON array of strings e.g. "3T MRI", "Open MRI"
  accepts_insurance INTEGER NOT NULL DEFAULT 1, insurance_notes TEXT,
  accepts_self_pay INTEGER NOT NULL DEFAULT 1,
  accepts_medical_legal INTEGER NOT NULL DEFAULT 0,
  legal_services TEXT NOT NULL DEFAULT '[]', -- JSON array of LEGAL_SERVICES keys
  offers_order_review INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS prices (
  practice_id INTEGER NOT NULL REFERENCES practices(id), exam_code TEXT NOT NULL, price_cents INTEGER NOT NULL,
  PRIMARY KEY (practice_id, exam_code)
);
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY, email TEXT NOT NULL UNIQUE COLLATE NOCASE, password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('patient','physician','attorney','practice')),
  name TEXT NOT NULL, phone TEXT, npi TEXT, organization TEXT,
  practice_id INTEGER REFERENCES practices(id), created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY, user_id INTEGER NOT NULL REFERENCES users(id), expires_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS slots (
  id INTEGER PRIMARY KEY, practice_id INTEGER NOT NULL REFERENCES practices(id),
  modality TEXT NOT NULL, equipment TEXT, starts_at TEXT NOT NULL, duration_min INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','held','booked')), created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS slots_search ON slots (modality, status, starts_at);
CREATE INDEX IF NOT EXISTS slots_practice ON slots (practice_id, starts_at);
CREATE TABLE IF NOT EXISTS referrals (
  id INTEGER PRIMARY KEY, ref_code TEXT NOT NULL UNIQUE, created_by INTEGER NOT NULL REFERENCES users(id),
  pathway TEXT NOT NULL, payment TEXT NOT NULL, status TEXT NOT NULL, priority TEXT NOT NULL DEFAULT 'routine',
  practice_id INTEGER NOT NULL REFERENCES practices(id), slot_id INTEGER REFERENCES slots(id),
  exam_code TEXT NOT NULL, modality TEXT NOT NULL,
  patient_json TEXT NOT NULL, order_json TEXT NOT NULL, insurance_json TEXT, legal_json TEXT,
  screening_json TEXT, flags_json TEXT NOT NULL DEFAULT '[]', price_cents INTEGER,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS referrals_practice ON referrals (practice_id, status);
CREATE INDEX IF NOT EXISTS referrals_creator ON referrals (created_by);
CREATE TABLE IF NOT EXISTS referral_events (
  id INTEGER PRIMARY KEY, referral_id INTEGER NOT NULL REFERENCES referrals(id), user_id INTEGER REFERENCES users(id),
  kind TEXT NOT NULL, status TEXT, text TEXT, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS uploads (
  id TEXT PRIMARY KEY, owner_id INTEGER NOT NULL REFERENCES users(id), referral_id INTEGER REFERENCES referrals(id),
  kind TEXT, filename TEXT NOT NULL, content_type TEXT NOT NULL, size INTEGER NOT NULL, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS audit (
  id INTEGER PRIMARY KEY, user_id INTEGER, action TEXT NOT NULL, entity TEXT, entity_id TEXT, ip TEXT, at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS zips (zip TEXT PRIMARY KEY, lat REAL NOT NULL, lon REAL NOT NULL, city TEXT, state TEXT);
`;

// Approximate ZIP centroids for the demo area. Replace with a full ZIP/geocoding source in production.
const ZIPS = [
  ['75201', 32.787, -96.799, 'Dallas', 'TX'], ['75204', 32.803, -96.786, 'Dallas', 'TX'], ['75230', 32.900, -96.791, 'Dallas', 'TX'],
  ['75243', 32.910, -96.729, 'Dallas', 'TX'], ['75024', 33.075, -96.784, 'Plano', 'TX'], ['75093', 33.035, -96.807, 'Plano', 'TX'],
  ['75062', 32.847, -96.974, 'Irving', 'TX'], ['76011', 32.758, -97.100, 'Arlington', 'TX'], ['76102', 32.754, -97.330, 'Fort Worth', 'TX'],
  ['75040', 32.928, -96.620, 'Garland', 'TX'], ['75069', 33.196, -96.612, 'McKinney', 'TX'], ['75007', 33.004, -96.880, 'Carrollton', 'TX'],
  ['75150', 32.815, -96.630, 'Mesquite', 'TX'], ['75019', 32.967, -96.983, 'Coppell', 'TX'], ['75080', 32.966, -96.746, 'Richardson', 'TX'],
];

// All practices below are fictional demo data.
const PRACTICES = [
  { name: 'Uptown Imaging Center', address: '2100 McKinney Ave, Suite 120', city: 'Dallas', zip: '75201', lat: 32.792, lon: -96.803,
    phone: '(214) 555-0140', email: 'scheduling@uptownimaging.example', hours: 'Mon–Fri 7am–8pm, Sat 8am–2pm', accreditation: 'ACR accredited: MRI, CT, Ultrasound',
    description: 'Full-service outpatient imaging with a 3T MRI and same-day reads for urgent studies.',
    modalities: ['MRI', 'CT', 'US', 'XRAY'], equipment: ['3T MRI', '1.5T wide-bore MRI', '128-slice CT'],
    accepts_insurance: 1, insurance_notes: 'Most PPO plans, Medicare, Aetna, BCBS TX, Cigna, UnitedHealthcare', accepts_self_pay: 1,
    accepts_medical_legal: 1, legal_services: ['lop', 'expedited_read', 'narrative', 'records', 'deposition'], offers_order_review: 0, priceFactor: 1.15 },
  { name: 'North Dallas Open MRI', address: '7700 Forest Ln, Suite 200', city: 'Dallas', zip: '75230', lat: 32.909, lon: -96.770,
    phone: '(972) 555-0177', email: 'hello@ndopenmri.example', hours: 'Mon–Sat 7am–9pm', accreditation: 'ACR accredited: MRI',
    description: 'High-field open MRI for claustrophobic and larger patients (table limit 550 lb).',
    modalities: ['MRI', 'XRAY'], equipment: ['Open MRI (1.2T)', 'Wide-bore MRI'],
    accepts_insurance: 1, insurance_notes: 'Medicare, BCBS TX, Aetna, Humana', accepts_self_pay: 1,
    accepts_medical_legal: 1, legal_services: ['lop', 'expedited_read', 'records'], offers_order_review: 1, priceFactor: 0.9 },
  { name: 'Plano Diagnostic Radiology', address: '4500 W Plano Pkwy', city: 'Plano', zip: '75093', lat: 33.030, lon: -96.815,
    phone: '(469) 555-0102', email: 'frontdesk@planodx.example', hours: 'Mon–Fri 7:30am–6pm', accreditation: 'ACR accredited: CT, Ultrasound, Breast Imaging',
    description: 'Community imaging: CT, ultrasound, DEXA and digital X-ray, with walk-in X-ray.',
    modalities: ['CT', 'US', 'DEXA', 'XRAY'], equipment: ['64-slice low-dose CT', 'Hologic DEXA'],
    accepts_insurance: 1, insurance_notes: 'Medicare, Medicaid, most commercial plans', accepts_self_pay: 1,
    accepts_medical_legal: 0, legal_services: [], offers_order_review: 0, priceFactor: 1.0 },
  { name: 'ClearPrice Imaging', address: '1300 W Walnut Hill Ln', city: 'Irving', zip: '75062', lat: 32.873, lon: -96.960,
    phone: '(972) 555-0199', email: 'book@clearprice.example', hours: 'Mon–Sun 6am–10pm', accreditation: 'ACR accredited: MRI, CT',
    description: 'Cash-price imaging with published all-inclusive prices (scan + radiologist read). Physician order review available for self-pay patients.',
    modalities: ['MRI', 'CT', 'US', 'DEXA', 'XRAY'], equipment: ['1.5T MRI', '64-slice CT'],
    accepts_insurance: 0, insurance_notes: 'Self-pay and medical-legal only', accepts_self_pay: 1,
    accepts_medical_legal: 1, legal_services: ['lop', 'expedited_read', 'narrative', 'records'], offers_order_review: 1, priceFactor: 0.7 },
  { name: 'Arlington Spine & Joint Imaging', address: '901 N Cooper St', city: 'Arlington', zip: '76011', lat: 32.746, lon: -97.110,
    phone: '(817) 555-0123', email: 'imaging@asjimaging.example', hours: 'Mon–Fri 7am–7pm, Sat 8am–12pm', accreditation: 'ACR accredited: MRI, CT',
    description: 'Musculoskeletal and spine imaging with fellowship-trained MSK radiologists. Personal injury and workers’ comp friendly.',
    modalities: ['MRI', 'CT', 'XRAY'], equipment: ['3T MRI', 'Upright X-ray (flexion/extension)'],
    accepts_insurance: 1, insurance_notes: 'Workers’ comp carriers, BCBS TX, UHC, Cigna', accepts_self_pay: 1,
    accepts_medical_legal: 1, legal_services: ['lop', 'expedited_read', 'narrative', 'records', 'deposition'], offers_order_review: 0, priceFactor: 1.05 },
  { name: 'Fort Worth Women’s & Family Imaging', address: '800 W Magnolia Ave', city: 'Fort Worth', zip: '76102', lat: 32.730, lon: -97.333,
    phone: '(817) 555-0166', email: 'schedule@fwfamilyimaging.example', hours: 'Mon–Fri 8am–5pm', accreditation: 'ACR accredited: Ultrasound',
    description: 'Ultrasound, DEXA and X-ray in a calm, family-friendly setting.',
    modalities: ['US', 'DEXA', 'XRAY'], equipment: ['GE Logiq ultrasound', 'GE Lunar DEXA'],
    accepts_insurance: 1, insurance_notes: 'Medicare, Medicaid, most commercial plans', accepts_self_pay: 1,
    accepts_medical_legal: 0, legal_services: [], offers_order_review: 0, priceFactor: 0.95 },
];

const DEMO_PASSWORD = 'demo1234';
const DEMO_USERS = [
  { email: 'patient@demo.test', role: 'patient', name: 'Jordan Patient', phone: '(214) 555-0101' },
  { email: 'doctor@demo.test', role: 'physician', name: 'Dr. Alex Rivera', phone: '(214) 555-0102', npi: '1234567893', organization: 'Rivera Spine & Pain Clinic' },
  { email: 'attorney@demo.test', role: 'attorney', name: 'Casey Morgan', phone: '(214) 555-0103', organization: 'Morgan Injury Law (demo)' },
  { email: 'uptown@demo.test', role: 'practice', name: 'Uptown Scheduling Desk', practiceIndex: 0 },
  { email: 'clearprice@demo.test', role: 'practice', name: 'ClearPrice Front Desk', practiceIndex: 3 },
];

function openDb(file) {
  if (file !== ':memory:') fs.mkdirSync(path.dirname(file), { recursive: true });
  const db = new DatabaseSync(file);
  db.exec('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;');
  db.exec(SCHEMA);
  return db;
}

function tx(db, fn) {
  db.exec('BEGIN IMMEDIATE');
  try { const r = fn(); db.exec('COMMIT'); return r; } catch (e) { db.exec('ROLLBACK'); throw e; }
}

function localDateString(d, tz) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
}

// Generate open slots for the next `days` days within business hours.
function seedSlots(db, practiceId, modalities, equipment, tz, days, rand) {
  const insert = db.prepare('INSERT INTO slots (practice_id, modality, equipment, starts_at, duration_min, status, created_at) VALUES (?,?,?,?,?,?,?)');
  const now = new Date();
  const created = now.toISOString();
  for (let day = 0; day < days; day++) {
    const date = localDateString(new Date(now.getTime() + day * 86400000), tz);
    const weekday = new Date(date + 'T12:00:00Z').getUTCDay();
    if (weekday === 0) continue; // closed Sundays in the demo
    const endHour = weekday === 6 ? 13 : 18;
    for (const m of modalities) {
      const step = MODALITIES[m].slotMinutes;
      const equip = m === 'MRI' ? equipment.find((e) => /MRI/i.test(e)) || null : m === 'CT' ? equipment.find((e) => /CT/i.test(e)) || null : null;
      for (let mins = 7 * 60; mins + step <= endHour * 60; mins += step) {
        if (rand() > 0.3) continue; // most of the day is already booked
        const hh = String(Math.floor(mins / 60)).padStart(2, '0'), mm = String(mins % 60).padStart(2, '0');
        const start = zonedToUtc(date, `${hh}:${mm}`, tz);
        if (start <= now) continue;
        // MRI slots of 60 minutes are needed for contrast studies; make some double-length.
        const duration = m === 'MRI' && rand() < 0.35 ? 60 : step;
        insert.run(practiceId, m, equip, start.toISOString(), duration, 'open', created);
      }
    }
  }
}

function seed(db, { days = 14 } = {}) {
  const count = db.prepare('SELECT COUNT(*) AS n FROM practices').get().n;
  if (count > 0) return false;
  let s = 42; const rand = () => ((s = (s * 1103515245 + 12345) % 2147483648) / 2147483648);
  tx(db, () => {
    const zipIns = db.prepare('INSERT OR IGNORE INTO zips (zip, lat, lon, city, state) VALUES (?,?,?,?,?)');
    for (const z of ZIPS) zipIns.run(...z);
    const pIns = db.prepare(`INSERT INTO practices (name,address,city,state,zip,lat,lon,tz,phone,email,hours,accreditation,description,modalities,equipment,
      accepts_insurance,insurance_notes,accepts_self_pay,accepts_medical_legal,legal_services,offers_order_review) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`);
    const priceIns = db.prepare('INSERT INTO prices (practice_id, exam_code, price_cents) VALUES (?,?,?)');
    const ids = [];
    for (const p of PRACTICES) {
      const r = pIns.run(p.name, p.address, p.city, 'TX', p.zip, p.lat, p.lon, 'America/Chicago', p.phone, p.email, p.hours, p.accreditation, p.description,
        JSON.stringify(p.modalities), JSON.stringify(p.equipment), p.accepts_insurance, p.insurance_notes, p.accepts_self_pay, p.accepts_medical_legal,
        JSON.stringify(p.legal_services), p.offers_order_review);
      const id = Number(r.lastInsertRowid);
      ids.push(id);
      for (const e of EXAMS) if (p.modalities.includes(e.modality)) priceIns.run(id, e.code, Math.round((e.price * p.priceFactor) / 500) * 500);
      seedSlots(db, id, p.modalities, p.equipment, 'America/Chicago', days, rand);
    }
    const uIns = db.prepare('INSERT INTO users (email,password_hash,role,name,phone,npi,organization,practice_id,created_at) VALUES (?,?,?,?,?,?,?,?,?)');
    const hash = hashPassword(DEMO_PASSWORD);
    for (const u of DEMO_USERS) {
      uIns.run(u.email, hash, u.role, u.name, u.phone || null, u.npi || null, u.organization || null,
        u.practiceIndex !== undefined ? ids[u.practiceIndex] : null, new Date().toISOString());
    }
  });
  return true;
}

module.exports = { openDb, seed, tx, DEMO_PASSWORD, DEMO_USERS };
