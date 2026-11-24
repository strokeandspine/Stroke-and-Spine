# Stroke & Spine — Lower Back Pain iPhone App

## Feature Ideas (Draft v0.2)

> **Decisions so far**
> - **Audience:** direct to patients (consumer app downloaded from the App Store). It is not prescribed by or tied to a clinic.
> - **Content:** Claude drafts the medical content, exercise instructions and video scripts, and the product owner reviews them. Each item records who reviewed it, the date, and its sources, and is re-reviewed yearly.
> - **Scope:** lower back pain and spine only. There will be no stroke module, so the app's structure is built around the spine and does not need to be condition-agnostic.
> - **Market:** United States only at launch. This means US drug names and label doses (acetaminophen, not paracetamol), US crisis resources (988, 911), English first (Spanish is a likely second language), and US privacy and FDA rules.

An iPhone app that helps patients with lower back pain (LBP) track symptoms, follow a rehab plan, manage self-care, and keep an accurate record of their spine history. It does this in a way that also helps their clinicians.

> **Guiding principles**
> - **Validated measures first.** Use established patient-reported outcome measures (PROMs) wherever possible so the data means something to clinicians.
> - **Safety over engagement.** Red-flag symptoms always lead to "seek care now," not more app content.
> - **Low burden.** A daily check-in should take under 30 seconds. Longer questionnaires are spaced out (weekly or monthly).
> - **The patient owns their data.** Data stays on the device by default, sharing is explicit, and export is easy.
> - **Advice, not prescription.** The app educates and supports. It does not diagnose or replace a clinician.

---

## 1. Onboarding & Profile

- **Pain story intake:** when the pain started, whether it is acute (<6 wks), subacute (6–12 wks) or chronic (>12 wks), where it is (body map), whether it radiates down a leg (sciatica), and what makes it better or worse.
- **Risk stratification:** the **STarT Back Screening Tool** (9 questions) sorts the patient as low, medium or high risk of a poor outcome. The result tailors how intensive the content is (self-management only vs. a recommendation to see a physical therapist or for psychologically informed care).
- **Red-flag screening at setup, with re-screening periodically** (see §11).
- **Health background:** age, conditions that affect OTC medication safety (kidney disease, stomach ulcers or GI bleeding, liver disease, heart disease, high blood pressure, pregnancy, blood thinners), allergies, and current medications.
- **Goals:** for example "walk 30 min," "sit through a workday," "lift my child," "return to golf." Goals drive the progress dashboard.
- **Care team (optional):** names and contacts of the primary care doctor, spine surgeon, PT, pain clinic and pharmacist. These are used for one-tap calling and for sending the patient's own reports. The app does not connect to them.

## 2. Pain Monitoring

- **Daily quick check-in:** a 0–10 Numeric Rating Scale (NRS) for current, average and worst pain in the last 24 h. One-tap widgets work from the Home Screen, Lock Screen and Apple Watch.
- **Separate back vs. leg pain scores.** Leg pain is a key marker for radiculopathy and for how patients do after surgery.
- **Interactive body map:** tap where it hurts and choose the quality (aching, burning, shooting, numbness, pins and needles).
- **Function scores:**
  - **Oswestry Disability Index (ODI)**: the gold standard for LBP disability, taken every 2–4 weeks.
  - Alternatives or additions: **Roland-Morris Disability Questionnaire**, **PROMIS Pain Interference / Physical Function** short forms.
- **Triggers & context tags:** sitting, standing, lifting, driving, weather, stress, poor sleep, activity level, menstrual cycle.
- **Flare tracker:** a "Log a flare" button records when it started, how bad it is, the suspected trigger, and what helped. Flares appear on the timeline.
- **Trends & insights:** 7-, 30- and 90-day charts. "Your pain is ~2 points lower on days you walk more than 5,000 steps." Changes are shown against the **minimal clinically important difference (MCID)** (e.g., ≥2 points on NRS, ≥10 points on ODI) so patients know when change is meaningful.

## 3. Sleep Monitoring

