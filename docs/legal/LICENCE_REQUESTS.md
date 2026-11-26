# Questionnaire Licence Requests

The Oswestry Disability Index (ODI) and the Insomnia Severity Index (ISI) are both distributed by **Mapi Research Trust** through its **ePROVIDE** platform. Requests are made through an online form, not by email:

1. Go to https://eprovide.mapi-trust.org and create a free account.
2. Search for **"Oswestry Disability Index"** and open its page. Check that the copyright holder and the distributor are as expected, then choose **Request** (sometimes labelled "Obtain this questionnaire" or "Licensing"). Repeat for **"Insomnia Severity Index"**.
3. Fill in the form using the answers below. Many of the fields are the same for both.

Expect fees for commercial use. These are often charged per year or per number of users or downloads, and sometimes as a one-off. Ask for an e-health/mobile app licence covering the United States. Mapi usually replies within a few weeks.

> Before you submit, check that the wording in `SpineCare/Core/Questionnaires.swift` exactly matches the version Mapi sends you. Use their licensed text and layout instructions. They may also ask to see screenshots of how the questionnaire is displayed.

---

## Answers for the request form

| Field | Answer |
|---|---|
| Organization | [LEGAL COMPANY NAME] |
| Organization type | Commercial company — digital health / mobile app developer |
| Country | United States |
| Contact | [YOUR NAME], [TITLE], [EMAIL], [PHONE] |
| Questionnaire | Oswestry Disability Index v2.1a (English, United States) / Insomnia Severity Index (English, United States) |
| Type of use | Commercial — patient-facing mobile application (direct-to-consumer) |
| Mode of administration | Electronic (ePRO), self-completed on a smartphone (iOS) |
| Languages | English for the US. Possibly US Spanish later |
| Countries | United States |
| Expected number of users | [ESTIMATE, e.g. "up to 10,000 in year 1"] |
| Duration | Ongoing, licence renewable annually |
| Funding | Self-funded / commercial |

### Project description (paste into the free-text field)

```
Stroke & Spine is a direct-to-consumer iPhone app for adults in the United States with lower back pain. It helps patients track their pain, function, sleep and mood over time, follow exercise programs, and share a summary with their own doctors.

We would like a licence to include the [Oswestry Disability Index v2.1a / Insomnia Severity Index] in the app as a self-completed electronic questionnaire. Users would complete it about every [2 weeks for ODI / 4 weeks for ISI]. The app calculates the standard total score and severity category, shows it to the user with their previous scores, and includes it in an optional PDF summary that the user can choose to share with their healthcare providers.

The items and response options would be reproduced exactly as licensed, one item per screen, with the standard instructions and copyright notice. No items would be modified, removed or added. All data is stored only on the user's device. We do not collect or receive responses.

The app is monetized through an optional subscription for exercise content. The questionnaire itself is available to all users free of charge.

We are happy to provide screenshots of the electronic implementation for review and to follow any ePRO migration guidance.
```

---

## Follow-up email (if you haven't heard back in 3 weeks)

**To:** the contact address shown on the questionnaire's ePROVIDE page
**Subject:** Licence request follow-up — [Questionnaire name], Stroke & Spine app

```
Hello,

I submitted a licence request through ePROVIDE on [DATE] (reference [REQUEST NUMBER, if shown]) for commercial use of the [Oswestry Disability Index v2.1a / Insomnia Severity Index] in a patient-facing iPhone app for adults in the United States with lower back pain.

Could you let me know the status of the request and the likely licence terms and fees? I'm happy to provide more information or screenshots of the electronic version.

Thank you,
[YOUR NAME]
[TITLE], [LEGAL COMPANY NAME]
[EMAIL] · [PHONE]
```

---

## If the cost is too high

Swap in free or lower-cost alternatives. This is a small code change in `Questionnaires.swift`:

- **Instead of ODI:** PROMIS Physical Function and PROMIS Pain Interference short forms. Request terms at https://www.healthmeasures.net. The Roland-Morris Disability Questionnaire is another option; check its current terms with the authors.
- **Instead of ISI:** the PROMIS Sleep Disturbance short form (from HealthMeasures, as above).
