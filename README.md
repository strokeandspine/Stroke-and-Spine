# Stroke & Spine — Lower Back Pain App (iPhone)

A direct-to-patient iPhone app for people with lower back pain. Patients track pain, sleep and mood, complete validated questionnaires, keep over-the-counter pain relievers within label limits, check for warning signs, and keep a record of their spine surgeries and procedures.

See [`docs/FEATURES.md`](docs/FEATURES.md) for the full product plan, [`docs/LICENSING.md`](docs/LICENSING.md) for the questionnaire licences that must be in place before release, and [`docs/CONTENT_REVIEW.md`](docs/CONTENT_REVIEW.md) for the medical content review checklist and the video shot list.

> **Also in this repo:** [`imaging/`](imaging/README.md) is a web app for finding open MRI, CT, ultrasound, DEXA and X-ray slots at radiology practices, with patient, physician, medical-legal and imaging-center portals.

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