- **Apple HealthKit / Apple Watch import:** time asleep, sleep stages, time in bed, and resting heart rate/HRV as recovery markers.
- **Morning check-in:** sleep quality (0–10), whether pain woke them, how many times, and the sleeping position used.
- **Validated scores:** the **Insomnia Severity Index (ISI)** monthly, optionally the **Pittsburgh Sleep Quality Index (PSQI)**, or PROMIS Sleep Disturbance.
- **Pain ↔ sleep correlation:** shows how a bad night predicts next-day pain and vice versa.
- **Advice library:**
  - Back-friendly sleep positions (side-lying with a pillow between the knees, back-lying with a pillow under the knees).
  - Mattress and pillow guidance (evidence favors medium-firm).
  - Sleep hygiene and a CBT-I-informed "wind-down" routine.
  - A caution about sedating OTC sleep aids (e.g., diphenhydramine), especially in older adults.

## 4. Mental Health: Anxiety, Depression & Pain Coping

Chronic LBP and mood are closely linked, and psychological factors strongly predict recovery.

- **Validated screeners:**
  - **PHQ-9** (depression) and **GAD-7** (anxiety), monthly. Use the shorter **PHQ-2 / GAD-2** as weekly pulse checks.
  - **Pain Catastrophizing Scale (PCS)** and **Tampa Scale of Kinesiophobia** (fear of movement).
  - **Pain Self-Efficacy Questionnaire (PSEQ)**.
- **Mood journal:** a daily emoji/slider mood check and an optional free-text journal.
- **Safety handling:** if the patient endorses PHQ-9 item 9 (thoughts of self-harm), the app **immediately** shows crisis resources: one-tap call or text to **988** (Suicide & Crisis Lifeline), text HOME to 741741 (Crisis Text Line), and 911. It also suggests contacting their clinician. It never relies on the app alone.
- **Pain neuroscience education (PNE):** short lessons on "hurt ≠ harm," how pain sensitization works, and why movement is safe.
- **CBT / ACT-based modules:** pacing, reframing catastrophic thoughts, values-based goals, and graded exposure to feared movements.
- **Relaxation tools:** guided breathing, progressive muscle relaxation, body scan, and mindfulness audio.
- **Score trends** are shown with gentle, non-alarming language, plus "share with my clinician."

## 5. Exercise & Physical Activity

- **Activity tracking via HealthKit:** steps, walking distance, active minutes, and standing hours.
- **Walking program:** progressive daily walking goals, the most evidence-backed general activity for LBP.
- **Pacing / graded activity:** set a baseline, then increase by about 10% per week to avoid boom-and-bust cycles.
- **Sitting reminders:** "Time to stand up and move" nudges after a set period of sitting.
- **Recommended activity types:** walking, swimming or aquatic therapy, cycling, yoga, Pilates, and tai chi, each with LBP-specific tips.
- **Activity–pain correlation insights.**
- **Return-to-activity guides:** driving, work (desk vs. manual), sex, sports, and travel.

## 6. Physical Therapy & Rehabilitation

- **Exercise library:** video and animated demos with cues and common mistakes. Categories:
  - Mobility (cat-camel, knee-to-chest, pelvic tilts)
  - Core stability (dead bug, bird dog, bridges, side plank progressions)
  - Directional preference / McKinsey-style extension or flexion programs
  - Nerve glides (for sciatica)
  - Hip and glute strengthening, hamstring flexibility
- **Personalized programs:**
  - An app-generated starter program based on profile, risk group and post-op status.
  - **"My PT's program":** patients who already see a physical therapist can enter their home exercise program themselves (pick exercises from the library, set reps and frequency) or scan the PT's handout. The app then tracks it like any other program.
- **Guided sessions:** a timer, rep counter, voice coaching, and rest periods.
- **Post-session check:** pain before and after, difficulty (RPE), and "this exercise hurt" flags that automatically suggest a regression.
- **Progression and regression logic:** advance when exercises are easy and pain-free, and step back when pain flares.
- **Adherence tracking:** streaks, a weekly completion percentage, and reminders scheduled around the patient's day.
- **Ergonomics & posture education:** desk setup, lifting technique, and car seat setup. Messaging follows current evidence (no single "perfect posture"; vary positions).
- **Future idea:** camera-based form feedback using on-device pose estimation (Vision framework).

