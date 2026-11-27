# BioStack — supplement, medication and biomarker tracker

An iPhone app and a web app for people who optimise for longevity, training and performance. Both use the same content file, `Resources/catalog.json`.

## Content

| Section | What's in it |
|---|---|
| Supplements (110) | Typical evidence-based dose, timing, evidence grade (A strong → D weak), cautions and interactions, linked goals |
| Nootropics (41) | Own section: 27 over-the-counter supplements with doses (theanine, citicoline, bacopa, paraxanthine, phosphatidylserine and others) and 14 prescription or unapproved compounds as reference only (modafinil, armodafinil, stimulants, racetams, memantine, nicotine; warnings on phenibut and tianeptine) |
| Peptides (16) | Own section with a short guide. Approved peptide medicines (GLP-1s, tesamorelin, bremelanotide, teriparatide, setmelanotide, elamipretide and others) and peptides in clinical trials (retatrutide, CagriSema, kisspeptin): status, sport rules, approved use, mechanism, evidence, risks and labs. No doses |
| Prescription and clinical (38) | Reference-only entries (GLP-1s, metformin, SGLT2 inhibitors, rapamycin, statins, PCSK9 antibodies, hormone therapies and others): regulatory status, approved uses, how it works, evidence, key risks and labs to monitor. **No doses.** Dosing is for the prescriber |
| Goals (16) | Longevity, strength, muscle growth, endurance, recovery, body composition, sleep, cognition, stress, heart, metabolic, joints, immunity, hormonal health, gut, skin |
| Data apps (30) | Wearables, CGMs, lab-testing, biological-age, training and nutrition services, with links |

Anabolic steroids, SARMs and unapproved "research" peptides are intentionally not included.

Edit content in `tools/build_catalog.py` (nootropics and peptides: `tools/catalog_extra.py`), then run:

```
python3 BioStack/tools/build_catalog.py   # regenerates Resources/catalog.json
python3 BioStack/web/build.py             # regenerates web/index.html
```

## Trackers

- **Stack**: items you take, with your dose, time and an optional daily reminder (iPhone)
- **Today**: tick off doses; 7-day adherence dots per item
- **Dose log**: any item, including custom ones and prescriptions, with notes
- **Side effects**: free text plus severity
- **Labs**: blood work and body measurements with trend charts
- **Apple Health (iPhone)**: shows sleep, HRV, resting heart rate, VO2 max, weight, body fat and glucose written by Oura, WHOOP, Garmin, Withings, CGMs and others

All data stays on the device (SwiftData on iPhone, `localStorage` in the browser).

## Web app

`web/index.html` is a single self-contained page. Open it in a browser or host it anywhere. It opens with example data, which can be cleared with one tap.

## iPhone app

The `BioStack` target is defined in the repository's `project.yml`. On a Mac, run `xcodegen generate`, open `SpineCare.xcodeproj`, select the **BioStack** scheme and run. Requires iOS 17. Like the SpineCare app, this code was written without Xcode available and has **not been compiled yet**.

## Before release

- Have the content reviewed by a pharmacist or physician
- Write a privacy policy (consumer health data) and terms with a medical disclaimer
- App Store guideline 1.4.1 (medical apps) applies; keep the clinical section reference-only
