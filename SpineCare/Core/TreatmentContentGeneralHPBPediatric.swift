import Foundation

// DRAFT CONTENT — not yet clinically reviewed. See the header of TreatmentOptions.swift.
// General surgery, liver/gallbladder/pancreas (hepatobiliary) and children's surgery.
// Percentages are approximate ranges from the cited sources and must be verified before release.

extension TreatmentGuides {
    static let generalSurgery: [ConditionGuide] = [gsAdultAppendicitis, gsInguinalHernia, gsDiverticulitis]
    static let hepatobiliary: [ConditionGuide] = [hpbGallstones, hpbBileDuctStones, hpbEarlyLiverCancer]
    static let pediatric: [ConditionGuide] = [pedsTonsils, pedsEars, pedsAppendicitis]

    // MARK: - Appendicitis in adults

    static let gsAdultAppendicitis = ConditionGuide(
        id: "adult-appendicitis",
        name: "Appendicitis in adults",
        alsoCalled: "Acute appendicitis, inflamed appendix, uncomplicated appendicitis",
        symbol: "cross.case",
        summary: "The appendix — a small finger-shaped pouch off the large bowel — becomes inflamed and infected. It usually causes pain that starts around the belly button and moves to the lower right side, with fever, loss of appetite and nausea. 'Uncomplicated' means a CT scan shows no burst (perforation), abscess or hard stone (appendicolith) in the appendix.",
        naturalHistory: [
            "Appendicitis does not usually settle on its own without treatment, and some cases burst, which causes a more serious infection.",
            "For uncomplicated appendicitis, large trials show that antibiotics alone clear the attack for most people, so many can avoid or at least delay an operation.",
            "After antibiotics, appendicitis comes back in about 1 in 4 people within a year and about 4 in 10 within 5 years. People with a stone in the appendix are more likely to need surgery.",
        ],
        whenSurgeryIsOffered: [
            "Surgery (appendectomy) is the standard treatment in the US and is offered to almost everyone with appendicitis.",
            "Surgery is the safest option when the appendix has burst with infection spreading through the belly (peritonitis), or when you are very unwell.",
            "Surgery is more strongly advised if a CT scan shows a stone (appendicolith), because antibiotics fail more often and complications are more common.",
        ],
        urgentSigns: [
            "Pain that spreads across the whole belly, a rigid belly, fever over 101°F with shaking chills, fainting or a racing heart — this can mean the appendix has burst. Go to the emergency department now or call 911.",
            "If you are on antibiotics for appendicitis and the pain gets worse instead of better within 24–48 hours, go back to the emergency department.",
        ],
        improvementDefinition: "Treatment success: the appendicitis is cured without a serious complication and, for antibiotics, without needing an appendectomy, about 90 days to 1 year after treatment.",
        options: [
            TreatmentOption(
                id: "appy-antibiotics", name: "Antibiotics first (no operation)", tier: .conservative,
                summary: "Treating uncomplicated appendicitis with antibiotics alone and keeping surgery in reserve if they don't work or the appendicitis comes back.",
                whatHappens: ["Usually a first dose of antibiotics through a drip in the emergency department.", "Many people go home within hours to a day and finish 7–10 days of antibiotic pills.", "You are told what warning signs to watch for and how to come back quickly if pain gets worse."],
                anesthesia: "None", hospitalStay: "Often none or one night; about half of people in the CODA trial went home from the emergency department", recovery: "Most people return to usual activities in a few days to a week.",
                bestFor: ["Uncomplicated appendicitis confirmed on CT scan", "People who want to avoid or delay an operation, or who have a higher risk from anesthesia", "People who can get back to a hospital quickly if things get worse"],
                lessSuitableIf: ["A stone (appendicolith) in the appendix — antibiotics fail more often and complications are more common", "A burst appendix, abscess or signs of spreading infection", "Pregnancy, a weakened immune system or a suspected tumor — these were often excluded from trials"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(2, 8), furtherTreatment: PercentRange(25, 40)),
                keyFindings: [
                    "In the CODA trial of 1,552 US adults, antibiotics were as good as surgery for overall health at 30 days. About 29 in 100 people on antibiotics had an appendectomy within 90 days, rising to about 41 in 100 in those with a stone in the appendix (Flum 2020).",
                    "In the Finnish APPAC trial, about 27 in 100 people treated with antibiotics had an appendectomy within 1 year and about 39 in 100 within 5 years. Most people who needed surgery later did not have a more serious appendicitis (Salminen 2015; Salminen 2018).",
                ],
                sideEffects: [
                    SE.make("Appendicitis doesn't settle or comes back", "You then need an appendectomy, usually the same keyhole operation you would have had at first. About 1 in 4 within a year and 4 in 10 within 5 years.", 25, 40, .moderate),
                    SE.make("Antibiotic side effects", "Diarrhea, nausea, rash or thrush. A serious bowel infection (C. difficile) is uncommon.", 5, 15, .mild),
                    SE.make("Appendix bursts or forms an abscess during treatment", "Higher if there is a stone in the appendix. Needs urgent surgery or a drain.", 1, 5, .serious),
                    SE.make("A hidden tumor in the appendix is missed", "Rare, but more likely in people over about 40. Your doctor may suggest a follow-up scan or colonoscopy.", 0.5, 2, .serious),
                    SE.make("Worry about it coming back", "Some people find the uncertainty stressful; others are glad to have avoided surgery.", 10, 30, .mild),
                ],
                evidence: .strong,
                availability: "Any emergency department can give antibiotics, but not all US surgeons offer antibiotics-first as a routine choice. Covered by Medicare and insurers. A surgeon may not mention it because surgery is the long-standing standard and is very effective.",
                sources: ["Flum DR et al. N Engl J Med 2020;383:1907–19", "Salminen P et al. JAMA 2015;313:2340–8", "Salminen P et al. JAMA 2018;320:1259–65"]),

            TreatmentOption(
                id: "appy-drain", name: "Image-guided drain and antibiotics (for an abscess)", tier: .interventional,
                summary: "If the appendix has already burst and walled off into a pocket of pus (abscess), a radiologist can drain it through a thin tube placed through the skin, with antibiotics, instead of operating straight away.",
                whatHappens: ["A CT or ultrasound scan guides a needle and thin tube into the abscess.", "The tube drains pus into a small bag for several days.", "Antibiotics are given; surgery may be offered weeks later (interval appendectomy) or you may be followed with scans."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Usually several days", recovery: "1–3 weeks; the drain may stay in after you go home.",
                bestFor: ["A walled-off abscess seen on CT, usually after several days of symptoms", "When early surgery would be difficult because of inflamed tissue"],
                lessSuitableIf: ["Uncomplicated appendicitis (no abscess)", "Spreading infection through the belly (peritonitis) — surgery is safer", "Abscesses too small or in a place a needle can't safely reach"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 95), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(10, 25)),
                keyFindings: [
                    "In a review of observational studies, treating an appendix abscess or inflammatory mass without immediate surgery worked for about 9 in 10 people and had fewer complications than immediate surgery. Appendicitis came back in about 7 in 100 (Andersson 2007).",
                ],
                sideEffects: [
                    SE.make("Drain discomfort or blockage", "The tube can be sore or need flushing or replacing.", 10, 25, .mild),
                    SE.make("Drainage doesn't work", "You then need surgery.", 5, 15, .moderate),
                    SE.make("Bleeding or bowel injury from the needle", "Rare. May need surgery.", 0.5, 2, .serious),
                    SE.make("Appendicitis comes back later", "Some people then choose an appendectomy.", 5, 15, .moderate),
                ],
                evidence: .limited,
                availability: "Offered by interventional radiologists at most hospitals. Covered by Medicare and insurers. It's only an option when there is an abscess.",
                sources: ["Andersson RE, Petzold MG. Ann Surg 2007;246:741–8"]),

            TreatmentOption(
                id: "appy-lap", name: "Laparoscopic (keyhole) appendectomy", tier: .minimallyInvasive,
                summary: "The standard operation in the US. The appendix is removed through 3 small cuts using a camera and long instruments.",
                whatHappens: ["Under general anesthesia, the belly is filled with gas so the surgeon can see.", "The appendix is tied off and removed through one of the small cuts.", "Takes about 30–60 minutes."],
                anesthesia: "General anesthesia", hospitalStay: "Often same day or one night for uncomplicated appendicitis", recovery: "Most people return to desk work in 1–2 weeks; avoid heavy lifting for about 2–4 weeks.",
                bestFor: ["Most people with appendicitis, including when there is a stone", "People who want a one-time, definite treatment"],
                lessSuitableIf: ["Very high anesthesia risk (antibiotics or a drain may be safer)"],
                outcomes: OptionOutcomes(improvement: PercentRange(95, 99), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(1, 3)),
                keyFindings: [
                    "Compared with open surgery, keyhole appendectomy causes less pain, fewer wound infections and a shorter hospital stay, though pockets of infection inside the belly may be slightly more common (Jaschinski 2018 review).",
                    "In APPAC, complications over 5 years were more common after surgery than after antibiotics (about 24 vs 7 in 100), mostly wound problems and pain, and mostly in people who had open surgery (Salminen 2018).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(1, 3),
                    SE.make("Pocket of infection inside the belly (abscess)", "May need antibiotics and a drain. More common if the appendix had burst.", 1, 4, .moderate),
                    SE.make("Hernia at a cut", "A bulge at one of the small cuts, sometimes months later. May need repair.", 0.5, 2, .moderate),
                    SE.make("Injury to the bowel, bladder or a blood vessel", "Rare. Usually repaired at the time, but may need a larger operation.", 0.1, 1, .serious),
                    SE.clots(0.1, 0.5),
                    SE.death(0.01, 0.1),
                ],
                evidence: .strong,
                availability: "Available at almost every US hospital with a surgeon on call. Covered by Medicare and insurers.",
                sources: ["Jaschinski T et al. Cochrane Database Syst Rev 2018;11:CD001546", "Salminen P et al. JAMA 2018;320:1259–65", "Flum DR et al. N Engl J Med 2020;383:1907–19"]),

            TreatmentOption(
                id: "appy-open", name: "Open appendectomy", tier: .traditional,
                summary: "The appendix is removed through a single cut of about 2–4 inches in the lower right belly. Still used when keyhole surgery isn't possible or safe.",
                whatHappens: ["Under general anesthesia (sometimes spinal), a cut is made over the appendix.", "The appendix is removed and the muscle layers closed."],
                anesthesia: "General anesthesia, sometimes spinal", hospitalStay: "1–3 days for uncomplicated appendicitis", recovery: "2–4 weeks for usual activities; longer before heavy lifting.",
                bestFor: ["When keyhole equipment or expertise isn't available", "Some people with many previous belly operations or a very complicated infection"],
                lessSuitableIf: ["Most people can have keyhole surgery instead"],
                outcomes: OptionOutcomes(improvement: PercentRange(95, 99), seriousComplications: PercentRange(2, 6), furtherTreatment: PercentRange(1, 3)),
                keyFindings: [
                    "Open surgery has more wound infections and a slightly longer stay and recovery than keyhole surgery, with similar cure rates (Jaschinski 2018 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(3, 8),
                    SE.make("Longer-lasting wound pain or numbness", "Around the scar; usually fades over months.", 5, 15, .mild),
                    SE.make("Hernia at the scar", "May need repair later.", 0.5, 2, .moderate),
                    SE.clots(0.1, 1),
                    SE.death(0.01, 0.2),
                ],
                evidence: .strong,
                availability: "Available at all hospitals. Covered by Medicare and insurers. Usually chosen by the surgeon for a specific reason.",
                sources: ["Jaschinski T et al. Cochrane Database Syst Rev 2018;11:CD001546"]),
        ],
        comparisons: [
            ComparisonStudy(name: "CODA trial", compared: "Antibiotics vs appendectomy for appendicitis (1,552 US adults)",
                finding: "Antibiotics were as good for overall health at 30 days. About 3 in 10 on antibiotics needed an appendectomy by 90 days; those with a stone did worse.", citation: "Flum 2020, N Engl J Med"),
            ComparisonStudy(name: "APPAC trial", compared: "Antibiotics vs open appendectomy for CT-confirmed uncomplicated appendicitis (530 adults)",
                finding: "About 7 in 10 avoided surgery at 1 year and about 6 in 10 at 5 years. Complications were lower with antibiotics.", citation: "Salminen 2015, JAMA; Salminen 2018, JAMA"),
            ComparisonStudy(name: "Cochrane review of keyhole vs open appendectomy", compared: "Laparoscopic vs open appendectomy (many randomized trials)",
                finding: "Keyhole surgery had less pain, fewer wound infections and shorter stays, with a possible small increase in abscesses inside the belly.", citation: "Jaschinski 2018, Cochrane"),
        ],
        questionsToAsk: [
            "Does my CT scan show a stone in the appendix, a burst or an abscess?",
            "Am I a candidate for antibiotics first? What would make you advise surgery instead?",
            "If I choose antibiotics and the pain comes back, how quickly can I be seen?",
            "Given my age, do I need a follow-up scan or colonoscopy to check for a hidden tumor?",
        ],
        specialty: .general)

    // MARK: - Inguinal hernia in adults