## 7. Diet & Nutrition

- **Weight & BMI tracking:** manual or from HealthKit/smart scales. Excess weight raises load on the spine, but messaging avoids blame.
- **Anti-inflammatory eating guidance:** Mediterranean-style patterns, omega-3s, fruit/veg, and limiting ultra-processed foods.
- **Bone health:** calcium and vitamin D guidance, especially after fusion surgery, for older adults, and for osteoporosis risk.
- **Hydration tracker.**
- **Post-surgery nutrition:** protein for wound healing and fusion. Smoking and nicotine cessation is strongly emphasized because nicotine impairs fusion and healing.
- **Constipation prevention:** fiber and fluids, especially important for patients taking opioids or after surgery.
- **Simple daily diet score:** quick check-boxes (e.g., "5 servings of fruit/veg," "water goal," "no sugary drinks") rather than full calorie counting. Optional HealthKit nutrition import for users who already log food elsewhere.
- **Alcohol tracking**, which interacts with sleep, mood and medications (especially acetaminophen).

## 8. Over-the-Counter Medication

- **Medication log:** what was taken, the dose and time, and whether it helped. Quick-log favorites.
- **Daily dose tracking with limits:** running totals warn before maximum daily doses are exceeded:
  - Acetaminophen/paracetamol: a cumulative total that includes **combination products** (cold/flu remedies, sleep aids).
  - Ibuprofen, naproxen, and aspirin: label maximums.
- **Personalized safety warnings** drawn from the profile: NSAID cautions for kidney disease, GI ulcer or bleeding history, heart disease, uncontrolled high blood pressure, blood thinners, pregnancy (especially the third trimester), and older age. Acetaminophen cautions for liver disease or heavy alcohol use.
- **Duplicate-ingredient detection:** e.g., warns about taking two NSAIDs together.
- **Topical options education:** topical NSAIDs (diclofenac gel), menthol, capsaicin, and lidocaine patches.
- **Non-drug alternatives:** heat (evidence supports it for acute LBP), ice, movement, and TENS.
- **"Talk to your pharmacist/doctor if…" prompts:** e.g., using OTC analgesics on most days for more than 10 days.
- **Reminders** for scheduled doses.
- **US label data:** dose limits follow US over-the-counter Drug Facts labels (e.g., the 3,000 or 4,000 mg/day acetaminophen ceilings that different brands use, and OTC naproxen at 660 mg/day). The app always defers to the label and to the patient's doctor.
- **Prescription meds (optional):** can also be logged so the record is complete for clinicians. Supports Apple Health's **Medications** feature where available.
- **Effectiveness insights:** "Naproxen reduced your pain by about 2 points on average in the 2 hours after you took it."

## 9. Surgical & Procedure History Log

### What can be logged
- **Surgeries:** microdiscectomy, laminectomy/decompression, spinal fusion (TLIF, PLIF, ALIF, XLIF/LLIF), artificial disc replacement, kyphoplasty/vertebroplasty, SI joint fusion, hardware removal, and spinal cord stimulator implantation.
- **Procedures/injections:** epidural steroid injections (interlaminar, transforaminal, caudal), facet joint injections, medial branch blocks, radiofrequency ablation (RFA), SI joint injections, trigger point injections, basivertebral nerve ablation, and SCS trials.
- **Imaging:** X-ray, MRI, CT and EMG/nerve conduction, with dates and the ability to attach reports or photos.
- **Other treatments:** physical therapy courses, chiropractic, acupuncture, and massage, plus whether each helped.

### Details captured per entry
- Date, facility, surgeon or provider, spinal level(s) (e.g., L4–L5, L5–S1), side, and approach.
- Implants or hardware (important for MRI safety and future care).
- Outcome: pain and function before vs. after (auto-filled from app data where available), complications, and "how much did this help?" (% relief, how long it lasted).
- Attach documents: op notes, discharge instructions, and imaging reports (camera scan with on-device OCR).

