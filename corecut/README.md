# CoreCut: visible-abs coach (installable web app)

CoreCut plans, trains and tracks a person toward visible abs. It runs in any modern browser and installs to the home screen on iPhone and Android ("Add to Home Screen"). Everything, including photos, is stored on the device in IndexedDB. There is no account and no server.

## What it does

| Area | Details | Code |
|---|---|---|
| Onboarding | 18+ and not-medical-advice confirmation, units, sex, age, height, weight, pregnancy/breastfeeding flag | `js/app.js` (`viewOnboarding`) |
| Body-fat estimate | Any mix of: a test result (DEXA, Bod Pod, hydrostatic, clinic BIA, calipers, smart scale), tape measure (US Navy formula plus Relative Fat Mass), and a visual check with drawn torsos and descriptions plus an optional reference photo. Estimates are combined by inverse-variance weighting, so a DEXA counts far more than a home scale. Shows a likely range. Falls back to a BMI equation only when nothing else is entered | `js/calc.js` |
| Plan | Goal (ab outline, clear six-pack, shredded) sets target body fat by sex. Lean mass, goal weight, Katch-McArdle BMR, maintenance from daily activity plus lifting days, deficit from pace (0.5–1% of body weight a week, auto-slowed near the goal), capped at 25% below maintenance with 1,200/1,500 kcal floors. Protein 2.4 g/kg lean mass, fat ≥ 25% of calories, carbs the rest, fiber and water. Training-day and rest-day calories. Time-to-goal range | `js/calc.js` (`buildPlan`) |
| Safety | Plan is blocked for under-18s and pregnancy/breastfeeding; maintenance only for BMI < 18.5; warnings for floors, "shredded" and very low female body fat; eating-disorder helpline (ANAD) and 988 | `js/calc.js`, `js/app.js` (`safetyCard`) |
| Food | Omnivore, vegetarian and vegan sample days (2–3 swappable options per meal) scaled to hit calories and protein, with per-meal macros, a weekly grocery list and 8 nutrition rules | `js/content.js`, `scaleDay` in `js/calc.js` |
| Training | 4 phases (Foundation, Build, Sharpen, Reveal) with rep schemes; 3–6 day splits; two alternating ab circuits per phase (3 times a week); daily step target, zone 2 and HIIT that ramp up by phase and experience; weekly schedule; 36 exercises with steps, cues and easier swaps | `js/content.js`, `weekSchedule` in `js/app.js` |
| Progress | Weekly check-in (weight, waist, neck, hips, optional test), body-fat, weight and waist charts with goal lines, history | `viewProgress` |
| Photos | Front, side, back and flexed photos (resized to 1200 px JPEG), gallery by date, side-by-side and slider compare | `photosSection` |
| Motivation | Daily checklist with streaks, tip of the day (37 tips), and coaching that reacts to the data: on pace, too fast, plateau, scale flat but waist shrinking, weight trending up, adaptive maintenance estimate after 4+ weeks, photo reminders, diet break after 12 weeks, at-goal advice | `coach` in `js/calc.js` |
| Data | Export and import a JSON backup (validated on import), delete everything | `viewMe` |

## Run it

No build step. Serve the folder over HTTP:

```
cd corecut && python3 -m http.server 8000
```

Then open http://localhost:8000. The service worker (`sw.js`) caches the app so it opens offline once installed; bump `VERSION` in `sw.js` when you change files.

## Tests

```
node corecut/test/calc.test.js
```

Covers the body-fat formulas, combining estimates, plan rules (cut, maintenance, calorie floors, blocks), meal scaling, trends, coaching and streaks, and checks that every exercise and food referenced in the content exists.

## Publishing

Any static host works. To put it on the existing Cloudflare site, copy the folder to `website/corecut/` (it uses relative paths) or create a separate Cloudflare Worker whose assets directory is `./corecut`.

## Before release

- Have a registered dietitian and a qualified trainer review `js/content.js` and the plan rules, as with the SpineCare content.
- Food values are USDA-style averages per 100 g; check them against your preferred database.
- The visual check is a self-assessment guide, not image analysis.
