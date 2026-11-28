# Release Checklist

Where the app stands, and the remaining steps to get it on the App Store. Steps marked **(you)** need your Apple account, money, signatures or clinical sign-off, so they can't be done from the code.

## Done

- [x] App code: tracking, questionnaires, warning signs, medicines, history, exercise and rehab, Premium subscription, trends, report, and the treatment options guide (44 conditions, 224 options, 13 specialties)
- [x] Builds with Xcode 16 for the iPhone simulator, and all unit tests pass (GitHub Actions, `.github/workflows/ci.yml`)
- [x] Platform-independent logic builds and passes its tests on Linux (`scripts/test-core-linux.sh`)
- [x] UI walkthrough test that also captures 6.9-inch App Store screenshots (CI artifact "screenshots")
- [x] Placeholder app icon (1024 × 1024)
- [x] Version set to 1.0.0 (build 1) in `project.yml`
- [x] Draft App Store listing, review notes, privacy policy, terms and support page (`docs/APP_STORE_CONNECT.md`, `docs/legal/`, `docs/site/`)

## Remaining

### Accounts and agreements (you)
- [ ] Enroll in the Apple Developer Program ($99 a year) as an organization if you want the company name on the App Store (needs a D-U-N-S number)
- [ ] In App Store Connect, sign the Paid Applications agreement and add tax and banking details (needed for subscriptions)
- [ ] Register bundle ID `com.strokeandspine.spinecare` with the HealthKit capability, and create the app record (`docs/APP_STORE_CONNECT.md` §2–3)

### Content and legal (you, with reviewers)
- [ ] Clinical review and sign-off of all medical content, including each treatment-options specialty (`docs/CONTENT_REVIEW.md`). Change `TreatmentOptionsContent.version` and `ExerciseContent.version` once approved
- [ ] ODI and ISI questionnaire licences, or remove those questionnaires (`docs/legal/LICENCE_REQUESTS.md`)
- [ ] Fill in the [BRACKETS] in the privacy policy and terms, have them legally reviewed, publish `docs/site/*.html`, and set the URLs in `AppLinks` (`SpineCare/App/AppServices.swift`)
- [ ] Short FDA regulatory review. The treatment options guide presents outcome data for treatment choices; confirm it stays within general wellness / patient-education enforcement discretion
- [ ] Optional: replace the placeholder icon with a designed one

### Build, test and submit (you, on a Mac with Xcode)
- [ ] `xcodegen generate`, open the project, choose your team under *Signing & Capabilities*
- [ ] Run on a real iPhone and check HealthKit, Face ID lock, reminders, photo attachments and PDF sharing
- [ ] Create the subscriptions in App Store Connect (`docs/APP_STORE_CONNECT.md` §4) and test purchase, renewal, cancellation and restore in TestFlight with a Sandbox account
- [ ] **Product → Archive**, then **Distribute App → App Store Connect → Upload**
- [ ] Add screenshots (from the CI "screenshots" artifact or your own), the listing text, privacy answers and review notes
- [ ] Submit for review; choose manual release