### Advice & guidance tied to entries
- **Procedure-specific recovery timelines:** e.g., common "BLT" restrictions (no Bending, Lifting >10 lb, or Twisting) after fusion, with milestones by week. **Always** framed as "general guidance — follow your surgeon's specific instructions," and editable to match the surgeon's actual protocol.
- **Post-op warning signs:** fever, wound redness or drainage, new or worsening leg weakness or numbness, bladder or bowel changes, calf pain or swelling (DVT), and chest pain or shortness of breath (PE). Each links to "call your surgeon" or "go to the ER."
- **Injection-specific guidance:** what to expect, the typical time to effect, how long relief may last, how often injections are generally repeated, and a post-injection pain diary (useful because diagnostic blocks often need a structured log of % relief over the following hours).
- **Post-op rehab track:** automatically switches the exercise program to a phase-appropriate post-surgical protocol.
- **Wound care checklist** and incision photo log, so the patient can track healing over time and share it with the care team.
- **Upcoming follow-ups:** reminders for post-op visits and imaging.
- **Clinician summary:** a one-page history sorted by date that is handy for new providers and second opinions.

## 10. Dashboard, Insights & Reporting

- **Home dashboard:** today's check-in, a pain trend, sleep, mood, exercise adherence, and the next scheduled task.
- **Weekly summary:** key changes, wins, and gentle suggestions.
- **Correlation engine (on-device):** relationships between pain and sleep, steps, mood, medications, weather, and sitting time.
- **Pre-appointment report:** a one-tap PDF covering scores over time (NRS, ODI, PHQ-9, GAD-7, ISI), medications, flares, adherence, and surgical history. Shared via AirDrop, email or print.
- **Apple Health Records import (future):** many US health systems let patients download their own records into the Health app. The app can read these (with permission) to pre-fill surgery, procedure, imaging and medication history.

## 11. Safety: Red-Flag Screening

These items trigger **"Seek urgent medical care"** screens with no other content in the way:
- **Cauda equina symptoms:** new bladder or bowel dysfunction, saddle numbness, or weakness in both legs.
- Progressive leg weakness or foot drop.
- Fever with back pain, or a history of IV drug use or immunosuppression (infection).
- History of cancer, unexplained weight loss, or night pain that is not relieved by rest.
- Significant trauma, or older age with osteoporosis (fracture).
- Post-op warning signs (see §9).
- Self-harm thoughts (see §4).

The app re-asks the short red-flag checklist when pain or the body map changes markedly, and at intervals.

## 12. Education Library

- Short, evidence-based articles and videos (2–5 min) on LBP basics, what imaging findings really mean (many "abnormalities" are normal with age), when surgery is and isn't indicated, opioid risks, and pacing.
- Content is tagged to the patient's profile and surfaced at the right moment (e.g., the fusion recovery article in week 1 post-op).
- Reading level aimed at roughly grade 6–8, with audio narration.

## 13. Engagement & Usability

- Smart reminders that adapt to when the user actually checks in.
- Home Screen and Lock Screen widgets, an Apple Watch app, Siri/App Intents ("Log my pain as 5"), and Live Activities for exercise sessions.
- Accessibility: Dynamic Type, VoiceOver, high contrast, and large tap targets (many users are in pain or are older).
- Gentle streaks and milestones, without punishing missed days.
- Localization and units (lb/kg).

## 14. Privacy, Security & Compliance

