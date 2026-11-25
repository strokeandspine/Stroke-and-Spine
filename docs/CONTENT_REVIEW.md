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
| Warning signs | `SpineCare/Core/RedFlags.swift` | Questions, urgency levels, advice text, crisis numbers |
| Medicine limits and warnings | `SpineCare/Core/MedicationSafety.swift` | Label limits, dose intervals, product presets, condition cautions |
| Questionnaire follow-up advice | `SpineCare/Views/Questionnaires/QuestionnaireView.swift` (`followUp`) | Score cut-offs and wording |
| Disclaimer and privacy text | `SpineCare/App/AppServices.swift` (`AppText`) | Legal review |

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
| Warning signs | | | | |
| Medicine limits and warnings | | | | |
| Questionnaire advice | | | | |
| Disclaimer and privacy (legal) | | | | |
