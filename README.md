# Stroke & Spine — Lower Back Pain App (iPhone)

A direct-to-patient iPhone app for people with lower back pain. Patients track pain, sleep and mood, complete validated questionnaires, keep over-the-counter pain relievers within label limits, check for warning signs, and keep a record of their spine surgeries and procedures.

See [`docs/FEATURES.md`](docs/FEATURES.md) for the full product plan, [`docs/LICENSING.md`](docs/LICENSING.md) for the questionnaire licences that must be in place before release, and [`docs/CONTENT_REVIEW.md`](docs/CONTENT_REVIEW.md) for the medical content review checklist and the video shot list.

## What's built (v0.2)

| Area | What it does | Files |
|---|---|---|
| Onboarding | Welcome, disclaimer + 18+ confirmation, optional name, pain start date, goal, health conditions for medicine safety | `Views/Onboarding` |
| Today | Daily check-in (back, leg and worst pain, sleep, pain woke me, mood, trigger tags, flare, notes), weekly pain summary, steps + sleep from Apple Health, due questionnaires, quick actions | `Views/Today` |
| Questionnaires | ODI, PHQ-9, GAD-7, ISI with scoring, severity bands, change-vs-last-time using MCIDs, follow-up advice. PHQ-9 question 9 shows 988 crisis resources immediately | `Core/Questionnaires.swift`, `Views/Questionnaires` |
| Warning signs | Yes/no checklist (bladder/bowel, saddle numbness, weakness, fever, trauma, cancer, post-op signs) → "Call 911", "Contact a doctor today" or "See your doctor soon". Never names a diagnosis | `Core/RedFlags.swift`, `Views/Safety` |
| Medicines | Rolling 24-hour totals for acetaminophen, ibuprofen, naproxen and aspirin against US OTC label limits, including hidden ingredients in combination products. Warns on over-limit (with Poison Control), short dose intervals, more than one NSAID, health-condition cautions and 10+ days in a row. Patient-set limits can't exceed the label maximum | `Core/MedicationSafety.swift`, `Views/Medications` |
| Spine history | Surgeries, injections/procedures, imaging and therapy with levels, side, provider, implants, % relief, complications, notes and photos of documents. Each entry shows plain-language "what to expect" guidance and warning signs, always deferring to the surgeon | `Core/SpineHistoryCatalog.swift`, `Views/History` |
| Exercise and rehab | 25 exercises with steps, tips, mistakes, doses and stop signs, plus 5 programs (Getting started, After surgery: early recovery, Core and strength, Leg pain, Desk worker reset). Guided sessions log pain before and after, hold timers and "this hurt" flags. Progression advice uses the pain traffic-light rules, and exercises get a caution after a recent fusion. **Content is a draft awaiting clinical review** | `Core/ExerciseLibrary.swift`, `Views/Exercise` |
| Premium subscription | StoreKit 2 monthly and annual plans with a 1-week free trial, Apple's subscription screen, restore, manage subscription and entitlement checks. A local StoreKit test file is included | `App/Store.swift`, `Views/Settings/PaywallView.swift`, `Resources/Products.storekit` |
| Trends | Pain, sleep and mood charts (30 days free; 90/365 days with Premium), flare markers, sleep–pain pattern, questionnaire score charts | `Views/Trends` |
| Report | Appointment summary viewable in-app and shareable as a PDF | `Views/Settings/ReportView.swift` |
| Privacy | On-device SwiftData storage, no account, optional Face ID lock, daily reminder, JSON export, delete everything | `Views/Settings/MoreView.swift` |

Unit tests for scoring, warning signs, medication safety and insights are in `SpineCareTests/`.

## Stronger Years — strength training for older adults (second app)

A separate iPhone app in the same project (target `StrongerYears`, bundle ID `com.strokeandspine.strongeryears`). It helps people aged 60+ start and keep up weight training safely. Everything is stored on the phone with SwiftData; there is no account.

