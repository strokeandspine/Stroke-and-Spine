# App Store Connect Setup and Listing Copy

Everything to enter in App Store Connect, in order. Text in code blocks is ready to paste. Character counts are shown where Apple sets a limit.

You need a paid Apple Developer Program membership ($99 a year), enrolled as an **organization** if possible. Health apps from organizations get less scrutiny at review, and the seller name shown on the App Store will be your company rather than your personal name.

---

## 1. Agreements, tax and banking

App Store Connect → **Business**: accept the **Paid Applications Agreement**, then add bank and tax details. Subscriptions can't be tested in TestFlight or sold until this shows as *Active*.

## 2. Register the bundle ID

developer.apple.com → Certificates, IDs & Profiles → Identifiers → **+** → App IDs → App.

- Description: `Stroke and Spine`
- Bundle ID (explicit): `com.strokeandspine.spinecare`
- Capabilities: tick **HealthKit** and **In-App Purchase**.

## 3. Create the app

App Store Connect → Apps → **+** → New App.

| Field | Value |
|---|---|
| Platform | iOS |
| Name (30) | `Stroke & Spine: Back Pain` (25) |
| Primary language | English (U.S.) |
| Bundle ID | `com.strokeandspine.spinecare` |
| SKU | `spinecare-ios-001` |
| User access | Full access |

## 4. Subscriptions

App → **Monetization → Subscriptions**.

### Subscription group

- Reference name: `Premium`
- Localization (English U.S.) → Display name: `Stroke & Spine Premium`

### Subscription 1 — monthly

| Field | Value |
|---|---|
| Reference name | `Premium Monthly` |
| Product ID | `com.strokeandspine.spinecare.premium.monthly` |
| Duration | 1 month |
| Price | $9.99 (United States). Accept Apple's suggested equivalents if you add other countries later |
| Display name | `Premium Monthly` |
| Description | `All programs and long-term trends` (33) |
| Family Sharing | Off |

### Subscription 2 — annual

| Field | Value |
|---|---|
| Reference name | `Premium Annual` |
| Product ID | `com.strokeandspine.spinecare.premium.annual` |
| Duration | 1 year |
| Price | $59.99 |
| Display name | `Premium Annual` |
| Description | `All programs and trends. Best value.` (36) |
| Family Sharing | Off |

Both subscriptions must be at the **same level** in the group so people can switch between them. Drag them to level 1 together.

### Free trial (introductory offer), for each subscription

Subscription → **Subscription Prices → Introductory Offers → +**

- Countries: United States
- Start date: today. End date: none
- Type: **Free**
- Duration: **1 week**

### Review information, for each subscription

- **Screenshot:** a screenshot of the Premium screen (More → Subscription → See Premium) from the simulator.
- **Review notes:**

```
Premium unlocks the Core and strength, Leg pain and Desk worker programs, the full exercise library, and 90-day/1-year trends. To view: Exercise tab → tap any program marked Premium, or Trends → 90 days. Safety features remain free.
```

The first subscriptions have to be submitted **together with the first app version** (attach them on the version page under *In-App Purchases and Subscriptions*).

## 5. App information

App → **General → App Information**.

| Field | Value |
|---|---|
| Subtitle (30) | `Track pain, rehab & medicines` (29) |
| Category | Primary: **Health & Fitness**. Secondary: **Medical** |
| Content rights | No third-party content requiring rights *other than the licensed questionnaires*. Answer "Yes, it contains third-party content" and confirm you have the rights (once the ODI and ISI licences are signed) |

### Age rating

Answer the questionnaire honestly. The relevant answer is **Medical or Treatment-Focused Content: Yes**. Everything else is *None/No*. If App Store Connect offers a minimum age higher than the calculated one, choose **18+** to match the app's adult-only onboarding.

## 6. App privacy

App → **App Privacy**.

- **Privacy Policy URL:** the URL where you publish `docs/site/privacy.html` (see section 9).
- **Data collection:** answer **"No, we do not collect data from this app."**

That answer is accurate for version 0.2, because nothing the user enters leaves their iPhone and the app contains no analytics or advertising tools. Purchase handling and opt-in crash reports done by Apple don't count as collection by you. **If you ever add analytics, accounts, cloud sync or a crash-reporting SDK, this answer must change first.**

## 7. Version page (1.0)

### Promotional text (170). This can be changed any time without review

```
Track your back pain in 30 seconds a day, follow guided rehab programs, keep over-the-counter medicines within label limits, and keep your spine history in one place.
```

### Description (4,000)

