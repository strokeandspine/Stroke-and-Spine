# Medical Content Review

All medical content in the app was drafted by Claude and **must be reviewed before release**. Ideally a licensed physical therapist reviews the exercises, and a physician or pharmacist reviews the medicine and post-surgery content. Record each sign-off in the table at the bottom.

All content lives in plain Swift files, so it's easy to read and edit. Change the text inside the quotes and leave the rest alone.

## Where the content is

| Content | File | What to check |
|---|---|---|
| Exercises (25) and programs (5) | `SpineCare/Core/ExerciseLibrary.swift` | Steps, tips, mistakes, doses, easier/harder links, stop signs, the `earlyPostOpOK` and `avoidAfterRecentFusion` flags |
| Pain "traffic light" guide and stop signs | `SpineCare/Core/ExerciseLibrary.swift` (`ExerciseContent`) | Thresholds (+2 green, +3–4 amber, +5 red) |
| Progression rules | `SpineCare/Core/ExerciseLibrary.swift` (`RehabProgression`) | Step back if pain rises ≥3 points, an exercise hurt, or the session felt too hard. Move on after the stage's minimum sessions with the last 3 comfortable |
| Surgery and procedure guidance | `SpineCare/Core/SpineHistoryCatalog.swift` | Recovery expectations, warning signs, NSAID-after-fusion note |
| Treatment options — spine (8 conditions) | `SpineCare/Core/TreatmentContentLumbar.swift`, `TreatmentContentOther.swift` | Every percentage against its cited source; tier assignment; "best for / less suitable if"; availability and coverage; that cervical myelopathy content does not discourage timely surgery |
| Treatment options — vascular, heart and chest, trauma (9) | `SpineCare/Core/TreatmentContentVascularCardiacTrauma.swift` | As above. Flagged by the drafter: CREST-2 and EARLY TAVR figures and citations, TAVR pacemaker rate, post-splenectomy infection risk, trauma mortality ranges, Medicare statements (carotid stenting, supervised exercise, TAVR heart team) |
| Treatment options — general, liver/gallbladder/pancreas, children (9) | `SpineCare/Core/TreatmentContentGeneralHPBPediatric.swift` | As above. Flagged: SECURE and C-GALL citations, liver cancer 5-year survival ranges (drafter's estimates), bile duct stone passage rate, tonsillectomy mortality, several trial sizes |
| Treatment options — orthopedic, neurosurgery, ENT (9) | `SpineCare/Core/TreatmentContentOrthoNeuroENT.swift` | As above. Most citations were checked against PubMed by the drafter. Flagged: aneurysm rupture/regrowth ranges, subdural hematoma mortality, CPAP abandonment, thyroid lobectomy follow-on rates, cuff re-tear rate |
| Treatment options — urologic, gynecologic, eye (9) | `SpineCare/Core/TreatmentContentUroGynEye.swift` | As above. Flagged: ProtecT continence and erection figures, ECLIPSE, Rezum/UroLift retreatment, PTVT 5-year citation, untreated retinal tear detachment rate, several possibly mismatched citations |
| Warning signs | `SpineCare/Core/RedFlags.swift` | Questions, urgency levels, advice text, crisis numbers |
| Medicine limits and warnings | `SpineCare/Core/MedicationSafety.swift` | Label limits, dose intervals, product presets, condition cautions |
| Questionnaire follow-up advice | `SpineCare/Views/Questionnaires/QuestionnaireView.swift` (`followUp`) | Score cut-offs and wording |
| Disclaimer and privacy text | `SpineCare/App/AppServices.swift` (`AppText`) | Legal review |

### Checking the treatment-options numbers

The outcome and side-effect figures were drafted from memory of the cited trials and reviews (a few were spot-checked against PubMed while drafting) and **have not been checked line by line**. Each specialty needs a reviewer from that specialty. For each option:

1. Open each source in `sources:` and confirm every number in `keyFindings`, `outcomes` and `sideEffects`. Ranges are meant to span what good studies report, not a single study.
2. Change any figure that doesn't match, or remove it. `outcomes` values may be `nil` ("Not reported").
3. Check `availability` against current Medicare national/local coverage decisions and major insurers.
4. When a condition is approved, record it in the sign-off log, and when all are done change `TreatmentOptionsContent.version`.

Frequency words follow the drug-leaflet convention: very common ≥1 in 10, common 1–10 in 100, uncommon 1–10 in 1,000, rare 1–10 in 10,000, very rare <1 in 10,000 (`FrequencyBand`). Severity is mild, moderate or serious (`SideEffect.Severity`).

When the exercise content is approved, change `ExerciseContent.version` from "Draft 0.1 — not yet clinically reviewed" to something like "Reviewed by [name, credentials], [date]".

## Exercise video shot list

Each exercise's steps are written to be read as the voice-over. Suggested filming specs:

- **Format:** vertical 9:16, 1080×1920, 15–40 seconds per exercise, looped. Film a side view plus a second angle where it helps (bird dog, side plank).
- **Demonstrator:** in plain clothing, on a mat, against a neutral background. Show 2–3 slow reps of the main version and one rep of a common mistake with a red ✕ overlay.
- **Captions:** burn in the step text so videos work with the sound off. Also supply captions as a separate `.vtt` file for accessibility.
- **Naming:** `<exercise-id>.mp4`, matching the `id` in `ExerciseLibrary.swift` (e.g. `bird-dog.mp4`).

Film in priority order: the free-tier exercises first (pelvic-tilt, knee-rolls, knee-to-chest, abdominal-brace, bridge, sit-to-stand, walking, ankle-pumps, heel-slides, clamshell), then the rest.

## Sign-off log

| Area | Reviewer | Credentials | Date | Notes |
|---|---|---|---|---|
| Exercises and programs | | | | |
| Surgery and procedure guidance | | | | |
| Treatment options — spine | | | | |
| Treatment options — vascular, heart and chest, trauma | | | | |
| Treatment options — general, liver/gallbladder/pancreas, children | | | | |
| Treatment options — orthopedic, neurosurgery, ENT | | | | |
| Treatment options — urologic, gynecologic, eye | | | | |
| Warning signs | | | | |
| Medicine limits and warnings | | | | |
| Questionnaire advice | | | | |
| Disclaimer and privacy (legal) | | | | |
