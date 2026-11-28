// Run: node corecut/test/calc.test.js
const assert = require('assert');
const C = require('../js/calc.js');
const K = require('../js/content.js');
let n = 0; const t = (name, fn) => { fn(); n++; console.log('ok', name); };

t('navy male matches published example', () => {
  // 178 cm, neck 38 cm, waist 86 cm -> about 17%
  const v = C.navyBodyFat({ sex: 'male', heightCm: 178, neckCm: 38, waistCm: 86 });
  assert(v > 15 && v < 19, v);
});
t('navy female needs hips', () => {
  assert.strictEqual(C.navyBodyFat({ sex: 'female', heightCm: 165, neckCm: 32, waistCm: 70 }), null);
  const v = C.navyBodyFat({ sex: 'female', heightCm: 165, neckCm: 32, waistCm: 70, hipCm: 97 });
  assert(v > 22 && v < 30, v);
});
t('rfm', () => {
  const v = C.rfmBodyFat({ sex: 'male', heightCm: 178, waistCm: 86 });
  assert(Math.abs(v - (64 - 20 * 178 / 86)) < 1e-9);
});
t('combine weights DEXA most', () => {
  const c = C.combineEstimates([{ value: 15, sd: 1.8 }, { value: 22, sd: 5 }]);
  assert(c.value > 15 && c.value < 17, c.value);
});
t('plan cut', () => {
  const p = C.buildPlan({ sex: 'male', age: 35, heightCm: 178, weightKg: 85, job: 'desk', days: 4, goal: 'sixpack', pace: 'steady' }, 20);
  assert.strictEqual(p.mode, 'cut');
  assert(p.kcal < p.tdee && p.kcal >= 1500, p.kcal);
  assert(Math.abs(p.targetWeight - 85 * 0.8 / 0.9) < 0.01);
  assert(p.weeksLow > 10 && p.weeksLow < 40, p.weeksLow);
  const m = p.macros; const kc = m.protein * 4 + m.carbs * 4 + m.fat * 9;
  assert(Math.abs(kc - p.kcal) < 40, kc + ' vs ' + p.kcal);
  console.log('   ', JSON.stringify({ kcal: p.kcal, tdee: Math.round(p.tdee), m, wk: [p.weeksLow, p.weeksHigh] }));
});
t('plan maintain when lean', () => {
  const p = C.buildPlan({ sex: 'female', age: 30, heightCm: 165, weightKg: 58, job: 'mixed', days: 3, goal: 'sixpack', pace: 'fast' }, 16);
  assert.strictEqual(p.mode, 'maintain');
});
t('plan floor for small female', () => {
  const p = C.buildPlan({ sex: 'female', age: 50, heightCm: 152, weightKg: 60, job: 'desk', days: 0, goal: 'shredded', pace: 'fast' }, 35);
  assert(p.kcal >= 1200, p.kcal);
});
t('plan blocks minors and pregnancy', () => {
  assert.strictEqual(C.buildPlan({ sex: 'male', age: 16, heightCm: 175, weightKg: 70, goal: 'sixpack' }, 18).mode, 'blocked');
  assert.strictEqual(C.buildPlan({ sex: 'female', age: 30, heightCm: 165, weightKg: 70, pregnant: true, goal: 'sixpack' }, 30).mode, 'blocked');
});
t('scaleDay hits kcal and protein', () => {
  const day = ['breakfast', 'lunch', 'snack', 'dinner'].flatMap(s => K.MEALS.omnivore[s][0].items);
  const r = C.scaleDay(K.FOODS, day, 2200, 180);
  assert(Math.abs(r.totals.kcal - 2200) < 150, r.totals.kcal);
  assert(Math.abs(r.totals.p - 180) < 20, r.totals.p);
  for (const style of Object.keys(K.MEALS)) for (const s of Object.keys(K.MEALS[style])) for (const meal of K.MEALS[style][s]) for (const it of meal.items) assert(K.FOODS[it.food], it.food);
});
t('trend and coach', () => {
  const now = C.parseISO('2026-03-01');
  const entries = [0, 7, 14, 21].map(d => ({ date: C.toISO(now - (21 - d) * C.DAY), weightKg: 85 - d / 7 * 0.6, waistCm: 90 - d / 7 * 0.5 }));
  const tr = C.trend(entries, 'weightKg', 28, now);
  assert(Math.abs(tr.slopePerWeek + 0.6) < 0.01, tr.slopePerWeek);
  const plan = C.buildPlan({ sex: 'male', age: 35, heightCm: 178, weightKg: 85, job: 'desk', days: 4, goal: 'sixpack', pace: 'steady' }, 20);
  const out = C.coach({ entries, plan, profile: { weightKg: 85 }, photos: [], streak: 4, nowMs: now, startISO: '2026-02-01' });
  assert(out.some(o => o.title === 'Right on pace'), JSON.stringify(out.map(o => o.title)));
});
t('streak', () => {
  const now = C.parseISO('2026-03-10');
  const c = {}; ['2026-03-07', '2026-03-08', '2026-03-09'].forEach(d => c[d] = { a: 1, b: 1, c: 1 });
  assert.strictEqual(C.streak(c, now, 3), 3);
});
t('every exercise referenced exists', () => {
  Object.values(K.WORKOUTS).forEach(w => w.main.concat(w.acc).forEach(e => assert(K.EXERCISES[e], e)));
  Object.values(K.AB_CIRCUITS).forEach(ph => ph.forEach(c => c.forEach(x => assert(K.EXERCISES[x[0]], x[0]))));
});
console.log(n + ' tests passed');
