# Bone Health — Osteoporosis & Osteopenia App (iPhone)

A direct-to-patient iPhone app for people with osteoporosis or osteopenia, or at risk of them. It is a separate app from Stroke & Spine, built the same way: SwiftUI + SwiftData, iOS 17, iPhone only, everything stored on the device, no account.

## What's built (v0.1)

| Area | What it does | Files |
|---|---|---|
| Onboarding | Welcome, disclaimer + 18+ confirmation, name, year of birth, sex, menopause status, what they've been told about their bones, US/metric units | `Views/Onboarding` |
| Today | Alerts from across the app (late denosumab, height loss, falls risk, long-term treatment reviews), medicines due, today's calcium / vitamin D / magnesium vs target, this week's exercise vs goals, quick actions (pain score, exercise, vitals, record a fall), latest DEXA | `Views/Today` |
| Vitals | Blood pressure (ACC/AHA categories, very-high and low-BP advice), pulse, weight, height, BMI; charts. **Height-loss check**: 2 cm measured loss or 4 cm from tallest adult height → "ask about a spine X-ray/VFA" | `Core/Vitals.swift`, `Views/Records/VitalsViews.swift` |
| Medical history | Conditions, surgeries, allergies, other medicines, family history. Broken-bones list (site, date, low-trauma vs high-trauma → fragility fracture). Risk-factor checklist (FRAX inputs, secondary causes, bone-harming medicines) and FRAX result entry with US treatment thresholds. The app does **not** calculate FRAX | `Core/RiskFactors.swift`, `Views/Records/MedicalHistoryViews.swift` |
| Radiology & DEXA | DEXA, VFA, X-ray, CT, MRI, bone scan, ultrasound. DEXA results per site (BMD, T, Z), TBS, FRAX, machine; WHO category from the lowest T-score (Z-score for premenopausal women/men < 50); BMD change vs previous scan using least-significant-change, with a warning when machines/centres differ; T-score chart over time; photos of reports; DEXA explainer | `Core/BoneDensity.swift`, `Views/Records/RadiologyViews.swift` |
| Lab results | Vitamin D, calcium, eGFR, creatinine, PTH, ALP, Mg, phosphate, TSH, CTX, P1NP, with cautious notes for vitamin D, calcium and eGFR (kidney limits for bisphosphonates/denosumab) | `Core/Vitals.swift` (`LabTest`), `Views/Records/VitalsViews.swift` |
| Osteoporosis medicines | Library of 12 medicines: alendronate, risedronate, ibandronate (oral and IV), zoledronic acid, denosumab, teriparatide, abaloparatide, romosozumab, raloxifene, estrogen therapy and calcitonin. Each has how it works, dose, how to take it, missed doses, side effects, when to call the doctor, who shouldn't take it, boxed warnings, how long it's taken and what happens on stopping | `Core/OsteoMedications.swift`, `Views/Medicines/DrugLibraryViews.swift` |
| Medicine tracking | Add a medicine with frequency and start date; log doses; next-due date and status; oral bisphosphonate "take it right" checklist and a countdown until food/calcium is OK; **denosumab more than 30 days late → urgent alert**; romosozumab 12-dose course; 2-year review for teriparatide/abaloparatide; 5-year (oral) / 3-year (IV) bisphosphonate review prompts; local reminders (with a 2-week "book your appointment" heads-up for 6-monthly/yearly medicines) | `Views/Medicines/MedicinesView.swift` |
| Calcium, vitamin D, magnesium | Log supplements or foods (presets with elemental amounts from NIH ODS, or custom). Daily targets by age/sex (NIH RDA; vitamin D 800 IU from 50 per BHOF), editable. Warnings: calcium over the UL, > 500 mg per dose, supplemental magnesium > 350 mg, magnesium with kidney disease, vitamin D 7-day average > 4,000 IU (unless "doctor prescribed high-dose"), and **calcium within 30/60 min of an oral bisphosphonate**. 14-day chart and a plain-language guide | `Core/Supplements.swift`, `Views/Medicines/SupplementViews.swift` |
| Exercise | 24 exercises in 5 categories (strength, balance, weight-bearing, posture/spine-sparing, gentle stretching), each with steps, dose, tips and stop signs. "Movements to avoid" (loaded spinal flexion, end-range twisting…), the hip hinge. Logging with minutes, effort and pain before/after; weekly goals from *Too Fit To Fracture* (150 min weight-bearing, strength 2 days, balance 2 h, posture 5 days). **Content is a draft awaiting PT review** | `Core/ExerciseLibrary.swift`, `Views/Exercise` |
| Falls | Record falls and near-misses (where, what happened, injuries, hit head, got up alone, long lie, care sought) with after-fall 911/see-a-doctor advice and a prompt to add any fracture to the history. CDC STEADI *Stay Independent* 12-item checklist (score ≥ 4 = at risk), recommendations (≥ 2 falls or an injurious fall → falls assessment), CDC home-safety checklist, how to get up after a fall | `Core/Falls.swift`, `Views/Falls` |
| Pain | 0–10 pain score with location, quality, "new and sudden", "after a fall", what helped; optional **PEG** 3-item pain/interference score with 30% change rule; charts. Alerts: sudden new back pain → possible vertebral fracture; hip/groin pain after a fall; thigh/groin pain on a bisphosphonate or denosumab (atypical femur fracture); jaw symptoms (ONJ) | `Core/Pain.swift`, `Views/Pain` |
| Doctor summary | One-tap summary (DEXA, fractures, risk factors, medicines with last/next dose, supplement averages vs targets, vitals and height loss, labs, falls and checklist score, pain and PEG, exercise, other imaging, history) shareable as a multi-page PDF | `Views/More/ReportView.swift` |
| Privacy | On-device SwiftData, optional Face ID lock, supplement reminder, JSON export, delete everything | `Views/More/MoreView.swift` |

Unit tests for DEXA classification and change, supplement targets and warnings, medication schedules, the falls checklist, PEG, pain alerts, blood pressure, height loss and weekly exercise are in `BoneHealthTests/`.

## Build and run (requires a Mac)

1. Install Xcode 15 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. `cd BoneHealth && xcodegen generate`. This creates `BoneHealth.xcodeproj`.
3. Open it, choose your Apple developer team under *Signing & Capabilities*, pick an iPhone simulator and press **Run** (⌘R). Run tests with ⌘U.

> The code was written in an environment without Xcode or a Swift compiler, so it has **not yet been compiled**. Expect to fix a few small compile errors on the first build.

## Before release

- **Clinical review.** Medicine summaries (`OsteoDrugLibrary.contentVersion`) and exercise content (`ExerciseLibrary.contentVersion`) are drafts from US prescribing information, the BHOF 2022 clinician's guide and *Too Fit To Fracture*. They need review by a clinician and a physical therapist. Thresholds that need sign-off are kept in one place each: `BoneDensity`, `NutrientTargets`, `SupplementChecker`, `MedicationSchedule`, `BodyMeasures.heightLossWarning`, `FallRisk`, `PainAlerts`.
- **Questionnaires.** The STEADI Stay Independent checklist (CDC) and PEG are public domain; no licences are needed.
- **Legal pages.** Set the privacy, terms and support URLs in `AppLinks` (`BoneHealth/App/AppServices.swift`). The Stroke & Spine drafts in `docs/legal` can be adapted.
- **App icon** and accent colour (currently copied from Stroke & Spine).

## Not yet built

- Apple Health integration (weight, height, blood pressure, steps)
- Reading values from a photographed DEXA report (VisionKit OCR)
- Exercise videos and guided sessions with timers
- Widgets and Apple Watch