    static let gsInguinalHernia = ConditionGuide(
        id: "adult-inguinal-hernia",
        name: "Inguinal (groin) hernia in adults",
        alsoCalled: "Groin hernia, rupture, direct or indirect inguinal hernia",
        symbol: "circle.dashed",
        summary: "A weak spot in the lower belly wall lets fat or bowel bulge out into the groin. It is much more common in men. Many cause only a mild ache or a bulge that goes back in when you lie down.",
        naturalHistory: [
            "Hernias don't heal on their own and tend to slowly get bigger over years.",
            "For men with few or no symptoms, the risk of the hernia becoming stuck (incarcerated) is low — about 2 in 1,000 people each year in a large US trial.",
            "Over time, most people with a hernia develop more symptoms. In long-term follow-up, about 7 in 10 men who started with watchful waiting had chosen surgery by 10 years.",
            "Femoral hernias (lower in the groin, more common in women) are more likely to get stuck and are usually repaired.",
        ],
        whenSurgeryIsOffered: [
            "A hernia that causes pain or limits work, exercise or daily life.",
            "A hernia that is getting bigger or is hard to push back in.",
            "Femoral hernias and most groin hernias in women.",
        ],
        urgentSigns: [
            "A hernia that becomes hard, very tender or can't be pushed back, especially with vomiting, a swollen belly or not passing gas or stool — it may be stuck or losing its blood supply (strangulated). Go to the emergency department now. Emergency surgery is the safest option.",
            "Red, purple or dark skin over the bulge.",
        ],
        improvementDefinition: "Meaningful improvement: groin pain and limits on activity are relieved and the hernia is fixed without recurrence, measured about 2 years after treatment. For watchful waiting, this means symptoms stay acceptable without surgery.",
        options: [
            TreatmentOption(
                id: "ih-watchful-waiting", name: "Watchful waiting", tier: .conservative,
                summary: "Not repairing a hernia that causes few or no symptoms, and having surgery later only if it starts to bother you.",
                whatHappens: ["Your surgeon confirms the hernia and that it is not a femoral hernia.", "You learn the warning signs of a stuck hernia.", "You check in if symptoms grow. Some people wear a support garment or truss for comfort, though evidence for trusses is weak."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Men with a hernia that causes little or no pain", "People with health problems that make surgery riskier", "People who want to delay surgery"],
                lessSuitableIf: ["Femoral hernias", "Women (more likely to have femoral hernias)", "A hernia that is painful, growing or hard to push back"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 75), seriousComplications: PercentRange(0.2, 2), furtherTreatment: PercentRange(25, 70)),
                keyFindings: [
                    "In a US trial of 720 men with minimally symptomatic hernias, watchful waiting was a safe option: at 2 years pain was similar to repair, about 23 in 100 had crossed over to surgery and acute incarceration happened about 1.8 times per 1,000 people per year (Fitzgibbons 2006).",
                    "In long-term follow-up of the same trial, about 68 in 100 men had crossed over to surgery by 10 years — more in men over 65 (Fitzgibbons 2013).",
                ],
                sideEffects: [
                    SE.make("Hernia becomes more painful over time", "The most common reason people change their mind and have a repair.", 25, 70, .mild),
                    SE.make("Hernia becomes stuck (incarcerated)", "Needs emergency surgery, which has higher risks than a planned repair.", 0.2, 2, .serious),
                    SE.make("Bowel loses its blood supply (strangulation)", "Very rare in small, symptom-free hernias but life-threatening. This is why you need to know the warning signs.", 0.05, 0.5, .serious),
                ],
                evidence: .strong,
                availability: "Always available. Some surgeons repair most hernias routinely and may not offer this. Medicare and insurers cover follow-up visits.",
                sources: ["Fitzgibbons RJ et al. JAMA 2006;295:285–92", "Fitzgibbons RJ et al. Ann Surg 2013;258:508–15", "HerniaSurge Group. Hernia 2018;22:1–165"]),

            TreatmentOption(
                id: "ih-lap", name: "Laparoscopic mesh repair (TEP or TAPP)", tier: .minimallyInvasive,
                summary: "The weak spot is covered from inside with a mesh patch, through 3 small cuts using a camera.",
                whatHappens: ["Under general anesthesia, the surgeon works behind the belly wall muscles.", "A mesh patch is placed over the weak area and sometimes fixed with tacks or glue.", "Both sides can be repaired at once."],
                anesthesia: "General anesthesia", hospitalStay: "Usually same day", recovery: "Light activity within days; most people return to work in 1–2 weeks.",
                bestFor: ["Hernias on both sides", "A hernia that came back after open repair", "Women (allows checking for a femoral hernia)", "People who want a faster early recovery"],
                lessSuitableIf: ["People who can't have general anesthesia", "Previous lower-belly surgery such as prostate removal (harder, depending on surgeon experience)", "Very large hernias into the scrotum"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "In a large VA trial, keyhole repair caused less pain and a faster return to activity than open mesh repair, but recurrence was higher (about 10 vs 5 in 100 at 2 years) in surgeons' hands at that time, and serious complications were slightly more common (Neumayer 2004).",
                    "In experienced hands, recurrence after keyhole and open mesh repair is similar, and long-term groin pain may be a little less common after keyhole repair (HerniaSurge 2018).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Fluid collection in the groin (seroma)", "Usually goes away on its own over weeks.", 5, 15, .mild),
                    SE.make("Trouble passing urine after surgery", "May need a catheter for a short time, more common in older men.", 1, 5, .mild),
                    SE.make("Long-lasting groin pain", "Pain that lasts more than 3 months. Severe pain that limits daily life affects fewer people.", 5, 10, .moderate),
                    SE.make("Hernia comes back", "May need another repair.", 1, 5, .moderate),
                    SE.make("Injury to the bladder, bowel or a major blood vessel", "Rare but serious; may need a larger operation.", 0.1, 0.5, .serious),
                    SE.death(0.01, 0.1),
                ],
                evidence: .strong,
                availability: "Widely available, though not every general surgeon does it. Covered by Medicare and insurers.",
                sources: ["Neumayer L et al. N Engl J Med 2004;350:1819–27", "HerniaSurge Group. Hernia 2018;22:1–165"]),

            TreatmentOption(
                id: "ih-robotic", name: "Robotic mesh repair", tier: .minimallyInvasive,
                summary: "The same inside-out mesh repair as laparoscopic surgery, done with a surgical robot that the surgeon controls from a console.",
                whatHappens: ["Similar small cuts and mesh placement as laparoscopic repair.", "The operation often takes longer."],
                anesthesia: "General anesthesia", hospitalStay: "Usually same day", recovery: "Similar to laparoscopic repair.",
                bestFor: ["Similar to laparoscopic repair; some surgeons prefer it for difficult or recurrent hernias"],
                lessSuitableIf: ["Similar to laparoscopic repair"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "In the RIVAL trial, robotic repair gave no benefit over laparoscopic repair for pain or recovery at 30 days, but took longer and cost more (Prabhu 2020).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Fluid collection in the groin (seroma)", "Usually goes away on its own over weeks.", 5, 15, .mild),
                    SE.make("Long-lasting groin pain", "Pain lasting more than 3 months.", 5, 10, .moderate),
                    SE.make("Hernia comes back", "May need another repair.", 1, 5, .moderate),
                    SE.make("Injury to the bladder, bowel or a major blood vessel", "Rare but serious.", 0.1, 0.5, .serious),
                ],
                evidence: .limited,
                availability: "Increasingly common in US hospitals that own a robot. Covered like laparoscopic repair. A surgeon may offer it mainly because it's the system they use.",
                sources: ["Prabhu AS et al. JAMA Surg 2020;155:380–7"]),

            TreatmentOption(
                id: "ih-open-mesh", name: "Open mesh repair (Lichtenstein)", tier: .traditional,
                summary: "The most common hernia repair worldwide. A mesh patch is stitched over the weak area through a 2–3 inch cut in the groin.",
                whatHappens: ["Often done with local anesthetic and sedation, or with spinal or general anesthesia.", "The hernia is pushed back and a flat mesh is stitched in place."],
                anesthesia: "Local anesthetic with sedation, spinal or general anesthesia", hospitalStay: "Usually same day", recovery: "Most people return to light work in 1–3 weeks.",
                bestFor: ["One-sided hernias, especially a first hernia", "People who would rather avoid general anesthesia", "Very large hernias into the scrotum"],
                lessSuitableIf: ["Hernias on both sides or a recurrence after an open repair (keyhole is usually preferred)"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "Open mesh repair had lower recurrence than keyhole repair in the VA trial (about 5 vs 10 in 100 at 2 years) but more pain early on (Neumayer 2004).",
                    "Mesh repairs have fewer recurrences than stitch-only repairs (Lockhart 2018 review).",
                ],
                sideEffects: [
                    SE.make("Bruising and swelling of the groin or scrotum", "Common; settles over 1–2 weeks.", 10, 20, .mild),
                    SE.woundInfection(1, 3),
                    SE.make("Long-lasting groin pain", "Pain lasting more than 3 months, sometimes from a nerve caught in scar tissue. Severe pain affects fewer people.", 6, 12, .moderate),
                    SE.make("Hernia comes back", "May need another repair, usually keyhole.", 1, 5, .moderate),
                    SE.make("Testicle problems (men)", "Swelling or, rarely, shrinking of the testicle from injury to its blood supply.", 0.3, 1, .serious),
                    SE.clots(0.05, 0.5),
                ],
                evidence: .strong,
                availability: "Available almost everywhere. Covered by Medicare and insurers.",
                sources: ["Neumayer L et al. N Engl J Med 2004;350:1819–27", "Lockhart K et al. Cochrane Database Syst Rev 2018;9:CD011517", "HerniaSurge Group. Hernia 2018;22:1–165"]),

