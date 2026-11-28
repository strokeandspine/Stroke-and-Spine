/* CoreCut calculation engine. Pure functions, no DOM. Works in the browser (window.Calc) and in Node (require). */
(function (root) {
  'use strict';

  var KCAL_PER_KG = 7700; // energy in ~1 kg of body-fat tissue
  var DAY = 86400000;

  function clamp(x, a, b) { return Math.min(b, Math.max(a, x)); }
  function round(x, step) { step = step || 1; return Math.round(x / step) * step; }
  function log10(x) { return Math.log(x) / Math.LN10; }

  var units = {
    cmToIn: function (cm) { return cm / 2.54; },
    inToCm: function (i) { return i * 2.54; },
    kgToLb: function (kg) { return kg * 2.2046226; },
    lbToKg: function (lb) { return lb / 2.2046226; }
  };

  /* ---------- Body-fat estimates ---------- */

  // US Navy circumference method (Hodgdon & Beckett), metric form. Men: waist at navel. Women: waist at narrowest, hips at widest.
  function navyBodyFat(p) {
    var h = p.heightCm, n = p.neckCm, w = p.waistCm, hip = p.hipCm, v;
    if (!h || !n || !w) return null;
    if (p.sex === 'female') {
      if (!hip) return null;
      var d = w + hip - n;
      if (d <= 0) return null;
      v = 495 / (1.29579 - 0.35004 * log10(d) + 0.22100 * log10(h)) - 450;
    } else {
      var dm = w - n;
      if (dm <= 0) return null;
      v = 495 / (1.0324 - 0.19077 * log10(dm) + 0.15456 * log10(h)) - 450;
    }
    if (!isFinite(v) || v < 2 || v > 65) return null;
    return v;
  }

  // Relative Fat Mass (Woolcott & Bergman 2018): 64 - 20 x (height / waist) + 12 x female.
  function rfmBodyFat(p) {
    if (!p.heightCm || !p.waistCm) return null;
    var v = 64 - 20 * (p.heightCm / p.waistCm) + (p.sex === 'female' ? 12 : 0);
    if (!isFinite(v) || v < 2 || v > 65) return null;
    return v;
  }

  // Deurenberg BMI equation. Weak; only used when nothing else exists.
  function bmiBodyFat(p) {
    if (!p.heightCm || !p.weightKg || !p.age) return null;
    var bmi = p.weightKg / Math.pow(p.heightCm / 100, 2);
    var v = 1.2 * bmi + 0.23 * p.age - 10.8 * (p.sex === 'female' ? 0 : 1) - 5.4;
    return clamp(v, 3, 60);
  }

  function bmi(p) { return p.weightKg / Math.pow(p.heightCm / 100, 2); }

  // Typical error (1 SD, body-fat percentage points) used for inverse-variance weighting.
  var TEST_METHODS = {
    dexa: { label: 'DEXA scan', sd: 1.8 },
    hydrostatic: { label: 'Hydrostatic (underwater) weighing', sd: 2.2 },
    bodpod: { label: 'Bod Pod', sd: 2.5 },
    bia_clinic: { label: 'Clinic bioimpedance (InBody or similar)', sd: 3.5 },
    calipers: { label: 'Skinfold calipers (trained tester)', sd: 3.5 },
    smart_scale: { label: 'Home smart scale', sd: 5 }
  };
  var ESTIMATE_SD = { navy: 3.5, rfm: 4, visual: 3.5, bmi: 6 };

  // Visual self-assessment levels. Ranges are % body fat.
  var VISUAL_LEVELS = {
    male: [
      { id: 'm1', lo: 6, hi: 8, title: 'Very lean', desc: 'Every ab segment is sharp in most light. Veins on the lower belly and arms. Obliques and serratus visible.' },
      { id: 'm2', lo: 9, hi: 11, title: 'Lean, clear six-pack', desc: 'Six-pack visible standing relaxed. Clear line down the middle. A little softness at the lowest abs.' },
      { id: 'm3', lo: 12, hi: 14, title: 'Fit, ab outline', desc: 'Top two or four abs show in good overhead light, especially when flexed. Small pinch at the sides.' },
      { id: 'm4', lo: 15, hi: 18, title: 'Athletic but soft', desc: 'Flat-ish stomach with no clear ab lines. Some love handles. Muscle shape shows in the arms and shoulders.' },
      { id: 'm5', lo: 19, hi: 23, title: 'Average', desc: 'Smooth stomach that rounds slightly when relaxed. Noticeable love handles. Waist about as wide as the chest.' },
      { id: 'm6', lo: 24, hi: 29, title: 'Above average', desc: 'Belly rounds forward and overhangs the belt a little when sitting. Waist wider than the chest.' },
      { id: 'm7', lo: 30, hi: 36, title: 'High', desc: 'Belly clearly overhangs the belt. Fat around the chest, back and neck. Waist is the widest part of the torso.' }
    ],
    female: [
      { id: 'f1', lo: 14, hi: 16, title: 'Very lean', desc: 'Clear ab segments and obliques. Little fat on hips and thighs. Muscle separation in the shoulders and legs.' },
      { id: 'f2', lo: 17, hi: 19, title: 'Lean, ab definition', desc: 'Visible ab lines and a deep midline. Some curve at the hips. Defined arms and shoulders.' },
      { id: 'f3', lo: 20, hi: 23, title: 'Fit, ab outline', desc: 'Flat stomach with a faint midline and upper-ab shape in good light. Gentle curve at hips and thighs.' },
      { id: 'f4', lo: 24, hi: 27, title: 'Athletic but soft', desc: 'Flat-ish stomach, no ab lines. Softer hips and thighs. Healthy and common for active women.' },
      { id: 'f5', lo: 28, hi: 31, title: 'Average', desc: 'Some fat below the navel. Fuller hips, thighs and upper arms. Little muscle definition.' },
      { id: 'f6', lo: 32, hi: 37, title: 'Above average', desc: 'Lower belly rounds forward. Fat on hips, thighs, back and upper arms is clearly visible.' },
      { id: 'f7', lo: 38, hi: 45, title: 'High', desc: 'Belly overhangs the waistband. Waist close to or wider than the hips. Fat on the back and arms.' }
    ]
  };

  function visualBodyFat(sex, levelId) {
    var list = VISUAL_LEVELS[sex === 'female' ? 'female' : 'male'];
    for (var i = 0; i < list.length; i++) if (list[i].id === levelId) return (list[i].lo + list[i].hi) / 2;
    return null;
  }

  // Combine any number of estimates by inverse-variance weighting.
  // items: [{source, label, value, sd}] -> {value, sd, low, high, items}
  function combineEstimates(items) {
    var valid = items.filter(function (x) { return x && isFinite(x.value) && x.sd > 0; });
    if (!valid.length) return null;
    var sw = 0, swv = 0;
    valid.forEach(function (x) { var w = 1 / (x.sd * x.sd); sw += w; swv += w * x.value; });
    var value = swv / sw;
    var sd = Math.sqrt(1 / sw);
    // If sources disagree a lot, widen the range to reflect that.
    var spread = 0;
    valid.forEach(function (x) { spread = Math.max(spread, Math.abs(x.value - value)); });
    var half = Math.max(1.5, sd, valid.length > 1 ? spread * 0.6 : 0);
    return { value: value, sd: sd, low: Math.max(3, value - half), high: value + half, items: valid };
  }

  // Gather every estimate available for one person at one moment.
  // ctx: {sex, age, heightCm, weightKg, neckCm, waistCm, hipCm, test:{method,value}, visualLevel}
  function estimateBodyFat(ctx) {
    var items = [];
    if (ctx.test && TEST_METHODS[ctx.test.method] && isFinite(ctx.test.value)) {
      items.push({ source: 'test', label: TEST_METHODS[ctx.test.method].label, value: +ctx.test.value, sd: TEST_METHODS[ctx.test.method].sd });
    }
    var navy = navyBodyFat(ctx);
    if (navy != null) items.push({ source: 'navy', label: 'Tape measure (US Navy method)', value: navy, sd: ESTIMATE_SD.navy });
    var rfm = rfmBodyFat(ctx);
    if (rfm != null) items.push({ source: 'rfm', label: 'Height-to-waist (RFM)', value: rfm, sd: ESTIMATE_SD.rfm });
    var vis = ctx.visualLevel ? visualBodyFat(ctx.sex, ctx.visualLevel) : null;
    if (vis != null) items.push({ source: 'visual', label: 'Visual check', value: vis, sd: ESTIMATE_SD.visual });
    if (!items.length) {
      var b = bmiBodyFat(ctx);
      if (b != null) items.push({ source: 'bmi', label: 'BMI equation (rough)', value: b, sd: ESTIMATE_SD.bmi });
    }
    return combineEstimates(items);
  }

  /* ---------- Plan ---------- */

  var GOALS = {
    outline: { label: 'Ab outline', male: 13, female: 21, desc: 'Upper abs and the midline show in good light. Easy to keep year-round.' },
    sixpack: { label: 'Clear six-pack', male: 10, female: 17, desc: 'Abs visible standing relaxed. The classic goal. Takes steady effort to hold.' },
    shredded: { label: 'Shredded', male: 8, female: 14, desc: 'Photo-shoot lean. Fine for a short peak; hard on energy, hormones and mood if held long.' }
  };

  var JOB = {
    desk: { label: 'Mostly sitting (desk job)', factor: 1.25 },
    mixed: { label: 'On my feet part of the day', factor: 1.38 },
    active: { label: 'On my feet most of the day', factor: 1.5 },
    physical: { label: 'Hard physical work', factor: 1.65 }
  };

  var PACE = {
    gentle: { label: 'Gentle', pct: 0.5, desc: 'About 0.5% of body weight a week. Easiest to stick with and keeps the most muscle.' },
    steady: { label: 'Steady', pct: 0.75, desc: 'About 0.75% a week. A good balance for most people.' },
    fast: { label: 'Fast', pct: 1.0, desc: 'About 1% a week. Harder; best if you have more fat to lose.' }
  };

  var CAL_FLOOR = { male: 1500, female: 1200 };

  // profile: {sex, age, heightCm, weightKg, job, days, goal, pace, pregnant}
  // bf: % body fat (number)
  function buildPlan(profile, bf) {
    var sex = profile.sex === 'female' ? 'female' : 'male';
    var w = profile.weightKg;
    var warnings = [];
    var goal = GOALS[profile.goal] || GOALS.sixpack;
    var targetBf = goal[sex];
    var lbm = w * (1 - bf / 100);
    var bmr = 370 + 21.6 * lbm; // Katch-McArdle
    var factor = (JOB[profile.job] || JOB.desk).factor + 0.03 * clamp(profile.days || 3, 0, 7);
    var tdee = bmr * factor;
    var targetWeight = lbm / (1 - targetBf / 100);
    var fatToLose = Math.max(0, w - targetWeight);

    var plan = {
      sex: sex, bf: bf, lbm: lbm, bmr: bmr, tdee: tdee, targetBf: targetBf, goalLabel: goal.label,
      targetWeight: targetWeight, fatToLose: fatToLose, warnings: warnings
    };

    if (profile.age && profile.age < 18) {
      plan.mode = 'blocked';
      plan.blockReason = 'CoreCut plans are for adults. If you are under 18, talk with a parent, coach or doctor about healthy training. Growing bodies need enough food, so a calorie deficit is not recommended.';
    } else if (profile.pregnant) {
      plan.mode = 'blocked';
      plan.blockReason = 'Fat-loss diets are not recommended during pregnancy or while breastfeeding. Your doctor or midwife can advise on safe exercise and nutrition for now.';
    }

    var bmiVal = bmi(profile);
    if (bmiVal < 18.5) warnings.push('Your BMI is under 18.5. Losing more weight is not advised. The plan is set to maintenance with a focus on building muscle. Consider checking in with a doctor.');

    var gap = bf - targetBf;
    var kcal, mode;
    if (plan.mode === 'blocked') {
      mode = 'blocked';
      kcal = tdee;
    } else if (gap <= 0.5 || bmiVal < 18.5) {
      mode = 'maintain';
      kcal = tdee;
    } else {
      mode = 'cut';
      var pct = (PACE[profile.pace] || PACE.steady).pct;
      if (gap < 3) pct = Math.min(pct, 0.5);
      else if (gap < 6) pct = Math.min(pct, 0.75);
      var weeklyKg = w * pct / 100;
      var deficit = weeklyKg * KCAL_PER_KG / 7;
      kcal = tdee - deficit;
      kcal = Math.max(kcal, tdee * 0.75); // never cut more than 25% below maintenance
      if (kcal < CAL_FLOOR[sex]) {
        kcal = Math.min(CAL_FLOOR[sex], tdee);
        warnings.push('Your calorie target was raised to ' + CAL_FLOOR[sex] + ' kcal, the lowest we recommend without medical supervision. Progress will be slower; adding daily steps helps more than eating less.');
      }
      if (goal === GOALS.shredded) warnings.push('"Shredded" is a short-term peak. Plan to ease back to "Clear six-pack" levels after a few weeks to protect energy, sleep, mood and hormones.');
      if (sex === 'female' && targetBf < 16) warnings.push('Very low body fat can stop periods and weaken bones. If your cycle changes, ease off and talk with a doctor.');
    }
    kcal = round(kcal, 10);

    var proteinPerLbm = mode === 'cut' ? 2.4 : 2.0;
    var protein = round(clamp(proteinPerLbm * lbm, 1.4 * w * 0.8, 2.6 * w), 5);
    var fat = Math.max(0.6 * w, 0.25 * kcal / 9);
    var carbs = (kcal - protein * 4 - fat * 9) / 4;
    if (carbs < 50) {
      fat = Math.max(0.5 * w, (kcal - protein * 4 - 50 * 4) / 9);
      carbs = Math.max(0, (kcal - protein * 4 - fat * 9) / 4);
    }

    var dailyDeficit = Math.max(0, tdee - kcal);
    var weeklyLossKg = dailyDeficit * 7 / KCAL_PER_KG;
    var weeks = mode === 'cut' && weeklyLossKg > 0 ? fatToLose / weeklyLossKg : 0;

    plan.mode = mode;
    plan.kcal = kcal;
    plan.trainingKcal = round(kcal + (mode === 'cut' ? 100 : 150), 10); // a little more fuel on lifting days
    plan.restKcal = round(kcal - (mode === 'cut' ? 70 : 100), 10);
    plan.deficit = round(dailyDeficit, 10);
    plan.weeklyLossKg = weeklyLossKg;
    plan.weeklyLossPct = weeklyLossKg / w * 100;
    plan.weeksLow = Math.ceil(weeks);
    plan.weeksHigh = Math.ceil(weeks * 1.35); // real-world progress is rarely linear
    plan.macros = {
      protein: round(protein, 5),
      fat: round(fat, 5),
      carbs: round(carbs, 5),
      fiber: round(14 * kcal / 1000, 1),
      waterL: Math.round((0.035 * w) * 10) / 10
    };
    return plan;
  }

  // Training phase from weeks since the start date.
  var PHASES = [
    { id: 1, name: 'Foundation', weeks: [1, 4], focus: 'Learn the movements, build the habit, set your baseline.' },
    { id: 2, name: 'Build', weeks: [5, 8], focus: 'Add load and volume. Abs get harder variations.' },
    { id: 3, name: 'Sharpen', weeks: [9, 12], focus: 'Heavier lifting, more conditioning, tighter food tracking.' },
    { id: 4, name: 'Reveal', weeks: [13, 999], focus: 'Hold strength while the last fat comes off. Recovery matters most now.' }
  ];
  function weekNumber(startISO, nowMs) {
    var start = parseISO(startISO);
    return Math.max(1, Math.floor((nowMs - start) / (7 * DAY)) + 1);
  }
  function phaseFor(week) {
    for (var i = 0; i < PHASES.length; i++) if (week >= PHASES[i].weeks[0] && week <= PHASES[i].weeks[1]) return PHASES[i];
    return PHASES[PHASES.length - 1];
  }

  /* ---------- Meal scaling ---------- */

  // foods: {id: {kcal, p, c, f, role}} per 100 g. role: 'P' protein, 'C' carb/fat, 'V' vegetables (fixed)
  // items: [{food, g}] -> scaled items and totals that hit kcal and protein as closely as possible.
  function macroOf(foods, items) {
    var t = { kcal: 0, p: 0, c: 0, f: 0 };
    items.forEach(function (it) {
      var fd = foods[it.food]; var k = it.g / 100;
      t.kcal += fd.kcal * k; t.p += fd.p * k; t.c += fd.c * k; t.f += fd.f * k;
    });
    return t;
  }
  function scaleDay(foods, items, targetKcal, targetProtein) {
    var P = { kcal: 0, p: 0 }, C = { kcal: 0, p: 0 }, V = { kcal: 0, p: 0 };
    items.forEach(function (it) {
      var fd = foods[it.food]; var k = it.g / 100;
      var bucket = fd.role === 'P' ? P : fd.role === 'V' ? V : C;
      bucket.kcal += fd.kcal * k; bucket.p += fd.p * k;
    });
    // Solve fp*P.p + fc*C.p = tp - V.p ; fp*P.kcal + fc*C.kcal = tk - V.kcal
    var tp = targetProtein - V.p, tk = targetKcal - V.kcal;
    var det = P.p * C.kcal - C.p * P.kcal;
    var fp = 1, fc = 1;
    if (Math.abs(det) > 1e-6) {
      fp = (tp * C.kcal - C.p * tk) / det;
      fc = (P.p * tk - tp * P.kcal) / det;
    }
    fp = clamp(fp, 0.6, 2.2);
    // Re-fit carbs/fats to calories after clamping protein foods.
    fc = C.kcal > 0 ? clamp((tk - fp * P.kcal) / C.kcal, 0.4, 2.5) : 1;
    var scaled = items.map(function (it) {
      var role = foods[it.food].role;
      var f = role === 'P' ? fp : role === 'V' ? 1 : fc;
      var g = it.g * f;
      var step = g > 60 ? 10 : 5;
      return { food: it.food, g: Math.max(step, round(g, step)), slot: it.slot };
    });
    return { items: scaled, totals: macroOf(foods, scaled) };
  }

  /* ---------- Progress analysis ---------- */

  function parseISO(s) { var p = String(s).split('-'); return Date.UTC(+p[0], +p[1] - 1, +p[2]); }
  function toISO(ms) { return new Date(ms).toISOString().slice(0, 10); }

  // Least-squares slope (units per week) over entries in the last `days` days.
  function trend(entries, key, days, nowMs) {
    var from = nowMs - days * DAY;
    var pts = entries.filter(function (e) { return e[key] != null && isFinite(e[key]) && parseISO(e.date) >= from && parseISO(e.date) <= nowMs + DAY; })
      .map(function (e) { return { t: (parseISO(e.date) - from) / DAY, v: +e[key] }; });
    if (pts.length < 2) return { n: pts.length, slopePerWeek: null, spanDays: 0 };
    var n = pts.length, st = 0, sv = 0, stt = 0, stv = 0;
    pts.forEach(function (p) { st += p.t; sv += p.v; stt += p.t * p.t; stv += p.t * p.v; });
    var den = n * stt - st * st;
    var span = pts[pts.length - 1].t - pts[0].t;
    if (den === 0 || span < 1) return { n: n, slopePerWeek: null, spanDays: span };
    var slope = (n * stv - st * sv) / den;
    return { n: n, slopePerWeek: slope * 7, spanDays: span };
  }

  // Returns [{tone:'good'|'warn'|'info', title, body}] — context-aware coaching.
  // s: {entries, plan, profile, photos, streak, nowMs, startISO}
  function coach(s) {
    var out = [];
    var now = s.nowMs;
    var entries = (s.entries || []).slice().sort(function (a, b) { return a.date < b.date ? -1 : 1; });
    var last = entries[entries.length - 1];
    var daysSinceLog = last ? Math.floor((now - parseISO(last.date)) / DAY) : 999;
    var plan = s.plan;
    var w = (last && last.weightKg) || s.profile.weightKg;

    if (plan && plan.mode === 'maintain' && plan.bf <= plan.targetBf + 0.5) {
      out.push({ tone: 'good', title: 'You are at your target', body: 'Your estimate is at or below ' + plan.targetBf + '% body fat. Eat at maintenance, keep lifting heavy and keep protein high. Build muscle now so the abs look thicker at the same body fat.' });
    }

    if (daysSinceLog >= 7) {
      out.push({ tone: 'info', title: 'Weekly check-in due', body: last ? 'Your last weigh-in was ' + daysSinceLog + ' days ago. Weigh in after the bathroom, before food, and measure your waist at the navel.' : 'Log your first weigh-in and waist measurement to start your trend line.' });
    }

    var wt = trend(entries, 'weightKg', 21, now);
    var wst = trend(entries, 'waistCm', 21, now);
    if (plan && plan.mode === 'cut' && wt.slopePerWeek != null && wt.n >= 3 && wt.spanDays >= 10) {
      var lossPct = -wt.slopePerWeek / w * 100;
      var target = plan.weeklyLossPct;
      if (lossPct > Math.max(1.2, target * 1.6)) {
        out.push({ tone: 'warn', title: 'Losing faster than planned', body: 'You are losing about ' + lossPct.toFixed(1) + '% of body weight a week. That risks muscle loss and burnout. Add about 150–200 kcal a day, mostly from carbs around training.' });
      } else if (Math.abs(lossPct) < 0.15 && wt.spanDays >= 14) {
        if (wst.slopePerWeek != null && wst.slopePerWeek < -0.25) {
          out.push({ tone: 'good', title: 'Scale is flat but your waist is shrinking', body: 'Your waist is down about ' + Math.abs(wst.slopePerWeek).toFixed(1) + ' cm a week while weight holds. That usually means fat loss with muscle gain or water shifts. Stay the course.' });
        } else {
          out.push({ tone: 'warn', title: 'Plateau: 2+ weeks with no change', body: 'Pick one: (1) check that portions match the plan for 7 days, (2) add 2,000 steps a day, or (3) drop 100–150 kcal a day. Change one thing, then give it 2 weeks.' });
        }
      } else if (lossPct >= target * 0.6) {
        out.push({ tone: 'good', title: 'Right on pace', body: 'You are losing about ' + lossPct.toFixed(2) + '% of body weight a week (plan: ' + target.toFixed(2) + '%). Keep doing exactly what you are doing.' });
      } else if (lossPct > 0) {
        out.push({ tone: 'info', title: 'Slower than planned, still moving', body: 'You are losing about ' + lossPct.toFixed(2) + '% a week. Slow loss keeps muscle. If you want more speed, add a 30-minute walk on rest days before cutting food.' });
      } else {
        out.push({ tone: 'warn', title: 'Weight is trending up', body: 'Check weekends, drinks, cooking oils and sauces first; they hide the most calories. Water from salty meals or a hard leg day can also add 1–2 kg for a few days.' });
      }
    }

    // Adaptive maintenance estimate after enough data.
    var long = trend(entries, 'weightKg', 35, now);
    if (plan && plan.mode === 'cut' && long.slopePerWeek != null && long.n >= 6 && long.spanDays >= 24) {
      var observedTdee = plan.kcal - long.slopePerWeek * KCAL_PER_KG / 7;
      var diff = observedTdee - plan.tdee;
      if (Math.abs(diff) > 150) {
        out.push({ tone: 'info', title: 'Your real burn is ' + (diff > 0 ? 'higher' : 'lower') + ' than estimated', body: 'Based on 4+ weeks of weigh-ins, your maintenance looks closer to ' + round(observedTdee, 10) + ' kcal than ' + round(plan.tdee, 10) + ' kcal (assuming you hit your targets). Use this if your pace stays off for another week.' });
      }
    }

    var photos = s.photos || [];
    if (!photos.length) {
      out.push({ tone: 'info', title: 'Take your baseline photos', body: 'Front, side and back, same spot, same light, relaxed. In 8 weeks you will be glad you did. They stay on this device.' });
    } else {
      var lastPhoto = photos.reduce(function (m, p) { return p.date > m ? p.date : m; }, '');
      var dp = Math.floor((now - parseISO(lastPhoto)) / DAY);
      if (dp >= 14) out.push({ tone: 'info', title: 'Time for progress photos', body: 'Your last photos are ' + dp + ' days old. Every 2 weeks is the sweet spot; changes are too small to see day to day.' });
    }

    if (s.streak >= 3) {
      out.push({ tone: 'good', title: s.streak + '-day streak', body: s.streak >= 14 ? 'Two weeks of showing up. This is what abs are actually made of.' : 'Consistency beats intensity. Keep the chain going today.' });
    }

    if (s.startISO) {
      var wk = weekNumber(s.startISO, now);
      if (wk >= 12 && plan && plan.mode === 'cut') {
        out.push({ tone: 'info', title: 'Consider a diet break', body: 'You have been in a deficit for ' + wk + ' weeks. One or two weeks at maintenance calories can restore energy and training performance with little fat regain. Keep protein and training the same.' });
      }
    }
    return out;
  }

  // Consecutive days (ending today or yesterday) with at least `min` checklist items ticked.
  function streak(checks, nowMs, min) {
    min = min || 3;
    var count = 0;
    var d = nowMs;
    var today = toISO(d);
    var c = checks[today];
    var n = c ? Object.keys(c).filter(function (k) { return c[k]; }).length : 0;
    if (n < min) d -= DAY; // today not done yet doesn't break the streak
    for (;;) {
      var k = toISO(d);
      var cc = checks[k];
      var m = cc ? Object.keys(cc).filter(function (x) { return cc[x]; }).length : 0;
      if (m >= min) { count++; d -= DAY; } else break;
    }
    return count;
  }

  var api = {
    units: units, clamp: clamp, round: round,
    navyBodyFat: navyBodyFat, rfmBodyFat: rfmBodyFat, bmiBodyFat: bmiBodyFat, bmi: bmi,
    visualBodyFat: visualBodyFat, combineEstimates: combineEstimates, estimateBodyFat: estimateBodyFat,
    TEST_METHODS: TEST_METHODS, VISUAL_LEVELS: VISUAL_LEVELS, GOALS: GOALS, JOB: JOB, PACE: PACE, PHASES: PHASES,
    buildPlan: buildPlan, weekNumber: weekNumber, phaseFor: phaseFor,
    macroOf: macroOf, scaleDay: scaleDay,
    trend: trend, coach: coach, streak: streak, parseISO: parseISO, toISO: toISO, DAY: DAY
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.Calc = api;
})(this);