| Area | What it does | Files |
|---|---|---|
| Onboarding | Disclaimer, name, experience level (new / returning / train regularly), an 8-question "before you start" health check that recommends seeing a doctor on any "yes", training days and equipment | `StrongerYears/Views/Onboarding`, `Core/HealthCheck.swift` |
| Weekly schedule by body part | Picks a split for 1–4 days a week (full body; A/B full body; lower / upper / full; lower / push / lower / pull). Each day can be renamed and its body parts changed. Warns when the same muscles are worked on back-to-back days, and lists body parts missing from the week | `Core/Schedule.swift`, `Views/Plan` |
| Duration, intensity and volume | Three adjustable settings with defaults for each experience level. **Duration** 20 / 35 / 50 min, including warm-up and cool-down. **Intensity** gentle / moderate / challenging: effort 3–4, 5–6 or 7–8 out of 10, rep range and rest time. **Volume** 1–3 sets and 1–2 exercises per body part. A choice above the recommended level for the person's experience shows a caution. Settings can also be changed for one workout only | `Core/Training.swift`, `SettingsDials` in `Views/Workout/WorkoutPreviewView.swift` |
| Workout builder | Chooses exercises for the day's body parts that match the person's experience and equipment, fits them into the time available, and rotates exercises and body-part order between sessions | `Core/WorkoutBuilder.swift` |
| Exercise library | 41 exercises across legs, hips and glutes, back, chest, shoulders, arms and grip, core and balance. Each has steps, tips, cautions, a starting weight, and links to easier and harder versions | `Core/ExerciseCatalog.swift`, `Views/Library` |
| Guided workout | Warm-up checklist, then one exercise at a time: log weight, reps or hold time (with a countdown timer), effort and pain. Rest timer between sets. "Make it easier" swaps in the easier version, a pain flag ends that exercise, and a "Feeling unwell" button shows stop signs and a Call 911 button. Then a cool-down with stretches for the muscles worked, and a finish screen for overall effort, how you feel and notes | `Views/Workout/WorkoutSessionView.swift` |
| Training log | Workouts grouped by month with every set; a recovery log for sauna, cold plunge, stretching and walks (with time and temperature cautions); progress charts for each exercise | `Views/Log`, `Models/Models.swift` |
| Progression advice | Uses the "2-for-2" idea: suggests the smallest weight step (2 lb for arms, 5 lb for legs, 5–10 lb on machines, a firmer band or a harder version) only when every set reaches the top of the rep range within the target effort. Suggests going lighter after pain or very high effort. Next session's weight is pre-filled | `Core/Progression.swift` |
| Learn | Guides to warming up (with a routine), cooling down, stretching (13 stretches with holds and cautions), using a sauna, cold plunge, avoiding injury, and the effort scale | `Core/GuideLibrary.swift`, `Views/Learn` |
| Senior-friendly design | Text one size larger by default (can be turned off), buttons at least 60 points tall, large +/– steppers, VoiceOver labels, and plain language | `Views/Components.swift` |
| Settings | Equipment, health check answers, "my doctor has cleared me", JSON export, delete everything | `Views/Settings` |

Unit tests for the catalog, workout builder, settings, schedule and progression rules are in `StrongerYearsTests/`. In Xcode, choose the **StrongerYears** scheme to run or test it.

> **Content is a draft.** All exercise, guide and health check wording needs review by a physician and a physical therapist or exercise physiologist before release, like the back pain app's content (see `docs/CONTENT_REVIEW.md`). As with the back pain app, this code has not been compiled yet.

**Not yet built for Stronger Years:** exercise videos and pictures, workout reminders, Apple Health (workouts and heart rate), Apple Watch, metric (kg) units, a printable report for the doctor, and a Premium subscription.

## Build and run (requires a Mac)

1. Install Xcode 15 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. From the repository root run `xcodegen generate`. This creates `SpineCare.xcodeproj`.
3. Open `SpineCare.xcodeproj`, choose your Apple developer team under *Signing & Capabilities*, pick an iPhone simulator, and press **Run** (⌘R).
4. Run tests with **Product → Test** (⌘U).

> The code was written in an environment without Xcode or a Swift compiler, so it has **not yet been compiled**. Expect to fix a few small compile errors on the first build.

HealthKit needs a paid Apple Developer account to run on a real iPhone. The rest of the app works in the simulator without one.

## Launch paperwork (drafts)

| Document | File |
|---|---|
| App Store Connect setup and all listing text (name, subtitle, description, keywords, subscriptions, review notes, privacy answers, screenshots) | `docs/APP_STORE_CONNECT.md` |
| Privacy policy, including the consumer health data section required by Washington and similar state laws | `docs/legal/PRIVACY_POLICY.md` |
| Terms of use, including the medical disclaimer and subscription terms | `docs/legal/TERMS_OF_USE.md` |
| Support page | `docs/legal/SUPPORT.md` |
| Web-ready pages to upload (built with `python3 docs/site/build.py`) | `docs/site/privacy.html`, `terms.html`, `support.html` |
| Questionnaire licence requests (ODI, ISI) | `docs/legal/LICENCE_REQUESTS.md` |

Set the published URLs in `AppLinks` in `SpineCare/App/AppServices.swift`.

## Subscription setup (App Store Connect)

1. Create the app in App Store Connect with bundle ID `com.strokeandspine.spinecare`.
2. Create a subscription group called **Premium** with two auto-renewable subscriptions:
   - `com.strokeandspine.spinecare.premium.monthly`: 1 month
   - `com.strokeandspine.spinecare.premium.annual`: 1 year
3. Add a 1-week free-trial introductory offer to each, then set prices. The local test file uses $9.99 a month and $59.99 a year as placeholders.
4. Fill in the subscription display names, descriptions and review screenshot, and sign the Paid Applications agreement.
5. Set the privacy, terms and support URLs in `AppLinks` (`SpineCare/App/AppServices.swift`).

The full field-by-field walkthrough is in `docs/APP_STORE_CONNECT.md`.

While developing, the scheme uses `SpineCare/Resources/Products.storekit`, so purchases work in the simulator without App Store Connect. Use **Debug → StoreKit → Manage Transactions** in Xcode to refund or expire test subscriptions.

**Free vs Premium:** everything related to safety and record-keeping is free. That covers check-ins, questionnaires, warning signs, crisis support, the medicine log, spine history, 30-day trends, the appointment report, and the Getting started and After surgery programs. Premium adds the other programs, the full exercise library, 90-day and 1-year trends, and pattern insights.

## Not yet built

- Exercise videos (the shot list is in `docs/CONTENT_REVIEW.md`)
- Diet and nutrition tracking, education library, CBT/ACT coping modules
- Widgets, Apple Watch app, Siri shortcuts
- Document scanning with OCR (VisionKit)