- On-device storage by default (SwiftData/Core Data with file protection), Face ID / passcode app lock, and optional end-to-end encrypted iCloud sync.
- No ads, no ad tracking, and no sale of data. Clear consent for any sharing. Apple's App Store rules already forbid using HealthKit data for advertising or selling it.
- **US privacy rules for a consumer health app:**
  - **HIPAA usually does not apply** to an app patients download themselves, because the app is not acting for a doctor, hospital or insurer. Do not claim to be "HIPAA compliant" in marketing unless that is actually true.
  - The **FTC Health Breach Notification Rule** does apply. Any unauthorized disclosure of health data (including sharing it with analytics or ad SDKs without consent) must be reported to users and the FTC.
  - **State consumer health data laws:** Washington's My Health My Data Act, Nevada's and Connecticut's similar laws, and California's CCPA/CPRA. These require explicit opt-in consent to collect health data, a separate health-data privacy policy, and the right to delete. Designing for Washington's rules covers most states.
  - The simplest way to stay low-risk: **keep data on the device, collect no accounts in v1**, and use privacy-preserving analytics only (or none).
- **FDA:** under the FDA's *General Wellness* and *Policy for Device Software Functions* guidance, symptom tracking, logging, education and general exercise content are generally low-risk or not regulated. Features that **diagnose, triage, or recommend specific treatment or doses** may make the app a regulated medical device. For v1:
  - Red-flag screens say "these symptoms need prompt medical attention." They do not say what the condition is.
  - The medication feature tracks totals against the patient's own label limits. It does not recommend doses.
  - Get a short FDA regulatory review before launch.
- **Medical disclaimer and age gate:** the app is for adults (18+), and a clear "not medical advice / not for emergencies" notice is shown at onboarding.
- Medical content reviewed by clinicians (spine surgeon, PT, pain psychologist, pharmacist), with citations and review dates.

## 15. Sharing With Your Own Doctors (Patient-Controlled)

Because the app is direct to patients, there is no clinician portal. Instead the patient decides what to share and when:
- **Pre-appointment PDF** (see §10), sent by AirDrop, email, Messages, print, or uploaded to their health system's patient portal (e.g., MyChart).
- **"Show my doctor" mode:** a clean, full-screen summary to hand the phone across during a visit.
- **Export all data** (CSV/JSON) at any time, and delete all data in one tap.

## 16. Business Model (Direct to Patients)

- **Free core:** daily check-ins, scores, red-flag safety, medication log with limits, surgery history, and basic trends. Safety features are never behind a paywall.
- **Premium subscription** (monthly or annual, with a free trial): personalized rehab programs and progressions, the full exercise video library, CBT/ACT coping courses, advanced insights, and the full PDF report.
- **No ads and no data sales.** This is both a trust feature and a legal simplifier.
- Optional later: an HSA/FSA-eligible plan if there is a qualifying route, and partnerships with US PT networks for referrals.

---

## Suggested Phasing

| Phase | Scope |
|---|---|
| **MVP (v1)** | Onboarding + red flags, daily pain/sleep/mood check-in, ODI/PHQ-9/GAD-7/ISI, HealthKit (steps, sleep), OTC medication log with dose limits, surgery & procedure log with document attachments, starter exercise library, trends dashboard, PDF report, local storage + Face ID |
| **v1.1** | STarT Back stratification, personalized and progressive rehab programs, post-op recovery tracks, education library, widgets and Apple Watch |
| **v2** | Correlation insights engine, CBT/ACT modules, diet scoring, OCR document import, iCloud sync |
| **v3** | Apple Health Records import, pose-estimated form feedback, Spanish localization |

## Proposed Tech Stack

- **UI:** SwiftUI (iOS 17+), Swift Charts
- **Data:** SwiftData, with CloudKit for optional sync
- **Health:** HealthKit (steps, sleep, HRV, weight, medications, State of Mind for mood)
- **Other Apple frameworks:** WidgetKit, App Intents, WatchKit, VisionKit (document scanning and OCR), PDFKit, UserNotifications, LocalAuthentication
- **Architecture:** MVVM with a modular feature layout (Pain, Sleep, Mood, Activity, Rehab, Nutrition, Medications, History, Reports, Safety)

---

## Open Questions for the Product Owner

Resolved: audience (direct to patients), market (US only), content (drafted by Claude, reviewed by the product owner), and scope (spine only, no stroke module).

1. **Minimum iOS version and devices:** iPhone only, or iPad as well?
2. **Monetization:** is the free + premium subscription model in §16 the right starting point?
