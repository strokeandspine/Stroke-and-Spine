# Questionnaire Licensing

The app uses validated questionnaires so scores mean something to doctors. Some of them are copyrighted and need a licence for use in a commercial app. **Sort these out before App Store release.** Do not change the wording of any questionnaire, because that invalidates it.

| Questionnaire | Status | What to do |
|---|---|---|
| **PHQ-9** (depression) | Free to use. No permission needed (Pfizer) | Keep the attribution in About |
| **GAD-7** (anxiety) | Free to use. No permission needed (Pfizer) | Keep the attribution in About |
| **Oswestry Disability Index (ODI) v2.1a** | Copyrighted (J. Fairbank). Commercial use needs a licence and possibly a fee | Request a licence through Mapi Research Trust / ePROVIDE (eprovide.mapi-trust.org). Confirm the exact licensed wording matches the text in `SpineCare/Core/Questionnaires.swift` |
| **Insomnia Severity Index (ISI)** | Copyrighted (C. Morin). Commercial use needs a licence and possibly a fee | Request a licence through Mapi Research Trust / ePROVIDE. Confirm the wording |

## If a licence isn't available or is too expensive

- **Instead of ODI:** the Roland-Morris Disability Questionnaire (check current terms) or PROMIS Physical Function / Pain Interference short forms (licensed through HealthMeasures, which is often free for many uses).
- **Instead of ISI:** PROMIS Sleep Disturbance short form.

## Planned questionnaires (not yet in the app)

- **STarT Back Screening Tool:** owned by Keele University. A commercial licence is required for use in an app.
- **Pain Catastrophizing Scale, Tampa Scale of Kinesiophobia, Pain Self-Efficacy Questionnaire:** check each author's terms.