```
Stroke & Spine helps people with lower back pain understand their pain, stay active and keep their care organized — all in one private app.

TRACK HOW YOU'RE DOING
• A 30-second daily check-in for back pain, leg pain, sleep and mood
• Log flare-ups and what triggered them
• See your pain, sleep and mood trends over time
• Connect Apple Health to see your steps and sleep next to your pain

QUESTIONNAIRES DOCTORS USE
• Back function (Oswestry Disability Index), mood (PHQ-9), anxiety (GAD-7) and sleep (Insomnia Severity Index)
• See whether your scores have changed by an amount that really matters
• Gentle reminders when a questionnaire is due

SAFER OVER-THE-COUNTER MEDICINES
• Log acetaminophen, ibuprofen, naproxen and aspirin — including hidden ingredients in cold, flu and PM products
• See your 24-hour total against your label limit
• Warnings for doubling up on anti-inflammatories, doses too close together, and health conditions that make a medicine riskier

GUIDED EXERCISE AND REHAB
• Step-by-step exercises with tips, common mistakes and clear stop signs
• Programs for getting started, early recovery after surgery, core strength, leg pain (sciatica) and desk workers
• Programs that suggest when to progress — or ease off — based on how your back responds

YOUR SPINE HISTORY IN ONE PLACE
• Record surgeries, injections, scans and therapy, with levels, implants and how much each one helped
• Attach photos of reports and discharge instructions
• Plain-language information on what to expect and warning signs to watch for

KNOW WHEN TO GET HELP
• A quick warning-sign check tells you whether to call 911, contact a doctor today, or book an appointment
• Crisis support (988) is always one tap away

SHARE WITH YOUR DOCTOR
• Create a one-page appointment summary PDF to share or print

PRIVATE BY DESIGN
• Your information stays on your iPhone — no account, no ads, no data sales
• Optional Face ID lock
• Export or delete everything at any time

FREE AND PREMIUM
Daily check-ins, questionnaires, warning-sign checks, the medicine log, your spine history, 30-day trends, the appointment report and two exercise programs are free. Stroke & Spine Premium adds all exercise programs, the full exercise library and long-term trends and insights. Premium is available as a monthly or annual subscription with a 1-week free trial.

Payment is charged to your Apple ID at confirmation of purchase or when the free trial ends. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID settings.

IMPORTANT
Stroke & Spine is for adults 18 and over. It does not diagnose conditions or give medical advice, and is not for emergencies — if you think you have a medical emergency, call 911. Talk to your doctor or physical therapist before starting a new exercise program.

Terms of Use: [TERMS URL]
Privacy Policy: [PRIVACY URL]
```

### Keywords (100 bytes, comma-separated, no spaces after commas)

```
lower back,sciatica,pain tracker,physical therapy,rehab,spine surgery,ODI,sleep,mood,posture,PT
```

(95 bytes. Don't repeat words already in the name or subtitle, such as "back pain", "track" or "medicines". Apple already indexes those.)

### URLs

| Field | Value |
|---|---|
| Support URL | Your website's contact page, or the hosted `support.html` (see section 9) |
| Marketing URL | Optional |
| Privacy Policy URL | Hosted `privacy.html` |
| Terms of Use (EULA) | Leave Apple's standard EULA selected. Your Terms of Use link is already in the description |

### Screenshots

Required: **6.9-inch iPhone** (1320 × 2868 px, e.g. iPhone 16 Pro Max simulator). Apple scales these down for smaller iPhones. Use up to 10 shots; this order works well:

1. Today screen with a completed check-in — caption: "A 30-second daily check-in"
2. Trends charts — "See how your back is really doing"
3. An exercise session — "Guided exercises with clear stop signs"
4. Medicines with the 24-hour totals — "Stay within label limits"
5. Spine history detail — "Your surgeries and procedures in one place"
6. Warning-sign result — "Know when to get help"
7. Appointment report — "Share a summary with your doctor"

Use realistic, invented sample data. Never use a real patient's information.

### App Review information

- **Sign-in required:** No.
- **Contact:** your name, phone and email.
- **Notes:**

```
Stroke & Spine is a self-tracking and education app for adults with lower back pain. There is no login; all data is stored on the device with SwiftData and nothing is sent to a server.

HealthKit: the app reads step count and sleep analysis (read-only) to display alongside pain scores on the Today screen. HealthKit data is not stored, shared or used for advertising. Tap "Connect Apple Health" on the Today screen to see the permission request.

Medical content (Guideline 1.4.1): the app does not diagnose or recommend treatment. The warning-sign check only tells users how urgently to seek care. Medicine tracking compares the user's logged doses with standard US OTC label limits and never suggests a dose. Questionnaires are validated instruments used under licence/permission. Sources and citations are listed in More → About and disclaimer → Sources. A medical disclaimer is shown and accepted at onboarding.

Subscriptions: Premium (monthly/annual, 1-week free trial) unlocks additional exercise programs, the full exercise library and long-term trends. All safety features are free. To see the paywall: Exercise tab → tap a program marked "Premium".
```

### Version release

Choose **Manually release this version** for the first launch so you control the date.

## 8. Before you press "Submit for Review"

- [ ] ODI and ISI licences signed (or those questionnaires replaced). See `docs/legal/LICENCE_REQUESTS.md`
- [ ] Medical content signed off. See `docs/CONTENT_REVIEW.md`
- [ ] Privacy policy and terms published, and their URLs set in `SpineCare/App/Store.swift` (`privacyURL`, `termsURL`) and in the description
- [ ] [BRACKETS] filled in throughout the privacy policy and terms
- [ ] App icon added (1024 × 1024 PNG, no transparency) in `SpineCare/Resources/Assets.xcassets/AppIcon.appiconset`
- [ ] Tested a purchase, a renewal, a cancellation and Restore in TestFlight with a Sandbox account
- [ ] Short FDA regulatory review done (see `docs/FEATURES.md` §14)

## 9. Hosting the privacy policy, terms and support pages

`docs/site/` contains ready-to-upload pages: `privacy.html`, `terms.html` and `support.html`. Upload them to your own website, for example `https://[your-domain]/privacy`. Any static web host works. Squarespace, Wix or WordPress pages are fine too: paste the content from the Markdown files in `docs/legal/`.

The pages are regenerated from the Markdown with:

```
python3 docs/site/build.py
```