            TreatmentOption(
                id: "ih-tissue-repair", name: "Open stitch repair without mesh (Shouldice)", tier: .traditional,
                summary: "The weak layers of the belly wall are overlapped and stitched together without mesh, through an open groin cut.",
                whatHappens: ["Usually local anesthetic with sedation.", "Layers of muscle and tissue are stitched in several rows."],
                anesthesia: "Usually local anesthetic with sedation", hospitalStay: "Same day to a few days", recovery: "2–4 weeks for usual activities.",
                bestFor: ["People who want to avoid mesh", "Small hernias, often in younger men, in specialist centers"],
                lessSuitableIf: ["Large or recurrent hernias", "If no surgeon nearby is experienced in the technique"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 95), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(2, 8)),
                keyFindings: [
                    "Shouldice repair has fewer recurrences than other stitch-only repairs but more than mesh repairs in most trials (Amato 2012 review; Lockhart 2018 review).",
                ],
                sideEffects: [
                    SE.make("Bruising and swelling", "Settles over 1–2 weeks.", 10, 20, .mild),
                    SE.woundInfection(1, 3),
                    SE.make("Long-lasting groin pain", "Pain lasting more than 3 months.", 5, 10, .moderate),
                    SE.make("Hernia comes back", "Higher than with mesh in most studies outside specialist centers.", 2, 8, .moderate),
                    SE.make("Testicle problems (men)", "Rarely, injury to the testicle's blood supply.", 0.3, 1, .serious),
                ],
                evidence: .moderate,
                availability: "Offered by a few specialist centers and some surgeons for people who want to avoid mesh. Covered like other hernia repairs.",
                sources: ["Amato B et al. Cochrane Database Syst Rev 2012;4:CD001543", "Lockhart K et al. Cochrane Database Syst Rev 2018;9:CD011517"]),
        ],
        comparisons: [
            ComparisonStudy(name: "US watchful waiting trial", compared: "Watchful waiting vs open mesh repair in men with minimally symptomatic hernias (720 men)",
                finding: "Pain and function similar at 2 years; stuck hernias were rare. Most men eventually chose surgery over 10 years.", citation: "Fitzgibbons 2006, JAMA; Fitzgibbons 2013, Ann Surg"),
            ComparisonStudy(name: "VA hernia trial", compared: "Laparoscopic vs open mesh repair (about 2,000 men)",
                finding: "Keyhole repair: less pain and faster recovery, but more recurrences overall at that time.", citation: "Neumayer 2004, N Engl J Med"),
            ComparisonStudy(name: "RIVAL trial", compared: "Robotic vs laparoscopic repair (102 people)",
                finding: "No difference in pain or recovery; robotic surgery took longer and cost more.", citation: "Prabhu 2020, JAMA Surg"),
        ],
        questionsToAsk: [
            "Is this an inguinal or a femoral hernia? How likely is it to get stuck?",
            "If my hernia barely bothers me, is it reasonable to wait?",
            "Which repair do you recommend for me, and how many of each do you do?",
            "What is your rate of long-lasting groin pain and recurrence?",
        ],
        specialty: .general)

    // MARK: - Diverticulitis

    static let gsDiverticulitis = ConditionGuide(
        id: "adult-diverticulitis",
        name: "Diverticulitis",
        alsoCalled: "Colonic diverticulitis, sigmoid diverticulitis, diverticular disease",
        symbol: "arrow.triangle.2.circlepath",
        summary: "Small pouches in the wall of the large bowel (diverticula) become inflamed, usually in the lower left belly. It causes pain, sometimes with fever and changed bowel habits. 'Uncomplicated' means no abscess, burst (perforation), blockage or abnormal connection (fistula).",
        naturalHistory: [
            "Most attacks of uncomplicated diverticulitis settle within 1–2 weeks with rest, clear fluids and pain relief.",
            "After a first attack, roughly 1 to 2 in 10 people have another within a few years. Most repeat attacks are no more severe than the first.",
            "The risk of a burst bowel needing emergency surgery is low after a first attack and doesn't rise steeply with each repeat attack. That's why surgery is no longer advised just because of the number of attacks.",
        ],
        whenSurgeryIsOffered: [
            "Emergency surgery for a burst bowel with infection spreading through the belly (peritonitis) — here surgery is the safest option.",
            "Planned surgery may be offered for frequent attacks or ongoing pain that affects your quality of life, or after complicated diverticulitis (abscess, fistula, narrowing).",
            "Planned surgery is also considered more often in people with a weakened immune system.",
        ],
        urgentSigns: [
            "Severe belly pain that spreads, a rigid belly, fever over 101°F, vomiting or being unable to keep fluids down — go to the emergency department now.",
            "Passing gas or stool from the vagina or bubbles in the urine (a possible fistula), or blood in your stool — contact your doctor promptly.",
        ],
        improvementDefinition: "Meaningful improvement: recovery from the attack without complications, and fewer repeat attacks or better bowel-related quality of life, measured about 6 months to 2 years after treatment.",
        options: [
            TreatmentOption(
                id: "div-observation", name: "Observation without antibiotics", tier: .conservative,
                summary: "For mild, uncomplicated diverticulitis confirmed on CT, managing the attack with pain relief and a liquid then soft diet, without antibiotics.",
                whatHappens: ["A CT scan confirms uncomplicated diverticulitis.", "Usually at home, with acetaminophen (Tylenol) for pain and a clear-fluid diet for a few days.", "A check-in within a few days, and a plan to return if you get worse."],
                anesthesia: "None", hospitalStay: "Usually none", recovery: "Most people feel better in 1–2 weeks.",
                bestFor: ["Healthy people with a mild, CT-confirmed uncomplicated attack who can eat and drink"],
                lessSuitableIf: ["Fever, high white cell count or feeling very unwell", "A weakened immune system, pregnancy or serious other illness", "An abscess or other complication on CT"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(0.5, 3), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In the Dutch DIABOLO trial (528 people), observation without antibiotics did not slow recovery (median about 14 vs 12 days) and complications, repeat attacks and surgery rates were similar to antibiotics (Daniels 2017).",
                    "In the Swedish AVOD trial (623 people), not using antibiotics did not speed or prevent complications or recurrence compared with antibiotics (Chabok 2012).",
                ],
                sideEffects: [
                    SE.make("Attack doesn't settle", "You may then need antibiotics or a hospital stay.", 5, 10, .moderate),
                    SE.make("Repeat attack", "About 1 to 2 in 10 people within a year or two — similar with or without antibiotics.", 10, 20, .moderate),
                    SE.make("Abscess or burst bowel", "Uncommon. Needs a drain or surgery.", 0.5, 3, .serious),
                ],
                evidence: .strong,
                availability: "Recommended as an option in US guidelines for selected people, but many doctors still prescribe antibiotics routinely. No special cost.",
                sources: ["Daniels L et al. Br J Surg 2017;104:52–61", "Chabok A et al. Br J Surg 2012;99:532–9"]),

            TreatmentOption(
                id: "div-outpatient-antibiotics", name: "Antibiotics and bowel rest at home or in hospital", tier: .conservative,
                summary: "The traditional treatment for an attack: antibiotics (pills at home, or through a drip in the hospital if you are unwell) with a liquid diet.",
                whatHappens: ["Antibiotic pills for about 7–10 days at home, or through a drip in the hospital if you can't keep fluids down.", "Clear liquids, then a gradual return to normal food.", "A colonoscopy is often suggested 6–8 weeks later if you haven't had one recently, to rule out cancer."],
                anesthesia: "None", hospitalStay: "None for most people; a few days if admitted", recovery: "1–2 weeks.",
                bestFor: ["Most uncomplicated attacks, especially with fever or other health problems", "Small abscesses (under about 1.5 inches) that may settle with antibiotics alone"],
                lessSuitableIf: ["Spreading infection through the belly (needs surgery)", "Large abscess (usually needs a drain)"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(0.5, 3), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In a Spanish trial, outpatient treatment was as safe as hospital treatment for uncomplicated diverticulitis, with lower cost (Biondo 2014).",
                    "Antibiotics did not reduce complications or repeat attacks compared with observation in mild uncomplicated cases (Daniels 2017; Chabok 2012).",
                ],
                sideEffects: [
                    SE.make("Antibiotic side effects", "Diarrhea, nausea, metallic taste or rash. A serious bowel infection (C. difficile) is uncommon.", 10, 20, .mild),
                    SE.make("Repeat attack", "About 1 to 2 in 10 people within a year or two.", 10, 20, .moderate),
                    SE.make("Abscess or burst bowel", "Uncommon. Needs a drain or surgery.", 0.5, 3, .serious),
                ],
                evidence: .strong,
                availability: "Widely available. Covered by Medicare and insurers.",
                sources: ["Biondo S et al. Ann Surg 2014;259:38–44", "Daniels L et al. Br J Surg 2017;104:52–61", "Chabok A et al. Br J Surg 2012;99:532–9"]),

            TreatmentOption(
                id: "div-drain", name: "Image-guided abscess drain", tier: .interventional,
                summary: "For a larger abscess next to the bowel, a radiologist places a thin tube through the skin to drain the pus, with antibiotics.",
                whatHappens: ["A CT scan guides a needle and drain into the abscess.", "The drain stays in for several days to a couple of weeks.", "Planned surgery may be discussed later."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Usually several days", recovery: "1–3 weeks.",
                bestFor: ["An abscess larger than about 1.5 inches that a needle can reach safely"],
                lessSuitableIf: ["Spreading infection through the belly (needs surgery)", "Very small abscesses (antibiotics alone)"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 90), seriousComplications: PercentRange(2, 10), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "Drainage avoids emergency surgery for most people with a diverticular abscess, but repeat attacks and later surgery are more common than after uncomplicated diverticulitis. Evidence comes mostly from observational studies and is of limited quality.",
                ],
                sideEffects: [
                    SE.make("Drain discomfort or blockage", "May need flushing or replacing.", 10, 25, .mild),
                    SE.make("Drainage doesn't work", "You may then need surgery.", 10, 25, .moderate),
                    SE.make("Bleeding or bowel injury from the needle", "Rare.", 0.5, 2, .serious),
                ],
                evidence: .limited,
                availability: "Offered by interventional radiologists at most hospitals. Covered by Medicare and insurers.",
                sources: ["Hall J et al. Dis Colon Rectum 2020;63:728–47"]),

            TreatmentOption(
                id: "div-lap-colectomy", name: "Planned laparoscopic sigmoid colectomy", tier: .minimallyInvasive,
                summary: "Removing the affected part of the bowel (usually the sigmoid colon) and joining the ends, through small cuts with a camera, at a time when you are well.",
                whatHappens: ["Usually planned at least 6–8 weeks after an attack.", "The diseased bowel is removed and the two ends are joined.", "Occasionally a temporary bag (stoma) is needed."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 2–5 days", recovery: "Usually 4–6 weeks for normal activities.",
                bestFor: ["Frequent attacks or ongoing pain that seriously affects quality of life", "After complicated diverticulitis such as a fistula or narrowing", "Some people with weakened immune systems"],
                lessSuitableIf: ["One or two mild attacks that settled well", "High surgical risk"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(10, 20), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the Dutch DIRECT trial (109 people with repeated or ongoing symptoms), surgery gave better bowel-related quality of life at 6 months than continued non-surgical care. But 15 in 100 of those who had surgery had a leak where the bowel was joined, and about 23 in 100 of the non-surgical group chose surgery later (van de Wall 2017).",
                    "In the Sigma trial, keyhole surgery had fewer major complications than open surgery (Klarenbeek 2009).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(3, 10),
                    SE.make("Leak where the bowel is joined (anastomotic leak)", "Can cause serious infection and may need another operation or a temporary bag.", 2, 15, .serious),
                    SE.make("Temporary or permanent bag (stoma)", "Sometimes needed, especially if there's a leak.", 2, 10, .moderate),
                    SE.make("Changes in bowel habit", "More frequent or urgent stools for some months.", 10, 25, .mild),
                    SE.make("Ongoing belly pain after surgery", "Symptoms don't fully go away for some people.", 10, 25, .moderate),
                    SE.clots(0.5, 2),
                    SE.death(0.1, 1),
                ],
                evidence: .moderate,
                availability: "Offered by general and colorectal surgeons in most hospitals. Covered by Medicare and insurers.",
                sources: ["van de Wall BJM et al. Lancet Gastroenterol Hepatol 2017;2:13–22", "Klarenbeek BR et al. Ann Surg 2009;249:39–44", "Hall J et al. Dis Colon Rectum 2020;63:728–47"]),

            TreatmentOption(
                id: "div-open-colectomy", name: "Open colectomy (planned or emergency, including Hartmann's)", tier: .traditional,
                summary: "Removing the diseased bowel through a larger cut in the belly. In emergencies, the ends may not be joined and a bag (colostomy) is made (Hartmann's procedure).",
                whatHappens: ["A cut down the middle of the belly.", "The diseased bowel is removed; the ends are joined or a colostomy is made.", "A colostomy can often be reversed months later with another operation."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 5–10 days; longer after emergencies", recovery: "6–12 weeks.",
                bestFor: ["Emergency surgery for a burst bowel with peritonitis — here surgery is the safest option", "When keyhole surgery isn't possible"],
                lessSuitableIf: ["Most planned operations can be done by keyhole surgery"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(20, 35), furtherTreatment: PercentRange(20, 50)),
                keyFindings: [
                    "Emergency operations for a burst bowel carry much higher risks than planned surgery, including death in roughly 5 to 15 in 100 people, depending on age and illness. Many people who have a colostomy made in an emergency never have it reversed.",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(10, 25),
                    SE.make("Colostomy bag", "Common after emergency surgery. Reversal needs another major operation.", 30, 70, .moderate),
                    SE.make("Hernia at the scar", "A bulge in the scar that may need repair.", 10, 30, .moderate),
                    SE.make("Leak where the bowel is joined", "May need another operation.", 2, 10, .serious),
                    SE.clots(1, 3),
                    SE.death(1, 15),
                ],
                evidence: .moderate,
                availability: "Available at all hospitals with surgeons on call. Covered by Medicare and insurers.",
                sources: ["Klarenbeek BR et al. Ann Surg 2009;249:39–44", "Hall J et al. Dis Colon Rectum 2020;63:728–47"]),
        ],
        comparisons: [
            ComparisonStudy(name: "DIABOLO trial", compared: "Observation vs antibiotics for uncomplicated diverticulitis (528 people)",
                finding: "No meaningful difference in recovery time, complications, repeat attacks or surgery.", citation: "Daniels 2017, Br J Surg"),
            ComparisonStudy(name: "AVOD trial", compared: "No antibiotics vs antibiotics for uncomplicated diverticulitis (623 people)",
                finding: "Antibiotics didn't speed recovery or prevent complications or recurrence.", citation: "Chabok 2012, Br J Surg"),
            ComparisonStudy(name: "DIRECT trial", compared: "Planned sigmoid colectomy vs non-surgical care for recurrent or ongoing symptoms (109 people)",
                finding: "Better quality of life with surgery at 6 months, at the cost of a 15 in 100 rate of leaks; about 1 in 4 non-surgical patients chose surgery later.", citation: "van de Wall 2017, Lancet Gastroenterol Hepatol"),
        ],
        questionsToAsk: [
            "Was my diverticulitis uncomplicated on the CT scan?",
            "Do I need antibiotics this time, or is observation reasonable?",
            "Is surgery being suggested because of the number of attacks, or because of how they affect my life?",
            "What is your leak and stoma rate for planned keyhole colectomy?",
            "Have I had a colonoscopy to rule out cancer?",
        ],
        specialty: .general)

    // MARK: - Symptomatic gallstones and acute cholecystitis

    static let hpbGallstones = ConditionGuide(
        id: "symptomatic-gallstones",
        name: "Gallstones causing pain, and gallbladder inflammation",
        alsoCalled: "Biliary colic, symptomatic cholelithiasis, acute cholecystitis",
        symbol: "leaf",
        summary: "Stones in the gallbladder can block its outlet, causing attacks of pain in the upper right or middle belly, often after meals (biliary colic). If the blockage lasts, the gallbladder can become inflamed or infected (acute cholecystitis).",
        naturalHistory: [
            "Most people with gallstones never have symptoms and don't need treatment.",
            "After a first attack of pain, many people have more attacks, but some have few or none for years.",
            "Each year, roughly 1 to 3 in 100 people with painful gallstones develop a complication such as gallbladder inflammation, a stone in the bile duct or pancreatitis.",
        ],
        whenSurgeryIsOffered: [
            "Repeated attacks of typical gallstone pain.",
            "After a complication such as acute cholecystitis, gallstone pancreatitis or a bile duct stone.",
            "For acute cholecystitis, keyhole gallbladder removal within a few days is usually advised for people fit enough for surgery.",
        ],
        urgentSigns: [
            "Pain lasting more than 6 hours, fever over 100.4°F with chills, yellow skin or eyes (jaundice), dark urine or pale stools — go to the emergency department.",
            "Severe pain going through to your back with vomiting — this may be pancreatitis. Go to the emergency department now.",
        ],
        improvementDefinition: "Meaningful improvement: free of gallstone pain and complications, measured about 1–2 years after starting treatment.",
        options: [
            TreatmentOption(
                id: "gb-watchful-waiting", name: "Watchful waiting with pain relief", tier: .conservative,
                summary: "Not removing the gallbladder straight away after typical pain, managing attacks with pain relief and having surgery only if attacks continue or a complication occurs.",
                whatHappens: ["Pain relief such as anti-inflammatories for attacks.", "Some people find smaller, lower-fat meals help, though evidence is limited.", "Review if pain keeps coming back."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Mild or infrequent attacks", "Pain that isn't clearly from gallstones", "People with a high risk from surgery"],
                lessSuitableIf: ["Past acute cholecystitis, pancreatitis or a bile duct stone", "Frequent or severe attacks"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(2, 6), furtherTreatment: PercentRange(25, 40)),
                keyFindings: [
                    "In the UK C-GALL trial (434 adults), quality of life over 18 months was the same with watchful waiting as with keyhole surgery. About 30 in 100 people in the watchful waiting group had surgery within 2 years. Gallstone-specific symptoms were somewhat better after surgery (Innes 2024).",
                    "In the Dutch SECURE trial, offering surgery only to people meeting stricter pain criteria led to fewer operations but did not leave more people pain-free (van Dijk 2019).",
                ],
                sideEffects: [
                    SE.make("More attacks of pain", "Many people continue to have attacks.", 30, 50, .mild),
                    SE.make("Gallbladder inflammation (acute cholecystitis)", "Needs hospital treatment and often urgent surgery.", 1, 5, .moderate),
                    SE.make("Gallstone pancreatitis or bile duct stone", "Can be serious and needs hospital treatment.", 0.5, 2, .serious),
                    SE.nsaidStomach,
                ],
                evidence: .moderate,
                availability: "Always available. Many surgeons offer surgery after the first attack because it is effective and low-risk for most people.",
                sources: ["Innes K et al. Health Technol Assess 2024;28(26):1–151", "van Dijk AH et al. Lancet 2019;393:2322–30"]),

            TreatmentOption(
                id: "gb-perc-drain", name: "Gallbladder drain through the skin (percutaneous cholecystostomy)", tier: .interventional,
                summary: "For acute cholecystitis in people too unwell for surgery, a radiologist places a thin tube through the skin into the gallbladder to drain the infected bile.",
                whatHappens: ["Ultrasound or CT guides a needle and tube into the gallbladder.", "The tube drains bile into a bag for several weeks.", "The tube may be removed later, or the gallbladder removed once you are fitter."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Usually several days", recovery: "Weeks; the tube stays in after you go home.",
                bestFor: ["Acute cholecystitis in people who are very frail or too ill for surgery"],
                lessSuitableIf: ["People fit enough for keyhole surgery — the CHOCOLATE trial found surgery safer for them", "Uncomplicated gallstone pain"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 90), seriousComplications: PercentRange(20, 65), furtherTreatment: PercentRange(30, 66)),
                keyFindings: [
                    "In the CHOCOLATE trial of 142 high-risk people with acute cholecystitis, major complications happened in 65 in 100 after a drain vs 12 in 100 after keyhole surgery, mostly because the problem came back (53 vs 5 in 100) and more repeat procedures were needed (Loozen 2018).",
                ],
                sideEffects: [
                    SE.make("Tube falls out or gets blocked", "May need replacing.", 10, 20, .moderate),
                    SE.make("Gallbladder trouble comes back", "About half of people had more gallstone problems within a year in CHOCOLATE.", 30, 55, .moderate),
                    SE.make("Bile leak or bleeding", "Uncommon.", 1, 5, .serious),
                ],
                evidence: .moderate,
                availability: "Offered by interventional radiologists at most hospitals. Covered by Medicare and insurers.",
                sources: ["Loozen CS et al. BMJ 2018;363:k3965"]),

            TreatmentOption(
                id: "gb-eus-drain", name: "Endoscopic gallbladder drain (EUS-guided)", tier: .interventional,
                summary: "A gastroenterologist uses an ultrasound scope passed through the mouth to place a small stent between the stomach or duodenum and the gallbladder, so it drains internally with no tube outside the body.",
                whatHappens: ["Done under sedation or anesthesia with a scope through the mouth.", "A short metal stent connects the gallbladder to the bowel.", "No external bag."],
                anesthesia: "Deep sedation or general anesthesia", hospitalStay: "Usually a few days", recovery: "Days to weeks.",
                bestFor: ["Acute cholecystitis in people too ill or frail for surgery, at centers with expertise"],
                lessSuitableIf: ["People who may later want their gallbladder removed (the stent can make later surgery harder)", "Centers without experienced endoscopists"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(10, 26), furtherTreatment: PercentRange(3, 15)),
                keyFindings: [
                    "In the DRAC 1 trial of 80 very high-risk people, endoscopic drainage had fewer adverse events at 1 year than a drain through the skin (about 26 vs 78 in 100), with less recurrent cholecystitis (Teoh 2020).",
                ],
                sideEffects: [
                    SE.make("Stent blocks or moves", "May need another endoscopy.", 2, 10, .moderate),
                    SE.make("Bleeding or leak", "Uncommon; may need another procedure.", 1, 5, .serious),
                    SE.make("Recurrent gallbladder inflammation", "Less common than with a tube through the skin.", 2, 5, .moderate),
                ],
                evidence: .limited,
                availability: "Available mainly at larger hospitals with advanced endoscopy. Usually covered, but not every hospital offers it, so it may not be mentioned.",
                sources: ["Teoh AYB et al. Gut 2020;69:1085–91"]),

            TreatmentOption(
                id: "gb-lap-chole", name: "Laparoscopic (keyhole) gallbladder removal", tier: .minimallyInvasive,
                summary: "The standard operation: the gallbladder and its stones are removed through 3–4 small cuts using a camera.",
                whatHappens: ["Under general anesthesia, the belly is filled with gas.", "The gallbladder is separated from the liver and its duct and artery are clipped.", "Takes about 1 hour. Sometimes an X-ray of the bile ducts is done during surgery."],
                anesthesia: "General anesthesia", hospitalStay: "Usually same day for planned surgery; a few days after acute cholecystitis", recovery: "Most people return to desk work within 1–2 weeks.",
                bestFor: ["Repeated typical gallstone attacks", "After acute cholecystitis, pancreatitis or a bile duct stone", "High-risk people with acute cholecystitis who can still have surgery (CHOCOLATE)"],
                lessSuitableIf: ["Pain that may not be from gallstones — it may persist after surgery", "Very high anesthesia risk"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 90), seriousComplications: PercentRange(1, 5), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "Keyhole removal has similar safety to open surgery with a shorter stay and faster recovery (Keus 2006 review).",
                    "In the CHOCOLATE trial, keyhole surgery in high-risk people with acute cholecystitis had far fewer major complications (12 vs 65 in 100) than a drain, with no significant difference in deaths (3 vs 9 in 100) (Loozen 2018).",
                    "Some people still have belly pain or digestive symptoms after surgery — in trials, roughly 1 in 4 to 1 in 3.",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Ongoing pain or digestive symptoms", "Some people's symptoms weren't fully caused by gallstones.", 20, 35, .mild),
                    SE.make("Diarrhea after fatty meals", "Usually improves over months.", 5, 15, .mild),
                    SE.woundInfection(1, 3),
                    SE.make("Bile leak", "Usually treated with an ERCP stent.", 0.5, 1.5, .moderate),
                    SE.make("Bile duct injury", "Rare but serious; may need major reconstructive surgery.", 0.2, 0.5, .serious),
                    SE.death(0.05, 0.3),
                ],
                evidence: .strong,
                availability: "Available at almost every US hospital. Covered by Medicare and insurers.",
                sources: ["Keus F et al. Cochrane Database Syst Rev 2006;4:CD006231", "Loozen CS et al. BMJ 2018;363:k3965", "Innes K et al. Health Technol Assess 2024;28(26):1–151"]),

            TreatmentOption(
                id: "gb-open-chole", name: "Open gallbladder removal", tier: .traditional,
                summary: "The gallbladder is removed through a 4–6 inch cut under the right ribs. Today mostly used when keyhole surgery is unsafe or has to be converted.",
                whatHappens: ["Under general anesthesia, a cut below the right ribs.", "The gallbladder is removed; sometimes only part of it if it is very inflamed (subtotal cholecystectomy)."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 3–5 days", recovery: "4–6 weeks.",
                bestFor: ["Severe inflammation or scarring where keyhole surgery isn't safe", "When the surgeon converts during a keyhole operation"],
                lessSuitableIf: ["Most people can have keyhole surgery"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 90), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "Open surgery cures gallstone disease as well as keyhole surgery but means a longer stay and recovery (Keus 2006 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(3, 8),
                    SE.make("Hernia at the scar", "May need repair.", 2, 8, .moderate),
                    SE.make("Bile leak or bile duct injury", "May need more procedures or surgery.", 0.5, 2, .serious),
                    SE.clots(0.5, 2),
                    SE.death(0.2, 1),
                ],
                evidence: .moderate,
                availability: "Available at all hospitals. Covered by Medicare and insurers. Usually chosen for a specific reason.",
                sources: ["Keus F et al. Cochrane Database Syst Rev 2006;4:CD006231"]),
        ],
        comparisons: [
            ComparisonStudy(name: "C-GALL trial", compared: "Watchful waiting vs keyhole gallbladder removal for uncomplicated painful gallstones (434 adults)",
                finding: "Same overall quality of life at 18 months; about 30 in 100 in the waiting group had surgery by 2 years. Gallstone symptoms were somewhat better after surgery.", citation: "Innes 2024, Health Technol Assess"),
            ComparisonStudy(name: "CHOCOLATE trial", compared: "Keyhole surgery vs drain through the skin for acute cholecystitis in high-risk people (142 people)",
                finding: "Far fewer major complications with surgery (12 vs 65 in 100), fewer repeat procedures and shorter stays.", citation: "Loozen 2018, BMJ"),
            ComparisonStudy(name: "DRAC 1 trial", compared: "Endoscopic vs through-the-skin gallbladder drainage in very high-risk people (80 people)",
                finding: "Fewer adverse events at 1 year with the endoscopic approach.", citation: "Teoh 2020, Gut"),
        ],
        questionsToAsk: [
            "How sure are you that my pain is from gallstones?",
            "Have I had a complication, or only pain? Is waiting reasonable for me?",
            "If I'm too unwell for surgery, could an endoscopic drain be an option instead of a tube?",
            "How many gallbladder removals do you do, and what is your bile duct injury rate?",
        ],
        specialty: .hepatobiliary)

    // MARK: - Common bile duct stones

    static let hpbBileDuctStones = ConditionGuide(
        id: "common-bile-duct-stones",
        name: "Gallstones in the bile duct",
        alsoCalled: "Common bile duct stones, choledocholithiasis",
        symbol: "point.topleft.down.to.point.bottomright.curvepath",
        summary: "A gallstone moves out of the gallbladder into the main bile duct, which carries bile from the liver to the bowel. It can cause pain, yellow skin (jaundice), infection of the bile duct (cholangitis) or pancreatitis.",
        naturalHistory: [
            "Some small stones pass into the bowel on their own — perhaps roughly 1 in 5 to 1 in 3 within weeks — but it's hard to predict which.",
            "Stones left in the duct can cause serious infection or pancreatitis, so most guidelines advise removing them even if symptoms settle.",
            "If the gallbladder is left in place after clearing the duct, gallstone problems often come back.",
        ],
        whenSurgeryIsOffered: [
            "Removing the gallbladder is usually advised after bile duct stones are cleared, to stop new ones forming.",
            "Some hospitals remove the gallbladder and clear the duct in one keyhole operation.",
        ],
        urgentSigns: [
            "Fever with chills, yellow skin or eyes and belly pain together can mean a bile duct infection (cholangitis), which can be life-threatening — go to the emergency department now.",
            "Severe upper belly pain going to your back with vomiting may be pancreatitis — go to the emergency department.",
        ],
        improvementDefinition: "Meaningful improvement: the bile duct is cleared of stones without serious complications, and no further gallstone problems for about 2 years.",
        options: [
            TreatmentOption(
                id: "cbd-wait-and-see", name: "Wait for a small stone to pass, with repeat imaging", tier: .conservative,
                summary: "For a small stone in someone without infection or jaundice that is getting worse, waiting a short time and rescanning before deciding on a procedure.",
                whatHappens: ["Blood tests and an MRI scan (MRCP) or endoscopic ultrasound to check whether the stone is still there.", "If the stone has passed, a procedure on the duct may not be needed."],
                anesthesia: "None", hospitalStay: "Often in hospital for a short time while tests are done", recovery: "None.",
                bestFor: ["Small stones with improving blood tests and no infection", "People in whom it's unclear whether a stone is still present"],
                lessSuitableIf: ["Cholangitis (bile duct infection) — needs urgent ERCP", "Worsening jaundice or blood tests", "Large stones"],
                outcomes: OptionOutcomes(improvement: PercentRange(20, 35), seriousComplications: PercentRange(2, 10), furtherTreatment: PercentRange(65, 80)),
                keyFindings: [
                    "Studies that rescanned before ERCP found that a meaningful share of suspected stones had already passed, avoiding an unneeded procedure. Exact numbers vary widely between studies, so this figure is approximate.",
                ],
                sideEffects: [
                    SE.make("Stone stays and still needs removing", "Most people still need ERCP or surgery.", 65, 80, .mild),
                    SE.make("Bile duct infection (cholangitis)", "Needs urgent treatment.", 1, 5, .serious),
                    SE.make("Pancreatitis from the stone", "Can be serious.", 1, 5, .serious),
                ],
                evidence: .veryLimited,
                availability: "Depends on the hospital and access to MRI or endoscopic ultrasound. Usually covered.",
                sources: ["Buxbaum JL et al. Gastrointest Endosc 2019;89:1075–105"]),

            TreatmentOption(
                id: "cbd-ercp-then-chole", name: "ERCP to clear the duct, then keyhole gallbladder removal", tier: .interventional,
                summary: "The most common approach in the US. A gastroenterologist passes a flexible scope through the mouth to the bile duct opening, widens it and pulls the stone out. The gallbladder is then removed by keyhole surgery.",
                whatHappens: ["ERCP under sedation or anesthesia; a small cut in the duct opening (sphincterotomy) and a balloon or basket to remove stones.", "A stent may be left if the duct can't be cleared.", "Keyhole gallbladder removal, ideally in the same admission or within weeks."],
                anesthesia: "Deep sedation or general anesthesia", hospitalStay: "1–3 days", recovery: "About 1–2 weeks after the gallbladder surgery.",
                bestFor: ["Most people with bile duct stones", "Cholangitis (urgent ERCP)", "People whose hospital doesn't offer keyhole duct exploration"],
                lessSuitableIf: ["Altered stomach anatomy (such as gastric bypass) — ERCP is harder"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(5, 10), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "ERCP and keyhole bile duct exploration clear the duct about equally well, with similar deaths and complications (Dasari 2013 review).",
                    "Complications of ERCP with sphincterotomy, mostly pancreatitis, occurred in about 10 in 100 people in a large US study (Freeman 1996).",
                ],
                sideEffects: [
                    SE.make("Pancreatitis after ERCP", "Usually mild, but can be severe.", 3, 10, .moderate),
                    SE.make("Bleeding from the duct opening", "Usually stopped during a repeat endoscopy.", 1, 2, .moderate),
                    SE.make("Bile duct infection", "Treated with antibiotics.", 0.5, 2, .moderate),
                    SE.make("Bowel tear (perforation)", "Rare but may need surgery.", 0.1, 0.6, .serious),
                    SE.make("Stones not fully cleared", "May need another ERCP.", 5, 15, .moderate),
                    SE.death(0.1, 0.5),
                ],
                evidence: .strong,
                availability: "ERCP is widely available at US hospitals. Covered by Medicare and insurers.",
                sources: ["Dasari BV et al. Cochrane Database Syst Rev 2013;12:CD003327", "Freeman ML et al. N Engl J Med 1996;335:909–18"]),

            TreatmentOption(
                id: "cbd-ercp-only", name: "ERCP only, keeping the gallbladder", tier: .interventional,
                summary: "Clearing the bile duct with ERCP but not removing the gallbladder — sometimes chosen for frail or older people.",
                whatHappens: ["ERCP clears the duct as above.", "No surgery afterwards unless symptoms return."],
                anesthesia: "Deep sedation or general anesthesia", hospitalStay: "1–2 days", recovery: "Days.",
                bestFor: ["Very frail people or those with a high risk from surgery", "People who have already had their gallbladder removed"],
                lessSuitableIf: ["Fit people who still have gallstones in the gallbladder — about half have more problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 60), seriousComplications: PercentRange(5, 10), furtherTreatment: PercentRange(35, 50)),
                keyFindings: [
                    "In a Dutch trial, 47 in 100 people who kept their gallbladder after ERCP had more gallstone problems within 2 years, and 37 in 100 needed it removed, compared with 2 in 100 after removal (Boerma 2002).",
                ],
                sideEffects: [
                    SE.make("Gallstone problems come back", "Pain, inflammation or more duct stones.", 35, 50, .moderate),
                    SE.make("Pancreatitis after ERCP", "Usually mild, but can be severe.", 3, 10, .moderate),
                    SE.make("Bleeding or bowel tear", "Rare; may need another procedure or surgery.", 0.5, 2, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available. Often suggested for frail people; fitter people are usually advised to have the gallbladder removed.",
                sources: ["Boerma D et al. Lancet 2002;360:761–5"]),

            TreatmentOption(
                id: "cbd-lap-exploration", name: "One-stage keyhole surgery: gallbladder removal plus bile duct exploration", tier: .minimallyInvasive,
                summary: "During keyhole gallbladder removal, the surgeon also clears the bile duct using a tiny camera, so you have one procedure instead of two.",
                whatHappens: ["Keyhole surgery under general anesthesia.", "Stones are flushed or removed through the small duct from the gallbladder or a small cut in the main duct.", "Sometimes a drain or stent is left."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "About 1–3 weeks.",
                bestFor: ["Fit people with bile duct stones at hospitals that offer it", "People who want a single procedure"],
                lessSuitableIf: ["Cholangitis needing urgent drainage (ERCP is quicker)", "Hospitals without trained surgeons"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(5, 10), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "Clearing the duct during keyhole surgery was as effective and safe as ERCP before or after surgery, with fewer procedures overall (Dasari 2013 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Bile leak", "May need a drain or ERCP.", 2, 8, .moderate),
                    SE.make("Stones left behind", "May need ERCP later.", 5, 15, .moderate),
                    SE.woundInfection(1, 3),
                    SE.make("Bile duct injury or narrowing", "Rare but serious.", 0.2, 1, .serious),
                    SE.death(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered at fewer US hospitals because it needs special training and equipment; many surgeons refer for ERCP instead. Covered by Medicare and insurers.",
                sources: ["Dasari BV et al. Cochrane Database Syst Rev 2013;12:CD003327"]),

            TreatmentOption(
                id: "cbd-open-exploration", name: "Open bile duct exploration", tier: .traditional,
                summary: "The bile duct is opened through a larger cut to remove stones. Now used mainly when ERCP and keyhole approaches have failed.",
                whatHappens: ["A cut under the right ribs.", "The duct is opened, stones removed and the duct closed, sometimes over a tube."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 5–7 days", recovery: "4–8 weeks.",
                bestFor: ["Large or stuck stones that ERCP couldn't clear", "Altered anatomy where ERCP isn't possible"],
                lessSuitableIf: ["Most people can be treated with ERCP or keyhole surgery"],
                outcomes: OptionOutcomes(improvement: PercentRange(85, 95), seriousComplications: PercentRange(10, 20), furtherTreatment: PercentRange(5, 10)),
                keyFindings: [
                    "Open exploration clears the duct reliably, but has a longer stay and more complications than endoscopic or keyhole approaches in older trials (Dasari 2013 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(5, 10),
                    SE.make("Bile leak", "May need a drain or ERCP.", 2, 8, .moderate),
                    SE.make("Hernia at the scar", "May need repair.", 5, 10, .moderate),
                    SE.clots(0.5, 2),
                    SE.death(0.5, 2),
                ],
                evidence: .moderate,
                availability: "Available at most hospitals as a backup. Covered by Medicare and insurers.",
                sources: ["Dasari BV et al. Cochrane Database Syst Rev 2013;12:CD003327"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Cochrane review of surgical vs endoscopic duct clearance", compared: "Keyhole or open bile duct exploration vs ERCP (16 trials)",
                finding: "Similar stone clearance, deaths and complications. One-stage keyhole surgery needed fewer procedures.", citation: "Dasari 2013, Cochrane"),
            ComparisonStudy(name: "Dutch wait-and-see trial", compared: "Keeping vs removing the gallbladder after ERCP (120 people)",
                finding: "Gallstone problems came back in 47 in 100 who kept the gallbladder vs 2 in 100 after removal.", citation: "Boerma 2002, Lancet"),
        ],
        questionsToAsk: [
            "How sure are we that a stone is still in the duct? Should I have an MRI or endoscopic ultrasound first?",
            "Does this hospital offer one-stage keyhole surgery, or will I have ERCP and then surgery?",
            "Given my health, should my gallbladder be removed afterwards?",
            "What is the risk of pancreatitis after ERCP for me?",
        ],
        specialty: .hepatobiliary)

    // MARK: - Early liver cancer (hepatocellular carcinoma)

    static let hpbEarlyLiverCancer = ConditionGuide(
        id: "early-hepatocellular-carcinoma",
        name: "Early liver cancer (hepatocellular carcinoma)",
        alsoCalled: "HCC, hepatoma, primary liver cancer",
        symbol: "cross.vial",
        summary: "A cancer that starts in liver cells, usually in people with cirrhosis (scarring of the liver) from hepatitis B or C, alcohol or fatty liver disease. 'Early' usually means one tumor up to about 2 inches, or up to 3 tumors each up to about 1.2 inches, with no spread outside the liver. Treatment depends on the tumor, how well your liver works and your overall health.",
        naturalHistory: [
            "Without treatment, liver cancer almost always grows. Simply watching is not usually a safe choice for someone well enough for treatment.",
            "Several treatments can aim for a cure in early liver cancer: transplant, surgery and ablation. Others aim to control the cancer.",
            "Even after successful treatment, new tumors often appear elsewhere in a scarred liver, so regular scans continue.",
        ],
        whenSurgeryIsOffered: [
            "Liver surgery (resection) is offered when the tumor can be removed and the remaining liver works well enough.",
            "Liver transplant is offered when the cancer is within size limits (such as the Milan criteria) and the liver is badly damaged.",
            "A team (tumor board) of surgeons, liver doctors, radiologists and cancer doctors usually decides together.",
        ],
        urgentSigns: [
            "Vomiting blood, black tarry stools, sudden confusion or severe sleepiness, or a rapidly swelling belly — go to the emergency department or call 911.",
            "Sudden severe belly pain with fainting can mean bleeding from the tumor — call 911.",
        ],
        improvementDefinition: "Meaningful improvement: being alive 5 years after treatment (overall survival). Further treatment means needing more treatment because cancer comes back in the liver.",
        options: [
            TreatmentOption(
                id: "hcc-supportive", name: "Supportive (comfort-focused) care", tier: .conservative,
                summary: "Focusing on symptoms, liver function and quality of life without treating the tumor directly. A reasonable choice for some people with advanced liver failure or serious other illnesses who are not transplant candidates.",
                whatHappens: ["Care from your liver team and palliative care specialists.", "Treating fluid build-up, itching, pain and confusion.", "You can change your mind and ask about treatment later."],
                anesthesia: "None", hospitalStay: "None, unless complications occur", recovery: "None.",
                bestFor: ["People with severe liver failure who can't have a transplant", "People with other serious illnesses or who don't want cancer treatment"],
                lessSuitableIf: ["People well enough for curative treatment — survival is much shorter without it"],
                outcomes: OptionOutcomes(improvement: PercentRange(0, 10), seriousComplications: nil, furtherTreatment: nil),
                keyFindings: [
                    "In older trials of untreated people with liver cancer that couldn't be removed, about 1 in 4 to 1 in 5 were alive at 2 years (control groups in Llovet 2002). Untreated early cancer does somewhat better, but numbers are uncertain.",
                ],
                sideEffects: [
                    SE.make("Cancer grows", "Usually within months to a few years.", 80, 100, .serious),
                    SE.make("Worsening liver function", "Fluid in the belly, jaundice or confusion.", 30, 60, .serious),
                ],
                evidence: .limited,
                availability: "Always available. Palliative care is covered by Medicare and most insurers and can be combined with cancer treatment.",
                sources: ["Llovet JM et al. Lancet 2002;359:1734–9", "Singal AG et al. Hepatology 2023;78:1922–65"]),

            TreatmentOption(
                id: "hcc-ablation", name: "Thermal ablation (radiofrequency or microwave)", tier: .interventional,
                summary: "A needle placed through the skin into the tumor heats and destroys it, guided by ultrasound or CT. Can cure small tumors.",
                whatHappens: ["Under sedation or general anesthesia, a radiologist places one or more needle probes.", "The tumor and a small rim of normal liver are heated for several minutes.", "A scan about a month later checks that the tumor is fully treated."],
                anesthesia: "Deep sedation or general anesthesia", hospitalStay: "Same day or overnight", recovery: "Usually a few days to a week.",
                bestFor: ["Tumors up to about 1.2 inches (3 cm), and especially under 0.8 inch (2 cm)", "People whose liver can't tolerate surgery"],
                lessSuitableIf: ["Larger tumors (higher chance of tumor left behind)", "Tumors next to large blood vessels, the bowel or the main bile ducts"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(2, 5), furtherTreatment: PercentRange(50, 75)),
                keyFindings: [
                    "In a Chinese trial of small tumors, radiofrequency ablation gave similar survival to surgery with fewer complications (Chen 2006). Another trial found surgery gave better survival for tumors within the Milan criteria (Huang 2010), so results are mixed.",
                ],
                sideEffects: [
                    SE.make("Pain, fever and tiredness for a few days", "Post-ablation syndrome; settles on its own.", 20, 40, .mild),
                    SE.make("Tumor not fully destroyed", "May need a second ablation or another treatment.", 5, 15, .moderate),
                    SE.make("Bleeding, liver abscess or bile duct injury", "Uncommon; may need a drain or procedure.", 1, 4, .serious),
                    SE.make("Cancer comes back elsewhere in the liver", "Common within 5 years; regular scans continue.", 50, 70, .serious),
                    SE.death(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered by interventional radiologists at most larger hospitals and cancer centers. Covered by Medicare and insurers. A surgeon may favor surgery if they don't work closely with an ablation team.",
                sources: ["Chen MS et al. Ann Surg 2006;243:321–8", "Huang J et al. Ann Surg 2010;252:903–12", "Singal AG et al. Hepatology 2023;78:1922–65"]),

            TreatmentOption(
                id: "hcc-tace-tare", name: "Treatment through the liver artery (chemoembolization or radioembolization)", tier: .interventional,
                summary: "A catheter is passed from the groin or wrist into the artery feeding the tumor, to deliver chemotherapy and blocking particles (TACE) or tiny radioactive beads (radioembolization, Y-90).",
                whatHappens: ["Under sedation, a thin catheter is threaded into the liver artery under X-ray.", "Chemotherapy beads or radioactive beads are released into the tumor's blood supply.", "May be repeated. Sometimes used to shrink a tumor before transplant."],
                anesthesia: "Sedation", hospitalStay: "Same day to 2 days", recovery: "About 1–2 weeks of tiredness.",
                bestFor: ["Tumors too large or numerous for ablation or surgery", "Controlling or shrinking cancer while waiting for a transplant"],
                lessSuitableIf: ["Poor liver function", "Cancer that has spread outside the liver or blocked the main liver vein"],
                outcomes: OptionOutcomes(improvement: PercentRange(20, 40), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(50, 80)),
                keyFindings: [
                    "In a trial of people whose cancer couldn't be removed, chemoembolization improved 2-year survival compared with no treatment (about 63 vs 27 in 100) (Llovet 2002).",
                    "In the small PREMIERE trial, radioembolization controlled tumors for longer than chemoembolization (Salem 2016).",
                ],
                sideEffects: [
                    SE.make("Pain, fever and nausea for a few days (post-embolization syndrome)", "Very common after chemoembolization; less after radioembolization.", 30, 70, .mild),
                    SE.make("Tiredness", "For 1–2 weeks.", 30, 60, .mild),
                    SE.make("Worsening liver function or liver failure", "More likely if liver function was already poor.", 1, 5, .serious),
                    SE.make("Liver abscess or damage to the gallbladder or bowel", "Rare.", 0.5, 2, .serious),
                    SE.death(0.5, 2),
                ],
                evidence: .moderate,
                availability: "Offered by interventional radiologists at cancer centers and larger hospitals. Covered by Medicare and insurers; radioembolization may need prior approval.",
                sources: ["Llovet JM et al. Lancet 2002;359:1734–9", "Salem R et al. Gastroenterology 2016;151:1155–63"]),

            TreatmentOption(
                id: "hcc-sbrt", name: "Stereotactic body radiation therapy (SBRT)", tier: .interventional,
                summary: "Highly focused radiation beams aimed at the tumor from many angles, usually in 3–5 sessions, with no needle or incision.",
                whatHappens: ["A planning scan, and sometimes small markers placed in the liver.", "3–5 outpatient treatments, each lasting under an hour.", "Scans afterwards to check the response."],
                anesthesia: "None", hospitalStay: "None (outpatient)", recovery: "Usually mild tiredness for a few weeks.",
                bestFor: ["Tumors where ablation is hard because of size or position", "People who can't have surgery or ablation", "Controlling cancer while waiting for a transplant"],
                lessSuitableIf: ["Poor liver function", "Previous radiation to the same area"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(2, 8), furtherTreatment: PercentRange(50, 75)),
                keyFindings: [
                    "In a US study of people who couldn't have surgery, SBRT controlled tumors at least as well as radiofrequency ablation, especially for tumors 0.8 inch (2 cm) or larger; 2-year survival was about 46 vs 53 in 100. This was not a randomized trial (Wahl 2016).",
                ],
                sideEffects: [
                    SE.make("Tiredness and nausea", "Usually mild and short-lived.", 20, 40, .mild),
                    SE.make("Worsening liver function (radiation liver damage)", "More likely with already damaged livers.", 2, 10, .serious),
                    SE.make("Stomach or bowel ulcer near the treated area", "Rare.", 0.5, 2, .serious),
                    SE.make("Cancer comes back elsewhere in the liver", "Common; regular scans continue.", 50, 70, .serious),
                ],
                evidence: .limited,
                availability: "Offered by radiation oncologists at cancer centers. Usually covered, sometimes after prior approval. Surgeons may not mention it because it's newer and comes from a different specialty.",
                sources: ["Wahl DR et al. J Clin Oncol 2016;34:452–9", "Singal AG et al. Hepatology 2023;78:1922–65"]),

            TreatmentOption(
                id: "hcc-lap-resection", name: "Laparoscopic (keyhole) liver resection", tier: .minimallyInvasive,
                summary: "The part of the liver containing the tumor is removed through small cuts using a camera.",
                whatHappens: ["Under general anesthesia, the tumor and a margin of normal liver are removed.", "The liver regrows over weeks to months.", "Done at specialist liver surgery centers."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 3–5 days", recovery: "4–6 weeks.",
                bestFor: ["Tumors in parts of the liver that are reachable by keyhole surgery", "People with good liver function and no high pressure in the liver veins"],
                lessSuitableIf: ["Advanced cirrhosis", "Tumors near major vessels or in hard-to-reach areas"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(10, 20), furtherTreatment: PercentRange(50, 70)),
                keyFindings: [
                    "In the OSLO-COMET trial (people with bowel cancer that had spread to the liver), keyhole liver resection had fewer complications than open surgery (about 19 vs 31 in 100) and a shorter stay, with similar cancer results (Fretland 2018). Evidence specific to liver cancer in cirrhosis is mostly observational.",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Bile leak", "May need a drain.", 3, 8, .moderate),
                    SE.make("Fluid build-up in the belly (ascites)", "More common with cirrhosis.", 5, 15, .moderate),
                    SE.make("Liver failure after surgery", "If too little working liver remains. Can be life-threatening.", 1, 5, .serious),
                    SE.make("Cancer comes back elsewhere in the liver", "Common within 5 years.", 50, 70, .serious),
                    SE.death(0.5, 2),
                ],
                evidence: .limited,
                availability: "Offered at specialist liver surgery centers. Covered by Medicare and insurers. Many surgeons only do open liver surgery.",
                sources: ["Fretland AA et al. Ann Surg 2018;267:199–207", "Singal AG et al. Hepatology 2023;78:1922–65"]),

            TreatmentOption(
                id: "hcc-open-resection", name: "Open liver resection", tier: .traditional,
                summary: "The part of the liver containing the tumor is removed through a larger cut under the ribs.",
                whatHappens: ["Under general anesthesia, through an incision under the ribs.", "The tumor and a margin of liver are removed."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 5–10 days", recovery: "6–12 weeks.",
                bestFor: ["Larger tumors or those near major blood vessels", "People with good liver function"],
                lessSuitableIf: ["Advanced cirrhosis or high pressure in the liver veins (higher risk of liver failure)"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(15, 30), furtherTreatment: PercentRange(50, 70)),
                keyFindings: [
                    "For tumors within the Milan criteria, one trial found better long-term survival after surgery than after radiofrequency ablation (Huang 2010), while another found similar results (Chen 2006).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(5, 10),
                    SE.make("Bile leak", "May need a drain.", 3, 10, .moderate),
                    SE.make("Liver failure after surgery", "Can be life-threatening.", 2, 8, .serious),
                    SE.clots(1, 3),
                    SE.death(1, 5),
                ],
                evidence: .moderate,
                availability: "Offered at hospitals with liver surgeons. Covered by Medicare and insurers.",
                sources: ["Huang J et al. Ann Surg 2010;252:903–12", "Chen MS et al. Ann Surg 2006;243:321–8"]),

            TreatmentOption(
                id: "hcc-transplant", name: "Liver transplant", tier: .traditional,
                summary: "Replacing the whole liver with a donor liver. It removes both the cancer and the scarred liver that can grow new cancers.",
                whatHappens: ["Evaluation at a transplant center and placement on the waiting list if you qualify.", "Bridging treatment (ablation, chemoembolization or SBRT) may be given while you wait.", "A major operation followed by lifelong anti-rejection medicines."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 1–3 weeks", recovery: "3–6 months.",
                bestFor: ["Early liver cancer within transplant criteria together with poor liver function", "People without other major health problems or ongoing alcohol or drug use"],
                lessSuitableIf: ["Cancer beyond transplant criteria", "Serious heart or lung disease", "Not able to take lifelong medicines and attend frequent follow-up"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 80), seriousComplications: PercentRange(25, 40), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In the study that set the Milan criteria, about 75 in 100 people transplanted for early liver cancer were alive at 4 years, and cancer came back in few (Mazzaferro 1996).",
                ],
                sideEffects: [
                    SE.make("Rejection of the new liver", "Usually treated with medicines.", 10, 25, .moderate),
                    SE.make("Infections from anti-rejection medicines", "Lifelong higher risk.", 20, 40, .serious),
                    SE.make("Kidney damage, diabetes or high blood pressure from medicines", "Common over years.", 20, 40, .moderate),
                    SE.make("Bile duct leak or narrowing", "May need ERCP or surgery.", 10, 20, .serious),
                    SE.make("Cancer comes back", "Less common than after other treatments.", 10, 15, .serious),
                    SE.death(5, 10),
                ],
                evidence: .moderate,
                availability: "Only at transplant centers, with long waits for donor livers in some regions. Covered by Medicare and most insurers after evaluation. A local surgeon may not mention it if they don't work with a transplant center.",
                sources: ["Mazzaferro V et al. N Engl J Med 1996;334:693–9", "Singal AG et al. Hepatology 2023;78:1922–65"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Chinese ablation vs surgery trial", compared: "Radiofrequency ablation vs liver resection for small liver cancer (180 people)",
                finding: "Similar survival over 4 years, with fewer complications after ablation.", citation: "Chen 2006, Ann Surg"),
            ComparisonStudy(name: "Huang trial", compared: "Radiofrequency ablation vs resection for liver cancer within the Milan criteria (230 people)",
                finding: "Better survival and fewer recurrences after surgery at 5 years.", citation: "Huang 2010, Ann Surg"),
            ComparisonStudy(name: "Barcelona chemoembolization trial", compared: "Chemoembolization vs no treatment for unresectable liver cancer",
                finding: "Chemoembolization improved survival at 2 years.", citation: "Llovet 2002, Lancet"),
            ComparisonStudy(name: "PREMIERE trial", compared: "Radioembolization vs chemoembolization (45 people)",
                finding: "Radioembolization controlled tumors for longer; survival was not clearly different.", citation: "Salem 2016, Gastroenterology"),
        ],
        questionsToAsk: [
            "Has my case been discussed at a liver tumor board?",
            "Am I a transplant candidate? If not, why not?",
            "Is ablation an option for my tumor's size and position? Who does it here?",
            "How well does my liver work, and how does that affect surgery?",
            "What is the plan for scans after treatment?",
        ],
        specialty: .hepatobiliary)

    // MARK: - Children: enlarged tonsils, sleep apnea and throat infections

    static let pedsTonsils = ConditionGuide(
        id: "pediatric-tonsils-sleep-apnea",
        name: "Enlarged tonsils in children: snoring, sleep apnea or repeated throat infections",
        alsoCalled: "Obstructive sleep-disordered breathing, pediatric sleep apnea, recurrent tonsillitis",
        symbol: "mouth",
        summary: "Large tonsils and adenoids can partly block your child's airway during sleep, causing snoring, pauses in breathing, restless sleep and daytime tiredness or behavior problems. Some children instead have repeated throat infections. Removing the tonsils (tonsillectomy, often with the adenoids) is one of the most common children's operations.",
        naturalHistory: [
            "Many children's snoring and mild sleep apnea improve as they grow, as the airway gets bigger relative to the tonsils.",
            "In the CHAT trial, sleep studies returned to normal in about half of children with mild to moderate sleep apnea within 7 months without surgery.",
            "Throat infections also tend to become less frequent over time, even without surgery.",
        ],
        whenSurgeryIsOffered: [
            "Moderate or severe sleep apnea on a sleep study, or snoring with behavior, learning or growth problems.",
            "Repeated throat infections: about 7 or more in a year, 5 or more a year for 2 years, or 3 or more a year for 3 years, each documented by a doctor (the Paradise criteria).",
            "Other problems such as an abscess behind the tonsil.",
        ],
        urgentSigns: [
            "Any bleeding from the mouth or nose after tonsil surgery — go to the emergency department. Heavy bleeding or vomiting blood — call 911.",
            "Your child is struggling to breathe, can't swallow saliva or has a high fever with a stiff neck — go to the emergency department now.",
            "Your child isn't drinking enough after surgery and has few wet diapers or very dark urine (dehydration).",
        ],
        improvementDefinition: "Meaningful improvement: sleep apnea resolves on a sleep study, or symptoms, behavior and quality of life clearly improve, or throat infections become much less frequent, measured about 7–12 months after treatment.",
        options: [
            TreatmentOption(
                id: "peds-ton-watchful", name: "Watchful waiting with supportive care", tier: .conservative,
                summary: "Monitoring your child's sleep and symptoms for 6–12 months, treating allergies or nasal blockage, and having surgery later if problems persist.",
                whatHappens: ["Treating allergies and colds as they arise.", "Tracking snoring, sleep and daytime behavior.", "A repeat check or sleep study after some months."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Snoring or mild sleep apnea without behavior or growth problems", "Fewer throat infections than the Paradise criteria"],
                lessSuitableIf: ["Severe sleep apnea, low oxygen levels during sleep, or poor growth", "Children with Down syndrome, heart or lung problems or obesity — talk with your child's doctor"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 50), seriousComplications: PercentRange(0, 1), furtherTreatment: PercentRange(10, 30)),
                keyFindings: [
                    "In the CHAT trial of 464 children aged 5–9 with mild to moderate sleep apnea, sleep studies normalized in about 46 in 100 with watchful waiting vs 79 in 100 after surgery. Attention and thinking test scores were similar in both groups at 7 months (Marcus 2013).",
                    "In the PATS trial of children with snoring and mild sleep apnea, surgery did not improve thinking skills at 12 months, but improved behavior, sleepiness, symptoms and quality of life. About 13 in 100 children in watchful waiting worsened to more significant sleep apnea (Redline 2023).",
                ],
                sideEffects: [
                    SE.make("Snoring and poor sleep continue", "Behavior, sleepiness and quality of life improve less than with surgery.", 40, 60, .mild),
                    SE.make("Sleep apnea gets worse", "About 1 in 8 children with mild apnea in PATS.", 10, 15, .moderate),
                    SE.make("More throat infections and missed school", "For children with repeated infections.", 30, 60, .mild),
                ],
                evidence: .strong,
                availability: "Always available. Some ear, nose and throat surgeons may recommend surgery early because it reliably improves symptoms.",
                sources: ["Marcus CL et al. N Engl J Med 2013;368:2366–76", "Redline S et al. JAMA 2023;330:2084–95", "Paradise JL et al. N Engl J Med 1984;310:674–83"]),

            TreatmentOption(
                id: "peds-ton-medicines", name: "Nasal steroid spray or montelukast", tier: .conservative,
                summary: "Medicines that reduce swelling of the adenoids and nasal lining, which can ease mild sleep apnea in some children.",
                whatHappens: ["A daily steroid nose spray (such as fluticasone or mometasone), montelukast tablets, or both.", "Usually tried for about 3 months, then reviewed."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Mild sleep apnea or snoring, especially with allergies", "Families who want to try something before surgery"],
                lessSuitableIf: ["Moderate or severe sleep apnea", "Repeated throat infections (doesn't help these)"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 60), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "In small randomized trials, a nasal steroid spray and montelukast each modestly improved mild sleep apnea compared with placebo (Brouillette 2001; Kheirandish-Gozal 2016). Long-term benefit is less certain.",
                ],
                sideEffects: [
                    SE.make("Nosebleeds or nasal irritation (spray)", "Usually mild.", 5, 15, .mild),
                    SE.make("Mood or behavior changes, nightmares (montelukast)", "The FDA has a boxed warning about these. Stop and call your doctor if they occur.", 1, 5, .moderate),
                    SE.make("Headache or tummy ache", "Usually mild.", 2, 10, .mild),
                ],
                evidence: .limited,
                availability: "Prescribed by pediatricians and ENT doctors; steroid sprays are available over the counter. Usually covered.",
                sources: ["Brouillette RT et al. J Pediatr 2001;138:838–44", "Kheirandish-Gozal L et al. Ann Am Thorac Soc 2016;13:1736–41"]),

            TreatmentOption(
                id: "peds-ton-cpap", name: "CPAP breathing machine", tier: .conservative,
                summary: "A mask worn during sleep that gently blows air to keep the airway open.",
                whatHappens: ["A sleep study to set the pressure.", "Your child wears a nose or face mask every night.", "Regular follow-up to check the fit and pressure as your child grows."],
                anesthesia: "None", hospitalStay: "None", recovery: "None; ongoing nightly use.",
                bestFor: ["Sleep apnea that continues after surgery", "Children who can't have surgery or have small tonsils"],
                lessSuitableIf: ["Children who can't tolerate a mask", "Repeated throat infections"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 80), seriousComplications: PercentRange(0, 0.5), furtherTreatment: nil),
                keyFindings: [
                    "CPAP works well when used, but many children find it hard to use every night. Evidence in children comes mostly from small studies.",
                ],
                sideEffects: [
                    SE.make("Hard to use every night", "Many children and families struggle with it.", 30, 50, .mild),
                    SE.make("Skin irritation or dry nose", "From the mask or air flow.", 10, 30, .mild),
                    SE.make("Changes to face shape with long-term use", "Rare; mask fit is monitored.", 0.5, 2, .moderate),
                ],
                evidence: .limited,
                availability: "Prescribed through pediatric sleep centers. Usually covered with a sleep study showing apnea.",
                sources: ["Marcus CL et al. Pediatrics 2012;130:e714–55"]),

            TreatmentOption(
                id: "peds-ton-tonsillotomy", name: "Partial tonsillectomy (tonsillotomy)", tier: .lessInvasive,
                summary: "Removing most of the tonsil but leaving a thin layer of tissue over the throat muscles, which tends to mean less pain and bleeding.",
                whatHappens: ["Under general anesthesia, through the mouth, with no skin cuts.", "Often done with removal of the adenoids.", "Usually day surgery."],
                anesthesia: "General anesthesia", hospitalStay: "Usually same day", recovery: "About 5–7 days, usually a little faster than full tonsillectomy.",
                bestFor: ["Sleep apnea from enlarged tonsils"],
                lessSuitableIf: ["Repeated throat infections (tonsil tissue left behind can still get infected)"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "A Cochrane review found that partial tonsillectomy probably works about as well as full tonsillectomy for sleep-disordered breathing in the short term, with less pain and a quicker return to normal eating (Blackshaw 2022).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Sore throat and ear pain", "Usually for about a week.", 60, 90, .mild),
                    SE.make("Bleeding after surgery", "Less common than after full tonsillectomy. May need a return to the operating room.", 0.5, 2, .serious),
                    SE.make("Tonsils grow back", "May need further surgery.", 1, 5, .moderate),
                ],
                evidence: .moderate,
                availability: "Common in Europe and offered by some US pediatric ENT surgeons. Covered like tonsillectomy. Your surgeon may not do it routinely.",
                sources: ["Blackshaw H et al. Cochrane Database Syst Rev 2022;1:CD011365"]),

            TreatmentOption(
                id: "peds-ton-tonsillectomy", name: "Tonsillectomy (with or without adenoid removal)", tier: .traditional,
                summary: "Removing the whole tonsils, usually with the adenoids, through the mouth.",
                whatHappens: ["Under general anesthesia, with no skin cuts.", "Takes about 30–45 minutes.", "Most children go home the same day; younger children and those with severe sleep apnea stay overnight for monitoring."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "About 7–14 days of sore throat; usually 1–2 weeks off school.",
                bestFor: ["Moderate or severe sleep apnea with enlarged tonsils", "Repeated throat infections meeting the Paradise criteria"],
                lessSuitableIf: ["Mild symptoms that may improve with time", "Bleeding disorders (need special planning)"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(2, 5), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "In the CHAT trial, sleep studies normalized in about 79 in 100 children after surgery vs 46 in 100 with watchful waiting, and symptoms, behavior and quality of life improved more (Marcus 2013).",
                    "In children with frequent severe throat infections, tonsillectomy reduced infections in the first 2 years, but infections also fell in children who didn't have surgery (Paradise 1984).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Sore throat and ear pain", "Often worst around days 3–7.", 80, 100, .mild),
                    SE.make("Not drinking enough (dehydration)", "May need a hospital visit for fluids.", 2, 5, .moderate),
                    SE.make("Bleeding after surgery", "Most often 5–10 days after surgery. Some children need to return to the operating room.", 2, 5, .serious),
                    SE.make("Breathing problems right after surgery", "Mostly in young children or those with severe sleep apnea; this is why some stay overnight.", 1, 5, .moderate),
                    SE.death(0.003, 0.01),
                ],
                evidence: .strong,
                availability: "Widely available from ENT surgeons. Covered by Medicaid and insurers when criteria are met.",
                sources: ["Marcus CL et al. N Engl J Med 2013;368:2366–76", "Paradise JL et al. N Engl J Med 1984;310:674–83", "Mitchell RB et al. Otolaryngol Head Neck Surg 2019;160(1 Suppl):S1–42"]),
        ],
        comparisons: [
            ComparisonStudy(name: "CHAT trial", compared: "Early adenotonsillectomy vs watchful waiting in children aged 5–9 with sleep apnea (464 children)",
                finding: "No difference in attention and thinking tests at 7 months, but better sleep studies, symptoms, behavior and quality of life after surgery.", citation: "Marcus 2013, N Engl J Med"),
            ComparisonStudy(name: "PATS trial", compared: "Adenotonsillectomy vs watchful waiting for snoring and mild sleep apnea (459 children)",
                finding: "No difference in thinking skills at 12 months; surgery improved behavior, symptoms, quality of life and blood pressure.", citation: "Redline 2023, JAMA"),
            ComparisonStudy(name: "Pittsburgh throat infection trial", compared: "Tonsillectomy vs no surgery for frequent, severe throat infections",
                finding: "Fewer infections after surgery in the first 2 years, though the non-surgical group also improved.", citation: "Paradise 1984, N Engl J Med"),
        ],
        questionsToAsk: [
            "Does my child need a sleep study before deciding?",
            "How likely is my child to grow out of this if we wait?",
            "Would a partial tonsillectomy be suitable for my child? Do you offer it?",
            "Will my child stay overnight, and what should I do if there is bleeding at home?",
        ],
        specialty: .pediatric)

    // MARK: - Children: ear infections and glue ear

    static let pedsEars = ConditionGuide(
        id: "pediatric-ear-infections-glue-ear",
        name: "Repeated ear infections or glue ear in children",
        alsoCalled: "Recurrent acute otitis media, otitis media with effusion, middle ear fluid",
        symbol: "ear",
        summary: "Young children often get ear infections because the tubes linking their ears and throat are short. Some get many infections in a year. Others have fluid trapped behind the eardrum (glue ear) for months, which can muffle hearing. Ear tubes are tiny tubes placed in the eardrum to let air in and fluid out.",
        naturalHistory: [
            "Ear infections become much less frequent as children get older, especially after about age 3.",
            "Most glue ear clears on its own: about 3 in 4 children within 3 months.",
            "Hearing usually returns to normal once the fluid clears.",
        ],
        whenSurgeryIsOffered: [
            "Repeated infections: about 3 or more in 6 months, or 4 or more in a year with one in the past 6 months, when fluid is present at the time of assessment.",
            "Glue ear in both ears for 3 months or longer with hearing loss, or with speech, learning or balance problems.",
            "Sooner for children at higher risk for speech or learning delays, such as those with Down syndrome, cleft palate or other hearing problems.",
        ],
        urgentSigns: [
            "Swelling, redness or pain behind the ear that pushes the ear forward, severe headache, stiff neck, a very high fever or unusual drowsiness — go to the emergency department now.",
            "Sudden weakness of one side of the face.",
        ],
        improvementDefinition: "Meaningful improvement: fewer ear infections over the following 1–2 years, or hearing returning to normal with glue ear, measured about 3–24 months after starting treatment.",
        options: [
            TreatmentOption(
                id: "peds-ear-watchful", name: "Watchful waiting and hearing checks", tier: .conservative,
                summary: "Monitoring glue ear for at least 3 months, with hearing tests, since most fluid clears on its own.",
                whatHappens: ["A check of the ears and a hearing test.", "Talking face to face with your child, reducing background noise and reading together.", "A repeat check every 3–6 months."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Glue ear without major hearing loss or speech delay", "Children without extra risk factors for speech and learning problems"],
                lessSuitableIf: ["Significant hearing loss or speech delay", "Children with Down syndrome, cleft palate or other hearing problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0, 1), furtherTreatment: PercentRange(15, 35)),
                keyFindings: [
                    "Most glue ear clears within 3 months, which is why guidelines advise waiting at least 3 months before ear tubes (Rosenfeld 2016 guideline).",
                ],
                sideEffects: [
                    SE.make("Muffled hearing for longer", "Can affect speech and attention while fluid persists.", 20, 40, .mild),
                    SE.make("Fluid keeps coming back", "Some children then need ear tubes.", 15, 35, .mild),
                    SE.make("Changes to the eardrum with long-lasting fluid", "Rare; monitored at check-ups.", 0.5, 3, .moderate),
                ],
                evidence: .strong,
                availability: "Always available through pediatricians and ENT doctors.",
                sources: ["Rosenfeld RM et al. Otolaryngol Head Neck Surg 2016;154(1 Suppl):S1–41"]),

            TreatmentOption(
                id: "peds-ear-antibiotics", name: "Antibiotics for each infection (episodic treatment)", tier: .conservative,
                summary: "Treating each new ear infection when it happens, with antibiotics if needed, rather than placing ear tubes.",
                whatHappens: ["Pain relief with acetaminophen or ibuprofen.", "Antibiotics (usually amoxicillin) for each confirmed infection, or a short wait-and-see period for milder infections in older children.", "Follow-up if infections keep happening."],
                anesthesia: "None", hospitalStay: "None", recovery: "Each infection usually settles in a few days.",
                bestFor: ["Most children with repeated ear infections, especially as infections usually become less frequent with age"],
                lessSuitableIf: ["Allergies to several antibiotics", "Infections that don't respond to antibiotics"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(0.1, 1), furtherTreatment: PercentRange(15, 30)),
                keyFindings: [
                    "In a US trial of 250 children aged 6–35 months with repeated ear infections, ear tubes did not lower the rate of infections over 2 years compared with treating each infection with antibiotics (about 1.5 per year in both groups) (Hoberman 2021).",
                ],
                sideEffects: [
                    SE.make("Diarrhea or diaper rash", "Common with amoxicillin-clavulanate.", 10, 30, .mild),
                    SE.make("Allergic rash", "Usually mild; tell your doctor.", 2, 5, .moderate),
                    SE.make("More antibiotic courses and resistant germs", "Repeated use encourages resistant bacteria.", 10, 30, .mild),
                    SE.make("Serious allergic reaction", "Rare; needs emergency care.", 0.01, 0.1, .serious),
                ],
                evidence: .strong,
                availability: "Widely available from pediatricians. Covered by Medicaid and insurers.",
                sources: ["Hoberman A et al. N Engl J Med 2021;384:1789–99"]),

            TreatmentOption(
                id: "peds-ear-autoinflation", name: "Autoinflation (nose balloon) or hearing aids for glue ear", tier: .conservative,
                summary: "For glue ear, blowing up a special balloon with the nose several times a day can help open the ear tubes. Children with lasting hearing loss can also use hearing aids instead of surgery.",
                whatHappens: ["Your child blows up a balloon through each nostril about 3 times a day for 1–3 months.", "Or a hearing aid is fitted by an audiologist while waiting for fluid to clear."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Glue ear in children over about 4 who can use the balloon", "Families who want to avoid surgery"],
                lessSuitableIf: ["Very young children (balloon)", "Repeated infections rather than glue ear"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 50), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(20, 35)),
                keyFindings: [
                    "In a UK primary care trial of children aged 4–11, autoinflation made it more likely that glue ear cleared at 1 and 3 months than usual care (Williamson 2015).",
                ],
                sideEffects: [
                    SE.make("Hard to use regularly", "Children may lose interest.", 20, 40, .mild),
                    SE.make("Mild nosebleed or ear discomfort", "Usually brief.", 1, 5, .mild),
                    SE.make("Hearing aids may be teased or rejected", "Some children dislike wearing them.", 10, 30, .mild),
                ],
                evidence: .limited,
                availability: "Balloons are inexpensive and available online or from some doctors; not always covered. Hearing aids are covered by Medicaid and some insurers. Surgeons may not mention these because they are managed by primary care or audiologists.",
                sources: ["Williamson I et al. CMAJ 2015;187:961–9", "Rosenfeld RM et al. Otolaryngol Head Neck Surg 2016;154(1 Suppl):S1–41"]),

            TreatmentOption(
                id: "peds-ear-tubes", name: "Ear tubes (tympanostomy tubes)", tier: .minimallyInvasive,
                summary: "A tiny cut is made in each eardrum and a small tube is placed to let air in and fluid drain. The tubes usually fall out on their own in 6–18 months.",
                whatHappens: ["A brief general anesthetic, usually with a mask and no breathing tube.", "Takes about 10–15 minutes, done through the ear canal with a microscope.", "Home the same day."],
                anesthesia: "Brief general anesthesia", hospitalStay: "Same day", recovery: "Usually back to normal the next day.",
                bestFor: ["Glue ear in both ears for 3 months or more with hearing loss", "Repeated ear infections with fluid present, especially if antibiotics cause problems"],
                lessSuitableIf: ["Repeated infections without fluid between them", "Glue ear lasting less than 3 months"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(15, 30)),
                keyFindings: [
                    "In the Hoberman trial, children with tubes had their first infection later and fewer treatment failures, but the overall number of infections over 2 years was the same as with antibiotics alone (Hoberman 2021).",
                    "For glue ear, tubes improve hearing modestly in the first 6–9 months, with the benefit fading as fluid clears without surgery (Browning 2010 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Ear drainage (otorrhea)", "Discharge from the ear, usually treated with antibiotic ear drops.", 15, 30, .mild),
                    SE.make("White scarring on the eardrum (tympanosclerosis)", "Common but usually doesn't affect hearing.", 20, 35, .mild),
                    SE.make("Hole in the eardrum that doesn't heal", "May need surgery to repair.", 1, 3, .moderate),
                    SE.make("Tubes fall out early or block", "Some children need a second set.", 15, 30, .moderate),
                    SE.make("Serious anesthesia problem", "Very rare in healthy children.", 0.01, 0.1, .serious),
                ],
                evidence: .strong,
                availability: "Very common and offered by ENT surgeons everywhere. Covered by Medicaid and insurers when criteria are met.",
                sources: ["Hoberman A et al. N Engl J Med 2021;384:1789–99", "Browning GG et al. Cochrane Database Syst Rev 2010;10:CD001801", "Rosenfeld RM et al. Otolaryngol Head Neck Surg 2022;166(1 Suppl):S1–55"]),

            TreatmentOption(
                id: "peds-ear-adenoidectomy", name: "Ear tubes with adenoid removal", tier: .minimallyInvasive,
                summary: "Removing the adenoids (tissue at the back of the nose) at the same time as placing tubes, to reduce germs and blockage near the ear tubes.",
                whatHappens: ["Under general anesthesia, the adenoids are removed through the mouth.", "Ear tubes are placed at the same time.", "Usually home the same day."],
                anesthesia: "General anesthesia", hospitalStay: "Same day", recovery: "A few days.",
                bestFor: ["Children over about 4 with glue ear", "Children needing a second set of tubes", "Children with blocked nose or snoring from large adenoids"],
                lessSuitableIf: ["Children under about 4 having their first tubes (less benefit)", "Cleft palate or certain other palate problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 85), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "Adding adenoid removal improved clearance of glue ear in some trials, mainly in older children, with little evidence of benefit for repeated ear infections in young children (van den Aardweg 2010 review).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Ear drainage", "Usually treated with ear drops.", 10, 25, .mild),
                    SE.make("Bleeding from the back of the nose", "Uncommon; occasionally needs a return to the operating room.", 0.2, 1, .serious),
                    SE.make("Nasal-sounding speech", "Usually temporary.", 0.1, 1, .moderate),
                ],
                evidence: .moderate,
                availability: "Offered by ENT surgeons. Covered by Medicaid and insurers when criteria are met.",
                sources: ["van den Aardweg MT et al. Cochrane Database Syst Rev 2010;1:CD007810", "Rosenfeld RM et al. Otolaryngol Head Neck Surg 2022;166(1 Suppl):S1–55"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Hoberman trial", compared: "Ear tubes vs antibiotics for each infection in children aged 6–35 months (250 children)",
                finding: "No difference in the number of ear infections over 2 years.", citation: "Hoberman 2021, N Engl J Med"),
            ComparisonStudy(name: "Cochrane review of ear tubes for glue ear", compared: "Ear tubes vs watchful waiting for glue ear",
                finding: "Modest hearing benefit in the first months, fading over time.", citation: "Browning 2010, Cochrane"),
            ComparisonStudy(name: "UK autoinflation trial", compared: "Nose balloon vs usual care for glue ear (320 children aged 4–11)",
                finding: "More children had their fluid clear with the nose balloon at 1 and 3 months.", citation: "Williamson 2015, CMAJ"),
        ],
        questionsToAsk: [
            "Does my child have fluid behind the eardrum now, and how is their hearing?",
            "How many infections has my child had, and is treating each one a reasonable option?",
            "Is my child at higher risk of speech or learning problems that would change the advice?",
            "If we choose tubes, should the adenoids be removed too?",
        ],
        specialty: .pediatric)

    // MARK: - Children: appendicitis

    static let pedsAppendicitis = ConditionGuide(
        id: "pediatric-appendicitis",
        name: "Appendicitis in children",
        alsoCalled: "Acute appendicitis, uncomplicated appendicitis in children",
        symbol: "figure.child",
        summary: "Your child's appendix — a small pouch off the large bowel — becomes inflamed and infected. It usually causes tummy pain that moves to the lower right side, with fever, vomiting and loss of appetite. 'Uncomplicated' means scans show no burst, abscess or hard stone in the appendix.",
        naturalHistory: [
            "Appendicitis does not usually go away without treatment, and younger children are more likely to have a burst appendix by the time it is diagnosed.",
            "For uncomplicated appendicitis, antibiotics alone work for about 2 in 3 children over the following year.",
        ],
        whenSurgeryIsOffered: [
            "Surgery is the standard treatment for appendicitis in children in the US.",
            "Surgery is the safest option if the appendix has burst with infection spreading through the belly, or if your child is very unwell.",
            "Surgery is more strongly advised if a scan shows a stone (appendicolith) in the appendix.",
        ],
        urgentSigns: [
            "Pain spreading across the whole tummy, a hard tummy, high fever, repeated vomiting, very fast breathing or your child is floppy or hard to wake — go to the emergency department now or call 911.",
            "If your child is on antibiotics and the pain gets worse or doesn't improve within 24–48 hours, go back to the emergency department.",
        ],
        improvementDefinition: "Treatment success: the appendicitis is cured without a serious complication and, for antibiotics, without needing an appendectomy, at 1 year.",
        options: [
            TreatmentOption(
                id: "peds-appy-antibiotics", name: "Antibiotics first (no operation)", tier: .conservative,
                summary: "Treating uncomplicated appendicitis with antibiotics through a drip and then by mouth, keeping surgery in reserve.",
                whatHappens: ["Your child stays in the hospital for about a day of antibiotics through a drip.", "If improving, they go home on antibiotic medicine for about 7–10 days.", "You are given clear instructions on warning signs."],
                anesthesia: "None", hospitalStay: "Usually 1–2 days", recovery: "Back to school and activities in a few days once well.",
                bestFor: ["Children 7 and older with uncomplicated appendicitis seen on ultrasound or CT", "Families who want to avoid or delay an operation"],
                lessSuitableIf: ["A stone in the appendix", "Signs of a burst appendix or abscess", "Symptoms for more than about 2 days"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(1, 5), furtherTreatment: PercentRange(25, 40)),
                keyFindings: [
                    "In a US study of 1,068 children aged 7–17 whose families chose treatment, antibiotics alone worked for about 67 in 100 at 1 year. Children treated with antibiotics had fewer days off normal activities (about 7 vs 11 days) (Minneci 2020).",
                    "Children who need surgery after antibiotics usually have the same keyhole operation, and most do not have a more serious appendicitis.",
                ],
                sideEffects: [
                    SE.make("Appendicitis doesn't settle or comes back", "Your child then needs an appendectomy. About 1 in 3 within a year.", 25, 40, .moderate),
                    SE.make("Antibiotic side effects", "Diarrhea, tummy upset or rash.", 5, 15, .mild),
                    SE.make("Appendix bursts during treatment", "Uncommon; needs surgery.", 1, 5, .serious),
                    SE.make("Worry about it coming back", "Some families find the uncertainty stressful.", 10, 30, .mild),
                ],
                evidence: .moderate,
                availability: "Offered at many US children's hospitals, but not everywhere. Covered by Medicaid and insurers. A surgeon may not offer it because surgery is the long-standing standard.",
                sources: ["Minneci PC et al. JAMA 2020;324:581–93"]),

            TreatmentOption(
                id: "peds-appy-drain", name: "Antibiotics with or without a drain, then later surgery (for a burst appendix with abscess)", tier: .interventional,
                summary: "If the appendix has already burst and formed an abscess, some children are treated first with antibiotics and sometimes a drain placed through the skin, with the appendix removed weeks later (interval appendectomy).",
                whatHappens: ["Antibiotics through a drip.", "A radiologist may place a thin drain into the abscess under ultrasound or CT, with sedation or anesthesia.", "Appendectomy planned about 6–8 weeks later."],
                anesthesia: "Sedation or general anesthesia for the drain", hospitalStay: "Usually several days to a week", recovery: "Several weeks, then recovery from the later operation.",
                bestFor: ["A well-formed abscess seen on a scan, especially when early surgery looks difficult"],
                lessSuitableIf: ["Uncomplicated appendicitis", "Spreading infection through the belly — surgery is safer"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(10, 25), furtherTreatment: PercentRange(90, 100)),
                keyFindings: [
                    "In a randomized trial of 131 children with a burst appendix, early appendectomy led to fewer days away from normal activities (about 14 vs 19 days) and fewer adverse events (30 vs 55 in 100) than the delayed approach. About 1 in 3 children planned for delayed surgery needed an earlier operation (Blakely 2011).",
                ],
                sideEffects: [
                    SE.make("Drain discomfort", "The tube can be sore and may need flushing.", 10, 30, .mild),
                    SE.make("Treatment doesn't work and earlier surgery is needed", "About 1 in 3 in the trial.", 20, 35, .moderate),
                    SE.make("Bleeding or bowel injury from the drain", "Rare.", 0.5, 2, .serious),
                    SE.make("Two hospital stays", "One for the infection and one for the later operation.", 90, 100, .mild),
                ],
                evidence: .moderate,
                availability: "Offered at children's hospitals with pediatric interventional radiology. Covered by Medicaid and insurers.",
                sources: ["Blakely ML et al. Arch Surg 2011;146:660–5"]),

            TreatmentOption(
                id: "peds-appy-lap", name: "Laparoscopic (keyhole) appendectomy", tier: .minimallyInvasive,
                summary: "The standard operation for children: the appendix is removed through 1–3 small cuts using a camera.",
                whatHappens: ["Under general anesthesia, usually within hours of diagnosis.", "The appendix is removed through one of the small cuts, often at the belly button.", "Takes about 30–60 minutes."],
                anesthesia: "General anesthesia", hospitalStay: "Often same day or one night for uncomplicated appendicitis; several days if it had burst", recovery: "Back to school in about 1 week; avoid sports for 2–4 weeks.",
                bestFor: ["Most children with appendicitis, including with a stone or a burst appendix"],
                lessSuitableIf: ["Rarely unsuitable"],
                outcomes: OptionOutcomes(improvement: PercentRange(95, 99), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(1, 3)),
                keyFindings: [
                    "In the Minneci study, surgery cured nearly all children, with more days off normal activities in the first year than antibiotics alone (about 11 vs 7 days) (Minneci 2020).",
                    "Keyhole surgery in children causes less wound infection and a shorter stay than open surgery in most studies.",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(1, 3),
                    SE.make("Pocket of infection inside the tummy (abscess)", "More common if the appendix had burst — up to about 1 in 5 then. May need antibiotics or a drain.", 1, 5, .moderate),
                    SE.make("Bowel blockage from scar tissue", "Rare, sometimes years later.", 0.5, 1, .serious),
                    SE.make("Injury to the bowel, bladder or a blood vessel", "Very rare.", 0.05, 0.5, .serious),
                ],
                evidence: .strong,
                availability: "Available at almost all US children's hospitals and most general hospitals. Covered by Medicaid and insurers.",
                sources: ["Minneci PC et al. JAMA 2020;324:581–93", "Blakely ML et al. Arch Surg 2011;146:660–5"]),

            TreatmentOption(
                id: "peds-appy-open", name: "Open appendectomy", tier: .traditional,
                summary: "The appendix is removed through a single small cut in the lower right tummy. Used when keyhole surgery isn't available or suitable.",
                whatHappens: ["Under general anesthesia, a cut of about 1–2 inches in children.", "The appendix is removed and the muscle layers closed."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days for uncomplicated appendicitis", recovery: "About 2–3 weeks before full activity.",
                bestFor: ["Hospitals without pediatric keyhole expertise", "Some very young children or complex cases"],
                lessSuitableIf: ["Most children can have keyhole surgery"],
                outcomes: OptionOutcomes(improvement: PercentRange(95, 99), seriousComplications: PercentRange(2, 6), furtherTreatment: PercentRange(1, 3)),
                keyFindings: [
                    "Open and keyhole appendectomy cure appendicitis equally well; open surgery has more wound infections and a slightly longer recovery (Jaschinski 2018 review, mostly adults).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.woundInfection(2, 6),
                    SE.make("Pocket of infection inside the tummy", "More common if the appendix had burst.", 1, 5, .moderate),
                    SE.make("Bowel blockage from scar tissue", "Rare, sometimes years later.", 0.5, 2, .serious),
                ],
                evidence: .moderate,
                availability: "Available at all hospitals. Covered by Medicaid and insurers.",
                sources: ["Jaschinski T et al. Cochrane Database Syst Rev 2018;11:CD001546"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Midwest Pediatric Surgery Consortium study", compared: "Antibiotics alone vs keyhole appendectomy, chosen by families (1,068 children aged 7–17)",
                finding: "Antibiotics worked for about 2 in 3 children at 1 year, with fewer days off normal activities. Not randomized.", citation: "Minneci 2020, JAMA"),
            ComparisonStudy(name: "Early vs interval appendectomy trial", compared: "Early vs delayed appendectomy for burst appendicitis (131 children)",
                finding: "Early surgery meant fewer days away from normal activities and fewer complications.", citation: "Blakely 2011, Arch Surg"),
        ],
        questionsToAsk: [
            "Is my child's appendicitis uncomplicated? Is there a stone in the appendix?",
            "Is antibiotics-first an option here, and what would make you advise surgery instead?",
            "If my child has an operation, will it be keyhole, and how long will they stay in the hospital?",
            "What signs mean we should come back right away?",
        ],
        specialty: .pediatric)
}
