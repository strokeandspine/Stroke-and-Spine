# Open Imaging Slots

A web app that lists open MRI, CT, ultrasound, DEXA and X-ray appointments at radiology practices, with separate portals for:

| Portal | What it does |
|---|---|
| **Patients** | Book an open time with a **physician prescription** (upload a photo or PDF; bill insurance, self-pay or medical-legal), or as **self-pay without a prescription** at centers that offer physician order review. Answer safety screening, then track and message the center. |
| **Physicians** | Sign up with an NPI (check digit validated). Send electronic orders with ICD-10 codes, clinical indication and priority (routine/urgent/STAT). Book an open slot for the patient, or send the order and let the center schedule. Bill insurance, self-pay or medical-legal. |
| **Medical-legal** (attorneys and case managers) | Request scans for injured clients at centers that accept letters of protection, liens and workers' comp. Upload the treating physician's order and the LOP (or WC claim number and carrier), and request expedited reads, narrative reports, certified records or deposition availability. |
| **Imaging centers** | Publish open slots in bulk by modality and scanner, set self-pay prices per exam (CPT), set insurance, self-pay, order-review and medical-legal policies, and work a referral queue: confirm, ask for more information, decline, complete, no-show. |

Anyone can search open times without an account: filter by scan type, exam, ZIP and distance, payment option, scanner (open / wide-bore / 3T) and date, and sort by soonest, price or distance.

## Run it

Requires **Node.js 22.5 or later**. There are no npm dependencies; it uses Node's built-in SQLite.

```bash
cd imaging
npm start          # http://localhost:3000 (PORT=xxxx to change)
npm test           # 27 unit + API tests
npm run reset      # delete data/ and re-seed (demo slots are relative to today)
```

On first start the app seeds 6 fictional Dallas–Fort Worth practices with two weeks of open slots and these demo accounts (password `demo1234`):

| Role | Email |
|---|---|
| Patient | `patient@demo.test` |
| Physician | `doctor@demo.test` |
| Attorney | `attorney@demo.test` |
| Practice: Uptown Imaging Center | `uptown@demo.test` |
| Practice: ClearPrice Imaging (cash price + order review) | `clearprice@demo.test` |

## How requests work

| Request type | Who | Payment options | Order requirement |
|---|---|---|---|
| Physician referral | Physician | Insurance, self-pay, medical-legal | NPI + ICD-10 + indication; slot optional |
| Patient with prescription | Patient | Insurance, self-pay, medical-legal | Upload the prescription |
| Patient self-pay | Patient | Self-pay | Upload an order, **or** describe the reason at a center with physician order review |
| Medical-legal request | Attorney / case manager | Medical-legal | Upload the treating physician's order |

Medical-legal billing needs a case type and date of injury. Injury cases also need attorney contact details and an uploaded LOP/lien; workers' comp needs a claim number and carrier. Only centers that accept medical-legal cases are offered.

**Slots:** a requested slot is *held* (hidden from search) until the center confirms it (*booked*). Declining or cancelling releases it. Double-booking is prevented inside a database transaction.

**Safety screening:** MRI (devices, implants, metal, recent surgery, claustrophobia, pregnancy, plus kidney and allergy questions for contrast), CT (pregnancy, plus contrast questions), X-ray and DEXA (pregnancy; recent contrast for DEXA). A "yes" never blocks a request. It flags the request for the center's review, which is how screening works in practice.

**Statuses:** awaiting scheduling → pending review → confirmed → completed / no-show, with needs-info, declined and cancelled branches. Who can make each change is enforced on the server (`server/domain.js`, `TRANSITIONS`).

## Code map

| File | Contents |
|---|---|
| `server/domain.js` | Exam catalog (CPT, duration, contrast, default prices), prep instructions, screening, request validation, status rules, NPI/ICD-10 checks, time zones |
| `server/db.js` | SQLite schema and demo seed |
| `server/auth.js` | scrypt password hashing, session tokens (stored hashed) |
| `server/app.js` | HTTP API, access control, uploads, static files, security headers |
| `public/` | Single-page front end (vanilla JS, no build step) |
| `test/` | `node:test` unit and API tests |

## Before real patients use it

This is a working prototype. It handles protected health information, so production needs more:

- **HIPAA:** a hosting provider that signs a BAA, encryption at rest for the database and uploads, TLS (`COOKIE_SECURE=1` behind HTTPS), backups, BAAs with each participating practice, and a review of the audit log (`audit` table records logins, views, downloads and status changes).
- **Identity:** email verification, password reset, MFA for practice and physician accounts, and NPI verification against the NPPES registry (currently only the check digit is validated). Practice accounts should be approved before they go live.
- **Notifications:** email/SMS for confirmations and status changes, and a secure link so patients referred by a physician can see their appointment.
- **Order review:** the self-pay "physician order review" path assumes the center has a licensed physician who reviews requests and writes orders. Confirm this meets Texas (or your state's) rules before offering it.
- **Prices:** confirm self-pay prices meet hospital/provider price-transparency and Good Faith Estimate (No Surprises Act) requirements for self-pay patients.
- **Insurance:** eligibility checks and prior-authorization workflow are not built; insurance details are passed to the center.
- **Integrations:** slots are entered in the portal. A real rollout would sync with each center's RIS/PACS scheduling (HL7 SIU / FHIR Schedule and Slot) and send orders as HL7 ORM / FHIR ServiceRequest.
- **Geography:** ZIP search only knows the demo area's ZIP codes (`zips` table). Load a full ZIP centroid dataset.
- **Uploads:** add malware scanning; files are stored on local disk in `data/uploads`.
