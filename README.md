# Stroke & Spine — Lower Back Pain App (iPhone)

A direct-to-patient iPhone app for people with lower back pain. Patients track pain, sleep and mood, complete validated questionnaires, keep over-the-counter pain relievers within label limits, check for warning signs, and keep a record of their spine surgeries and procedures.

See [`docs/FEATURES.md`](docs/FEATURES.md) for the full product plan and [`docs/LICENSING.md`](docs/LICENSING.md) for the questionnaire licences that must be in place before release.

## What's built (v0.1 MVP)

| Area | What it does | Files |
|---|---|---|
| Onboarding | Welcome, disclaimer + 18+ confirmation, optional name, pain start date, goal, health conditions for medicine safety | `Views/Onboarding` |
| Today | Daily check-in (back, leg and worst pain, sleep, pain woke me, mood, trigger tags, flare, notes), weekly pain summary, steps + sleep from Apple Health, due questionnaires, quick actions | `Views/Today` |
| Questionnaires | ODI, PHQ-9, GAD-7, ISI with scoring, severity bands, change-vs-last-time using MCIDs, follow-up advice. PHQ-9 question 9 shows 988 crisis resources immediately | `Core/Questionnaires.swift`, `Views/Questionnaires` |
| Warning signs | Yes/no checklist (bladder/bowel, saddle numbness, weakness, fever, trauma, cancer, post-op signs) → "Call 911", "Contact a doctor today" or "See your doctor soon". Never names a diagnosis | `Core/RedFlags.swift`, `Views/Safety` |
| Medicines | Rolling 24-hour totals for acetaminophen, ibuprofen, naproxen and aspirin against US OTC label limits, including hidden ingredients in combination products. Warns on over-limit (with Poison Control), short dose intervals, more than one NSAID, health-condition cautions and 10+ days in a row. Patient-set limits can't exceed the label maximum | `Core/MedicationSafety.swift`, `Views/Medications` |
| Spine history | Surgeries, injections/procedures, imaging and therapy with levels, side, provider, implants, % relief, complications, notes and photos of documents. Each entry shows plain-language "what to expect" guidance and warning signs, always deferring to the surgeon | `Core/SpineHistoryCatalog.swift`, `Views/History` |
| Trends | Pain, sleep and mood charts (30/90/365 days), flare markers, sleep–pain pattern, questionnaire score charts | `Views/Trends` |
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

## Not yet built

- Exercise and rehab library (needs exercise videos and content review)
- Premium subscription (StoreKit 2) and paywall
- Diet and nutrition tracking, education library, CBT/ACT coping modules
- Widgets, Apple Watch app, Siri shortcuts
- Document scanning with OCR (VisionKit)
