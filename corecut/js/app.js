/* CoreCut app: state, storage, views and events. Depends on Calc (calc.js) and Content (content.js). */
(function () {
  'use strict';
  var C = window.Calc, K = window.Content;

  /* ======================= Utilities ======================= */
  var $ = function (s, el) { return (el || document).querySelector(s); };
  function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
  function pad(n) { return n < 10 ? '0' + n : '' + n; }
  function localISO(d) { return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()); }
  function todayISO() { return localISO(new Date()); }
  function nowMs() { return C.parseISO(todayISO()); }
  function isoAdd(iso, days) { return C.toISO(C.parseISO(iso) + days * C.DAY); }
  var MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  function fmtDate(iso, withYear) { var p = iso.split('-'); return MONTHS[+p[1] - 1] + ' ' + (+p[2]) + (withYear ? ', ' + p[0] : ''); }
  function dowIndex(iso) { return (new Date(C.parseISO(iso)).getUTCDay() + 6) % 7; }
  function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 8); }
  function num(v) { var n = parseFloat(String(v).replace(',', '.')); return isFinite(n) ? n : null; }
  function fixed(n, d) { return n == null || !isFinite(n) ? '–' : (+n).toFixed(d == null ? 1 : d); }
  function plural(n, w) { return n + ' ' + w + (n === 1 ? '' : 's'); }

  /* ======================= Storage ======================= */
  // IndexedDB on the device, with an in-memory fallback (private mode, blocked storage, previews).
  var Store = (function () {
    var db = null, mem = { kv: {}, photos: {} }, persistent = false;
    function open() {
      return new Promise(function (resolve) {
        try {
          var req = indexedDB.open('corecut', 1);
          req.onupgradeneeded = function () { req.result.createObjectStore('kv'); req.result.createObjectStore('photos'); };
          req.onsuccess = function () { db = req.result; persistent = true; resolve(true); };
          req.onerror = function () { resolve(false); };
          req.onblocked = function () { resolve(false); };
        } catch (e) { resolve(false); }
      });
    }
    function run(store, mode, fn) {
      if (!db) return Promise.resolve(fn(null, store));
      return new Promise(function (resolve, reject) {
        try {
          var tx = db.transaction(store, mode); var os = tx.objectStore(store); var req = fn(os, store);
          tx.oncomplete = function () { resolve(req && 'result' in req ? req.result : undefined); };
          tx.onerror = function () { reject(tx.error); };
          tx.onabort = function () { reject(tx.error); };
        } catch (e) { reject(e); }
      });
    }
    return {
      open: open,
      isPersistent: function () { return persistent; },
      get: function (store, key) { return run(store, 'readonly', function (os, s) { return os ? os.get(key) : { result: mem[s][key] }; }); },
      put: function (store, key, val) { return run(store, 'readwrite', function (os, s) { if (os) return os.put(val, key); mem[s][key] = val; }); },
      del: function (store, key) { return run(store, 'readwrite', function (os, s) { if (os) return os.delete(key); delete mem[s][key]; }); },
      all: function (store) { return run(store, 'readonly', function (os, s) { if (os) return os.getAll(); return { result: Object.keys(mem[s]).map(function (k) { return mem[s][k]; }) }; }); },
      clear: function (store) { return run(store, 'readwrite', function (os, s) { if (os) return os.clear(); mem[s] = {}; }); }
    };
  })();

  /* ======================= State ======================= */
  var state = null;           // persisted
  var photoData = {};         // id -> dataURL (loaded from the photo store)
  var ui = { dayType: null, trainDay: null, tipOffset: 0, cmpA: null, cmpB: null, cmpMode: 'side', addPose: 'front', confirmReset: false, saving: false };
  var draft = null;           // onboarding

  function blankState() { return { version: 1, sample: false, profile: null, entries: [], checks: {}, meals: {}, photos: [] }; }

  var saveTimer = null;
  function save() {
    clearTimeout(saveTimer);
    saveTimer = setTimeout(function () {
      Store.put('kv', 'state', JSON.parse(JSON.stringify(state))).catch(function () { toast('Could not save on this device'); });
    }, 150);
  }

  /* ======================= Units ======================= */
  function imperial() { return (state && state.profile ? state.profile.units : (draft && draft.units)) !== 'metric'; }
  function wUnit() { return imperial() ? 'lb' : 'kg'; }
  function lUnit() { return imperial() ? 'in' : 'cm'; }
  function toW(kg) { return kg == null ? null : imperial() ? C.units.kgToLb(kg) : kg; }
  function fromW(v) { return v == null ? null : imperial() ? C.units.lbToKg(v) : v; }
  function toL(cm) { return cm == null ? null : imperial() ? C.units.cmToIn(cm) : cm; }
  function fromL(v) { return v == null ? null : imperial() ? C.units.inToCm(v) : v; }
  function fmtW(kg, d) { return kg == null ? '–' : fixed(toW(kg), d == null ? 1 : d) + ' ' + wUnit(); }
  function fmtL(cm, d) { return cm == null ? '–' : fixed(toL(cm), d == null ? 1 : d) + ' ' + lUnit(); }
  function fmtH(cm) {
    if (!imperial()) return Math.round(cm) + ' cm';
    var inch = Math.round(C.units.cmToIn(cm)); return Math.floor(inch / 12) + '′' + (inch % 12) + '″';
  }
  function fmtMass(g) {
    if (imperial()) { var lb = g / 453.6; return lb >= 1 ? fixed(lb, 1) + ' lb' : Math.round(g / 28.35) + ' oz'; }
    return g >= 1000 ? fixed(g / 1000, 1) + ' kg' : Math.round(g) + ' g';
  }
  function inputVal(v, d) { return v == null || !isFinite(v) ? '' : String(+(+v).toFixed(d == null ? 1 : d)); }

  /* ======================= Derived data ======================= */
  function entriesSorted() { return state.entries.slice().sort(function (a, b) { return a.date < b.date ? -1 : a.date > b.date ? 1 : 0; }); }
  function latestWith(key, list) { list = list || entriesSorted(); for (var i = list.length - 1; i >= 0; i--) if (list[i][key] != null) return list[i]; return null; }
  function currentWeight() { var e = latestWith('weightKg'); return e ? e.weightKg : state.profile.weightKg; }

  function ctxFor(list, idx, includeVisual) {
    var p = state.profile, e = list[idx];
    function carry(key) { for (var i = idx; i >= 0; i--) if (list[i][key] != null) return list[i][key]; return null; }
    var w = carry('weightKg') || p.weightKg;
    return { sex: p.sex, age: p.age, heightCm: p.heightCm, weightKg: w, neckCm: carry('neckCm'), waistCm: e.waistCm != null ? e.waistCm : null, hipCm: carry('hipCm'), test: e.test || null, visualLevel: includeVisual ? includeVisual : null };
  }
  function currentEstimate() {
    var list = entriesSorted(), p = state.profile;
    if (!list.length) return C.estimateBodyFat({ sex: p.sex, age: p.age, heightCm: p.heightCm, weightKg: p.weightKg });
    var last = list.length - 1;
    var ctx = ctxFor(list, last, null);
    // Waist: most recent within 35 days.
    var we = latestWith('waistCm', list);
    ctx.waistCm = we && (nowMs() - C.parseISO(we.date)) < 35 * C.DAY ? we.waistCm : null;
    // Test: most recent within 90 days.
    var te = null; for (var i = last; i >= 0; i--) if (list[i].test) { te = list[i]; break; }
    ctx.test = te && (nowMs() - C.parseISO(te.date)) < 90 * C.DAY ? te.test : null;
    // Visual check: within 45 days.
    if (p.visual && (nowMs() - C.parseISO(p.visual.date)) < 45 * C.DAY) ctx.visualLevel = p.visual.level;
    ctx.weightKg = currentWeight();
    return C.estimateBodyFat(ctx);
  }
  function bfSeries() {
    var list = entriesSorted(), p = state.profile, out = [];
    list.forEach(function (e, i) {
      if (e.waistCm == null && !e.test) return;
      var vis = p.visual && p.visual.date === e.date ? p.visual.level : null;
      var est = C.estimateBodyFat(ctxFor(list, i, vis));
      if (est) out.push({ date: e.date, v: est.value });
    });
    return out;
  }
  function getPlan() {
    var est = currentEstimate();
    var prof = Object.assign({}, state.profile, { weightKg: currentWeight() });
    var plan = C.buildPlan(prof, est ? est.value : 25);
    plan.estimate = est;
    return plan;
  }
  function weekNo() { return C.weekNumber(state.profile.startDate, nowMs()); }

  function weekSchedule(profile, phaseId, wk) {
    var days = C.clamp(profile.days || 3, 3, 6);
    var split = K.SPLITS[days], cardio = K.CARDIO[phaseId], exp = profile.experience || 'beginner';
    var sched = [0, 1, 2, 3, 4, 5, 6].map(function (i) { return { i: i, lift: null, abs: null, liss: false, hiit: false }; });
    split.days.forEach(function (d, k) { sched[d].lift = split.seq[k]; });
    split.abs.forEach(function (d, k) { sched[d].abs = (k + wk) % 2; });
    var isLeg = function (id) { return /lower|legs/i.test(id); };
    var restWeek = sched.filter(function (d) { return !d.lift && d.i !== 6; }).map(function (d) { return d.i; });
    var liftNonLeg = sched.filter(function (d) { return d.lift && !isLeg(d.lift); }).map(function (d) { return d.i; });
    var hiitCands = restWeek.concat(liftNonLeg, [6]);
    for (var h = 0; h < cardio.hiit[exp] && h < hiitCands.length; h++) sched[hiitCands[h]].hiit = true;
    var lissCands = restWeek.filter(function (i) { return !sched[i].hiit; })
      .concat(sched.filter(function (d) { return d.lift && !d.hiit; }).map(function (d) { return d.i; }), [6]);
    for (var l = 0; l < cardio.liss[0] && l < lissCands.length; l++) sched[lissCands[l]].liss = true;
    return { split: split, cardio: cardio, sched: sched, exp: exp };
  }

  function streakNow() { return C.streak(state.checks, nowMs(), 3); }

  /* ======================= Small components ======================= */
  var ICONS = {
    today: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="1" /></svg>',
    food: '<svg viewBox="0 0 24 24"><path d="M3 12h18a9 9 0 0 1-18 0z"/><path d="M8 8c0-2 2-2 2-4M13 8c0-2 2-2 2-4"/></svg>',
    train: '<svg viewBox="0 0 24 24"><path d="M6.5 6.5v11M17.5 6.5v11M3.5 9v6M20.5 9v6M6.5 12h11"/></svg>',
    progress: '<svg viewBox="0 0 24 24"><path d="M3 20h18"/><path d="M5 16l5-5 4 3 6-7"/><path d="M16 7h4v4"/></svg>',
    me: '<svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21c1-4.5 4.5-6.5 8-6.5s7 2 8 6.5"/></svg>',
    tape: '<svg viewBox="0 0 24 24"><rect x="2.5" y="7" width="19" height="10" rx="2"/><path d="M6 7v4M10 7v3M14 7v4M18 7v3"/></svg>',
    plate: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/></svg>',
    camera: '<svg viewBox="0 0 24 24"><path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></svg>',
    spark: '<svg viewBox="0 0 24 24"><path d="M12 3v5M12 16v5M3 12h5M16 12h5M6 6l3 3M15 15l3 3M18 6l-3 3M9 15l-3 3"/></svg>'
  };
  var CHECK_SVG = '<svg viewBox="0 0 16 16"><path d="M3 8.5l3.2 3L13 4.5"/></svg>';

  function seg(name, options, current) {
    return '<div class="seg" role="group">' + options.map(function (o) {
      return '<button type="button" data-act="seg" data-name="' + name + '" data-val="' + esc(o[0]) + '" aria-pressed="' + (String(current) === String(o[0])) + '">' + esc(o[1]) + '</button>';
    }).join('') + '</div>';
  }
  function choiceList(name, map, current) {
    return '<div class="choice-list">' + Object.keys(map).map(function (k) {
      var o = map[k];
      return '<button type="button" class="choice" data-act="choice" data-name="' + name + '" data-val="' + k + '" aria-pressed="' + (current === k) + '"><b>' + esc(o.label) + '</b>' + (o.desc ? '<span>' + esc(o.desc) + '</span>' : '') + '</button>';
    }).join('') + '</div>';
  }
  function numField(id, label, value, unit, hint, bind) {
    return '<div class="field"><label for="' + id + '">' + esc(label) + '</label><div class="input-wrap"><input id="' + id + '" type="number" inputmode="decimal" step="any" value="' + esc(value) + '"' + (bind ? ' data-bind="' + bind + '"' : '') + '>' + (unit ? '<span class="unit">' + esc(unit) + '</span>' : '') + '</div>' + (hint ? '<span class="hint">' + esc(hint) + '</span>' : '') + '</div>';
  }
  function selectField(id, label, map, current, bind) {
    return '<div class="field"><label for="' + id + '">' + esc(label) + '</label><select class="plain" id="' + id + '"' + (bind ? ' data-bind="' + bind + '"' : '') + '>' + Object.keys(map).map(function (k) {
      var l = typeof map[k] === 'string' ? map[k] : map[k].label;
      return '<option value="' + esc(k) + '"' + (String(current) === String(k) ? ' selected' : '') + '>' + esc(l) + '</option>';
    }).join('') + '</select></div>';
  }
  function heightFields(cm, prefix, bind) {
    if (imperial()) {
      var inch = cm ? Math.round(C.units.cmToIn(cm)) : null;
      return '<div class="grid2">' +
        numField(prefix + '-ft', 'Height (feet)', inch != null ? Math.floor(inch / 12) : '', 'ft', '', bind ? 'height' : '') +
        numField(prefix + '-in', 'Height (inches)', inch != null ? inch % 12 : '', 'in', '', bind ? 'height' : '') + '</div>';
    }
    return numField(prefix + '-cm', 'Height', cm ? Math.round(cm) : '', 'cm', '', bind ? 'height' : '');
  }
  function readHeight(prefix) {
    if (imperial()) { var ft = num(($('#' + prefix + '-ft') || {}).value) || 0, inch = num(($('#' + prefix + '-in') || {}).value) || 0; var t = ft * 12 + inch; return t > 0 ? C.units.inToCm(t) : null; }
    return num(($('#' + prefix + '-cm') || {}).value);
  }

  // Simple front-view torso. idx 0 = leanest.
  function torsoSVG(idx, sex) {
    var f = sex === 'female', cx = 60;
    var ww = (f ? 50 : 58) + idx * (f ? 5 : 6.2), hw = f ? 84 + idx * 3.5 : 70 + idx * 4.2, sw = f ? 92 : 104;
    var bulge = Math.max(0, idx - 2) * 2.4;
    var L = function (v) { return (cx - v / 2).toFixed(1); }, R = function (v) { return (cx + v / 2).toFixed(1); };
    var path = 'M52 6 L68 6 L70 16 Q' + (+R(sw) - 4) + ' 18 ' + R(sw) + ' 30 L' + (+R(sw) - 8) + ' 50 Q' + (+R(ww) + bulge) + ' 78 ' + R(ww) + ' 104 Q' + (+R(hw) + 2) + ' 126 ' + R(hw) + ' 150 L' + L(hw) + ' 150 Q' + (+L(hw) - 2) + ' 126 ' + L(ww) + ' 104 Q' + (+L(ww) - bulge) + ' 78 ' + (+L(sw) + 8) + ' 50 L' + L(sw) + ' 30 Q' + (+L(sw) + 4) + ' 18 50 16 Z';
    var o = Math.max(0, 1 - idx * 0.3), mid = Math.max(o, idx < 4 ? 0.35 : 0);
    var abs = '';
    if (o > 0) [62, 73, 84].forEach(function (y, r) {
      var ro = r === 2 ? o * 0.7 : o;
      abs += '<rect class="abs" x="49.5" y="' + y + '" width="9.5" height="9" rx="3" opacity="' + ro.toFixed(2) + '"/><rect class="abs" x="61" y="' + y + '" width="9.5" height="9" rx="3" opacity="' + ro.toFixed(2) + '"/>';
    });
    var pec = f ? '<path class="abs" d="M40 46 Q50 54 58 47 M62 47 Q70 54 80 46" opacity=".55"/>' : '<path class="abs" d="M34 44 Q46 54 59 46 M61 46 Q74 54 86 44" opacity=".7"/>';
    var belly = idx >= 4 ? '<path class="abs" d="M' + (+L(ww) + 7) + ' 112 Q60 ' + (116 + idx * 1.5) + ' ' + (+R(ww) - 7) + ' 112" opacity=".6"/>' : '';
    return '<svg viewBox="0 0 120 156" aria-hidden="true"><path class="body" d="' + path + '"/>' + pec +
      '<line class="abs" x1="60" y1="58" x2="60" y2="98" opacity="' + mid.toFixed(2) + '"/>' + abs + '<circle class="abs" cx="60" cy="102" r="1.6"/>' + belly + '</svg>';
  }

  // Tape-measure progress strip for the hero card.
  function tapeSVG(start, current, target) {
    var hi = Math.ceil(Math.max(start, current) + 0.5), lo = Math.floor(Math.min(target, current) - 0.5);
    if (hi - lo < 4) { hi += 1; lo -= 1; }
    var W = 320, P = 12, span = hi - lo;
    var x = function (v) { return P + (hi - v) / span * (W - 2 * P); };
    var labelEvery = span <= 12 ? 1 : span <= 24 ? 2 : 5;
    var s = '<svg viewBox="0 0 ' + W + ' 50" width="100%" role="img" aria-label="Body fat ' + fixed(current) + '% on the way from ' + fixed(start) + '% to ' + target + '%">';
    for (var v = hi; v >= lo; v--) {
      var tall = v % 5 === 0 ? 16 : 10;
      s += '<line class="tape-line" x1="' + x(v).toFixed(1) + '" x2="' + x(v).toFixed(1) + '" y1="0" y2="' + tall + '" stroke-width="' + (v % 5 === 0 ? 1.6 : 1) + '"/>';
      if (span <= 12 && v > lo) { var hx = x(v - 0.5).toFixed(1); s += '<line class="tape-line" x1="' + hx + '" x2="' + hx + '" y1="0" y2="6" stroke-width=".8" opacity=".7"/>'; }
      if (v % labelEvery === 0) s += '<text x="' + x(v).toFixed(1) + '" y="30" text-anchor="middle" font-size="12" font-weight="600">' + v + '</text>';
    }
    var tx = x(target), cxm = x(current);
    s += '<line class="tape-line" x1="' + tx.toFixed(1) + '" x2="' + tx.toFixed(1) + '" y1="34" y2="39" stroke-width="2"/>';
    s += '<text x="' + tx.toFixed(1) + '" y="48" text-anchor="middle" font-size="10" font-weight="700" letter-spacing=".1em">GOAL</text>';
    s += '<path d="M' + (cxm - 7).toFixed(1) + ' 44 L' + (cxm + 7).toFixed(1) + ' 44 L' + cxm.toFixed(1) + ' 34 Z" fill="currentColor"/>';
    s += '<text x="' + cxm.toFixed(1) + '" y="' + (Math.abs(cxm - tx) < 28 ? 8 : 48) + '" text-anchor="middle" font-size="10" font-weight="700" letter-spacing=".1em" dy="' + (Math.abs(cxm - tx) < 28 ? -2 : 0) + '">' + (Math.abs(cxm - tx) < 28 ? '' : 'NOW') + '</text>';
    return s + '</svg>';
  }

  // Line chart with area fill, faint grid, emphasized endpoint and optional target line.
  function lineChart(points, opts) {
    if (points.length < 2) return '<div class="chart-empty">' + esc(opts.empty || 'Log at least two check-ins to see a trend.') + '</div>';
    var W = 340, H = 150, PL = 38, PR = 12, PT = 12, PB = 22;
    var xs = points.map(function (p) { return C.parseISO(p.date); });
    var ys = points.map(function (p) { return p.v; });
    var t = opts.target;
    var yMin = Math.min.apply(null, ys.concat(t != null ? [t] : [])), yMax = Math.max.apply(null, ys.concat(t != null ? [t] : []));
    var padY = Math.max((yMax - yMin) * 0.12, 0.5); yMin -= padY; yMax += padY;
    var step = niceStep((yMax - yMin) / 3);
    yMin = Math.floor(yMin / step) * step; yMax = Math.ceil(yMax / step) * step;
    var x0 = xs[0], x1 = xs[xs.length - 1] === x0 ? x0 + C.DAY : xs[xs.length - 1];
    var X = function (v) { return PL + (v - x0) / (x1 - x0) * (W - PL - PR); };
    var Y = function (v) { return PT + (yMax - v) / (yMax - yMin) * (H - PT - PB); };
    var s = '<svg class="chart" viewBox="0 0 ' + W + ' ' + H + '" role="img" aria-label="' + esc(opts.label) + '">';
    for (var g = yMin; g <= yMax + 1e-9; g += step) {
      s += '<line class="grid" x1="' + PL + '" x2="' + (W - PR) + '" y1="' + Y(g).toFixed(1) + '" y2="' + Y(g).toFixed(1) + '"/>';
      s += '<text x="' + (PL - 6) + '" y="' + (Y(g) + 3.5).toFixed(1) + '" text-anchor="end">' + (+g.toFixed(step < 1 ? 1 : 0)) + '</text>';
    }
    s += '<text x="' + PL + '" y="' + (H - 6) + '">' + fmtDate(points[0].date) + '</text>';
    s += '<text x="' + (W - PR) + '" y="' + (H - 6) + '" text-anchor="end">' + fmtDate(points[points.length - 1].date) + '</text>';
    var line = points.map(function (p, i) { return (i ? 'L' : 'M') + X(xs[i]).toFixed(1) + ' ' + Y(p.v).toFixed(1); }).join(' ');
    s += '<path class="area" d="' + line + ' L' + X(xs[xs.length - 1]).toFixed(1) + ' ' + Y(yMin).toFixed(1) + ' L' + X(xs[0]).toFixed(1) + ' ' + Y(yMin).toFixed(1) + ' Z"/>';
    if (t != null) {
      s += '<line class="target" x1="' + PL + '" x2="' + (W - PR) + '" y1="' + Y(t).toFixed(1) + '" y2="' + Y(t).toFixed(1) + '"/>';
      s += '<text class="target-label" x="' + (W - PR) + '" y="' + (Y(t) - 4).toFixed(1) + '" text-anchor="end">Goal ' + (+t.toFixed(1)) + '</text>';
    }
    s += '<path class="line" d="' + line + '"/>';
    points.forEach(function (p, i) {
      var last = i === points.length - 1;
      s += '<circle class="' + (last ? 'end' : 'dot') + '" cx="' + X(xs[i]).toFixed(1) + '" cy="' + Y(p.v).toFixed(1) + '" r="' + (last ? 4.5 : 2.8) + '"/>';
    });
    return s + '</svg>';
  }
  function niceStep(raw) {
    var p = Math.pow(10, Math.floor(Math.log(raw) / Math.LN10)), m = raw / p;
    return (m <= 1 ? 1 : m <= 2 ? 2 : m <= 2.5 ? 2.5 : m <= 5 ? 5 : 10) * p;
  }

  function exerciseRow(id, sets) {
    var e = K.EXERCISES[id];
    return '<details class="ex"><summary><span><span class="exname">' + esc(e.name) + '</span><span class="exarea">' + esc(e.area) + '</span></span><span class="sets">' + esc(sets) + '</span></summary>' +
      '<div class="exbody"><ol class="steps">' + e.steps.map(function (s) { return '<li>' + esc(s) + '</li>'; }).join('') + '</ol>' +
      '<p><b>Cue:</b> ' + esc(e.cue) + '</p><p class="muted"><b>Easier or no equipment:</b> ' + esc(e.swap) + '</p></div></details>';
  }

  /* ======================= App bar & tabs ======================= */
  var TABS = [['today', 'Today'], ['food', 'Food'], ['train', 'Train'], ['progress', 'Progress'], ['me', 'Me']];
  function route() { var h = (location.hash || '').replace('#', ''); return TABS.some(function (t) { return t[0] === h; }) ? h : 'today'; }

  function renderChrome(r) {
    var bar = $('#appbar'), tabs = $('#tabbar'), shell = $('#app');
    var meta = '';
    if (state.profile) {
      var wk = weekNo(), ph = C.phaseFor(wk);
      meta = 'Week ' + wk + ' · ' + ph.name + '<br><span style="font-weight:500">' + fmtDate(todayISO()) + '</span>';
    }
    bar.innerHTML = '<div class="appbar-inner"><div class="brand"><span class="brand-mark" aria-hidden="true">C</span>CoreCut</div><div class="appbar-meta">' + meta + '</div></div><div class="ruler" aria-hidden="true"></div>';
    if (!state.profile) { tabs.hidden = true; shell.classList.add('no-tabs'); return; }
    tabs.hidden = false; shell.classList.remove('no-tabs');
    tabs.innerHTML = '<div class="tabbar-inner">' + TABS.map(function (t) {
      return '<a class="tab" href="#' + t[0] + '"' + (r === t[0] ? ' aria-current="page"' : '') + '>' + ICONS[t[0]] + '<span>' + t[1] + '</span></a>';
    }).join('') + '</div>';
  }

  /* ======================= TODAY ======================= */
  function viewToday() {
    var p = state.profile, plan = getPlan(), est = plan.estimate;
    var wk = weekNo(), ph = C.phaseFor(wk), iso = todayISO(), di = dowIndex(iso);
    var ws = weekSchedule(p, ph.id, wk), day = ws.sched[di];
    var isTraining = !!day.lift;
    var kcalToday = plan.mode === 'cut' ? (isTraining ? plan.trainingKcal : plan.restKcal) : plan.kcal;
    var h = '';
    if (state.sample) h += '<div class="sample-banner"><span>Sample data: an example person 6 weeks in.</span><button class="linkish" data-act="go-reset">Start my own</button></div>';

    // Hero
    if (plan.mode === 'blocked') {
      h += '<section class="card"><h2>Plan paused</h2><p>' + esc(plan.blockReason) + '</p><p class="muted small">You can still log measurements and photos.</p></section>';
    } else {
      var startBf = p.startBf || (est ? est.value : plan.bf);
      var cur = est ? est.value : plan.bf;
      var atGoal = plan.mode === 'maintain';
      h += '<section class="hero" aria-label="Body-fat progress">' +
        '<div class="eyebrow">Estimated body fat</div>' +
        '<div class="hero-figures"><div class="hero-big">' + fixed(cur) + '<small>%</small></div>' +
        '<div class="hero-side">Goal ' + plan.targetBf + '%<b>' + (atGoal ? 'At goal' : plan.weeksLow + '–' + plan.weeksHigh + ' wk') + '</b></div></div>' +
        tapeSVG(startBf, cur, plan.targetBf) +
        '<div class="hero-foot"><span>Range ' + (est ? fixed(est.low) + '–' + fixed(est.high) + '%' : '–') + '</span><span>' + fmtW(currentWeight()) + ' → ' + fmtW(plan.targetWeight) + '</span></div></section>';
    }

    // Coach
    var insights = C.coach({ entries: state.entries, plan: plan, profile: Object.assign({}, p, { weightKg: currentWeight() }), photos: state.photos, streak: streakNow(), nowMs: nowMs(), startISO: p.startDate });
    plan.warnings.forEach(function (w) { insights.unshift({ tone: 'warn', title: 'Heads up', body: w }); });
    if (insights.length) {
      h += '<section class="stack"><div class="section-head"><h2>Coach</h2><span class="eyebrow">' + plural(insights.length, 'note') + '</span></div>' +
        insights.slice(0, 4).map(function (o) { return '<div class="insight ' + o.tone + '"><div><b>' + esc(o.title) + '</b><p>' + esc(o.body) + '</p></div></div>'; }).join('') + '</section>';
    }

    // Today's checklist
    var c = state.checks[iso] || {};
    var lissMin = ws.cardio.liss[1];
    var items = [
      { k: 'train', t: isTraining ? K.WORKOUTS[day.lift].name : 'Rest day', sub: isTraining ? (day.abs != null ? 'Lifting + ab circuit' : 'Lifting') : (day.abs != null ? 'Ab circuit + mobility' : 'Mobility, stretching or an easy walk') },
      { k: 'move', t: ws.cardio.steps.toLocaleString() + ' steps', sub: day.hiit ? '+ ' + K.HIIT[ws.exp].name.toLowerCase() : day.liss ? '+ ' + lissMin + ' min zone 2 cardio' : 'Walk after meals to get there' },
      { k: 'protein', t: plan.macros.protein + ' g protein', sub: 'About ' + Math.round(plan.macros.protein / 4) + ' g a meal over 4 meals' },
      { k: 'calories', t: '≈ ' + kcalToday.toLocaleString() + ' kcal', sub: plan.mode === 'cut' ? (isTraining ? 'Training-day target' : 'Rest-day target') : 'Maintenance' },
      { k: 'water', t: plan.macros.waterL + ' L water', sub: 'Add 0.5 L on training days' },
      { k: 'sleep', t: '7+ hours sleep', sub: 'Last night' }
    ];
    var done = items.filter(function (it) { return c[it.k]; }).length;
    h += '<section class="card"><div class="card-title"><h2>Today</h2><span class="pill ' + (done >= 3 ? 'tape' : '') + '">' + done + ' / ' + items.length + (streakNow() ? ' · ' + plural(streakNow(), 'day') + ' streak' : '') + '</span></div>' +
      '<div class="progress-dots" aria-hidden="true">' + items.map(function (it) { return '<i class="' + (c[it.k] ? 'on' : '') + '"></i>'; }).join('') + '</div>' +
      '<div class="checklist">' + items.map(function (it) {
        return '<button class="tick" type="button" data-act="tick" data-k="' + it.k + '" aria-pressed="' + !!c[it.k] + '"><span class="box">' + CHECK_SVG + '</span><span><b>' + esc(it.t) + '</b><span class="sub">' + esc(it.sub) + '</span></span><span></span></button>';
      }).join('') + '</div>' +
      '<div class="row"><a class="btn small" href="#train" data-act="open-day" data-day="' + di + '">Open today\'s session</a><a class="btn small ghost" href="#food">Today\'s meals</a></div>' +
      '<p class="tiny muted">Tick at least 3 to keep your streak.</p></section>';

    // Tip
    var dayN = Math.floor(nowMs() / C.DAY);
    var tip = K.TIPS[(dayN + ui.tipOffset) % K.TIPS.length];
    h += '<section class="card"><div class="card-title"><span class="eyebrow">Tip of the day · ' + esc(tip.cat) + '</span><button class="linkish small" data-act="next-tip">Another</button></div><p style="font-size:18px;line-height:1.4">' + esc(tip.text) + '</p></section>';

    // Targets
    h += '<section class="card"><div class="card-title"><h2>Daily targets</h2><span class="eyebrow">' + (plan.mode === 'cut' ? 'Fat loss' : 'Maintenance') + '</span></div>' +
      '<div class="kpis"><div class="kpi"><span class="v">' + plan.kcal.toLocaleString() + '</span><span class="l">kcal average</span></div><div class="kpi"><span class="v">' + plan.macros.protein + '<small>g</small></span><span class="l">protein</span></div><div class="kpi"><span class="v">' + fixed(toW(plan.weeklyLossKg), 2) + '<small>' + wUnit() + '</small></span><span class="l">loss per week</span></div></div>' +
      '<p class="small muted">Maintenance is about ' + Math.round(plan.tdee / 10) * 10 + ' kcal. ' + (plan.mode === 'cut' ? 'Your deficit is about ' + plan.deficit + ' kcal a day.' : '') + ' These update as your weight and measurements change.</p></section>';
    return h;
  }

  /* ======================= FOOD ======================= */
  function dayItems(style, sel) {
    var slots = ['breakfast', 'lunch', 'snack', 'dinner'], items = [];
    slots.forEach(function (s) {
      var opts = K.MEALS[style][s], i = (sel[style + ':' + s] || 0) % opts.length;
      opts[i].items.forEach(function (it) { items.push({ food: it.food, g: it.g, slot: s }); });
    });
    return items;
  }
  function viewFood() {
    var p = state.profile, plan = getPlan();
    var style = K.MEALS[p.diet] ? p.diet : 'omnivore';
    var wk = weekNo(), ws = weekSchedule(p, C.phaseFor(wk).id, wk);
    var todayTraining = !!ws.sched[dowIndex(todayISO())].lift;
    var type = ui.dayType || (todayTraining ? 'train' : 'rest');
    var kcal = plan.mode === 'cut' ? (type === 'train' ? plan.trainingKcal : plan.restKcal) : (type === 'train' ? plan.trainingKcal : plan.restKcal);
    var protein = plan.macros.protein;
    var fat = plan.macros.fat, carbs = Math.max(0, Math.round((kcal - protein * 4 - fat * 9) / 4 / 5) * 5);
    var pk = protein * 4, ck = carbs * 4, fk = fat * 9, tot = pk + ck + fk;
    var h = '';
    h += '<section class="card"><div class="card-title"><h2>Fuel</h2>' + seg('dayType', [['train', 'Training'], ['rest', 'Rest']], type) + '</div>' +
      '<div class="kpis"><div class="kpi"><span class="v">' + kcal.toLocaleString() + '</span><span class="l">kcal</span></div><div class="kpi"><span class="v">' + fixed(plan.macros.fiber, 0) + '<small>g</small></span><span class="l">fiber</span></div><div class="kpi"><span class="v">' + plan.macros.waterL + '<small>L</small></span><span class="l">water</span></div></div>' +
      '<div class="macro-bar" role="img" aria-label="Protein ' + protein + ' g, carbs ' + carbs + ' g, fat ' + fat + ' g"><span class="mb-p" style="width:' + (pk / tot * 100).toFixed(1) + '%"></span><span class="mb-c" style="width:' + (ck / tot * 100).toFixed(1) + '%"></span><span class="mb-f" style="width:' + (fk / tot * 100).toFixed(1) + '%"></span></div>' +
      '<div class="legend"><span><i class="mb-p"></i>Protein <b>' + protein + ' g</b></span><span><i class="mb-c"></i>Carbs <b>' + carbs + ' g</b></span><span><i class="mb-f"></i>Fat <b>' + fat + ' g</b></span></div></section>';

    var base = dayItems(style, state.meals);
    var scaled = C.scaleDay(K.FOODS, base, kcal, protein);
    var slots = [['breakfast', 'Breakfast'], ['lunch', 'Lunch'], ['snack', 'Snack'], ['dinner', 'Dinner']];
    h += '<section class="stack"><div class="section-head"><h2>Sample day</h2>' + selectInline('diet', { omnivore: 'Omnivore', vegetarian: 'Vegetarian', vegan: 'Vegan' }, style) + '</div>';
    h += '<p class="small muted">Portions are scaled to your targets. Weigh cooked foods on a kitchen scale for the first 2 weeks.</p>';
    slots.forEach(function (sl) {
      var opts = K.MEALS[style][sl[0]], idx = (state.meals[style + ':' + sl[0]] || 0) % opts.length, meal = opts[idx];
      var its = scaled.items.filter(function (it) { return it.slot === sl[0]; });
      var mt = C.macroOf(K.FOODS, its);
      h += '<article class="card meal"><div class="meal-head"><div><div class="eyebrow">' + sl[1] + '</div><div class="meal-name">' + esc(meal.name) + '</div></div>' +
        (opts.length > 1 ? '<button class="btn small" data-act="swap-meal" data-slot="' + sl[0] + '">Swap (' + (idx + 1) + '/' + opts.length + ')</button>' : '') + '</div>' +
        '<table class="foods">' + its.map(function (it) { return '<tr><td>' + esc(K.FOODS[it.food].name) + '</td><td>' + it.g + ' g' + (imperial() ? ' <span class="muted" style="font-weight:400">(' + (it.g / 28.35).toFixed(1) + ' oz)</span>' : '') + '</td></tr>'; }).join('') + '</table>' +
        '<p class="small">' + esc(meal.how) + '</p>' +
        '<p class="meal-macros">' + Math.round(mt.kcal) + ' kcal · P ' + Math.round(mt.p) + ' g · C ' + Math.round(mt.c) + ' g · F ' + Math.round(mt.f) + ' g</p></article>';
    });
    var T = scaled.totals;
    h += '<div class="card flat"><div class="card-title"><b>Day total</b><span class="meal-macros">' + Math.round(T.kcal) + ' kcal · P ' + Math.round(T.p) + ' g · C ' + Math.round(T.c) + ' g · F ' + Math.round(T.f) + ' g</span></div>' +
      '<p class="tiny muted">Within about 5% of your target is perfect. Add vegetables freely; they barely count.</p></div></section>';

    // Grocery list for the week
    var trainN = ws.sched.filter(function (d) { return d.lift; }).length;
    var tScaled = C.scaleDay(K.FOODS, base, plan.trainingKcal, protein), rScaled = C.scaleDay(K.FOODS, base, plan.restKcal, protein);
    var sum = {};
    tScaled.items.forEach(function (it) { sum[it.food] = (sum[it.food] || 0) + it.g * trainN; });
    rScaled.items.forEach(function (it) { sum[it.food] = (sum[it.food] || 0) + it.g * (7 - trainN); });
    h += '<section class="card"><details class="more"><summary><h2>Weekly grocery list</h2></summary><p class="small muted" style="margin:8px 0">For this sample day, eaten all week (' + trainN + ' training days). Cooked weights; buy a little more raw meat and dry grains weigh about a third as much.</p><ul class="plain grocery">' +
      Object.keys(sum).sort(function (a, b) { return K.FOODS[a].name < K.FOODS[b].name ? -1 : 1; }).map(function (f) { return '<li><span>' + esc(K.FOODS[f].name.replace(/\s*\(.*\)/, '')) + '</span><span>' + fmtMass(sum[f]) + '</span></li>'; }).join('') + '</ul></details></section>';

    h += '<section class="stack"><div class="section-head"><h2>Rules that matter</h2></div>' + K.NUTRITION_RULES.map(function (r) {
      return '<div class="card flat"><b>' + esc(r.title) + '</b><p class="small">' + esc(r.body) + '</p></div>';
    }).join('') + '</section>';
    return h;
  }
  function selectInline(name, map, current) {
    return '<select class="plain" style="width:auto;min-height:38px;padding:6px 10px" aria-label="Diet style" data-act-change="' + name + '">' + Object.keys(map).map(function (k) {
      return '<option value="' + k + '"' + (k === current ? ' selected' : '') + '>' + esc(map[k]) + '</option>';
    }).join('') + '</select>';
  }

  /* ======================= TRAIN ======================= */
  function viewTrain() {
    var p = state.profile, wk = weekNo(), ph = C.phaseFor(wk), ws = weekSchedule(p, ph.id, wk), scheme = K.SCHEMES[ph.id];
    var todayIdx = dowIndex(todayISO());
    if (ui.pendingDay != null) { ui.trainDay = ui.pendingDay; ui.pendingDay = null; }
    var sel = ui.trainDay == null ? todayIdx : ui.trainDay;
    var d = ws.sched[sel];
    var h = '';
    h += '<section class="card"><div class="card-title"><div><div class="eyebrow">Week ' + wk + ' · Phase ' + ph.id + ' of 4</div><h2>' + esc(ph.name) + '</h2></div><span class="pill">' + esc(ws.split.name.split(',')[0]) + '</span></div>' +
      '<p class="small">' + esc(ph.focus) + '</p>' +
      '<div class="phase-track">' + C.PHASES.map(function (x) { return '<div class="' + (x.id < ph.id ? 'done' : x.id === ph.id ? 'now' : '') + '">' + esc(x.name) + '<br><span class="muted" style="font-weight:500">wk ' + x.weeks[0] + (x.weeks[1] < 900 ? '–' + x.weeks[1] : '+') + '</span></div>'; }).join('') + '</div>' +
      '<p class="small muted"><b>Effort:</b> ' + esc(scheme.effort) + ' Rest ' + esc(scheme.rest) + ' between hard sets.</p></section>';

    h += '<section class="stack"><div class="section-head"><h2>This week</h2><span class="eyebrow">' + esc(ws.split.name) + '</span></div><div class="week">' + ws.sched.map(function (x) {
      var tags = [];
      if (x.lift) tags.push('<span class="pill tape">' + esc(K.WORKOUTS[x.lift].name.replace(/ \(.*\)/, '')) + '</span>');
      if (x.abs != null) tags.push('<span class="pill">Abs ' + (x.abs ? 'B' : 'A') + '</span>');
      if (x.hiit) tags.push('<span class="pill warn">HIIT</span>');
      if (x.liss) tags.push('<span class="pill info">Zone 2</span>');
      if (!tags.length) tags.push('<span class="pill">Rest · steps</span>');
      return '<button class="day' + (x.i === todayIdx ? ' today' : '') + '" data-act="pick-day" data-day="' + x.i + '" aria-pressed="' + (x.i === sel) + '"><span class="dname">' + DAYS[x.i] + '</span><span class="dtags">' + tags.join('') + '</span></button>';
    }).join('') + '</div></section>';

    // Session detail
    h += '<section class="card" id="session"><div class="card-title"><h2>' + DAYS[sel] + (sel === todayIdx ? ' · Today' : '') + '</h2>' + (d.lift ? '<span class="eyebrow">≈ ' + (d.abs != null ? 70 : 55) + ' min</span>' : '') + '</div>';
    if (d.lift) {
      var w = K.WORKOUTS[d.lift];
      h += '<div><div class="eyebrow">Warm-up · 8 min</div><p class="small">5 min easy cardio, then 2 light ramp-up sets of the first lift.</p></div>';
      h += '<div><div class="eyebrow">' + esc(w.name) + '</div>' + w.main.map(function (id) { return exerciseRow(id, scheme.main[0] + ' × ' + scheme.main[1]); }).join('') + w.acc.map(function (id) { return exerciseRow(id, scheme.acc[0] + ' × ' + scheme.acc[1]); }).join('') + '</div>';
    } else {
      h += '<p class="small">No lifting today. Hit your step target, and spend 10 minutes on hip and upper-back mobility. Recovery days are when muscle is built.</p>';
    }
    if (d.abs != null) {
      var circ = K.AB_CIRCUITS[ph.id][d.abs];
      h += '<div><div class="eyebrow">Ab circuit ' + (d.abs ? 'B' : 'A') + ' · rest 45 s between moves</div>' + circ.map(function (x) { return exerciseRow(x[0], x[1] + ' × ' + x[2]); }).join('') + '</div>';
    }
    if (d.hiit) { var hi = K.HIIT[ws.exp]; h += '<div class="insight warn"><div><b>HIIT: ' + esc(hi.name) + '</b><p>' + esc(hi.detail) + (d.lift ? ' Do it after lifting or later in the day.' : '') + '</p></div></div>'; }
    if (d.liss) h += '<div class="insight info"><div><b>Zone 2 cardio: ' + ws.cardio.liss[1] + ' min</b><p>' + esc(K.LISS_INFO) + '</p></div></div>';
    h += '<div class="insight"><div><b>Steps: ' + ws.cardio.steps.toLocaleString() + '</b><p>Every day, including rest days. Workouts count toward it.</p></div></div>';
    h += '</section>';

    h += '<section class="card"><h2>Cardio plan</h2><div class="kpis"><div class="kpi"><span class="v">' + (ws.cardio.steps / 1000) + 'k</span><span class="l">steps a day</span></div><div class="kpi"><span class="v">' + ws.cardio.liss[0] + '×' + ws.cardio.liss[1] + '</span><span class="l">zone 2 (min)</span></div><div class="kpi"><span class="v">' + ws.cardio.hiit[ws.exp] + '</span><span class="l">HIIT a week</span></div></div>' +
      '<p class="small muted">Cardio ramps up through the phases as your body adapts to eating less. Lifting is what keeps the muscle; cardio widens the deficit.</p></section>';

    h += '<section class="card"><details class="more"><summary><h2>Exercise library</h2></summary><div class="stack" style="margin-top:8px">' +
      ['core', 'strength'].map(function (g) {
        return '<div><div class="eyebrow">' + (g === 'core' ? 'Core and abs' : 'Strength') + '</div>' + Object.keys(K.EXERCISES).filter(function (id) { return K.EXERCISES[id].group === g; }).map(function (id) { return exerciseRow(id, ''); }).join('') + '</div>';
      }).join('') + '</div></details></section>';
    return h;
  }

  /* ======================= PROGRESS ======================= */
  function viewProgress() {
    var p = state.profile, plan = getPlan(), list = entriesSorted(), last = list[list.length - 1] || {};
    var neck = latestWith('neckCm', list), hip = latestWith('hipCm', list);
    var h = '';
    // Summary
    var first = list[0], wFirst = latestWithFrom(list, 'weightKg', true), wLast = latestWith('weightKg', list);
    var waFirst = latestWithFrom(list, 'waistCm', true), waLast = latestWith('waistCm', list);
    var bfs = bfSeries();
    function delta(a, b, fmt) { if (!a || !b || a === b) return '–'; var d = b - a; return (d > 0 ? '+' : '−') + fmt(Math.abs(d)); }
    h += '<section class="card"><div class="card-title"><h2>Since ' + (first ? fmtDate(first.date) : 'the start') + '</h2><span class="eyebrow">' + plural(list.length, 'check-in') + '</span></div><div class="kpis">' +
      '<div class="kpi"><span class="v">' + delta(wFirst && wFirst.weightKg, wLast && wLast.weightKg, function (v) { return fixed(toW(v)); }) + '<small>' + wUnit() + '</small></span><span class="l">weight</span></div>' +
      '<div class="kpi"><span class="v">' + delta(waFirst && waFirst.waistCm, waLast && waLast.waistCm, function (v) { return fixed(toL(v)); }) + '<small>' + lUnit() + '</small></span><span class="l">waist</span></div>' +
      '<div class="kpi"><span class="v">' + (bfs.length > 1 ? delta(bfs[0].v, bfs[bfs.length - 1].v, function (v) { return fixed(v); }) : '–') + '<small>%</small></span><span class="l">body fat</span></div></div></section>';

    // Check-in form
    var method = '';
    h += '<section class="card" id="checkin"><div class="card-title"><h2>Weekly check-in</h2><span class="eyebrow">' + ICONS.tape.replace('<svg', '<svg width="22" height="22" style="vertical-align:-6px;stroke:currentColor;fill:none;stroke-width:1.8"') + '</span></div>' +
      '<p class="small muted">Same day each week, in the morning after the bathroom and before food.</p>' +
      '<div class="grid2"><div class="field"><label for="ci-date">Date</label><input class="plain" id="ci-date" type="date" value="' + todayISO() + '" max="' + todayISO() + '"></div>' + numField('ci-weight', 'Weight', '', wUnit(), '') + '</div>' +
      '<div class="grid2">' + numField('ci-waist', p.sex === 'female' ? 'Waist (narrowest)' : 'Waist (at navel)', '', lUnit(), '') + numField('ci-neck', 'Neck', neck ? inputVal(toL(neck.neckCm)) : '', lUnit(), 'Changes slowly') + '</div>' +
      (p.sex === 'female' ? numField('ci-hip', 'Hips (widest)', hip ? inputVal(toL(hip.hipCm)) : '', lUnit(), '') : '') +
      '<details class="more"><summary class="small">Add a body-fat test result</summary><div class="grid2" style="margin-top:8px">' + selectField('ci-method', 'Test type', Object.assign({ '': 'Choose…' }, mapLabels(C.TEST_METHODS)), method) + numField('ci-bf', 'Result', '', '%', '') + '</div></details>' +
      '<details class="more"><summary class="small">How to measure</summary><ul class="small" style="margin:8px 0 0;padding-left:18px;display:flex;flex-direction:column;gap:4px">' +
      '<li><b>Waist:</b> ' + esc(p.sex === 'female' ? K.TAPE_GUIDE.waist_female : K.TAPE_GUIDE.waist_male) + '</li><li><b>Neck:</b> ' + esc(K.TAPE_GUIDE.neck) + '</li>' + (p.sex === 'female' ? '<li><b>Hips:</b> ' + esc(K.TAPE_GUIDE.hip) + '</li>' : '') + '<li>' + esc(K.TAPE_GUIDE.tips) + '</li></ul></details>' +
      '<button class="btn primary block" data-act="save-checkin">Save check-in</button></section>';

    // Charts
    h += '<section class="stack"><div class="section-head"><h2>Trends</h2></div>' +
      '<div class="card"><div class="card-title"><b>Body fat</b><span class="eyebrow">%</span></div>' + lineChart(bfs, { label: 'Body fat trend', target: plan.targetBf, empty: 'Log your waist at two check-ins to see your body-fat trend.' }) + '</div>' +
      '<div class="card"><div class="card-title"><b>Weight</b><span class="eyebrow">' + wUnit() + '</span></div>' + lineChart(list.filter(function (e) { return e.weightKg != null; }).map(function (e) { return { date: e.date, v: toW(e.weightKg) }; }), { label: 'Weight trend', target: plan.mode === 'cut' ? toW(plan.targetWeight) : null }) + '</div>' +
      '<div class="card"><div class="card-title"><b>Waist</b><span class="eyebrow">' + lUnit() + '</span></div>' + lineChart(list.filter(function (e) { return e.waistCm != null; }).map(function (e) { return { date: e.date, v: toL(e.waistCm) }; }), { label: 'Waist trend' }) + '</div></section>';

    // Photos
    h += photosSection();

    // History
    if (list.length) {
      h += '<section class="card"><details class="more"><summary><h2>History</h2></summary><div class="table-scroll" style="margin-top:8px"><table class="entries"><thead><tr><th>Date</th><th>Weight</th><th>Waist</th><th>Test</th><th></th></tr></thead><tbody>' +
        list.slice().reverse().map(function (e) {
          return '<tr><td>' + fmtDate(e.date, true) + '</td><td>' + (e.weightKg != null ? fixed(toW(e.weightKg)) : '–') + '</td><td>' + (e.waistCm != null ? fixed(toL(e.waistCm)) : '–') + '</td><td>' + (e.test ? fixed(e.test.value) + '%' : '–') + '</td><td><button class="iconbtn" aria-label="Delete check-in from ' + fmtDate(e.date) + '" data-act="del-entry" data-id="' + e.id + '">×</button></td></tr>';
        }).join('') + '</tbody></table></div></details></section>';
    }
    return h;
  }
  function latestWithFrom(list, key) { for (var i = 0; i < list.length; i++) if (list[i][key] != null) return list[i]; return null; }
  function mapLabels(m) { var o = {}; Object.keys(m).forEach(function (k) { o[k] = m[k].label; }); return o; }

  function photosSection() {
    var photos = state.photos.slice().sort(function (a, b) { return a.date < b.date ? 1 : -1; });
    var h = '<section class="card" id="photos"><div class="card-title"><h2>Photos</h2><span class="eyebrow">' + plural(photos.length, 'photo') + '</span></div>';
    h += '<div class="row">' + seg('addPose', [['front', 'Front'], ['side', 'Side'], ['back', 'Back'], ['flexed', 'Flexed']], ui.addPose) + '</div>' +
      '<label class="btn tape block" for="photo-file">' + ICONS.camera.replace('<svg', '<svg width="20" height="20" style="stroke:currentColor;fill:none;stroke-width:1.8"') + ' Add ' + ui.addPose + ' photo</label>' +
      '<input id="photo-file" type="file" accept="image/*" hidden data-act-change="photo">' +
      '<details class="more"><summary class="small">How to take good progress photos</summary><ul class="small" style="margin:8px 0 0;padding-left:18px">' + K.PHOTO_GUIDE.map(function (g) { return '<li>' + esc(g) + '</li>'; }).join('') + '</ul></details>';
    if (!photos.length) {
      h += '<div class="chart-empty">No photos yet. Your first set becomes the baseline you compare against.</div></section>';
      return h;
    }
    // Compare
    if (photos.length >= 2) {
      var asc = photos.slice().reverse();
      var A = byId(ui.cmpA) || asc[0];
      // Default "after" photo: the newest one with the same pose as "before".
      var B = byId(ui.cmpB) || photos.filter(function (x) { return x.pose === A.pose && x.id !== A.id; })[0] || photos[0];
      var opt = function (cur) { return photos.map(function (x) { return '<option value="' + x.id + '"' + (x.id === cur.id ? ' selected' : '') + '>' + fmtDate(x.date, true) + ' · ' + x.pose + '</option>'; }).join(''); };
      h += '<hr class="divider"><div class="card-title"><b>Compare</b>' + seg('cmpMode', [['side', 'Side by side'], ['slider', 'Slider']], ui.cmpMode) + '</div>' +
        '<div class="grid2"><select class="plain" aria-label="Before photo" data-act-change="cmpA">' + opt(A) + '</select><select class="plain" aria-label="After photo" data-act-change="cmpB">' + opt(B) + '</select></div>';
      var days = Math.round((C.parseISO(B.date) - C.parseISO(A.date)) / C.DAY);
      if (ui.cmpMode === 'slider') {
        h += '<div class="slider-wrap"><img src="' + (photoData[A.id] || '') + '" alt="Before, ' + fmtDate(A.date) + '"><div class="after" id="cmp-after" style="clip-path:inset(0 0 0 50%)"><img src="' + (photoData[B.id] || '') + '" alt="After, ' + fmtDate(B.date) + '"></div><div class="handle" id="cmp-handle" style="left:50%"></div><span class="lbl" style="left:8px">' + fmtDate(A.date) + '</span><span class="lbl" style="right:8px">' + fmtDate(B.date) + '</span></div>' +
          '<input type="range" id="cmp-slider" min="0" max="100" value="50" aria-label="Reveal after photo">';
      } else {
        h += '<div class="compare"><figure><img src="' + (photoData[A.id] || '') + '" alt="Before, ' + fmtDate(A.date) + '"><figcaption>' + fmtDate(A.date, true) + '</figcaption></figure><figure><img src="' + (photoData[B.id] || '') + '" alt="After, ' + fmtDate(B.date) + '"><figcaption>' + fmtDate(B.date, true) + '</figcaption></figure></div>';
      }
      h += '<p class="small muted" style="text-align:center">' + (days === 0 ? 'Same day' : plural(Math.abs(days), 'day') + ' apart') + '</p>';
    }
    // Gallery by date
    var byDate = {};
    photos.forEach(function (x) { (byDate[x.date] = byDate[x.date] || []).push(x); });
    h += '<hr class="divider">' + Object.keys(byDate).sort().reverse().map(function (d) {
      return '<div class="photo-day"><div class="eyebrow">' + fmtDate(d, true) + '</div><div class="photo-grid">' + byDate[d].map(function (x) {
        return '<button class="photo" data-act="view-photo" data-id="' + x.id + '" aria-label="' + x.pose + ' photo, ' + fmtDate(d) + '"><img src="' + (photoData[x.id] || '') + '" alt=""><span>' + x.pose + '</span></button>';
      }).join('') + '</div></div>';
    }).join('');
    return h + '</section>';
  }
  function byId(id) { for (var i = 0; i < state.photos.length; i++) if (state.photos[i].id === id) return state.photos[i]; return null; }

  /* ======================= ME ======================= */
  function viewMe() {
    var p = state.profile, plan = getPlan(), est = plan.estimate;
    var h = '';
    h += '<section class="card"><div class="card-title"><h2>Body-fat estimate</h2><span class="eyebrow">' + (est ? fixed(est.value) + '%' : '–') + '</span></div>' +
      (est ? '<ul class="plain small stack" style="gap:4px">' + est.items.map(function (i) { return '<li class="row between"><span>' + esc(i.label) + '</span><b>' + fixed(i.value) + '%</b></li>'; }).join('') + '</ul>' : '') +
      '<p class="small muted">Combined by how accurate each method is. A DEXA or Bod Pod result counts most. Add a test result or retake the visual check to refine it.</p>' +
      '<details class="more"' + (ui.openVisual ? ' open' : '') + '><summary>Visual check</summary><div style="margin-top:10px" class="stack">' + visualPicker(p.sex, p.visual ? p.visual.level : null, 'me') + '</div></details></section>';

    h += '<section class="card"><h2>Profile and plan</h2>' +
      '<div class="field"><span class="label">Units</span>' + seg('units', [['imperial', 'lb / in'], ['metric', 'kg / cm']], p.units) + '</div>' +
      '<div class="grid2">' + selectField('pf-sex', 'Sex (for body-fat formulas)', { male: 'Male', female: 'Female' }, p.sex) + numField('pf-age', 'Age', p.age, 'yrs', '') + '</div>' +
      heightFields(p.heightCm, 'pf', false) +
      selectField('pf-goal', 'Goal', C.GOALS, p.goal) +
      selectField('pf-pace', 'Pace', C.PACE, p.pace) +
      selectField('pf-job', 'Daily activity outside workouts', C.JOB, p.job) +
      '<div class="grid2">' + selectField('pf-days', 'Lifting days a week', { 3: '3 days', 4: '4 days', 5: '5 days', 6: '6 days' }, p.days) + selectField('pf-exp', 'Lifting experience', { beginner: 'Beginner (under 1 year)', intermediate: 'Intermediate (1–3 years)', advanced: 'Advanced (3+ years)' }, p.experience) + '</div>' +
      selectField('pf-diet', 'Diet style', { omnivore: 'Omnivore', vegetarian: 'Vegetarian', vegan: 'Vegan' }, p.diet) +
      '<div class="field"><label for="pf-start">Plan start date</label><input class="plain" id="pf-start" type="date" value="' + esc(p.startDate) + '"><span class="hint">Sets your week number and training phase.</span></div>' +
      (p.sex === 'female' ? '<label class="check"><input type="checkbox" id="pf-preg"' + (p.pregnant ? ' checked' : '') + '> I am pregnant or breastfeeding</label>' : '') +
      '<button class="btn primary block" data-act="save-profile">Save changes</button></section>';

    h += '<section class="card"><h2>Your data</h2><p class="small muted">Everything stays on this device' + (Store.isPersistent() ? '' : ' for this session only (storage is blocked in this browser, so data will not be kept)') + '. Nothing is uploaded. Export a backup before changing phones.</p>' +
      '<div class="row"><button class="btn" data-act="export">Export backup</button><label class="btn" for="import-file">Import backup</label><input id="import-file" type="file" accept="application/json,.json" hidden data-act-change="import"></div>' +
      (ui.confirmReset ? '<div class="notice"><b>Delete everything?</b> This removes your profile, check-ins and photos from this device. It cannot be undone.<div class="row" style="margin-top:10px"><button class="btn danger" data-act="reset-yes">Delete everything</button><button class="btn ghost" data-act="reset-no">Keep my data</button></div></div>' : '<button class="btn danger" data-act="reset">Delete all data</button>') + '</section>';

    h += safetyCard();
    return h;
  }
  function safetyCard() {
    return '<section class="card flat"><h3>Health and safety</h3><ul class="small" style="margin:0;padding-left:18px;display:flex;flex-direction:column;gap:6px">' +
      '<li>CoreCut gives general fitness and nutrition guidance. It is not medical advice and does not replace a doctor or dietitian.</li>' +
      '<li>Check with a doctor before starting if you have heart, kidney, liver or blood-sugar conditions, take medication, are pregnant, or have had an eating disorder.</li>' +
      '<li>Stop exercising and get help for chest pain, fainting, severe shortness of breath, or sharp joint pain.</li>' +
      '<li>If food, weight or your body is taking over your thoughts, you are not alone. In the US, the ANAD helpline is free: <b>1-888-375-7767</b>. In a crisis, call or text <b>988</b>.</li></ul></section>';
  }

  function visualPicker(sex, current, ctx) {
    var levels = C.VISUAL_LEVELS[sex === 'female' ? 'female' : 'male'];
    return '<p class="small muted">Stand in front of a mirror in good overhead light, relaxed (not flexed or sucking in). Pick the description closest to what you see. If you are between two, pick the higher one.</p>' +
      '<div class="figures">' + levels.map(function (l, i) {
        return '<button class="figure" data-act="visual" data-ctx="' + ctx + '" data-val="' + l.id + '" aria-pressed="' + (current === l.id) + '">' + torsoSVG(i, sex) +
          '<span class="range">' + l.lo + '–' + l.hi + '%</span><span class="ftitle">' + esc(l.title) + '</span><span class="fdesc">' + esc(l.desc) + '</span></button>';
      }).join('') + '</div><p class="tiny muted">Drawings show the general pattern only. Where fat sits varies a lot from person to person.</p>';
  }

  /* ======================= ONBOARDING ======================= */
  function newDraft() {
    return { step: 0, agree: false, units: 'imperial', sex: 'male', age: null, heightCm: null, weightKg: null, testMethod: '', testValue: null, neckCm: null, waistCm: null, hipCm: null, visual: null, refPhoto: null, goal: 'sixpack', pace: 'steady', job: 'desk', days: 4, experience: 'beginner', diet: 'omnivore', pregnant: false };
  }
  function draftEstimate() {
    var d = draft;
    return C.estimateBodyFat({ sex: d.sex, age: d.age, heightCm: d.heightCm, weightKg: d.weightKg, neckCm: d.neckCm, waistCm: d.waistCm, hipCm: d.hipCm, test: d.testMethod && d.testValue ? { method: d.testMethod, value: d.testValue } : null, visualLevel: d.visual });
  }
  function viewOnboarding() {
    var d = draft, h = '';
    if (d.step === 0) {
      return '<div class="welcome view-enter"><div class="eyebrow">Visible abs, planned</div><h1>Get lean enough to see your abs.</h1>' +
        '<p class="lede">A plan built from your height, weight and body fat, then adjusted every week from your own progress.</p>' +
        '<ul class="plain feature-list">' +
        '<li><span class="fi">' + ICONS.tape + '</span><div><b>Know your number</b><span>Enter a DEXA or other test, or estimate with a tape measure and a visual check.</span></div></li>' +
        '<li><span class="fi">' + ICONS.plate + '</span><div><b>Meals that hit your macros</b><span>Calories, protein and sample days scaled to you. Omnivore, vegetarian or vegan.</span></div></li>' +
        '<li><span class="fi">' + ICONS.train + '</span><div><b>Lifting, abs and cardio</b><span>A 4-phase program with ab circuits that progress and cardio that ramps up.</span></div></li>' +
        '<li><span class="fi">' + ICONS.camera + '</span><div><b>Photos and coaching</b><span>Private progress photos, side-by-side compare, and advice when you stall.</span></div></li></ul>' +
        '<label class="check"><input type="checkbox" id="ob-agree"' + (d.agree ? ' checked' : '') + '> <span class="small">I am 18 or older. I understand CoreCut gives general fitness guidance, not medical advice, and I will check with a doctor if I have health conditions.</span></label>' +
        '<div class="stack"><button class="btn primary block" data-act="ob-next"' + (d.agree ? '' : ' disabled') + ' id="ob-start">Set up my plan</button><button class="btn ghost block" data-act="sample">Explore with sample data</button></div>' +
        '<p class="tiny muted">Your data and photos stay on this device. No account needed.</p></div>';
    }
    h += '<div class="ob-progress" aria-label="Step ' + d.step + ' of 4">' + [1, 2, 3, 4].map(function (i) { return '<i class="' + (i <= d.step ? 'on' : '') + '"></i>'; }).join('') + '</div>';
    if (d.step === 1) {
      h += '<div class="stack-lg view-enter"><div><div class="eyebrow">Step 1 of 4</div><h1>About you</h1></div>' +
        '<div class="field"><span class="label">Units</span>' + seg('ob-units', [['imperial', 'lb / in'], ['metric', 'kg / cm']], d.units) + '</div>' +
        '<div class="field"><span class="label">Sex</span>' + seg('ob-sex', [['male', 'Male'], ['female', 'Female']], d.sex) + '<span class="hint">Used for the body-fat formulas and targets.</span></div>' +
        numField('ob-age', 'Age', d.age || '', 'years', '', 'age') +
        heightFields(d.heightCm, 'ob', true) +
        numField('ob-weight', 'Weight', inputVal(toW(d.weightKg)), wUnit(), 'Morning, after the bathroom, before food.', 'weight') +
        (d.sex === 'female' ? '<label class="check"><input type="checkbox" id="ob-preg" data-bind="pregnant"' + (d.pregnant ? ' checked' : '') + '> I am pregnant or breastfeeding</label>' : '') +
        '<div id="ob-err" class="notice" hidden></div></div>';
    } else if (d.step === 2) {
      var methods = Object.assign({ '': 'Choose…' }, mapLabels(C.TEST_METHODS));
      h += '<div class="stack-lg view-enter"><div><div class="eyebrow">Step 2 of 4</div><h1>Body fat</h1><p class="muted" style="margin-top:6px">Use any or all of these. More methods give a better estimate.</p></div>' +
        '<section class="card"><h3>I have a test result</h3><div class="grid2">' + selectField('ob-method', 'Test type', methods, d.testMethod, 'testMethod') + numField('ob-bf', 'Result', inputVal(d.testValue), '%', '', 'testValue') + '</div><p class="tiny muted">DEXA, Bod Pod and underwater weighing are the most accurate. Home scales can be off by 5% or more.</p></section>' +
        '<section class="card"><h3>Tape measure</h3><p class="small muted">' + esc(K.TAPE_GUIDE.tips) + '</p>' +
        '<div class="grid2">' + numField('ob-waist', d.sex === 'female' ? 'Waist (narrowest)' : 'Waist (at navel)', inputVal(toL(d.waistCm)), lUnit(), '', 'waistCm') + numField('ob-neck', 'Neck', inputVal(toL(d.neckCm)), lUnit(), '', 'neckCm') + '</div>' +
        (d.sex === 'female' ? numField('ob-hip', 'Hips (widest)', inputVal(toL(d.hipCm)), lUnit(), '', 'hipCm') : '') +
        '<details class="more"><summary class="small">Where exactly to measure</summary><ul class="small" style="margin:8px 0 0;padding-left:18px;display:flex;flex-direction:column;gap:4px"><li><b>Waist:</b> ' + esc(d.sex === 'female' ? K.TAPE_GUIDE.waist_female : K.TAPE_GUIDE.waist_male) + '</li><li><b>Neck:</b> ' + esc(K.TAPE_GUIDE.neck) + '</li>' + (d.sex === 'female' ? '<li><b>Hips:</b> ' + esc(K.TAPE_GUIDE.hip) + '</li>' : '') + '</ul></details></section>' +
        '<section class="card"><h3>Visual check</h3>' +
        '<div class="ref-photo">' + (d.refPhoto ? '<img src="' + d.refPhoto + '" alt="Your reference photo">' : '<div class="chart-empty" style="aspect-ratio:3/4;display:grid;place-items:center;padding:8px">' + ICONS.camera.replace('<svg', '<svg width="28" height="28" style="stroke:currentColor;fill:none;stroke-width:1.6"') + '</div>') +
        '<div class="stack"><p class="small">Add a relaxed front photo to compare against the descriptions. It becomes your first progress photo.</p><label class="btn small" for="ob-photo">' + (d.refPhoto ? 'Replace photo' : 'Add photo') + '</label><input id="ob-photo" type="file" accept="image/*" hidden data-act-change="ob-photo"></div></div>' +
        visualPicker(d.sex, d.visual, 'ob') + '</section>' +
        '<div id="bf-live">' + liveEstimateHTML() + '</div></div>';
    } else if (d.step === 3) {
      h += '<div class="stack-lg view-enter"><div><div class="eyebrow">Step 3 of 4</div><h1>Your plan</h1></div>' +
        '<div class="field"><span class="label">Goal</span>' + choiceList('ob-goal', goalMap(d.sex), d.goal) + '</div>' +
        '<div class="field"><span class="label">Pace</span>' + choiceList('ob-pace', C.PACE, d.pace) + '</div>' +
        '<div class="field"><span class="label">Daily activity outside workouts</span>' + choiceList('ob-job', C.JOB, d.job) + '</div>' +
        '<div class="field"><span class="label">Lifting days a week</span>' + seg('ob-days', [[3, '3'], [4, '4'], [5, '5'], [6, '6']], d.days) + '</div>' +
        '<div class="field"><span class="label">Lifting experience</span>' + seg('ob-exp', [['beginner', 'New'], ['intermediate', '1–3 yrs'], ['advanced', '3+ yrs']], d.experience) + '</div>' +
        '<div class="field"><span class="label">Diet style</span>' + seg('ob-diet', [['omnivore', 'Omnivore'], ['vegetarian', 'Vegetarian'], ['vegan', 'Vegan']], d.diet) + '</div></div>';
    } else if (d.step === 4) {
      var est = draftEstimate();
      var plan = C.buildPlan({ sex: d.sex, age: d.age, heightCm: d.heightCm, weightKg: d.weightKg, job: d.job, days: d.days, goal: d.goal, pace: d.pace, pregnant: d.pregnant }, est ? est.value : 25);
      h += '<div class="stack-lg view-enter"><div><div class="eyebrow">Step 4 of 4</div><h1>Here is your plan</h1></div>';
      if (plan.mode === 'blocked') {
        h += '<div class="notice">' + esc(plan.blockReason) + '</div>';
      } else {
        h += '<section class="hero"><div class="eyebrow">' + esc(plan.goalLabel) + '</div><div class="hero-figures"><div class="hero-big">' + fixed(plan.bf) + '<small>%</small></div><div class="hero-side">Goal ' + plan.targetBf + '%<b>' + (plan.mode === 'cut' ? plan.weeksLow + '–' + plan.weeksHigh + ' weeks' : 'Maintain') + '</b></div></div>' +
          tapeSVG(plan.bf, plan.bf, plan.targetBf) + '<div class="hero-foot"><span>' + fmtW(d.weightKg) + ' now</span><span>≈ ' + fmtW(plan.targetWeight) + ' at goal</span></div></section>' +
          '<div class="kpis"><div class="kpi"><span class="v">' + plan.kcal.toLocaleString() + '</span><span class="l">kcal a day</span></div><div class="kpi"><span class="v">' + plan.macros.protein + '<small>g</small></span><span class="l">protein</span></div><div class="kpi"><span class="v">' + fixed(toW(plan.weeklyLossKg), 2) + '<small>' + wUnit() + '</small></span><span class="l">per week</span></div></div>' +
          '<ul class="small" style="margin:0;padding-left:18px;display:flex;flex-direction:column;gap:4px"><li>Lean mass: about ' + fmtW(plan.lbm) + '. The goal weight assumes you keep it; lifting makes sure you do.</li><li>Maintenance: about ' + Math.round(plan.tdee / 10) * 10 + ' kcal a day.</li><li>Training: ' + esc(K.SPLITS[d.days].name) + ', ab circuits 3 times a week, cardio that ramps up over 4 phases.</li><li>The plan recalculates as you log weekly check-ins.</li></ul>';
        plan.warnings.forEach(function (w) { h += '<div class="notice">' + esc(w) + '</div>'; });
      }
      h += '</div>';
    }
    h += '<div class="sticky-actions"><button class="btn" data-act="ob-back">Back</button><button class="btn primary" data-act="' + (d.step === 4 ? 'ob-finish' : 'ob-next') + '">' + (d.step === 4 ? 'Start my plan' : 'Continue') + '</button></div>';
    return h;
  }
  function goalMap(sex) {
    var o = {}; Object.keys(C.GOALS).forEach(function (k) { var g = C.GOALS[k]; o[k] = { label: g.label + ' · ' + g[sex] + '%', desc: g.desc }; }); return o;
  }
  function liveEstimateHTML() {
    var est = draftEstimate();
    if (!est) return '<div class="estimate-box"><span class="eyebrow" style="color:inherit;opacity:.7">Your estimate</span><p>Fill in any section above to see your estimate.</p></div>';
    var bmiOnly = est.items.length === 1 && est.items[0].source === 'bmi';
    return '<div class="estimate-box"><span class="eyebrow" style="color:inherit;opacity:.7">Your estimate</span><div class="big">' + fixed(est.value) + '%</div><span class="muted small">Likely range ' + fixed(est.low) + '–' + fixed(est.high) + '%</span>' +
      '<ul class="plain">' + est.items.map(function (i) { return '<li>' + esc(i.label) + ': ' + fixed(i.value) + '%</li>'; }).join('') + '</ul>' +
      (bmiOnly ? '<p class="small">This is a rough guess from your BMI. Add a waist measurement or the visual check for a much better number.</p>' : '') + '</div>';
  }

  /* ======================= Rendering ======================= */
  var lastRoute = null;
  function render() {
    var view = $('#view');
    if (!state.profile) {
      if (!draft) draft = newDraft();
      renderChrome(null);
      view.innerHTML = viewOnboarding();
      return;
    }
    var r = route();
    renderChrome(r);
    var html = r === 'food' ? viewFood() : r === 'train' ? viewTrain() : r === 'progress' ? viewProgress() : r === 'me' ? viewMe() : viewToday();
    view.innerHTML = html;
    if (r !== lastRoute) { window.scrollTo(0, 0); lastRoute = r; }
  }

  var toastTimer = null;
  function toast(msg) {
    var t = $('#toast'); t.textContent = msg; t.hidden = false;
    clearTimeout(toastTimer); toastTimer = setTimeout(function () { t.hidden = true; }, 2400);
  }

  function modal(html) {
    closeModal();
    var m = document.createElement('div'); m.className = 'modal'; m.id = 'modal';
    m.innerHTML = '<div class="modal-card" role="dialog" aria-modal="true">' + html + '</div>';
    m.addEventListener('click', function (e) { if (e.target === m) closeModal(); });
    document.body.appendChild(m);
  }
  function closeModal() { var m = $('#modal'); if (m) m.remove(); }

  /* ======================= Actions ======================= */
  function readOnboardingStep1() {
    var d = draft;
    d.age = num(($('#ob-age') || {}).value);
    d.heightCm = readHeight('ob');
    d.weightKg = fromW(num(($('#ob-weight') || {}).value));
    var pr = $('#ob-preg'); if (pr) d.pregnant = pr.checked;
  }
  function validateStep1() {
    var d = draft, errs = [];
    if (!d.age || d.age < 13 || d.age > 100) errs.push('Enter your age.');
    if (!d.heightCm || d.heightCm < 120 || d.heightCm > 230) errs.push('Enter your height.');
    if (!d.weightKg || d.weightKg < 30 || d.weightKg > 300) errs.push('Enter your weight.');
    return errs;
  }

  function finishOnboarding() {
    var d = draft, est = draftEstimate(), iso = todayISO();
    state = blankState();
    state.profile = { units: d.units, sex: d.sex, age: d.age, heightCm: d.heightCm, weightKg: d.weightKg, job: d.job, days: d.days, experience: d.experience, diet: d.diet, goal: d.goal, pace: d.pace, pregnant: d.pregnant, startDate: iso, startBf: est ? Math.round(est.value * 10) / 10 : null, visual: d.visual ? { level: d.visual, date: iso } : null };
    state.entries = [{ id: uid(), date: iso, weightKg: d.weightKg, waistCm: d.waistCm, neckCm: d.neckCm, hipCm: d.sex === 'female' ? d.hipCm : null, test: d.testMethod && d.testValue ? { method: d.testMethod, value: d.testValue } : null }];
    var p = Promise.resolve();
    if (d.refPhoto) p = addPhotoData(d.refPhoto, 'front', iso);
    draft = null;
    p.then(function () { save(); location.hash = '#today'; render(); toast('Plan ready. Week 1 starts today.'); });
  }

  function addPhotoData(dataUrl, pose, date) {
    var id = uid();
    var rec = { id: id, date: date || todayISO(), pose: pose };
    photoData[id] = dataUrl;
    state.photos.push(rec);
    return Store.put('photos', id, Object.assign({ data: dataUrl }, rec)).catch(function () { toast('Photo kept for this session only'); });
  }

  function compressImage(file) {
    return new Promise(function (resolve, reject) {
      var url = URL.createObjectURL(file), img = new Image();
      img.onload = function () {
        var max = 1200, s = Math.min(1, max / Math.max(img.naturalWidth, img.naturalHeight));
        var c = document.createElement('canvas'); c.width = Math.round(img.naturalWidth * s); c.height = Math.round(img.naturalHeight * s);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);
        resolve(c.toDataURL('image/jpeg', 0.82));
      };
      img.onerror = function () { URL.revokeObjectURL(url); reject(new Error('That file could not be opened as an image. Try a JPEG or PNG.')); };
      img.src = url;
    });
  }

  function saveCheckin() {
    var date = ($('#ci-date') || {}).value || todayISO();
    var e = {
      date: date,
      weightKg: fromW(num($('#ci-weight').value)),
      waistCm: fromL(num($('#ci-waist').value)),
      neckCm: fromL(num($('#ci-neck').value)),
      hipCm: $('#ci-hip') ? fromL(num($('#ci-hip').value)) : null
    };
    var m = $('#ci-method').value, bf = num($('#ci-bf').value);
    if (m && bf) { if (bf < 3 || bf > 60) { toast('Body fat should be between 3 and 60%'); return; } e.test = { method: m, value: bf }; }
    if (e.weightKg == null && e.waistCm == null && !e.test) { toast('Enter at least your weight or waist'); return; }
    if (e.weightKg != null && (e.weightKg < 30 || e.weightKg > 300)) { toast('That weight looks off. Check the units.'); return; }
    if (e.waistCm != null && (e.waistCm < 45 || e.waistCm > 200)) { toast('That waist looks off. Check the units.'); return; }
    var existing = state.entries.filter(function (x) { return x.date === date; })[0];
    if (existing) {
      Object.keys(e).forEach(function (k) { if (e[k] != null) existing[k] = e[k]; });
    } else { e.id = uid(); state.entries.push(e); }
    save(); render(); toast(existing ? 'Check-in updated' : 'Check-in saved');
  }

  function saveProfile() {
    var p = state.profile;
    p.sex = $('#pf-sex').value;
    var age = num($('#pf-age').value); if (age) p.age = age;
    var hcm = readHeight('pf'); if (hcm && hcm > 120 && hcm < 230) p.heightCm = hcm;
    p.goal = $('#pf-goal').value; p.pace = $('#pf-pace').value; p.job = $('#pf-job').value;
    p.days = +$('#pf-days').value; p.experience = $('#pf-exp').value; p.diet = $('#pf-diet').value;
    var sd = $('#pf-start').value; if (sd) p.startDate = sd;
    var pr = $('#pf-preg'); p.pregnant = pr ? pr.checked : false;
    save(); render(); toast('Saved. Your plan has been updated.');
  }

  function exportData() {
    var payload = { app: 'CoreCut', version: 1, exported: new Date().toISOString(), state: state, photos: state.photos.map(function (p) { return Object.assign({ data: photoData[p.id] || null }, p); }) };
    try {
      var blob = new Blob([JSON.stringify(payload)], { type: 'application/json' });
      var a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = 'corecut-backup-' + todayISO() + '.json';
      document.body.appendChild(a); a.click(); a.remove();
      setTimeout(function () { URL.revokeObjectURL(a.href); }, 4000);
      toast('Backup file created');
    } catch (e) { toast('This browser blocked the download'); }
  }
  function importData(file) {
    var r = new FileReader();
    r.onload = function () {
      try {
        var data = JSON.parse(r.result);
        if (data.app !== 'CoreCut' || !data.state || !data.state.profile) throw new Error('bad');
        var photos = sanitizePhotos(data.photos || []);
        state = sanitizeState(Object.assign(blankState(), data.state));
        state.photos = photos.map(function (p) { return { id: p.id, date: p.date, pose: p.pose }; });
        photoData = {};
        Store.clear('photos').then(function () {
          return Promise.all(photos.filter(function (p) { return p.data; }).map(function (p) { photoData[p.id] = p.data; return Store.put('photos', p.id, p); }));
        }).then(function () { save(); render(); toast('Backup restored'); });
      } catch (e) { toast('That file is not a CoreCut backup'); }
    };
    r.readAsText(file);
  }

  // Backups are user files that could be edited: keep only well-formed values before they reach the page.
  var ISO_RE = /^\d{4}-\d{2}-\d{2}$/, ID_RE = /^[a-z0-9]{4,40}$/i, POSES = ['front', 'side', 'back', 'flexed'];
  function numOrNull(v) { return typeof v === 'number' && isFinite(v) ? v : null; }
  function pick(v, allowed, dflt) { return allowed.indexOf(v) >= 0 ? v : dflt; }
  function sanitizePhotos(list) {
    return list.filter(function (p) { return p && ID_RE.test(p.id) && ISO_RE.test(p.date) && typeof p.data === 'string' && /^data:image\/(jpeg|png|webp);base64,[A-Za-z0-9+\/=]+$/.test(p.data); })
      .map(function (p) { return { id: p.id, date: p.date, pose: pick(p.pose, POSES, 'front'), data: p.data }; });
  }
  function sanitizeState(s) {
    var p = s.profile || {};
    s.profile = {
      units: pick(p.units, ['imperial', 'metric'], 'imperial'), sex: pick(p.sex, ['male', 'female'], 'male'),
      age: numOrNull(p.age), heightCm: numOrNull(p.heightCm), weightKg: numOrNull(p.weightKg),
      job: pick(p.job, Object.keys(C.JOB), 'desk'), days: pick(+p.days, [3, 4, 5, 6], 4),
      experience: pick(p.experience, ['beginner', 'intermediate', 'advanced'], 'beginner'),
      diet: pick(p.diet, Object.keys(K.MEALS), 'omnivore'), goal: pick(p.goal, Object.keys(C.GOALS), 'sixpack'),
      pace: pick(p.pace, Object.keys(C.PACE), 'steady'), pregnant: !!p.pregnant,
      startDate: ISO_RE.test(p.startDate) ? p.startDate : todayISO(), startBf: numOrNull(p.startBf),
      visual: p.visual && ISO_RE.test(p.visual.date) && /^[mf][1-7]$/.test(p.visual.level) ? { level: p.visual.level, date: p.visual.date } : null
    };
    s.entries = (Array.isArray(s.entries) ? s.entries : []).filter(function (e) { return e && ISO_RE.test(e.date); }).map(function (e) {
      return { id: ID_RE.test(e.id) ? e.id : uid(), date: e.date, weightKg: numOrNull(e.weightKg), waistCm: numOrNull(e.waistCm), neckCm: numOrNull(e.neckCm), hipCm: numOrNull(e.hipCm),
        test: e.test && C.TEST_METHODS[e.test.method] && numOrNull(e.test.value) != null ? { method: e.test.method, value: e.test.value } : null };
    });
    var checks = {}; Object.keys(s.checks || {}).forEach(function (d) { if (ISO_RE.test(d) && s.checks[d] && typeof s.checks[d] === 'object') { checks[d] = {}; Object.keys(s.checks[d]).forEach(function (k) { if (/^[a-z]{2,12}$/.test(k)) checks[d][k] = !!s.checks[d][k]; }); } });
    s.checks = checks;
    var meals = {}; Object.keys(s.meals || {}).forEach(function (k) { if (/^[a-z]+:[a-z]+$/.test(k) && numOrNull(s.meals[k]) != null) meals[k] = Math.abs(Math.round(s.meals[k])); });
    s.meals = meals;
    s.sample = !!s.sample; s.version = 1;
    if (!s.profile.age || !s.profile.heightCm || !s.profile.weightKg) throw new Error('incomplete');
    return s;
  }

  function resetAll() {
    state = blankState(); photoData = {}; draft = newDraft(); ui.confirmReset = false;
    Promise.all([Store.clear('photos'), Store.clear('kv')]).then(function () { location.hash = ''; render(); toast('All data deleted'); });
  }

  function loadSample() {
    var iso = todayISO(), start = isoAdd(iso, -42);
    state = blankState(); state.sample = true;
    state.profile = { units: 'imperial', sex: 'male', age: 34, heightCm: 180, weightKg: 88.5, job: 'desk', days: 4, experience: 'intermediate', diet: 'omnivore', goal: 'sixpack', pace: 'steady', pregnant: false, startDate: start, startBf: 21.4, visual: { level: 'm5', date: start } };
    var w = [88.5, 88.0, 87.4, 86.9, 86.6, 85.9, 85.4], wa = [95.5, 95.0, 94.2, 93.6, 93.1, 92.3, 91.6];
    state.entries = w.map(function (x, i) { return { id: uid(), date: isoAdd(start, i * 7), weightKg: x, waistCm: wa[i], neckCm: 39.5, hipCm: null, test: null }; });
    state.entries[0].test = { method: 'smart_scale', value: 23.5 };
    for (var k = 1; k <= 9; k++) {
      var dd = isoAdd(iso, -k);
      state.checks[dd] = { train: k % 3 !== 0, move: true, protein: k % 4 !== 0, calories: true, water: k % 2 === 0, sleep: k % 5 !== 0 };
    }
    draft = null; save(); location.hash = '#today'; render();
  }

  document.addEventListener('click', function (ev) {
    var el = ev.target.closest('[data-act]'); if (!el) return;
    var act = el.getAttribute('data-act'), name = el.getAttribute('data-name'), val = el.getAttribute('data-val');
    switch (act) {
      case 'seg': handleSeg(name, val); break;
      case 'choice': draft[name.replace('ob-', '')] = val; render(); break;
      case 'ob-next':
        if (draft.step === 1) { readOnboardingStep1(); var errs = validateStep1(); if (errs.length) { var e = $('#ob-err'); e.textContent = errs.join(' '); e.hidden = false; return; } }
        draft.step++; render(); window.scrollTo(0, 0); break;
      case 'ob-back': if (draft.step === 1) readOnboardingStep1(); draft.step = Math.max(0, draft.step - 1); render(); window.scrollTo(0, 0); break;
      case 'ob-finish': finishOnboarding(); break;
      case 'sample': loadSample(); break;
      case 'visual':
        if (el.getAttribute('data-ctx') === 'ob') {
          draft.visual = draft.visual === val ? null : val;
          document.querySelectorAll('[data-act="visual"]').forEach(function (b) { b.setAttribute('aria-pressed', String(b.getAttribute('data-val') === draft.visual)); });
          $('#bf-live').innerHTML = liveEstimateHTML();
        } else {
          state.profile.visual = { level: val, date: todayISO() }; ui.openVisual = true; save(); render(); ui.openVisual = false; toast('Visual check saved');
        }
        break;
      case 'tick': {
        var iso = todayISO(); var c = state.checks[iso] = state.checks[iso] || {}; var k = el.getAttribute('data-k');
        c[k] = !c[k]; save(); render();
        var n = Object.keys(c).filter(function (x) { return c[x]; }).length;
        if (c[k] && n === 3) toast('Streak secured for today');
        else if (c[k] && n === 6) toast('Perfect day. Every box ticked.');
        break;
      }
      case 'next-tip': ui.tipOffset++; render(); break;
      case 'open-day': ui.pendingDay = +el.getAttribute('data-day'); break;
      case 'pick-day': ui.trainDay = +el.getAttribute('data-day'); render(); var s = $('#session'); if (s) s.scrollIntoView({ block: 'start', behavior: 'smooth' }); break;
      case 'swap-meal': {
        var style = state.profile.diet, slot = el.getAttribute('data-slot'), key = style + ':' + slot;
        state.meals[key] = ((state.meals[key] || 0) + 1) % K.MEALS[style][slot].length; save(); render(); break;
      }
      case 'save-checkin': saveCheckin(); break;
      case 'del-entry':
        if (state.entries.length <= 1) { toast('Keep at least one check-in'); return; }
        state.entries = state.entries.filter(function (x) { return x.id !== el.getAttribute('data-id'); }); save(); render(); toast('Check-in deleted'); break;
      case 'view-photo': {
        var ph = byId(el.getAttribute('data-id'));
        modal('<img src="' + photoData[ph.id] + '" alt="' + ph.pose + ' photo"><div class="row between"><b>' + fmtDate(ph.date, true) + ' · ' + ph.pose + '</b><span class="row"><button class="btn small danger" data-act="del-photo" data-id="' + ph.id + '">Delete</button><button class="btn small" data-act="close-modal">Close</button></span></div>');
        break;
      }
      case 'del-photo': {
        var id = el.getAttribute('data-id');
        state.photos = state.photos.filter(function (x) { return x.id !== id; }); delete photoData[id];
        if (ui.cmpA === id) ui.cmpA = null; if (ui.cmpB === id) ui.cmpB = null;
        Store.del('photos', id); save(); closeModal(); render(); toast('Photo deleted'); break;
      }
      case 'close-modal': closeModal(); break;
      case 'save-profile': saveProfile(); break;
      case 'export': exportData(); break;
      case 'reset': ui.confirmReset = true; render(); break;
      case 'reset-no': ui.confirmReset = false; render(); break;
      case 'reset-yes': resetAll(); break;
      case 'go-reset': resetAll(); break;
    }
  });

  function handleSeg(name, val) {
    if (name.indexOf('ob-') === 0) {
      var key = name.slice(3);
      if (draft.step === 1) readOnboardingStep1();
      if (key === 'days') draft.days = +val;
      else if (key === 'exp') draft.experience = val;
      else draft[key] = val;
      render(); return;
    }
    if (name === 'dayType') ui.dayType = val;
    else if (name === 'units') { state.profile.units = val; save(); }
    else if (name === 'addPose') ui.addPose = val;
    else if (name === 'cmpMode') ui.cmpMode = val;
    render();
  }

  document.addEventListener('input', function (ev) {
    var t = ev.target;
    if (t.id === 'ob-agree') { draft.agree = t.checked; var b = $('#ob-start'); if (b) b.disabled = !t.checked; return; }
    if (t.id === 'cmp-slider') { var v = t.value; var a = $('#cmp-after'), hd = $('#cmp-handle'); if (a) a.style.clipPath = 'inset(0 0 0 ' + v + '%)'; if (hd) hd.style.left = v + '%'; return; }
    var bind = t.getAttribute && t.getAttribute('data-bind');
    if (!bind || !draft) return;
    if (draft.step === 2) {
      if (bind === 'testMethod') draft.testMethod = t.value;
      else if (bind === 'testValue') { var bf = num(t.value); draft.testValue = bf && bf >= 3 && bf <= 60 ? bf : null; }
      else draft[bind] = fromL(num(t.value));
      $('#bf-live').innerHTML = liveEstimateHTML();
    }
  });

  document.addEventListener('change', function (ev) {
    var t = ev.target, act = t.getAttribute && t.getAttribute('data-act-change');
    if (t.getAttribute && t.getAttribute('data-bind') === 'testMethod' && draft) { draft.testMethod = t.value; $('#bf-live').innerHTML = liveEstimateHTML(); return; }
    if (!act) return;
    if (act === 'diet') { state.profile.diet = t.value; save(); render(); }
    else if (act === 'cmpA') { ui.cmpA = t.value; render(); }
    else if (act === 'cmpB') { ui.cmpB = t.value; render(); }
    else if (act === 'import' && t.files[0]) importData(t.files[0]);
    else if ((act === 'photo' || act === 'ob-photo') && t.files[0]) {
      var file = t.files[0];
      toast('Saving photo…');
      compressImage(file).then(function (data) {
        if (act === 'ob-photo') { draft.refPhoto = data; render(); return; }
        var pose = ui.addPose;
        return addPhotoData(data, pose).then(function () { save(); render(); toast(pose.charAt(0).toUpperCase() + pose.slice(1) + ' photo saved'); var ph = $('#photos'); if (ph) ph.scrollIntoView({ block: 'start' }); });
      }).catch(function (e) { toast(e.message); });
    }
  });

  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });
  window.addEventListener('hashchange', function () { if (route() !== 'train') ui.trainDay = null; render(); });

  /* ======================= Boot ======================= */
  Store.open().then(function () {
    return Promise.all([Store.get('kv', 'state'), Store.all('photos')]);
  }).then(function (res) {
    state = res[0] && res[0].version ? Object.assign(blankState(), res[0]) : blankState();
    (res[1] || []).forEach(function (p) { if (p && p.id) photoData[p.id] = p.data; });
    render();
  }).catch(function () { state = blankState(); render(); });

  if ('serviceWorker' in navigator && /^https:|^http:\/\/localhost/.test(location.href)) {
    try { navigator.serviceWorker.register('sw.js').catch(function () {}); } catch (e) { /* not available here */ }
  }
})();
