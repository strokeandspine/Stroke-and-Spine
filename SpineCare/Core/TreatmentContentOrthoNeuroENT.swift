import Foundation

// DRAFT CONTENT — not yet clinically reviewed. See the header of TreatmentOptions.swift.
// Orthopedic (knee and shoulder), neurosurgery (brain and nerves, not spine) and ENT conditions.
// Percentages are approximate ranges from the cited sources and must be verified before release.

extension TreatmentGuides {
    static let orthopedic: [ConditionGuide] = [kneeOsteoarthritis, degenerativeMeniscalTear, subacromialShoulderPain]
    static let neurosurgery: [ConditionGuide] = [unrupturedAneurysm, trigeminalNeuralgia, chronicSubduralHematoma]
    static let ent: [ConditionGuide] = [chronicRhinosinusitis, obstructiveSleepApnea, thyroidNodules]

    // MARK: - Knee osteoarthritis

    static let kneeOsteoarthritis = ConditionGuide(
        id: "knee-osteoarthritis",
        name: "Knee osteoarthritis",
        alsoCalled: "Knee arthritis, wear-and-tear arthritis, degenerative joint disease of the knee",
        symbol: "figure.walk",
        summary: "The smooth cartilage that lines the knee joint wears thin, and the bone underneath changes. This causes pain, stiffness and sometimes swelling, especially with walking, stairs or after resting.",
        naturalHistory: [
            "Arthritis usually changes slowly over years. Many people have good and bad spells rather than a steady decline.",
            "Pain often matches X-ray changes poorly. Some people with severe X-ray changes have little pain, and the other way around.",
            "Exercise, building thigh strength and losing weight can reduce pain as much as many medicines, and the benefit lasts as long as you keep it up.",
            "In a Danish trial, about 3 in 4 people with arthritis bad enough to be offered a knee replacement did not have one within a year after a 12-week exercise and education program (Skou 2015).",
        ],
        whenSurgeryIsOffered: [
            "Pain and stiffness that limit walking, sleep or daily life despite several months of exercise, weight management and medicines.",
            "X-rays showing advanced arthritis that matches your symptoms.",
            "Partial knee replacement may be offered when arthritis is limited to one part of the knee and the ligaments are healthy.",
        ],
        urgentSigns: [
            "A hot, red, very swollen and painful knee with fever or feeling unwell — this can be a joint infection. Go to the emergency department the same day, especially if you have had a knee injection or replacement.",
            "Calf pain and swelling in the leg, or sudden shortness of breath or chest pain, after knee surgery — this can be a blood clot. Call 911 for breathing trouble or chest pain.",
            "Being unable to put any weight on the leg after a fall.",
        ],
        improvementDefinition: "A clear, meaningful improvement in knee pain and function on a questionnaire such as the Oxford Knee Score or KOOS, about 1 year after starting treatment (for injections and nerve ablation, at about 3–6 months, because the effect wears off).",
        options: [
            TreatmentOption(
                id: "knee-oa-exercise", name: "Exercise therapy, education and weight loss", tier: .conservative,
                summary: "A supervised program of strengthening and balance exercises with a physical therapist, learning how to manage flares, and losing weight if you carry extra weight.",
                whatHappens: ["Usually 2 sessions a week for 8–12 weeks with a physical therapist, then exercise on your own.", "Programs such as GLA:D combine education with neuromuscular exercise.", "Losing about 10% of body weight through diet, exercise or weight-loss medicines can reduce pain noticeably."],
                anesthesia: "None", hospitalStay: "None", recovery: "Benefits build over 6–12 weeks and last as long as you keep exercising.",
                bestFor: ["Almost everyone with knee arthritis, at any stage", "People who want to delay or avoid surgery", "Preparing for surgery (prehabilitation)"],
                lessSuitableIf: ["A hot, very swollen knee that needs checking first", "Severe heart or lung disease that limits exercise (a tailored program may still help)"],
                outcomes: OptionOutcomes(improvement: PercentRange(45, 70), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(20, 35)),
                keyFindings: [
                    "In a trial of people eligible for knee replacement, about 2 in 3 who had a 12-week nonsurgical program (exercise, education, weight loss advice, insoles and pain relief) had a meaningful improvement at 1 year, and about 1 in 4 went on to have the replacement (Skou 2015).",
                    "In the IDEA trial, people who lost about 10% of their weight with diet plus exercise had less knee pain and better function at 18 months than with exercise alone (Messier 2013).",
                    "Land-based exercise reduces knee pain and improves function by a small-to-moderate amount, with benefits lasting at least 2–6 months after a program ends (Fransen 2015 review).",
                ],
                sideEffects: [
                    SE.exerciseSoreness,
                    SE.make("Pain doesn't improve enough", "Some people still have pain that limits them and go on to consider surgery.", 30, 50, .mild),
                    SE.make("Stomach upset, nausea or gallstones (weight-loss medicines)", "If you use medicines such as semaglutide or tirzepatide to lose weight. Usually settles over weeks.", 20, 40, .moderate),
                    SE.make("Fall or injury while exercising", "Uncommon with a supervised program that starts at the right level.", 0.5, 2, .moderate),
                ],
                evidence: .strong,
                availability: "Widely available and covered by Medicare and most insurers, often with visit limits or copays. Structured programs like GLA:D are offered by trained physical therapists. Weight-loss medicines are expensive and often not covered. A surgeon may assume you've already tried exercise.",
                sources: ["Skou ST et al. N Engl J Med 2015;373:1597–606", "Messier SP et al. JAMA 2013;310:1263–73", "Fransen M et al. Cochrane 2015;CD004376", "Bliddal H et al. N Engl J Med 2024;391:1573–83", "Bannuru RR et al. Osteoarthritis Cartilage 2019;27:1578–89"]),

            TreatmentOption(
                id: "knee-oa-medicines", name: "Pain medicines, gels and supports", tier: .conservative,
                summary: "Anti-inflammatory gels or tablets, acetaminophen, a cane, supportive shoes or a knee brace to make daily activities easier.",
                whatHappens: ["Anti-inflammatory gel (such as diclofenac) rubbed on the knee is usually tried first, especially if you're over 75.", "Anti-inflammatory tablets (ibuprofen, naproxen) at the lowest dose for the shortest time.", "A cane in the opposite hand and a knee brace can reduce pain when walking."],
                anesthesia: "None", hospitalStay: "None", recovery: "Works within days; used as needed.",
                bestFor: ["Easing pain enough to stay active and exercise", "Flares of pain"],
                lessSuitableIf: ["Stomach ulcers, kidney disease, heart failure or blood thinners (anti-inflammatory tablets)"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0.2, 1), furtherTreatment: nil),
                keyFindings: [
                    "Anti-inflammatory tablets give a small-to-moderate reduction in arthritis pain; acetaminophen on its own gives very little benefit (da Costa 2017).",
                    "Guidelines recommend anti-inflammatory gels for knee arthritis because they work and have fewer side effects than tablets (Bannuru 2019).",
                ],
                sideEffects: [
                    SE.make("Skin irritation (gels)", "Redness or itching where the gel is applied.", 5, 10, .mild),
                    SE.nsaidStomach, SE.nsaidKidneyHeart, SE.nsaidBleed,
                ],
                evidence: .strong,
                availability: "Widely available; many are over the counter. Usually managed by your primary care doctor.",
                sources: ["da Costa BR et al. Lancet 2017;390:e21–33", "Bannuru RR et al. Osteoarthritis Cartilage 2019;27:1578–89"]),

            TreatmentOption(
                id: "knee-oa-injection", name: "Steroid or hyaluronic acid injection", tier: .interventional,
                summary: "A steroid (cortisone) or a gel-like fluid (hyaluronic acid) injected into the knee joint to ease pain for a few weeks to months.",
                whatHappens: ["Done in the clinic, sometimes with ultrasound guidance.", "Takes a few minutes.", "Steroid injections are usually limited to about 3–4 a year."],
                anesthesia: "Local anesthetic or none", hospitalStay: "None (clinic)", recovery: "Rest the knee for a day; normal activity after that.",
                bestFor: ["A painful flare, especially with swelling", "Getting through an important event or making exercise possible"],
                lessSuitableIf: ["Skin infection near the knee", "Poorly controlled diabetes (steroid)", "Knee replacement planned within about 3 months (higher infection risk)"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(50, 70)),
                keyFindings: [
                    "Steroid injections give short-term pain relief, usually lasting weeks rather than months.",
                    "In a 2-year trial, steroid injections every 3 months did not reduce pain more than saline (salt water) and were linked with slightly more cartilage loss on MRI (McAlindon 2017).",
                    "Hyaluronic acid injections give at most a small benefit over placebo injections (Rutjes 2012 review).",
                ],
                sideEffects: [
                    SE.make("Pain flare after the injection", "The knee can be sorer for 1–2 days.", 2, 10, .mild),
                    SE.steroidFlush, SE.steroidSugar,
                    SE.make("Faster cartilage loss with repeated steroid injections", "Seen on MRI in one trial; how much this matters is uncertain.", 5, 20, .moderate),
                    SE.make("Joint infection", "Rare, but serious; may need antibiotics and surgery to wash out the joint.", 0.01, 0.1, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available from primary care, sports medicine, rheumatology and orthopedic clinics. Medicare covers steroid injections; coverage for hyaluronic acid varies and some insurers no longer pay for it.",
                sources: ["McAlindon TE et al. JAMA 2017;317:1967–75", "Rutjes AW et al. Ann Intern Med 2012;157:180–91", "Bannuru RR et al. Osteoarthritis Cartilage 2019;27:1578–89"]),

            TreatmentOption(
                id: "knee-oa-gnrfa", name: "Genicular nerve radiofrequency ablation", tier: .interventional,
                summary: "Heat from a needle tip is used to switch off the small sensory nerves that carry pain signals from the knee. It doesn't change the joint itself.",
                whatHappens: ["First, a test block: numbing medicine is placed near the nerves to see if your pain eases.", "If it helps, needles are placed around the knee under X-ray or ultrasound and the nerves are heated for about 1–2 minutes each.", "Takes about 30–60 minutes; you go home the same day."],
                anesthesia: "Local anesthetic, sometimes light sedation", hospitalStay: "Outpatient (home the same day)", recovery: "Usual activities within 1–3 days. Relief usually lasts 6–12 months, and it can be repeated.",
                bestFor: ["People who aren't ready for, can't have or want to delay a knee replacement", "Ongoing pain after a knee replacement (sometimes used)"],
                lessSuitableIf: ["A test block that didn't help", "Pacemaker or other implants (check with the team)", "Infection or bleeding problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 75), seriousComplications: PercentRange(0.1, 1), furtherTreatment: PercentRange(30, 60)),
                keyFindings: [
                    "In a company-funded trial of 151 people, about 74 in 100 had at least a halving of knee pain 6 months after cooled radiofrequency ablation, compared with about 16 in 100 after a steroid injection (Davis 2018).",
                    "There are few sham-controlled trials, and the pain nerves usually grow back over 6–12 months, so the benefit is temporary.",
                ],
                sideEffects: [
                    SE.make("Soreness or bruising at the needle sites", "Usually settles within a week.", 5, 20, .mild),
                    SE.make("Patch of numbness on the skin around the knee", "Usually small and fades over weeks to months.", 2, 10, .mild),
                    SE.make("Pain doesn't improve", "Even after a positive test block.", 25, 50, .mild),
                    SE.make("Infection, bleeding into the joint or skin burn", "Rare reports.", 0.1, 1, .serious),
                ],
                evidence: .limited,
                availability: "Offered by pain medicine and some sports medicine and orthopedic practices. Medicare and many insurers cover it in some regions, often only after other treatments and a positive test block; rules vary. Surgeons may not mention it because it doesn't treat the arthritis itself.",
                sources: ["Davis T et al. Reg Anesth Pain Med 2018;43:84–91", "Kidd VD et al. JBJS Essent Surg Tech 2019;9:e10"]),

            TreatmentOption(
                id: "knee-oa-arthroscopy", name: "Arthroscopic washout and debridement", tier: .minimallyInvasive,
                summary: "A camera and small instruments are put into the knee to rinse it out and trim rough cartilage or torn tissue. Good trials show it doesn't help arthritis pain more than a sham operation or exercise.",
                whatHappens: ["Two or three small cuts around the knee.", "The joint is rinsed and loose or rough tissue is trimmed.", "Day surgery."],
                anesthesia: "General or spinal anesthesia", hospitalStay: "Same day", recovery: "Walking the same day; 2–6 weeks to settle.",
                bestFor: ["Rarely recommended for arthritis. It may still be used for a different problem, such as a knee that truly locks from a loose piece of bone or cartilage"],
                lessSuitableIf: ["Knee arthritis pain without true locking — guidelines strongly advise against it"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0.5, 1.5), furtherTreatment: PercentRange(10, 30)),
                keyFindings: [
                    "In a trial with a sham (skin cuts only) group, people who had arthroscopic washout or debridement did no better than those who had sham surgery at 2 years (Moseley 2002).",
                    "Adding arthroscopic surgery to physical therapy and medicines gave no extra benefit at 2 years (Kirkley 2008).",
                    "An international expert panel made a strong recommendation against arthroscopy for degenerative knee disease (Siemieniuk 2017).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Swelling or fluid in the knee", "Can last several weeks.", 5, 15, .mild),
                    SE.woundInfection(0.1, 0.5),
                    SE.clots(0.3, 1),
                ],
                evidence: .strong,
                availability: "Still widely performed, though much less than before. Medicare and many insurers restrict or deny coverage for arthroscopy for knee arthritis because it doesn't work better than sham.",
                sources: ["Moseley JB et al. N Engl J Med 2002;347:81–8", "Kirkley A et al. N Engl J Med 2008;359:1097–107", "Siemieniuk RAC et al. BMJ 2017;357:j1982"]),

            TreatmentOption(
                id: "knee-oa-ukr", name: "Partial (unicompartmental) knee replacement", tier: .lessInvasive,
                summary: "Only the worn part of the knee — usually the inner side — is resurfaced with metal and plastic. The rest of the knee and its ligaments are kept.",
                whatHappens: ["An incision of about 3–4 inches over the knee.", "The worn surfaces of one compartment are removed and replaced with an implant.", "Most people walk the same or next day."],
                anesthesia: "General or spinal anesthesia, often with a nerve block", hospitalStay: "Same day to 2 nights", recovery: "Walking with support right away; most daily activities in 3–6 weeks; full recovery 3–6 months. Usually faster than a total knee replacement.",
                bestFor: ["Arthritis limited to one part of the knee with healthy ligaments", "People who want a knee that feels more natural and a quicker recovery"],
                lessSuitableIf: ["Arthritis in more than one part of the knee", "Inflammatory arthritis such as rheumatoid arthritis", "A damaged ACL ligament or a very stiff or deformed knee"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(8, 15)),
                keyFindings: [
                    "In the TOPKAT trial of 528 people suitable for either operation, partial and total knee replacement gave similar results at 5 years; partial replacement cost less and had a similar rate of repeat surgery (Beard 2019).",
                    "In large registry studies, partial replacement had fewer complications and lower death rates than total replacement, but more revision surgery over 10 years — about 10–15 in 100 (Liddle 2014).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Ongoing pain or stiffness", "Some pain remains for a while or long term.", 5, 15, .moderate),
                    SE.make("Joint infection", "May need more surgery, sometimes a revision to a total knee.", 0.2, 1, .serious),
                    SE.make("Implant wears or loosens, or arthritis spreads to another part of the knee", "The main reasons for revision to a total knee replacement over 10–15 years.", 8, 15, .moderate),
                    SE.clots(0.3, 1),
                    SE.death(0.05, 0.2),
                ],
                evidence: .strong,
                availability: "Offered by many orthopedic surgeons, but results are best with surgeons who do it often, and not everyone is a candidate. Covered by Medicare and insurers like total knee replacement. Some surgeons prefer total replacement because of the higher revision rate.",
                sources: ["Beard DJ et al. Lancet 2019;394:746–56", "Liddle AD et al. Lancet 2014;384:1437–45"]),

            TreatmentOption(
                id: "knee-oa-tkr", name: "Total knee replacement", tier: .traditional,
                summary: "The worn surfaces of the whole knee are removed and replaced with metal and plastic parts. The most common and well-studied operation for advanced knee arthritis.",
                whatHappens: ["An incision of about 6–8 inches down the front of the knee.", "The ends of the thigh and shin bones are shaped and capped with an implant; the kneecap may be resurfaced.", "Physical therapy starts the same or next day."],
                anesthesia: "General or spinal anesthesia, often with a nerve block", hospitalStay: "Same day to 3 nights", recovery: "Walker or cane for 2–6 weeks; driving after about 4–6 weeks; most improvement by 3–6 months, continuing up to a year.",
                bestFor: ["Severe arthritis with pain that limits daily life despite nonsurgical treatment", "Arthritis in more than one part of the knee"],
                lessSuitableIf: ["Pain that is mild or that doesn't match the X-rays", "Active infection, poor skin over the knee or very poor circulation", "Health problems that make surgery very risky"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(2, 8), furtherTreatment: PercentRange(4, 8)),
                keyFindings: [
                    "In a randomized trial, about 85 in 100 people who had a knee replacement plus a nonsurgical program had a meaningful improvement at 1 year, compared with about 68 in 100 with the program alone — but the surgery group had about 4 times as many serious adverse events (Skou 2015).",
                    "About 10–20 in 100 people still have long-term pain in the knee after a total knee replacement (Beswick 2012 review).",
                    "About 4–6 in 100 knee replacements need revision surgery within 10 years (Evans 2019).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Long-term pain in the knee", "Pain that persists after recovery, even when the implant looks fine on X-ray.", 10, 20, .moderate),
                    SE.make("Stiffness needing a manipulation under anesthesia", "The knee doesn't bend enough and is gently bent while you're asleep.", 2, 5, .moderate),
                    SE.make("Deep joint infection", "Usually needs one or more operations and long courses of antibiotics.", 0.5, 2, .serious),
                    SE.make("Nerve or blood vessel injury", "For example, a foot drop from injury to the peroneal nerve. Rare.", 0.1, 1, .serious),
                    SE.clots(0.5, 2),
                    SE.delirium(2, 10),
                    SE.death(0.2, 0.5),
                ],
                evidence: .strong,
                availability: "Widely available and covered by Medicare and insurers. Results are better at hospitals and with surgeons who do many each year. Ask about your surgeon's own infection and revision rates.",
                sources: ["Skou ST et al. N Engl J Med 2015;373:1597–606", "Beswick AD et al. BMJ Open 2012;2:e000435", "Evans JT et al. Lancet 2019;393:655–63", "Carr AJ et al. Lancet 2012;379:1331–40"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Skou trial", compared: "Total knee replacement plus a 12-week nonsurgical program vs the program alone (100 people)",
                finding: "Surgery gave more improvement at 1 year but caused more serious adverse events; about 3 in 4 people in the nonsurgical group did not have surgery within a year.", citation: "Skou 2015, N Engl J Med"),
            ComparisonStudy(name: "TOPKAT", compared: "Partial vs total knee replacement (528 people)",
                finding: "Similar knee scores and repeat-surgery rates at 5 years; partial replacement was more cost-effective.", citation: "Beard 2019, Lancet"),
            ComparisonStudy(name: "Moseley sham trial", compared: "Arthroscopic washout or debridement vs sham surgery (180 people)",
                finding: "No better than sham surgery for pain or function at any point over 2 years.", citation: "Moseley 2002, N Engl J Med"),
            ComparisonStudy(name: "Kirkley trial", compared: "Arthroscopic surgery plus physical therapy vs physical therapy alone (about 180 people)",
                finding: "No added benefit from arthroscopy at 2 years.", citation: "Kirkley 2008, N Engl J Med"),
        ],
        questionsToAsk: [
            "Have I had a full trial of supervised exercise and weight management, and would trying longer be reasonable?",
            "Is my arthritis limited to one part of the knee, so a partial replacement is possible?",
            "What are the chances I'll still have pain after a total knee replacement?",
            "Would genicular nerve ablation or an injection be reasonable while I decide?",
            "How many knee replacements do you do each year, and what are your infection and revision rates?",
        ],
        specialty: .orthopedic)

    // MARK: - Degenerative meniscal tear

    static let degenerativeMeniscalTear = ConditionGuide(
        id: "degenerative-meniscal-tear",
        name: "Degenerative meniscal tear",
        alsoCalled: "Torn meniscus, torn cartilage in the knee, degenerative meniscus tear, middle-age meniscus tear",
        symbol: "figure.walk",
        summary: "A tear in one of the rubbery shock-absorbing pads in the knee that develops gradually with age, often without a clear injury. It is very common after age 40 and often occurs together with early arthritis.",
        naturalHistory: [
            "Meniscal tears show up on MRI scans in many people over 50 who have no knee pain at all, so a tear on a scan isn't always the cause of pain.",
            "Knee pain with a degenerative tear often improves over 3–6 months with exercise and time.",
            "Catching or clicking is common and, in trials, didn't improve more with surgery than with sham surgery.",
        ],
        whenSurgeryIsOffered: [
            "Pain that persists after at least 3 months of supervised exercise therapy.",
            "A knee that truly locks — gets stuck and can't be straightened — which can mean a torn flap is caught in the joint.",
            "A tear from a clear injury in a younger person, which is different from a degenerative tear and may be repairable.",
        ],
        urgentSigns: [
            "A knee locked so you can't straighten it — see an orthopedic or urgent care clinician within days.",
            "A hot, red, swollen knee with fever — go to the emergency department.",
            "Calf swelling and pain, or sudden shortness of breath or chest pain, after knee surgery — call 911 for breathing trouble or chest pain.",
        ],
        improvementDefinition: "A meaningful improvement in knee pain and function on a knee questionnaire (such as KOOS or WOMAC) about 6–24 months after starting treatment.",
        options: [
            TreatmentOption(
                id: "men-exercise", name: "Supervised exercise therapy", tier: .conservative,
                summary: "A physical therapist leads a program to strengthen the thigh and hip muscles, improve balance and control, and gradually build up activity.",
                whatHappens: ["Usually 2–3 sessions a week for about 12 weeks, plus home exercises.", "Exercises are progressed as your knee allows.", "Surgery can still be considered later if the knee doesn't improve."],
                anesthesia: "None", hospitalStay: "None", recovery: "Most improvement within 3 months.",
                bestFor: ["Most people over about 35 with a degenerative tear", "People with early arthritis as well as a tear"],
                lessSuitableIf: ["A knee that truly locks and can't be straightened", "A large tear from a recent injury in a younger person"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(20, 35)),
                keyFindings: [
                    "In the METEOR trial, physical therapy gave similar improvement to arthroscopic surgery at 6 months; about 3 in 10 people in the therapy group chose to have surgery during that time (Katz 2013).",
                    "In the ESCAPE trial, physical therapy was as good as surgery at 2 years; about 3 in 10 in the therapy group later had surgery (van de Graaf 2018).",
                    "In a Norwegian trial, 12 weeks of exercise therapy was as good as arthroscopic surgery at 2 years and improved thigh strength more (Kise 2016).",
                ],
                sideEffects: [
                    SE.exerciseSoreness,
                    SE.make("Pain or catching continues", "Some people still have symptoms and choose surgery later.", 20, 35, .mild),
                ],
                evidence: .strong,
                availability: "Widely available and covered by Medicare and most insurers, often with a visit limit or copay. It may not be emphasized at a surgical visit because a physical therapist provides it.",
                sources: ["Katz JN et al. N Engl J Med 2013;368:1675–84", "van de Graaf VA et al. JAMA 2018;320:1328–37", "Kise NJ et al. BMJ 2016;354:i3740"]),

            TreatmentOption(
                id: "men-medicines", name: "Activity changes and pain medicines", tier: .conservative,
                summary: "Easing off activities that aggravate the knee, using ice and anti-inflammatory gels or tablets, and letting time help while staying active.",
                whatHappens: ["Swap high-impact or deep-squatting activities for cycling, swimming or walking for a while.", "Use anti-inflammatory gel or tablets for flares.", "Usually combined with exercise therapy."],
                anesthesia: "None", hospitalStay: "None", recovery: "Weeks to a few months.",
                bestFor: ["Milder symptoms or the early weeks after symptoms start"],
                lessSuitableIf: ["Stomach ulcers, kidney disease or blood thinners (anti-inflammatory tablets)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(0.2, 1), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "In trials, the 'non-surgical' groups that improved usually combined activity advice, pain relief and exercise. Evidence for pain medicines alone in meniscal tears is limited.",
                ],
                sideEffects: [SE.nsaidStomach, SE.nsaidKidneyHeart, SE.nsaidBleed],
                evidence: .limited,
                availability: "Widely available; usually managed by a primary care doctor.",
                sources: ["Siemieniuk RAC et al. BMJ 2017;357:j1982", "Bannuru RR et al. Osteoarthritis Cartilage 2019;27:1578–89"]),

            TreatmentOption(
                id: "men-injection", name: "Steroid injection into the knee", tier: .interventional,
                summary: "A steroid injected into the knee joint to ease pain and swelling for a few weeks, often to make exercise therapy easier.",
                whatHappens: ["Done in the clinic in a few minutes, sometimes with ultrasound.", "Usually no more than 3–4 a year."],
                anesthesia: "Local anesthetic or none", hospitalStay: "None (clinic)", recovery: "Normal activity after a day.",
                bestFor: ["Pain and swelling that make it hard to do the exercise program"],
                lessSuitableIf: ["Skin infection near the knee", "Poorly controlled diabetes"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(40, 60)),
                keyFindings: [
                    "Steroid injections give short-term pain relief in knees with degenerative changes; there are few trials in people with meniscal tears specifically, so the effect is uncertain (approximate).",
                ],
                sideEffects: [
                    SE.make("Pain flare after the injection", "The knee can be sorer for 1–2 days.", 2, 10, .mild),
                    SE.steroidSugar,
                    SE.make("Joint infection", "Rare, but serious; may need antibiotics and surgery to wash out the joint.", 0.01, 0.1, .serious),
                ],
                evidence: .limited,
                availability: "Widely available and covered by Medicare and most insurers.",
                sources: ["McAlindon TE et al. JAMA 2017;317:1967–75", "Bannuru RR et al. Osteoarthritis Cartilage 2019;27:1578–89"]),

            TreatmentOption(
                id: "men-apm", name: "Arthroscopic partial meniscectomy", tier: .minimallyInvasive,
                summary: "Through small cuts, a camera and tiny instruments are used to trim away the torn part of the meniscus. One of the most common orthopedic operations, but sham-controlled trials found little benefit for degenerative tears.",
                whatHappens: ["Two or three small cuts around the knee.", "The torn, unstable part of the meniscus is trimmed; the rest is left.", "Day surgery."],
                anesthesia: "General or spinal anesthesia", hospitalStay: "Same day", recovery: "Walking the same day; most people return to desk work within 1–2 weeks and sport within 4–8 weeks.",
                bestFor: ["A knee that truly locks from a displaced flap of meniscus", "Pain that hasn't improved after at least 3 months of good exercise therapy (benefit is uncertain)"],
                lessSuitableIf: ["Knee arthritis as well as the tear — guidelines strongly advise against arthroscopy", "Clicking or catching without true locking"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(0.3, 1), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the FIDELITY trial, people with a degenerative tear and no arthritis did no better after partial meniscectomy than after sham surgery at 12 months (Sihvonen 2013).",
                    "In the same trial, surgery did not relieve catching or locking sensations better than sham surgery (Sihvonen 2016).",
                    "An international expert panel made a strong recommendation against arthroscopic surgery for degenerative knee disease, including degenerative meniscal tears (Siemieniuk 2017).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Swelling or fluid in the knee", "Can last several weeks.", 5, 15, .mild),
                    SE.make("Faster development of knee arthritis", "Removing meniscus tissue can increase load on the cartilage over years. How much is uncertain.", 5, 20, .moderate),
                    SE.woundInfection(0.1, 0.5),
                    SE.clots(0.3, 1),
                ],
                evidence: .strong,
                availability: "Very widely available and covered by Medicare and insurers, though some insurers now require a trial of physical therapy first.",
                sources: ["Sihvonen R et al. N Engl J Med 2013;369:2515–24", "Sihvonen R et al. Ann Intern Med 2016;164:449–55", "Katz JN et al. N Engl J Med 2013;368:1675–84", "Siemieniuk RAC et al. BMJ 2017;357:j1982"]),
        ],
        comparisons: [
            ComparisonStudy(name: "FIDELITY", compared: "Arthroscopic partial meniscectomy vs sham surgery (146 people, no arthritis)",
                finding: "No meaningful difference in knee pain or function at 12 months.", citation: "Sihvonen 2013, N Engl J Med"),
            ComparisonStudy(name: "METEOR", compared: "Partial meniscectomy plus physical therapy vs physical therapy alone (351 people with mild arthritis)",
                finding: "Similar improvement at 6 and 12 months; about 3 in 10 in the therapy group crossed over to surgery.", citation: "Katz 2013, N Engl J Med"),
            ComparisonStudy(name: "ESCAPE", compared: "Partial meniscectomy vs physical therapy (321 people)",
                finding: "Physical therapy was not worse than surgery at 2 years.", citation: "van de Graaf 2018, JAMA"),
            ComparisonStudy(name: "Norwegian exercise trial", compared: "12 weeks of exercise therapy vs partial meniscectomy (140 people)",
                finding: "No meaningful difference in knee function at 2 years; better thigh strength with exercise.", citation: "Kise 2016, BMJ"),
        ],
        questionsToAsk: [
            "Is this tear likely to be the cause of my pain, or could it be early arthritis?",
            "Does my knee truly lock, or does it click and catch?",
            "Have I had a full 3-month program of supervised exercise therapy?",
            "How do the results of this operation compare with the sham-controlled trials?",
        ],
        specialty: .orthopedic)

    // MARK: - Subacromial shoulder pain and rotator cuff tears

    static let subacromialShoulderPain = ConditionGuide(
        id: "subacromial-shoulder-pain",
        name: "Shoulder impingement and rotator cuff tears",
        alsoCalled: "Subacromial pain, shoulder impingement, rotator cuff tendinopathy, rotator cuff tear, bursitis of the shoulder",
        symbol: "figure.arms.open",
        summary: "Pain on the outside of the shoulder, often when lifting the arm or lying on it, from irritated or worn rotator cuff tendons and the bursa above them. Some people also have a tear in a rotator cuff tendon.",
        naturalHistory: [
            "Most shoulder pain of this kind improves over months with exercise, even without an operation.",
            "Rotator cuff tears are common with age and are often found in people with no pain. Many degenerative tears stay stable for years.",
            "Some tears slowly get larger over time, which can make later repair harder; this is one reason surgeons sometimes suggest repairing a tear in a younger, active person.",
        ],
        whenSurgeryIsOffered: [
            "Pain that persists after 3–6 months of a good exercise program, with or without an injection.",
            "A full-thickness tear in a younger or active person, or one that is getting larger.",
            "A sudden tear from an injury with marked new weakness, where repair within weeks may give the best result.",
        ],
        urgentSigns: [
            "Sudden inability to lift the arm after a fall or injury — see an orthopedic or urgent care clinician within days.",
            "A hot, swollen shoulder with fever — go to the emergency department.",
            "Left shoulder or arm pain with chest pain, shortness of breath or sweating — this can be a heart attack. Call 911.",
        ],
        improvementDefinition: "A meaningful improvement in shoulder pain and function on a questionnaire such as the Oxford Shoulder Score, about 6–12 months after starting treatment.",
        options: [
            TreatmentOption(
                id: "sap-exercise", name: "Exercise therapy with a physical therapist", tier: .conservative,
                summary: "A graded program to strengthen the rotator cuff and shoulder blade muscles and improve how the shoulder moves.",
                whatHappens: ["Several visits over 6–12 weeks, plus daily home exercises.", "Exercises are progressed as pain allows; some discomfort during exercise is expected.", "Often combined with advice on sleeping position and work tasks."],
                anesthesia: "None", hospitalStay: "None", recovery: "Benefits build over 6–12 weeks; full benefit can take 3–6 months.",
                bestFor: ["Almost everyone with impingement-type pain", "Many people with degenerative rotator cuff tears"],
                lessSuitableIf: ["A large, sudden tear from an injury with marked new weakness (see a surgeon early)"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(15, 30)),
                keyFindings: [
                    "In a Finnish trial of people over 55 with non-injury supraspinatus tears, physical therapy alone gave similar results at 1 year to physical therapy plus decompression surgery or plus tendon repair (Kukkonen 2014).",
                    "Exercise is recommended as the first treatment for subacromial pain because surgery hasn't been shown to work better than placebo surgery (Vandvik 2019).",
                ],
                sideEffects: [
                    SE.exerciseSoreness,
                    SE.make("Pain doesn't improve enough", "Some people go on to injections or surgery.", 20, 40, .mild),
                ],
                evidence: .moderate,
                availability: "Widely available and covered by Medicare and most insurers, often with a visit limit or copay.",
                sources: ["Kukkonen J et al. Bone Joint J 2014;96-B:75–81", "Vandvik PO et al. BMJ 2019;364:l294"]),

            TreatmentOption(
                id: "sap-injection", name: "Steroid injection", tier: .interventional,
                summary: "A steroid injected into the space above the rotator cuff (the subacromial bursa) to calm inflammation for a few weeks, often to make exercise easier.",
                whatHappens: ["Done in the clinic in a few minutes, often with ultrasound guidance.", "Usually no more than 2–3 injections into the same area."],
                anesthesia: "Local anesthetic or none", hospitalStay: "None (clinic)", recovery: "Normal light activity the next day.",
                bestFor: ["Pain that stops you sleeping or doing your exercises"],
                lessSuitableIf: ["Poorly controlled diabetes", "Infection near the shoulder", "Planned tendon repair soon (repeated injections may weaken tendons)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(40, 60)),
                keyFindings: [
                    "Steroid injections give short-term pain relief over weeks, with little difference from other treatments after a few months (approximate, from several small trials).",
                    "In the CSAW trial, all groups were offered injections before joining; the people who joined still had pain despite them (Beard 2018).",
                ],
                sideEffects: [
                    SE.make("Pain flare after the injection", "Usually lasts 1–2 days.", 2, 10, .mild),
                    SE.steroidFlush, SE.steroidSugar,
                    SE.make("Thinning of the skin or a pale patch", "At the injection site.", 1, 5, .mild),
                    SE.make("Infection", "Rare, but may need antibiotics or surgery.", 0.01, 0.1, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available from primary care, sports medicine and orthopedic clinics. Covered by Medicare and most insurers.",
                sources: ["Beard DJ et al. Lancet 2018;391:329–38", "Vandvik PO et al. BMJ 2019;364:l294"]),

            TreatmentOption(
                id: "sap-decompression", name: "Arthroscopic subacromial decompression", tier: .minimallyInvasive,
                summary: "Through small cuts, the surgeon shaves bone from the underside of the shoulder blade (acromion) and removes the inflamed bursa to make more room for the tendons. Sham-controlled trials found it works no better than a placebo operation.",
                whatHappens: ["Two or three small cuts around the shoulder.", "A camera and a shaver remove the bursa and some bone.", "Day surgery; a sling for a few days."],
                anesthesia: "General anesthesia, often with a nerve block", hospitalStay: "Same day", recovery: "Sling for a few days; desk work in 1–2 weeks; full recovery 3–6 months.",
                bestFor: ["Rarely the first choice. Some surgeons still offer it when long-lasting pain hasn't responded to exercise and injections"],
                lessSuitableIf: ["Pain that hasn't had a full trial of exercise therapy", "Frozen shoulder or arthritis as the main problem"],
                outcomes: OptionOutcomes(improvement: PercentRange(55, 75), seriousComplications: PercentRange(0.5, 1.5), furtherTreatment: PercentRange(5, 10)),
                keyFindings: [
                    "In the CSAW trial, decompression was no better than arthroscopy alone (looking with the camera but not removing anything) at 6 months and 1 year; both were only slightly better than no treatment (Beard 2018).",
                    "In the FIMPACT trial, decompression was no better than diagnostic arthroscopy or exercise therapy at 2 years (Paavola 2018).",
                    "An international expert panel made a strong recommendation against decompression surgery for subacromial pain (Vandvik 2019).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Frozen shoulder (stiffness)", "The shoulder becomes stiff and painful after surgery; can take months to settle.", 1, 5, .moderate),
                    SE.woundInfection(0.1, 0.5),
                    SE.make("Nerve injury or problems from the nerve block", "Numbness or weakness in the arm, usually temporary.", 0.1, 1, .serious),
                    SE.clots(0.05, 0.3),
                ],
                evidence: .strong,
                availability: "Still offered by many orthopedic surgeons, though much less often since the sham trials. Medicare and insurers usually cover it.",
                sources: ["Beard DJ et al. Lancet 2018;391:329–38", "Paavola M et al. BMJ 2018;362:k2860", "Vandvik PO et al. BMJ 2019;364:l294"]),

            TreatmentOption(
                id: "sap-cuff-repair", name: "Arthroscopic rotator cuff repair", tier: .minimallyInvasive,
                summary: "For a full-thickness tear: through small cuts, the torn tendon is stitched back onto the bone using small anchors.",
                whatHappens: ["Three to five small cuts around the shoulder.", "Anchors with stitches are placed in the bone and the tendon is tied down.", "A sling for about 4–6 weeks, then a long rehabilitation program."],
                anesthesia: "General anesthesia, often with a nerve block", hospitalStay: "Same day or overnight", recovery: "Sling for 4–6 weeks; no lifting for about 3 months; full recovery 6–12 months.",
                bestFor: ["A full-thickness tear in a younger or active person", "A sudden tear from an injury with new weakness", "A tear that is getting larger or causing ongoing weakness despite exercise"],
                lessSuitableIf: ["A degenerative tear in an older person whose pain improves with exercise", "Very large, long-standing tears with wasted muscle (they often don't heal)", "Smoking, which lowers healing rates"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In a Norwegian trial of small and medium tears, repair gave somewhat better shoulder scores than physical therapy, and the difference lasted to 10 years; tears in the therapy group tended to get bigger (Moosmayer 2010; Moosmayer 2019).",
                    "In a Finnish trial of people over 55 with non-injury tears, repair was no better than physical therapy at 1 year (Kukkonen 2014).",
                    "The repaired tendon doesn't heal in about 1 in 5 to 1 in 3 people, more often in large tears and older people, though many still have less pain (approximate).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Tendon doesn't heal or tears again", "Many people still feel better, but some need more surgery.", 15, 35, .moderate),
                    SE.make("Frozen shoulder (stiffness)", "Can take months to settle; sometimes needs more treatment.", 2, 8, .moderate),
                    SE.woundInfection(0.2, 1),
                    SE.make("Nerve injury or problems from the nerve block", "Numbness or weakness in the arm, usually temporary.", 0.1, 1, .serious),
                    SE.clots(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Widely available from orthopedic and sports surgeons and covered by Medicare and insurers. Long rehabilitation and time off work are needed, which matters if you do manual work.",
                sources: ["Moosmayer S et al. J Bone Joint Surg Br 2010;92:83–91", "Moosmayer S et al. J Bone Joint Surg Am 2019;101:1050–60", "Kukkonen J et al. Bone Joint J 2014;96-B:75–81"]),

            TreatmentOption(
                id: "sap-open-repair", name: "Open or mini-open rotator cuff repair", tier: .traditional,
                summary: "The same tendon repair done through an incision of about 1–3 inches over the shoulder instead of only through the camera ports.",
                whatHappens: ["An incision over the top or front of the shoulder.", "The tendon is stitched back to the bone.", "Sling and rehabilitation as for arthroscopic repair."],
                anesthesia: "General anesthesia, often with a nerve block", hospitalStay: "Same day or overnight", recovery: "Similar to arthroscopic repair: 6–12 months for full recovery.",
                bestFor: ["Large or complex tears, or surgeons who get their best results this way"],
                lessSuitableIf: ["Same as arthroscopic repair"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the UK Rotator Cuff (UKUFF) trial of 273 people, arthroscopic and open repair gave similar results at 2 years (Carr 2015).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Tendon doesn't heal or tears again", "Many people still feel better, but some need more surgery.", 15, 35, .moderate),
                    SE.make("Frozen shoulder (stiffness)", "Can take months to settle; sometimes needs more treatment.", 2, 8, .moderate),
                    SE.woundInfection(0.5, 2),
                    SE.make("Deltoid muscle detaches", "A rare problem specific to open repair that may need more surgery.", 0.1, 1, .serious),
                    SE.clots(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered by many orthopedic surgeons; covered by Medicare and insurers. Some surgeons do only arthroscopic repairs.",
                sources: ["Carr AJ et al. Health Technol Assess 2015;19(80):1–218"]),
        ],
        comparisons: [
            ComparisonStudy(name: "CSAW", compared: "Arthroscopic decompression vs arthroscopy only (placebo surgery) vs no treatment (313 people)",
                finding: "Decompression was no better than placebo surgery; both were slightly better than no treatment.", citation: "Beard 2018, Lancet"),
            ComparisonStudy(name: "FIMPACT", compared: "Arthroscopic decompression vs diagnostic arthroscopy vs exercise therapy (210 people)",
                finding: "No clinically important difference between the groups at 2 years.", citation: "Paavola 2018, BMJ"),
            ComparisonStudy(name: "Kukkonen trial", compared: "Physical therapy vs therapy plus decompression vs therapy plus rotator cuff repair (180 people over 55)",
                finding: "No clinically important difference at 1 year.", citation: "Kukkonen 2014, Bone Joint J"),
            ComparisonStudy(name: "Moosmayer trial", compared: "Rotator cuff repair vs physical therapy for small and medium tears (103 people)",
                finding: "Repair gave modestly better shoulder scores, lasting to 10 years.", citation: "Moosmayer 2010 and 2019, J Bone Joint Surg"),
        ],
        questionsToAsk: [
            "Do I have a full-thickness tear, and is it likely to be the cause of my pain?",
            "How likely is my tear to get bigger if I don't have it repaired?",
            "If you're suggesting decompression, how do you weigh the CSAW and FIMPACT results?",
            "What are the chances the repaired tendon heals, given my age, tear size and whether I smoke?",
            "How long will I be in a sling and off work?",
        ],
        specialty: .orthopedic)

    // MARK: - Unruptured brain aneurysm

    static let unrupturedAneurysm = ConditionGuide(
        id: "unruptured-brain-aneurysm",
        name: "Unruptured brain aneurysm",
        alsoCalled: "Unruptured intracranial aneurysm, cerebral aneurysm, berry aneurysm",
        symbol: "brain.head.profile",
        summary: "A weak, balloon-like bulge in the wall of an artery in the brain that hasn't burst. Most are found by chance on a scan done for another reason. The aim of any treatment is to prevent a rupture, which causes bleeding around the brain (subarachnoid hemorrhage).",
        naturalHistory: [
            "Most small unruptured aneurysms never burst. The yearly risk depends mainly on size, location, age, high blood pressure, smoking, ancestry and whether you've had a bleed before.",
            "For aneurysms smaller than 7 mm in the front part of the brain circulation, in people who had never had a bleed, the rupture risk in a large study was very low over 5 years (ISUIA, Wiebers 2003). In a Japanese study the average yearly risk across all sizes was about 1 in 100 (UCAS 2012).",
            "The PHASES score combines these factors. Estimated 5-year rupture risk ranges from under 1 in 100 for low scores to more than 15 in 100 for the highest scores (Greving 2014).",
            "When an aneurysm does rupture, about a third to half of people die and many survivors have lasting disability, which is why preventive treatment is sometimes worth its own risks.",
        ],
        whenSurgeryIsOffered: [
            "Larger aneurysms (often 7 mm or more), or ones that are growing or have an irregular shape.",
            "Aneurysms in higher-risk locations, such as the back of the brain or the posterior communicating artery.",
            "Younger people with many years of risk ahead, people who have had a previous bleed, or aneurysms that are pressing on nerves and causing symptoms.",
        ],
        urgentSigns: [
            "A sudden, severe 'worst headache of your life' that peaks within seconds to a minute — call 911.",
            "Sudden stiff neck, vomiting, confusion, a seizure or collapse — call 911.",
            "A new drooping eyelid, double vision or a large pupil on one side — go to the emergency department now. This can mean the aneurysm is enlarging.",
        ],
        improvementDefinition: "Because treatment is preventive, 'success' here means being alive, free of aneurysm rupture and without new disability from the aneurysm or its treatment, about 5 years later.",
        options: [
            TreatmentOption(
                id: "uia-observation", name: "Monitoring with blood pressure control and stopping smoking", tier: .conservative,
                summary: "Regular scans to check the aneurysm isn't changing, while lowering the risk of rupture by controlling blood pressure and stopping smoking.",
                whatHappens: ["An MRI or CT angiogram after 6–12 months, then usually every 1–3 years if stable.", "Treat high blood pressure to target and stop smoking — both raise rupture risk.", "Limit heavy alcohol and avoid stimulant drugs such as cocaine or amphetamines.", "Treatment is reconsidered if the aneurysm grows or changes shape."],
                anesthesia: "None", hospitalStay: "None", recovery: "None needed.",
                bestFor: ["Small aneurysms (usually under 7 mm) with a low PHASES score", "Older people or people with health problems that make treatment riskier"],
                lessSuitableIf: ["Aneurysms that are growing, large, irregular or causing symptoms", "A previous bleed from another aneurysm", "Severe anxiety about living with an untreated aneurysm"],
                outcomes: OptionOutcomes(improvement: PercentRange(95, 99.5), seriousComplications: PercentRange(0.5, 5), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In ISUIA, people with aneurysms under 7 mm in the front circulation and no previous bleed had a very low 5-year rupture risk — close to 0 in 100. Risk rose steeply with size and with location at the back of the brain (Wiebers 2003).",
                    "In the PHASES pooled analysis of about 8,400 people, estimated 5-year rupture risk ranged from about 0.25 in 100 to more than 15 in 100 depending on the score (Greving 2014).",
                    "In UCAS Japan, the average yearly rupture risk was about 1 in 100, with small aneurysms under 5 mm much lower (UCAS 2012).",
                ],
                sideEffects: [
                    SE.make("Aneurysm ruptures while being watched", "For a typical small aneurysm, about 1 to 5 in 100 over 5 years; much lower for the smallest and much higher for large ones. A rupture is life-threatening.", 0.5, 5, .serious),
                    SE.make("Aneurysm grows on follow-up scans", "Usually leads to a recommendation for treatment.", 5, 15, .moderate),
                    SE.make("Worry about living with an aneurysm", "Many people feel anxious; talking it through and having a clear plan helps.", 10, 30, .mild),
                    SE.make("Side effects of blood pressure medicines", "Such as dizziness or ankle swelling; usually managed by changing the medicine.", 5, 15, .mild),
                ],
                evidence: .moderate,
                availability: "Available everywhere. Scans are covered by Medicare and insurers. Blood pressure and smoking support usually come from your primary care doctor. A neurosurgeon or neurointerventional specialist should help you estimate your own rupture risk.",
                sources: ["Wiebers DO et al. Lancet 2003;362:103–10", "Greving JP et al. Lancet Neurol 2014;13:59–66", "UCAS Japan Investigators. N Engl J Med 2012;366:2474–82", "Thompson BG et al. Stroke 2015;46:2368–400"]),

            TreatmentOption(
                id: "uia-coiling", name: "Endovascular coiling", tier: .interventional,
                summary: "A thin tube (catheter) is passed from an artery in the groin or wrist up into the aneurysm, which is packed with soft platinum coils so blood no longer flows into it. Sometimes a stent or balloon helps hold the coils in place.",
                whatHappens: ["Done in an angiography suite using X-ray.", "The catheter is guided into the aneurysm and coils are placed one by one.", "You may need blood thinners (antiplatelet medicines) for months if a stent is used.", "Follow-up scans check that the aneurysm stays closed."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 1–2 nights", recovery: "Most people return to normal activities within 1–2 weeks.",
                bestFor: ["Aneurysms with a shape and location suitable for coils, especially at the back of the brain", "Older people or those who want to avoid open surgery"],
                lessSuitableIf: ["Aneurysms with a wide neck or complex shape (may need a stent or another option)", "People who can't take blood thinners when a stent is needed"],
                outcomes: OptionOutcomes(improvement: PercentRange(93, 97), seriousComplications: PercentRange(3, 6), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In a review of 74 studies of unruptured aneurysms, about 5 in 100 people had a complication within 30 days of endovascular treatment, and about 3 in 1,000 died (Algra 2019).",
                    "Coiled aneurysms re-open more often than clipped ones; about 1 in 10 to 1 in 5 need a repeat procedure over the years (approximate).",
                    "For ruptured aneurysms, the ISAT trial found fewer people died or became dependent at 1 year after coiling than after clipping (Molyneux 2002).",
                ],
                sideEffects: [
                    SE.make("Stroke from a clot or blocked artery", "During or soon after the procedure. Most are mild, some cause lasting disability.", 2, 5, .serious),
                    SE.make("Aneurysm ruptures during the procedure", "Rare, but can be life-threatening.", 0.5, 2, .serious),
                    SE.make("Aneurysm re-opens and needs another procedure", "Coils can compact over time; follow-up scans check for this.", 10, 20, .moderate),
                    SE.make("Bruising or bleeding at the groin or wrist", "Usually minor; rarely needs treatment.", 1, 5, .mild),
                    SE.make("Headache in the days after", "Common and usually settles.", 10, 30, .mild),
                    SE.death(0.2, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered at stroke and neurovascular centers by neurointerventional specialists (neuroradiologists or endovascular neurosurgeons). Covered by Medicare and insurers. A surgeon who clips aneurysms may not do coiling themselves — ask to see both kinds of specialist.",
                sources: ["Algra AM et al. JAMA Neurol 2019;76:282–93", "Molyneux A et al. Lancet 2002;360:1267–74", "Thompson BG et al. Stroke 2015;46:2368–400"]),

            TreatmentOption(
                id: "uia-flow-diverter", name: "Flow-diverting stent", tier: .interventional,
                summary: "A fine mesh tube is placed through a catheter into the artery across the neck of the aneurysm. It redirects blood flow so the aneurysm gradually clots off and heals over months.",
                whatHappens: ["Done through an artery in the groin or wrist under X-ray.", "You take two antiplatelet medicines for several months beforehand and afterward, then usually one long term.", "The aneurysm closes over 6–12 months; scans check progress."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 1–2 nights", recovery: "Normal activities within 1–2 weeks.",
                bestFor: ["Large or wide-necked aneurysms, especially on the internal carotid artery", "Aneurysms that are hard to coil or clip"],
                lessSuitableIf: ["People who can't take antiplatelet medicines for months", "Some aneurysm locations where branches would be covered"],
                outcomes: OptionOutcomes(improvement: PercentRange(90, 96), seriousComplications: PercentRange(4, 8), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the PUFS study of 108 people with large or giant carotid aneurysms, about 74 in 100 aneurysms were completely closed at 6 months, and about 6 in 100 people had a major stroke or died (Becske 2013).",
                ],
                sideEffects: [
                    SE.make("Stroke from a clot or blocked branch", "During or after the procedure.", 2, 6, .serious),
                    SE.make("Bleeding in the brain or delayed aneurysm rupture", "Rare, but can be life-threatening; partly linked to the blood thinners needed.", 0.5, 2, .serious),
                    SE.make("Bleeding elsewhere from antiplatelet medicines", "Nosebleeds or bruising; rarely serious stomach bleeding.", 5, 15, .moderate),
                    SE.make("Aneurysm doesn't fully close", "May need more time or another treatment.", 10, 25, .moderate),
                    SE.death(0.5, 2),
                ],
                evidence: .limited,
                availability: "Offered at larger neurovascular centers. Covered by Medicare and insurers for approved uses. Less widely available than coiling or clipping.",
                sources: ["Becske T et al. Radiology 2013;267:858–68", "Thompson BG et al. Stroke 2015;46:2368–400"]),

            TreatmentOption(
                id: "uia-clipping", name: "Surgical clipping", tier: .traditional,
                summary: "Open brain surgery. The surgeon removes a window of skull bone, gently opens the space around the brain and places a small titanium clip across the neck of the aneurysm to seal it off.",
                whatHappens: ["An incision behind the hairline and a small opening in the skull (craniotomy).", "The aneurysm is found under a microscope and clipped.", "The bone is replaced and the skin closed."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 3–7 days, including time in intensive care", recovery: "Often 4–8 weeks before returning to work; tiredness can last a few months.",
                bestFor: ["Younger people with many years of risk ahead (clipping is very durable)", "Aneurysms at a branch point, such as the middle cerebral artery, that suit clipping", "Aneurysms that are pressing on nearby structures"],
                lessSuitableIf: ["Aneurysms deep at the back of the brain, which are harder to reach", "Older people or those with serious health problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(90, 96), seriousComplications: PercentRange(5, 10), furtherTreatment: PercentRange(1, 3)),
                keyFindings: [
                    "In a review of 54 studies of unruptured aneurysms, about 8 in 100 people had a complication within 30 days of clipping, and about 1 in 1,000 died (Algra 2019).",
                    "Clipped aneurysms rarely re-open, so repeat treatment is uncommon (approximate, from long-term follow-up studies).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Stroke or brain injury", "New weakness, speech or thinking problems; some lasting.", 3, 8, .serious),
                    SE.make("Seizures", "Sometimes needing medicine for a while.", 1, 5, .moderate),
                    SE.make("Problems with memory, concentration or mood", "Usually improve over months.", 5, 15, .moderate),
                    SE.woundInfection(0.5, 2),
                    SE.clots(0.5, 2),
                    SE.death(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered at neurosurgical centers; fewer surgeons now do many clippings each year as endovascular treatment has grown. Covered by Medicare and insurers. Ask how many clippings the surgeon does each year.",
                sources: ["Algra AM et al. JAMA Neurol 2019;76:282–93", "Thompson BG et al. Stroke 2015;46:2368–400"]),
        ],
        comparisons: [
            ComparisonStudy(name: "ISAT", compared: "Coiling vs clipping for ruptured aneurysms suitable for either (2,143 people)",
                finding: "About 24 in 100 after coiling vs 31 in 100 after clipping were dead or dependent at 1 year; re-bleeding was somewhat more common after coiling. This was for ruptured, not unruptured, aneurysms.", citation: "Molyneux 2002, Lancet"),
            ComparisonStudy(name: "ISUIA", compared: "Natural history vs surgical and endovascular repair of unruptured aneurysms (about 4,000 people, not randomized)",
                finding: "Rupture risk was very low for small front-circulation aneurysms, and treatment risks often exceeded rupture risk for them; treatment risk rose with age.", citation: "Wiebers 2003, Lancet"),
            ComparisonStudy(name: "Algra meta-analysis", compared: "Endovascular treatment vs clipping for unruptured aneurysms (114 studies, indirect comparison)",
                finding: "Complications within 30 days: about 5 in 100 with endovascular treatment and 8 in 100 with clipping; deaths were rare with both.", citation: "Algra 2019, JAMA Neurol"),
        ],
        questionsToAsk: [
            "What is my PHASES score, and what is my estimated rupture risk over the next 5 and 10 years?",
            "What are the risks of treatment for my aneurysm, at my age, at this center?",
            "Is my aneurysm suitable for coiling, a flow diverter, clipping or all three? Can I see both an endovascular specialist and a surgeon?",
            "If we watch it, how often will I have scans, and what change would make you recommend treatment?",
            "Should my close relatives be screened?",
        ],
        specialty: .neurosurgery)

    // MARK: - Trigeminal neuralgia

    static let trigeminalNeuralgia = ConditionGuide(
        id: "trigeminal-neuralgia",
        name: "Trigeminal neuralgia",
        alsoCalled: "Tic douloureux, facial nerve pain, trigeminal nerve pain",
        symbol: "bolt",
        summary: "Sudden, very severe electric-shock-like attacks of pain on one side of the face, often set off by light touch, talking, chewing or brushing teeth. It's usually caused by a blood vessel pressing on the trigeminal nerve where it leaves the brainstem.",
        naturalHistory: [
            "Attacks often come in bouts lasting weeks or months, with pain-free spells in between that can last months or years.",
            "Over time, many people find the bouts become more frequent and medicines work less well.",
            "Most people get good relief from medicines at first. About half eventually consider a procedure because of side effects or lost effect (approximate).",
        ],
        whenSurgeryIsOffered: [
            "Medicines don't control the pain, or the doses needed cause side effects you can't live with.",
            "An MRI shows a blood vessel pressing on the nerve (for microvascular decompression).",
        ],
        urgentSigns: [
            "Pain you can't eat or drink through — you may need urgent pain control in hospital.",
            "Face pain with new weakness, numbness of the face that doesn't go away, double vision, hearing loss or trouble speaking — go to the emergency department. These aren't typical of trigeminal neuralgia.",
            "A widespread rash, blistering or peeling skin, mouth sores or fever after starting carbamazepine or oxcarbazepine — stop the medicine and get emergency care.",
        ],
        improvementDefinition: "Pain free or with only occasional mild pain, without needing medicine (or on a lower, tolerable dose), at about 1–5 years.",
        options: [
            TreatmentOption(
                id: "tn-medicines", name: "Carbamazepine or oxcarbazepine", tier: .conservative,
                summary: "Anti-seizure medicines that calm the irritated nerve. They're the first treatment and work very well for most people, at least at first. Other medicines (such as lamotrigine, baclofen or gabapentin) can be added or used instead.",
                whatHappens: ["Start with a low dose and increase gradually until the pain is controlled.", "Blood tests check sodium levels, blood counts and liver tests.", "People of Asian ancestry may be offered a gene test (HLA-B*1502) before carbamazepine to lower the risk of a severe skin reaction.", "The dose can often be lowered during pain-free spells."],
                anesthesia: "None", hospitalStay: "None (sometimes in hospital for a severe bout)", recovery: "Relief often within days.",
                bestFor: ["Almost everyone as the first treatment"],
                lessSuitableIf: ["Side effects at the doses needed", "Pregnancy or planning pregnancy (needs specialist advice)", "Interactions with other medicines, including birth control pills"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 90), seriousComplications: PercentRange(0.1, 1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: [
                    "Carbamazepine and oxcarbazepine give good initial pain control in most people with trigeminal neuralgia and are recommended as first treatment (Bendtsen 2019; Cruccu 2020).",
                    "Side effects are common and are a frequent reason for stopping or seeking a procedure (Cruccu 2020).",
                ],
                sideEffects: [
                    SE.make("Drowsiness, dizziness or unsteadiness", "Very common, especially when starting or at high doses. Can raise the risk of falls in older people.", 30, 50, .mild),
                    SE.make("Low sodium in the blood", "More common with oxcarbazepine and in older people. Can cause confusion or tiredness.", 5, 15, .moderate),
                    SE.make("Changes in blood counts or liver tests", "Checked with blood tests; usually mild.", 2, 10, .moderate),
                    SE.make("Mild rash", "Tell your doctor straight away.", 5, 10, .moderate),
                    SE.make("Severe skin reaction (Stevens-Johnson syndrome)", "Rare and life-threatening; much higher in people with HLA-B*1502, common in some Asian populations.", 0.01, 0.1, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available and inexpensive; prescribed by neurologists and primary care doctors.",
                sources: ["Bendtsen L et al. Eur J Neurol 2019;26:831–49", "Cruccu G et al. N Engl J Med 2020;383:754–62"]),

            TreatmentOption(
                id: "tn-radiosurgery", name: "Stereotactic radiosurgery (such as Gamma Knife)", tier: .interventional,
                summary: "Highly focused beams of radiation are aimed at the trigeminal nerve near the brainstem, with no incision. Pain relief usually comes on gradually over weeks to months.",
                whatHappens: ["A frame or mask keeps your head still; an MRI pinpoints the nerve.", "Treatment takes about 15–90 minutes.", "You go home the same day."],
                anesthesia: "Local anesthetic for the frame, or none with a mask; sometimes mild sedation", hospitalStay: "Outpatient (home the same day)", recovery: "Normal activities the next day. Relief usually starts after 1–3 months; medicines are lowered gradually.",
                bestFor: ["Older people or those with health problems that make open surgery risky", "People on blood thinners", "People who prefer to avoid an operation"],
                lessSuitableIf: ["Severe pain that needs relief right away (it works slowly)", "Pain that has come back after radiosurgery more than once"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 75), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(25, 50)),
                keyFindings: [
                    "In a review of 65 studies (about 6,500 people), about half were pain free without medicines at first after Gamma Knife radiosurgery; about 1 in 4 had the pain come back; facial numbness occurred in about 1 in 5 (Tuleasca 2019).",
                    "In 2 long-term series, about 30–45 in 100 people were pain free without medicines 10 years after radiosurgery (Tuleasca 2019).",
                ],
                sideEffects: [
                    SE.make("Facial numbness or tingling", "Usually mild, appears months after treatment and may be lasting.", 10, 30, .moderate),
                    SE.make("Pain comes back", "Often after 1–5 years; treatment can be repeated or another option tried.", 20, 50, .moderate),
                    SE.make("Dry eye", "Uncommon.", 1, 3, .mild),
                    SE.make("Painful numbness (deafferentation pain)", "Rare, but hard to treat.", 0.2, 1, .serious),
                ],
                evidence: .limited,
                availability: "Available at radiosurgery centers (Gamma Knife, CyberKnife or linear accelerator); not every hospital has one. Covered by Medicare and most insurers.",
                sources: ["Tuleasca C et al. J Neurosurg 2019;130:733–57", "Bendtsen L et al. Eur J Neurol 2019;26:831–49"]),

            TreatmentOption(
                id: "tn-rhizotomy", name: "Percutaneous rhizotomy (balloon, glycerol or radiofrequency)", tier: .interventional,
                summary: "A needle is passed through the cheek to the base of the skull, where the trigeminal nerve is deliberately injured by squeezing it with a tiny balloon, injecting glycerol or heating it. This stops the pain signals.",
                whatHappens: ["Done under X-ray guidance while you're asleep or heavily sedated.", "Takes about 30–60 minutes.", "Often done as day surgery or with one night in hospital."],
                anesthesia: "General anesthesia or deep sedation", hospitalStay: "Same day or overnight", recovery: "Normal activities within a few days. Relief is usually immediate.",
                bestFor: ["Older or frail people who need fast relief", "Pain that has come back after other treatments", "Multiple sclerosis-related trigeminal neuralgia"],
                lessSuitableIf: ["People who would find facial numbness very hard to live with", "Pain in the forehead and eye area (some techniques risk numbness of the eye surface)"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(30, 60)),
                keyFindings: [
                    "Percutaneous procedures relieve pain immediately in most people, but pain comes back in about half within 3–5 years (approximate, from case series; Bendtsen 2019).",
                    "Facial numbness is expected and is how the procedure works; it is more common and denser with radiofrequency heating.",
                ],
                sideEffects: [
                    SE.make("Facial numbness", "Expected in most people; often lasting.", 50, 90, .moderate),
                    SE.make("Weak chewing muscles on one side", "Mainly after balloon compression; usually recovers over months.", 5, 20, .moderate),
                    SE.make("Pain comes back", "The procedure can be repeated.", 30, 60, .moderate),
                    SE.make("Numb eye surface (corneal numbness) and eye injury", "Needs eye protection; more likely after radiofrequency.", 1, 5, .serious),
                    SE.make("Painful numbness (anesthesia dolorosa)", "Rare, but very hard to treat.", 0.5, 2, .serious),
                ],
                evidence: .limited,
                availability: "Offered by some neurosurgeons and pain specialists; experience varies widely. Covered by Medicare and insurers.",
                sources: ["Bendtsen L et al. Eur J Neurol 2019;26:831–49", "Cruccu G et al. N Engl J Med 2020;383:754–62", "Zakrzewska JM et al. Cochrane 2011;CD007312"]),

            TreatmentOption(
                id: "tn-mvd", name: "Microvascular decompression", tier: .traditional,
                summary: "Open brain surgery through a small opening in the skull behind the ear. The surgeon moves the blood vessel that is pressing on the nerve and places a small Teflon cushion between them. The nerve isn't damaged, so numbness is uncommon.",
                whatHappens: ["An incision of about 2–3 inches behind the ear and a small opening in the skull.", "Under a microscope, the vessel is lifted off the nerve and padded.", "The opening is closed."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 2–4 nights", recovery: "Most people return to normal activities in 3–6 weeks.",
                bestFor: ["Younger, healthy people with classic trigeminal neuralgia and a vessel pressing on the nerve on MRI", "People who want the longest-lasting relief without facial numbness"],
                lessSuitableIf: ["Serious health problems that make brain surgery risky", "No vessel pressing on the nerve, or trigeminal neuralgia from multiple sclerosis"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(2, 5), furtherTreatment: PercentRange(10, 25)),
                keyFindings: [
                    "In a series of 1,185 people, about 80 in 100 had complete relief right after surgery and about 70 in 100 were still pain free without medicines 10 years later; about 2 in 1,000 died (Barker 1996).",
                    "Guidelines suggest microvascular decompression as the first choice of surgery for classic trigeminal neuralgia with vessel compression in people fit for surgery (Bendtsen 2019).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Hearing loss on that side", "Usually partial; can be lasting.", 1, 4, .serious),
                    SE.make("Fluid leak from the wound (CSF leak)", "May need more surgery to repair.", 1, 4, .moderate),
                    SE.make("Facial numbness or weakness", "Usually mild and temporary.", 1, 5, .moderate),
                    SE.make("Stroke or bleeding in the brain", "Rare.", 0.1, 0.5, .serious),
                    SE.woundInfection(0.5, 2),
                    SE.death(0.1, 0.5),
                ],
                evidence: .limited,
                availability: "Offered by neurosurgeons at larger centers; results are best with surgeons who do many. Covered by Medicare and insurers. A neurologist may not refer you early, and a surgeon who does only one type of procedure may not describe the others in detail.",
                sources: ["Barker FG et al. N Engl J Med 1996;334:1077–83", "Bendtsen L et al. Eur J Neurol 2019;26:831–49", "Cruccu G et al. N Engl J Med 2020;383:754–62"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Cochrane review of neurosurgical treatments", compared: "Microvascular decompression, radiosurgery and percutaneous procedures for classic trigeminal neuralgia",
                finding: "No good randomized trials compared the procedures; the evidence comes from case series, so the options can't be ranked with certainty.", citation: "Zakrzewska 2011, Cochrane"),
            ComparisonStudy(name: "European Academy of Neurology guideline", compared: "Systematic review of medicines and surgical treatments",
                finding: "Recommends carbamazepine or oxcarbazepine first, and microvascular decompression as the first-choice surgery for classic trigeminal neuralgia with vessel compression; percutaneous procedures or radiosurgery for others.", citation: "Bendtsen 2019, Eur J Neurol"),
        ],
        questionsToAsk: [
            "Does my MRI show a blood vessel pressing on the nerve?",
            "Have we tried enough medicines and doses, including add-on medicines?",
            "Which procedure gives me the best balance of lasting relief and risk of facial numbness, given my age and health?",
            "How many of these procedures do you do each year, and what are your rates of hearing loss and numbness?",
        ],
        specialty: .neurosurgery)

    // MARK: - Chronic subdural hematoma

    static let chronicSubduralHematoma = ConditionGuide(
        id: "chronic-subdural-hematoma",
        name: "Chronic subdural hematoma",
        alsoCalled: "Subdural hematoma, subdural bleed, blood on the brain, chronic subdural",
        symbol: "brain",
        summary: "A collection of old blood and fluid between the brain and its outer covering, usually in older adults, often after a minor head bump or on blood thinners. It builds up slowly over weeks and can press on the brain, causing headaches, confusion, unsteadiness or weakness.",
        naturalHistory: [
            "Small collections with mild or no symptoms can shrink and disappear on their own over weeks to months.",
            "Larger collections, or those causing weakness, confusion or drowsiness, usually keep growing or come back unless drained.",
            "After surgical drainage, the collection comes back and needs another operation in about 1 in 10 to 1 in 5 people.",
            "Many people with this condition are older and have other health problems, so the overall risk of death in the months afterward is higher than for most operations.",
        ],
        whenSurgeryIsOffered: [
            "Symptoms such as weakness, speech problems, confusion, drowsiness or falls, together with a sizable collection on the scan.",
            "A collection that is pushing the brain to one side, or growing on repeat scans.",
            "Embolization may be offered with surgery to lower the chance of it coming back, or instead of surgery for milder cases.",
        ],
        urgentSigns: [
            "Increasing drowsiness, confusion, or being hard to wake — call 911.",
            "New weakness or numbness of an arm or leg, slurred speech or a seizure — call 911.",
            "A worsening headache with vomiting — go to the emergency department.",
        ],
        improvementDefinition: "Recovered to a good level of function (able to look after yourself, a modified Rankin score of 0–3) without the hematoma coming back and needing another operation, about 3–6 months after treatment.",
        options: [
            TreatmentOption(
                id: "csdh-observation", name: "Observation with repeat scans and medicine review", tier: .conservative,
                summary: "Watching a small collection with repeat CT scans, while reviewing blood thinners, controlling blood pressure and lowering the risk of falls.",
                whatHappens: ["A repeat CT scan after a few weeks, sooner if symptoms change.", "Your doctors decide whether to pause or change blood thinners — never stop them on your own.", "A fall-risk check and help at home if needed."],
                anesthesia: "None", hospitalStay: "Sometimes a short stay for observation", recovery: "Collections that resolve usually do so over 1–3 months.",
                bestFor: ["Small collections with mild or no symptoms", "People whose health makes any procedure risky"],
                lessSuitableIf: ["Weakness, confusion, drowsiness or a collection pressing on the brain"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 80), seriousComplications: PercentRange(2, 10), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "Many small, mildly symptomatic collections resolve without surgery, but evidence comes mainly from observational studies, so the numbers are approximate (Edlmann 2017 review).",
                    "In the STEM trial, the 'nonsurgical standard care' group was part of the control arm; embolization added to standard care, including nonsurgical care, reduced treatment failure (Fiorella 2025).",
                ],
                sideEffects: [
                    SE.make("Collection grows and needs surgery", "Watch for worsening symptoms.", 20, 40, .moderate),
                    SE.make("Sudden worsening from the collection", "Rarely, rapid decline from re-bleeding or pressure on the brain.", 1, 5, .serious),
                    SE.make("Clot or stroke while blood thinners are paused", "The risk depends on why you take them; your doctors weigh this.", 0.5, 3, .serious),
                ],
                evidence: .limited,
                availability: "Available everywhere; often managed jointly by neurosurgery and your primary care doctor or geriatrician.",
                sources: ["Edlmann E et al. J Neuroinflammation 2017;14:108", "Fiorella D et al. N Engl J Med 2025;392:855–64"]),

            TreatmentOption(
                id: "csdh-dexamethasone", name: "Dexamethasone (steroid tablets)", tier: .conservative,
                summary: "A course of steroid tablets to reduce the inflammation thought to keep the collection growing. A large trial found it led to worse overall results than placebo, so it's now rarely recommended.",
                whatHappens: ["Tablets for about 2 weeks, with the dose tapered down."],
                anesthesia: "None", hospitalStay: "None or as part of a hospital stay", recovery: "Weeks.",
                bestFor: ["Rarely recommended after the Dex-CSDH trial; may be discussed for people who can't have any procedure"],
                lessSuitableIf: ["Diabetes, infections, stomach ulcers or a history of steroid-related confusion"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 86), seriousComplications: PercentRange(10, 20), furtherTreatment: PercentRange(1, 5)),
                keyFindings: [
                    "In the Dex-CSDH trial of 748 people (most of whom also had surgery), about 84 in 100 on dexamethasone had a good outcome at 6 months, compared with about 90 in 100 on placebo. Dexamethasone reduced repeat surgery (about 2 vs 7 in 100) but caused more side effects (Hutchinson 2020).",
                ],
                sideEffects: [
                    SE.make("High blood sugar", "Especially in people with diabetes; may need insulin for a while.", 10, 30, .moderate),
                    SE.make("Infection, including pneumonia", "Steroids lower resistance to infection.", 5, 15, .serious),
                    SE.make("Confusion, agitation or poor sleep", "More common in older people.", 5, 15, .moderate),
                    SE.make("Stomach irritation or bleeding", "Usually prevented with stomach-protecting medicine.", 1, 3, .moderate),
                ],
                evidence: .strong,
                availability: "Inexpensive and widely available, but guidelines no longer recommend it routinely.",
                sources: ["Hutchinson PJ et al. N Engl J Med 2020;383:2616–27"]),

            TreatmentOption(
                id: "csdh-mma", name: "Middle meningeal artery embolization", tier: .interventional,
                summary: "A thin catheter is passed from the groin or wrist to the artery that feeds the fragile membranes around the collection, and the artery is blocked with a liquid glue or tiny particles. This reduces re-bleeding so the collection can shrink. It's usually done along with surgery, and sometimes on its own for milder cases.",
                whatHappens: ["Done in an angiography suite under X-ray, often within days of surgery.", "Takes about 1–2 hours.", "Follow-up CT scans check that the collection is shrinking."],
                anesthesia: "Local anesthetic with sedation, or general anesthesia", hospitalStay: "Often 1–2 nights, or part of the surgical stay", recovery: "Normal activity within a few days.",
                bestFor: ["Lowering the chance of the collection coming back after surgery", "People with milder symptoms who want to avoid surgery, or who have had it come back"],
                lessSuitableIf: ["Severe symptoms or a large collection pressing on the brain that needs draining quickly", "Kidney problems that make X-ray dye risky"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(4, 16)),
                keyFindings: [
                    "In the EMBOLISE trial of 400 people having surgery, adding embolization lowered repeat surgery within 90 days from about 11 in 100 to about 4 in 100; about 2 in 100 had a serious complication from the embolization (Davies 2024).",
                    "In the STEM trial of 310 people, treatment failure at 6 months was about 16 in 100 with embolization plus standard care vs about 36 in 100 with standard care alone (Fiorella 2025).",
                    "In the MAGIC-MT trial of 722 people in China, embolization lowered recurrence from about 10 to 7 in 100, a difference that could have been due to chance, and there were fewer serious adverse events (Liu 2024).",
                ],
                sideEffects: [
                    SE.make("Stroke or vision problems from glue or particles going to the wrong place", "Rare.", 0.5, 2, .serious),
                    SE.make("Facial weakness or numbness", "Rare; from blocking small nerve branches.", 0.2, 1, .moderate),
                    SE.make("Bruising or bleeding at the groin or wrist", "Usually minor.", 1, 5, .mild),
                    SE.make("Headache or jaw discomfort", "For a few days.", 5, 15, .mild),
                    SE.death(0.1, 0.5),
                ],
                evidence: .moderate,
                availability: "Offered at centers with neurointerventional specialists, and becoming much more common since the 2024 trials. Coverage by Medicare and insurers is generally available but may vary. Not every neurosurgery team offers it.",
                sources: ["Davies JM et al. N Engl J Med 2024;391:1890–900", "Fiorella D et al. N Engl J Med 2025;392:855–64", "Liu J et al. N Engl J Med 2024;391:1901–12"]),

            TreatmentOption(
                id: "csdh-burr-hole", name: "Burr-hole drainage with a drain", tier: .lessInvasive,
                summary: "The most common operation. One or two small holes (about the size of a dime) are drilled in the skull, the old blood is washed out, and a soft drain is left in for 1–2 days.",
                whatHappens: ["Small incisions in the scalp and one or two holes in the skull.", "The collection is rinsed out with saline.", "A drain under the skin lets remaining fluid out for 1–2 days."],
                anesthesia: "General anesthesia, or local anesthetic with sedation", hospitalStay: "Usually 2–5 days", recovery: "Many people feel better within days; full recovery can take weeks, especially in older people.",
                bestFor: ["Collections causing symptoms or pressing on the brain", "Mostly liquid collections"],
                lessSuitableIf: ["Collections with thick membranes or solid clot (may need a craniotomy)"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(8, 20)),
                keyFindings: [
                    "In a randomized trial of 215 people, leaving a drain after burr-hole surgery lowered repeat surgery from about 24 in 100 to about 9 in 100, and fewer people had died at 6 months (about 9 vs 18 in 100) (Santarius 2009).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Collection comes back and needs another operation", "Most often within the first few months.", 8, 20, .moderate),
                    SE.make("Seizures", "May need medicine.", 1, 5, .moderate),
                    SE.make("Bleeding in or around the brain", "May need more surgery.", 1, 3, .serious),
                    SE.woundInfection(1, 3),
                    SE.delirium(5, 20),
                    SE.death(2, 8),
                ],
                evidence: .moderate,
                availability: "Widely available at hospitals with neurosurgeons and covered by Medicare and insurers.",
                sources: ["Santarius T et al. Lancet 2009;374:1067–73", "Davies JM et al. N Engl J Med 2024;391:1890–900"]),

            TreatmentOption(
                id: "csdh-craniotomy", name: "Craniotomy", tier: .traditional,
                summary: "A larger window of skull bone is removed so the surgeon can clear thick or solid clot and membranes, then the bone is replaced.",
                whatHappens: ["A curved scalp incision and a bone window of a few inches.", "The collection and some of its membranes are removed.", "The bone is put back and fixed with small plates."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 3–7 days", recovery: "Several weeks; older people may need rehabilitation.",
                bestFor: ["Collections with thick membranes, multiple compartments or solid clot", "Collections that keep coming back after burr-hole drainage"],
                lessSuitableIf: ["Frail people with liquid collections that burr holes can drain"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(5, 15), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "Craniotomy is usually kept for collections that burr holes can't drain well; there are few direct trials comparing it with burr holes, and complication rates are generally higher (approximate).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Collection comes back and needs another operation", "Less often than after burr holes in some studies.", 5, 15, .moderate),
                    SE.make("Seizures", "May need medicine.", 2, 8, .moderate),
                    SE.make("Bleeding in or around the brain", "May need more surgery.", 2, 5, .serious),
                    SE.woundInfection(1, 4),
                    SE.delirium(5, 20),
                    SE.death(3, 10),
                ],
                evidence: .limited,
                availability: "Available at hospitals with neurosurgeons and covered by Medicare and insurers.",
                sources: ["Santarius T et al. Lancet 2009;374:1067–73", "Edlmann E et al. J Neuroinflammation 2017;14:108"]),
        ],
        comparisons: [
            ComparisonStudy(name: "EMBOLISE", compared: "Embolization plus surgery vs surgery alone (400 people)",
                finding: "Repeat surgery within 90 days about 4 in 100 vs 11 in 100, with similar function.", citation: "Davies 2024, N Engl J Med"),
            ComparisonStudy(name: "STEM", compared: "Embolization plus standard care (surgical or nonsurgical) vs standard care alone (310 people)",
                finding: "Treatment failure at 6 months about 16 in 100 vs 36 in 100; similar early safety.", citation: "Fiorella 2025, N Engl J Med"),
            ComparisonStudy(name: "MAGIC-MT", compared: "Embolization plus usual care vs usual care alone (722 people)",
                finding: "Recurrence about 7 vs 10 in 100 — not a statistically clear difference — with fewer serious adverse events after embolization.", citation: "Liu 2024, N Engl J Med"),
            ComparisonStudy(name: "Dex-CSDH", compared: "Dexamethasone vs placebo (748 people)",
                finding: "Fewer good outcomes with dexamethasone at 6 months (about 84 vs 90 in 100), despite fewer repeat operations.", citation: "Hutchinson 2020, N Engl J Med"),
        ],
        questionsToAsk: [
            "Is this collection large enough, or are my symptoms bad enough, that it needs draining now?",
            "Would middle meningeal artery embolization lower my chance of it coming back, and is it offered here?",
            "What should happen with my blood thinners, and when can I restart them?",
            "What are the chances I'll get back to how I was before, given my age and health?",
        ],
        specialty: .neurosurgery)

    // MARK: - Chronic rhinosinusitis

    static let chronicRhinosinusitis = ConditionGuide(
        id: "chronic-rhinosinusitis",
        name: "Chronic rhinosinusitis",
        alsoCalled: "Chronic sinusitis, sinus disease, nasal polyps (chronic rhinosinusitis with nasal polyps)",
        symbol: "nose",
        summary: "Long-lasting inflammation of the lining of the nose and sinuses for 12 weeks or more, causing a blocked nose, mucus, facial pressure and a reduced sense of smell. Some people also have nasal polyps — soft swellings of the lining.",
        naturalHistory: [
            "Chronic rhinosinusitis is usually a long-term condition that is controlled rather than cured. Symptoms often go up and down.",
            "Daily saline rinses and steroid sprays control symptoms well enough for many people.",
            "Nasal polyps often grow back after surgery, especially in people with asthma or aspirin sensitivity.",
        ],
        whenSurgeryIsOffered: [
            "Symptoms that still affect your quality of life after at least 8–12 weeks of correctly used saline rinses and steroid sprays, often with a short course of steroid tablets.",
            "A CT scan showing ongoing sinus disease that matches your symptoms.",
            "Complications such as infection spreading to the eye or brain, or a mucus cyst (mucocele) — these need urgent surgery.",
        ],
        urgentSigns: [
            "Swelling or redness around the eye, double vision, reduced vision or a bulging eye — go to the emergency department now.",
            "Severe headache with a stiff neck, high fever, confusion or drowsiness — call 911.",
            "Clear watery fluid dripping from one side of the nose after sinus surgery — contact your surgeon urgently.",
        ],
        improvementDefinition: "A meaningful improvement in sinus symptoms on the SNOT-22 questionnaire (a drop of about 9 points or more), about 6–12 months after starting treatment.",
        options: [
            TreatmentOption(
                id: "crs-rinses-sprays", name: "Saline rinses and steroid nasal sprays", tier: .conservative,
                summary: "Rinsing the nose daily with a large volume of salt water, plus a steroid nasal spray or a steroid added to the rinse. This is the foundation of treatment.",
                whatHappens: ["Rinse with a squeeze bottle or neti pot once or twice a day, using distilled or boiled water.", "Use a steroid spray daily, aiming slightly away from the middle of the nose.", "Your doctor may add a steroid (budesonide) to the rinse for stronger effect."],
                anesthesia: "None", hospitalStay: "None", recovery: "Improvement usually within 4–8 weeks; needs to continue long term.",
                bestFor: ["Everyone with chronic rhinosinusitis, before and after surgery"],
                lessSuitableIf: ["Frequent nosebleeds (sprays can make these worse)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "Daily saline irrigation and steroid nasal sprays improve symptoms and are recommended as first treatment by international guidelines (Fokkens 2020; Orlandi 2021).",
                    "Steroid sprays improve symptoms and shrink polyps in people with nasal polyps (Fokkens 2020).",
                ],
                sideEffects: [
                    SE.make("Nosebleeds or dryness (steroid spray)", "Usually mild; aiming the spray away from the middle of the nose helps.", 5, 15, .mild),
                    SE.make("Stinging or fluid draining out later (rinses)", "Usually settles as you get used to it.", 10, 25, .mild),
                    SE.make("Symptoms aren't controlled well enough", "Some people go on to other treatments or surgery.", 30, 50, .mild),
                ],
                evidence: .strong,
                availability: "Widely available; many products are over the counter and inexpensive. Usually started by a primary care doctor.",
                sources: ["Fokkens WJ et al. Rhinology 2020;58(Suppl S29):1–464", "Orlandi RR et al. Int Forum Allergy Rhinol 2021;11:213–739"]),

            TreatmentOption(
                id: "crs-oral", name: "Short courses of steroid tablets or antibiotics", tier: .conservative,
                summary: "A short course of steroid tablets (such as prednisone) to shrink swelling and polyps, or longer courses of certain antibiotics in selected people.",
                whatHappens: ["Steroid tablets for about 1–3 weeks, usually no more than 1–2 times a year.", "Antibiotics are mainly for flare-ups with infection, or sometimes a longer low-dose course."],
                anesthesia: "None", hospitalStay: "None", recovery: "Polyps shrink within days to weeks; the effect wears off over months.",
                bestFor: ["Flare-ups, especially with nasal polyps", "Testing how much better your nose could be before deciding on surgery"],
                lessSuitableIf: ["Diabetes, osteoporosis, glaucoma or stomach ulcers (steroid tablets)", "Repeated courses — side effects build up over a lifetime"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 70), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(40, 60)),
                keyFindings: [
                    "Short courses of steroid tablets improve symptoms and shrink polyps for weeks to a few months (Fokkens 2020).",
                    "Repeated steroid courses add up to long-term risks such as bone thinning, diabetes and cataracts, which is one reason biologics and surgery are considered (Fokkens 2020).",
                ],
                sideEffects: [
                    SE.make("Poor sleep, mood changes or increased appetite (steroid tablets)", "Usually for the length of the course.", 10, 30, .mild),
                    SE.make("Raised blood sugar (steroid tablets)", "Especially in people with diabetes.", 10, 30, .moderate),
                    SE.make("Stomach upset or diarrhea (antibiotics)", "Common.", 5, 20, .mild),
                    SE.make("Long-term steroid harm with repeated courses", "Bone thinning, cataracts, diabetes and, rarely, hip bone damage (avascular necrosis).", 0.5, 2, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available and inexpensive.",
                sources: ["Fokkens WJ et al. Rhinology 2020;58(Suppl S29):1–464", "Orlandi RR et al. Int Forum Allergy Rhinol 2021;11:213–739"]),

            TreatmentOption(
                id: "crs-biologic", name: "Biologic medicines for nasal polyps (such as dupilumab)", tier: .conservative,
                summary: "Injections under the skin every 2–4 weeks that block the type of inflammation behind most nasal polyps. Options include dupilumab, omalizumab, mepolizumab and tezepelumab.",
                whatHappens: ["You or a family member give an injection under the skin at home, usually every 2 weeks for dupilumab.", "Response is checked after about 4–6 months.", "Treatment is usually long term; polyps tend to regrow if it's stopped."],
                anesthesia: "None", hospitalStay: "None", recovery: "Smell and blockage often improve within weeks.",
                bestFor: ["Nasal polyps that keep coming back despite sprays and surgery", "People who also have asthma or aspirin-exacerbated respiratory disease"],
                lessSuitableIf: ["Chronic rhinosinusitis without nasal polyps (not approved)", "Some parasite infections; pregnancy needs discussion"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the SINUS-24 and SINUS-52 trials, dupilumab shrank polyps, improved blockage and sense of smell, and reduced the need for steroid tablets and surgery compared with placebo (Bachert 2019).",
                ],
                sideEffects: [
                    SE.make("Injection-site reactions", "Redness, swelling or itching where the injection is given.", 5, 10, .mild),
                    SE.make("Eye irritation (conjunctivitis)", "Mainly with dupilumab; usually mild.", 1, 5, .mild),
                    SE.make("Joint pain or a temporary rise in a type of white blood cell (eosinophils)", "Usually harmless; rarely needs the medicine stopped.", 1, 5, .moderate),
                    SE.make("Severe allergic reaction", "Rare.", 0.01, 0.1, .serious),
                ],
                evidence: .strong,
                availability: "Prescribed by ENT, allergy and asthma specialists. Very expensive (often tens of thousands of dollars a year); insurers and Medicare Part D usually require prior authorization showing that sprays, steroid tablets and often surgery have been tried. A surgeon may not mention it if you haven't had surgery yet.",
                sources: ["Bachert C et al. Lancet 2019;394:1638–50", "Fokkens WJ et al. Rhinology 2020;58(Suppl S29):1–464"]),

            TreatmentOption(
                id: "crs-balloon", name: "Balloon sinus dilation", tier: .interventional,
                summary: "A small balloon is passed through the nostril into the narrow drainage channel of a sinus and inflated to widen it, without removing tissue.",
                whatHappens: ["Can be done in the office under local anesthetic or in the operating room.", "A thin guide is placed into the sinus opening, then the balloon is inflated for a few seconds.", "Often combined with traditional sinus surgery for other sinuses."],
                anesthesia: "Local anesthetic, or general anesthesia", hospitalStay: "Outpatient (home the same day)", recovery: "Usually back to normal activities within 1–2 days.",
                bestFor: ["Chronic or recurrent sinusitis without nasal polyps, limited to the maxillary, frontal or sphenoid sinuses"],
                lessSuitableIf: ["Nasal polyps or widespread sinus disease", "Headache or facial pain alone, without sinus disease on CT"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0.1, 1), furtherTreatment: PercentRange(5, 20)),
                keyFindings: [
                    "Most studies of balloon dilation are small, short-term and funded by device makers. An expert panel agreed it can help selected people with chronic sinusitis confirmed on CT, but shouldn't be used for headache or symptoms without sinus disease (Piccirillo 2018).",
                ],
                sideEffects: [
                    SE.make("Nosebleed or crusting", "Usually minor.", 2, 10, .mild),
                    SE.make("Sinus opening narrows again", "May need repeat treatment or surgery.", 5, 20, .moderate),
                    SE.make("Injury to the eye socket or skull base", "Very rare.", 0.01, 0.2, .serious),
                ],
                evidence: .limited,
                availability: "Offered by many ENT surgeons, including in the office. Usually covered by Medicare and insurers when sinusitis is confirmed on CT. Concerns about overuse led to scrutiny of its billing; ask whether you truly have chronic sinusitis on CT.",
                sources: ["Piccirillo JF et al. Otolaryngol Head Neck Surg 2018;158:203–14", "Orlandi RR et al. Int Forum Allergy Rhinol 2021;11:213–739"]),

            TreatmentOption(
                id: "crs-ess", name: "Endoscopic sinus surgery", tier: .minimallyInvasive,
                summary: "Through the nostrils, with a camera and fine instruments, the surgeon opens the blocked sinus drainage channels and removes polyps and diseased tissue. There are no cuts on the face.",
                whatHappens: ["Done through the nose, often using CT-based image guidance.", "Takes about 1–3 hours depending on how many sinuses are treated.", "Rinses and steroid sprays continue afterward, usually for life."],
                anesthesia: "General anesthesia", hospitalStay: "Usually the same day", recovery: "Stuffiness and crusting for 1–3 weeks; back to work in about 1 week; follow-up cleanings in the clinic.",
                bestFor: ["Chronic rhinosinusitis that still affects your life after full medical treatment", "Nasal polyps, especially combined with medicines afterward"],
                lessSuitableIf: ["Facial pain or headache without sinus disease on CT", "Symptoms well controlled by medicines"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 85), seriousComplications: PercentRange(0.2, 1), furtherTreatment: PercentRange(10, 25)),
                keyFindings: [
                    "In the English national audit of over 3,000 people, symptom scores improved substantially after sinus surgery and the improvement largely lasted to 5 years (Hopkins 2009). Major complications are uncommon — roughly fewer than 1 in 100 (approximate).",
                    "Revision surgery within 5 years is more common in people with nasal polyps than without (approximate: about 1 in 5 vs 1 in 10) (Hopkins 2009).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Bleeding needing packing or a return to the operating room", "Usually within the first 2 weeks.", 0.5, 2, .moderate),
                    SE.make("Scarring that blocks the sinus again", "May need treatment in the office or more surgery.", 5, 15, .moderate),
                    SE.make("Polyps grow back", "Especially with asthma or aspirin sensitivity.", 20, 40, .moderate),
                    SE.make("Fluid leak from around the brain (CSF leak)", "A rare injury to the skull base; usually repaired straight away but can risk meningitis.", 0.1, 0.5, .serious),
                    SE.make("Eye injury (bleeding in the eye socket, double vision or loss of vision)", "Very rare, but serious.", 0.01, 0.2, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available from ENT surgeons and covered by Medicare and insurers once medical treatment has been tried.",
                sources: ["Hopkins C et al. Laryngoscope 2009;119:2459–65", "Fokkens WJ et al. Rhinology 2020;58(Suppl S29):1–464", "Orlandi RR et al. Int Forum Allergy Rhinol 2021;11:213–739"]),
        ],
        comparisons: [
            ComparisonStudy(name: "SINUS-24 and SINUS-52", compared: "Dupilumab vs placebo added to steroid spray for nasal polyps (724 people)",
                finding: "Dupilumab reduced polyp size and blockage, improved smell and reduced the need for surgery and steroid tablets.", citation: "Bachert 2019, Lancet"),
            ComparisonStudy(name: "English national sinus surgery audit", compared: "Symptom scores before and up to 5 years after endoscopic sinus surgery (over 3,000 people, no comparison group)",
                finding: "Large, lasting improvement on average; higher revision rates in people with polyps.", citation: "Hopkins 2009, Laryngoscope"),
        ],
        questionsToAsk: [
            "Does my CT scan confirm chronic sinusitis, and does it match my symptoms?",
            "Have I used rinses and steroid sprays correctly for long enough? Would a steroid rinse help?",
            "Do I have nasal polyps, and would a biologic medicine be an option for me?",
            "Am I suitable for balloon dilation, or would full endoscopic surgery work better for my type of disease?",
        ],
        specialty: .ent)

    // MARK: - Obstructive sleep apnea

    static let obstructiveSleepApnea = ConditionGuide(
        id: "obstructive-sleep-apnea",
        name: "Obstructive sleep apnea (adults)",
        alsoCalled: "OSA, sleep apnea, obstructive sleep apnoea",
        symbol: "bed.double",
        summary: "The throat repeatedly narrows or closes during sleep, causing pauses in breathing, loud snoring, broken sleep and daytime sleepiness. Severity is measured by the number of breathing pauses per hour (the AHI): 5–14 is mild, 15–29 moderate and 30 or more severe.",
        naturalHistory: [
            "Sleep apnea usually doesn't go away on its own and often worsens with weight gain and age.",
            "Untreated moderate-to-severe sleep apnea is linked with sleepiness, car crashes, high blood pressure, and heart and stroke risk.",
            "Losing weight can greatly reduce sleep apnea, and sometimes resolve it.",
        ],
        whenSurgeryIsOffered: [
            "You can't use CPAP or an oral appliance despite real effort and help with mask fitting.",
            "Large tonsils or a clear blockage in the nose or throat that surgery can fix.",
            "Hypoglossal nerve stimulation is considered for moderate-to-severe sleep apnea when CPAP fails, if your body mass index and the pattern of throat collapse are suitable.",
        ],
        urgentSigns: [
            "Falling asleep while driving or nearly crashing — stop driving and see your doctor promptly.",
            "Chest pain, fainting or severe shortness of breath — call 911.",
            "Breathing trouble, heavy bleeding from the mouth or throat, or being very hard to wake after throat surgery or after taking opioid pain medicines — call 911.",
        ],
        improvementDefinition: "Breathing pauses reduced by at least half to fewer than 20 an hour (a common definition of 'success'), together with less daytime sleepiness, about 6–12 months after starting treatment. For CPAP and oral appliances this depends on using them most nights.",
        options: [
            TreatmentOption(
                id: "osa-weight", name: "Weight loss (diet, exercise or weight-loss medicines)", tier: .conservative,
                summary: "Losing weight reduces fat around the airway and can greatly lessen sleep apnea. Tirzepatide is approved for moderate-to-severe sleep apnea in adults with obesity.",
                whatHappens: ["A structured diet and activity program, often with a dietitian.", "Weight-loss medicines such as tirzepatide, given as a weekly injection.", "A repeat sleep study after losing weight to see whether other treatment is still needed."],
                anesthesia: "None", hospitalStay: "None", recovery: "Benefits build over 6–12 months.",
                bestFor: ["Anyone with sleep apnea who carries extra weight, alongside other treatments"],
                lessSuitableIf: ["People who aren't overweight, whose sleep apnea is mainly from jaw or throat shape"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 60), seriousComplications: PercentRange(0.5, 2), furtherTreatment: nil),
                keyFindings: [
                    "In the SURMOUNT-OSA trials, tirzepatide reduced breathing pauses by about 25 an hour (from about 50) at 1 year, compared with about 5 an hour with placebo (Malhotra 2024).",
                    "In the Sleep AHEAD study of people with type 2 diabetes, an intensive lifestyle program reduced sleep apnea severity more than education alone (Foster 2009).",
                ],
                sideEffects: [
                    SE.make("Nausea, vomiting, diarrhea or constipation (weight-loss medicines)", "Most common when starting or increasing the dose.", 20, 40, .moderate),
                    SE.make("Gallstones or inflamed pancreas (weight-loss medicines)", "Uncommon.", 0.5, 2, .serious),
                    SE.make("Weight comes back", "Common when the program or medicine is stopped.", 30, 60, .mild),
                ],
                evidence: .moderate,
                availability: "Diet and exercise programs are widely available. Tirzepatide is expensive; coverage for sleep apnea varies, and Medicare Part D may cover it for this use. Sleep surgeons may focus on surgical options.",
                sources: ["Malhotra A et al. N Engl J Med 2024;391:1193–205", "Foster GD et al. Arch Intern Med 2009;169:1619–26"]),

            TreatmentOption(
                id: "osa-cpap", name: "CPAP (continuous positive airway pressure)", tier: .conservative,
                summary: "A bedside machine blows gentle air pressure through a mask to hold the throat open during sleep. The most effective treatment when it's used most nights.",
                whatHappens: ["A mask over the nose, the nose and mouth, or small cushions in the nostrils.", "Pressure is usually set automatically by the machine.", "Follow-up to adjust the mask and pressure; it may take weeks to get used to."],
                anesthesia: "None", hospitalStay: "None", recovery: "Many people feel more alert within days to weeks.",
                bestFor: ["Moderate-to-severe sleep apnea, especially with daytime sleepiness", "Anyone who can use it most nights"],
                lessSuitableIf: ["People who can't tolerate a mask despite help with fit and different styles"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "CPAP almost eliminates breathing pauses when worn, and improves sleepiness, mood and quality of life (McEvoy 2016).",
                    "In the SAVE trial of 2,717 people with heart or blood-vessel disease, CPAP did not prevent heart attacks or strokes over about 4 years; average use was about 3.3 hours a night (McEvoy 2016).",
                    "About a third to a half of people stop using CPAP or use it less than 4 hours a night (approximate).",
                ],
                sideEffects: [
                    SE.make("Mask discomfort, air leaks or skin marks", "Usually fixed by trying a different mask.", 20, 50, .mild),
                    SE.make("Dry mouth, dry nose or congestion", "A heated humidifier often helps.", 20, 40, .mild),
                    SE.make("Feeling closed in (claustrophobia)", "Gradual practice or a smaller mask can help.", 5, 15, .mild),
                    SE.make("Bloating from swallowed air", "Sometimes improves with a lower pressure.", 5, 15, .mild),
                ],
                evidence: .strong,
                availability: "Widely available and covered by Medicare and insurers. Medicare requires you to use it at least 4 hours a night on 70% of nights in the first 3 months to keep coverage.",
                sources: ["McEvoy RD et al. N Engl J Med 2016;375:919–31", "Phillips CL et al. Am J Respir Crit Care Med 2013;187:879–87"]),

            TreatmentOption(
                id: "osa-oral-appliance", name: "Oral appliance (mandibular advancement device)", tier: .conservative,
                summary: "A custom mouthguard made by a dentist that holds the lower jaw slightly forward during sleep to keep the airway open.",
                whatHappens: ["A dentist with sleep training takes impressions and fits the device.", "It's adjusted forward gradually over a few weeks.", "A follow-up sleep study checks how well it works."],
                anesthesia: "None", hospitalStay: "None", recovery: "A few weeks to get used to it.",
                bestFor: ["Mild-to-moderate sleep apnea", "People who can't tolerate CPAP or travel often"],
                lessSuitableIf: ["Few or loose teeth, gum disease or jaw joint problems", "Very severe sleep apnea (it may not lower breathing pauses enough)"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "In a randomized crossover trial, CPAP lowered breathing pauses more, but people used oral appliances more each night, and health outcomes such as sleepiness and blood pressure were similar after 1 month (Phillips 2013).",
                ],
                sideEffects: [
                    SE.make("Jaw or tooth soreness in the morning", "Usually settles in the first weeks.", 20, 40, .mild),
                    SE.make("Drooling or dry mouth", "Common at first.", 10, 30, .mild),
                    SE.make("Gradual change in your bite", "Teeth and bite can shift over years of use.", 10, 30, .moderate),
                ],
                evidence: .moderate,
                availability: "Provided by dentists with sleep medicine training. Medicare and many medical insurers cover custom devices when prescribed by a doctor after a sleep study; dental plans often don't.",
                sources: ["Phillips CL et al. Am J Respir Crit Care Med 2013;187:879–87"]),

            TreatmentOption(
                id: "osa-positional", name: "Positional therapy", tier: .conservative,
                summary: "Devices or simple methods that keep you from sleeping on your back, for people whose sleep apnea happens mostly on their back.",
                whatHappens: ["A vibrating device worn on the chest or neck nudges you when you roll onto your back.", "Or a backpack-style pillow or tennis-ball shirt.", "A sleep study checks whether your apnea is mainly position-related."],
                anesthesia: "None", hospitalStay: "None", recovery: "None.",
                bestFor: ["Mild or moderate sleep apnea that happens mainly when lying on your back"],
                lessSuitableIf: ["Sleep apnea in all sleeping positions", "Shoulder or hip pain when sleeping on your side"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 60), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: [
                    "Positional therapy reduces breathing pauses in people with position-dependent sleep apnea, but many stop using it over time; evidence comes from small trials (approximate).",
                ],
                sideEffects: [
                    SE.make("Disturbed sleep or discomfort", "From the device or sleeping position.", 10, 30, .mild),
                    SE.make("Stopping use over time", "Long-term use is often low.", 30, 50, .mild),
                ],
                evidence: .limited,
                availability: "Simple methods cost little; vibration devices may not be covered by insurance.",
                sources: ["Phillips CL et al. Am J Respir Crit Care Med 2013;187:879–87"]),

            TreatmentOption(
                id: "osa-hgns", name: "Hypoglossal nerve stimulation", tier: .minimallyInvasive,
                summary: "An implanted device, like a pacemaker, gently stimulates the nerve that moves the tongue forward with each breath during sleep. You turn it on at bedtime with a remote.",
                whatHappens: ["First, a sleep endoscopy while sedated checks how your throat collapses.", "The device is implanted under the skin of the upper chest, with a lead to the nerve under the jaw (and with some devices a breathing sensor).", "It's switched on about a month later and adjusted over a few months."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Back to normal activities in about 1–2 weeks.",
                bestFor: ["Moderate-to-severe sleep apnea in people who can't use CPAP", "Body mass index under about 32–40 (limits vary by insurer)"],
                lessSuitableIf: ["Complete circular collapse of the throat on sleep endoscopy", "Severe obesity", "Need for frequent MRI scans (check device compatibility)"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(2, 6)),
                keyFindings: [
                    "In the STAR trial of 126 people who couldn't use CPAP, median breathing pauses fell from about 29 to 9 an hour at 1 year, and about 2 in 3 met the definition of success (Strollo 2014).",
                    "The STAR trial had no sham or control group and was funded by the manufacturer.",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Tongue soreness or a sore under the tongue", "From the tongue rubbing on teeth; usually settles with adjustment.", 10, 25, .mild),
                    SE.make("Discomfort from stimulation", "Usually improved by adjusting the settings.", 10, 30, .mild),
                    SE.make("Temporary tongue weakness", "Usually recovers within weeks.", 1, 5, .moderate),
                    SE.make("Infection or device problems needing more surgery", "Sometimes the device must be removed.", 1, 3, .serious),
                ],
                evidence: .limited,
                availability: "Offered by trained ENT sleep surgeons at a growing number of centers. Medicare and many insurers cover it if you meet criteria (CPAP failure, AHI and body mass index limits, suitable sleep endoscopy).",
                sources: ["Strollo PJ et al. N Engl J Med 2014;370:139–49"]),

            TreatmentOption(
                id: "osa-uppp", name: "Throat surgery (UPPP with tonsillectomy)", tier: .lessInvasive,
                summary: "Through the mouth, the surgeon removes the tonsils and trims and reshapes the soft palate and uvula to widen the airway at the back of the throat.",
                whatHappens: ["Done through the mouth, with no skin cuts.", "Tonsils are removed if present, and the soft palate is reshaped.", "Often 1 night in hospital for breathing monitoring."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 1 night", recovery: "Severe throat pain for 1–2 weeks; soft foods; 2 weeks off work.",
                bestFor: ["Large tonsils with blockage mainly at the palate", "People who can't use CPAP or an oral appliance"],
                lessSuitableIf: ["Blockage mainly at the tongue base", "Severe obesity", "Small tonsils (results are less good)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 65), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(10, 30)),
                keyFindings: [
                    "In the SKUP3 trial of 65 people with large or medium tonsils, UPPP with tonsillectomy reduced breathing pauses by about 60%, compared with about 10% in the group that waited (Browaldh 2013).",
                    "Across older studies, UPPP met the usual definition of success in about 4 in 10 people overall (Sher 1996).",
                    "In a large US veterans study, about 1.5 in 100 had a serious complication and about 2 in 1,000 died within 30 days (Kezirian 2004).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Severe throat pain", "For 1–2 weeks; makes eating and drinking hard.", 80, 100, .moderate),
                    SE.make("Bleeding after surgery", "Most often 5–10 days later; may need a return to the operating room.", 2, 5, .serious),
                    SE.make("Liquid coming up through the nose, or voice change", "Usually temporary; occasionally lasting.", 1, 10, .moderate),
                    SE.make("Breathing problems after surgery", "Swelling and pain medicines can worsen breathing early on; this is why you're monitored.", 1, 2, .serious),
                    SE.death(0.1, 0.3),
                ],
                evidence: .moderate,
                availability: "Offered by ENT surgeons and covered by Medicare and insurers, usually after CPAP has failed.",
                sources: ["Browaldh N et al. Thorax 2013;68:846–53", "Sher AE et al. Sleep 1996;19:156–77", "Kezirian EJ et al. Laryngoscope 2004;114:450–3"]),

            TreatmentOption(
                id: "osa-mma", name: "Maxillomandibular advancement (jaw surgery)", tier: .traditional,
                summary: "The upper and lower jaws are cut and moved forward about half an inch to an inch, and fixed with plates. This pulls the tongue and soft tissues forward and widens the whole airway.",
                whatHappens: ["Cuts are made inside the mouth, so there are usually no face scars.", "Both jaws are moved forward and held with small titanium plates and screws.", "Orthodontic work may be needed before or after."],
                anesthesia: "General anesthesia", hospitalStay: "Usually 1–3 nights", recovery: "Liquid then soft diet for about 6 weeks; swelling for weeks; 4–6 weeks off work.",
                bestFor: ["Moderate-to-severe sleep apnea when CPAP and other treatments have failed", "People with a small or set-back jaw"],
                lessSuitableIf: ["People not willing to accept a change in facial appearance", "Serious health problems that make long surgery risky"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(2, 10)),
                keyFindings: [
                    "In a review of 22 studies (627 people), about 86 in 100 met the definition of surgical success and about 43 in 100 had their sleep apnea essentially cured (fewer than 5 pauses an hour); major complications occurred in about 1 in 100 (Holty 2010).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Numbness of the lower lip and chin", "Very common at first; lasting numbness in a minority.", 10, 30, .moderate),
                    SE.make("Change in facial appearance or bite", "Usually mild; some people find it noticeable.", 10, 30, .moderate),
                    SE.make("Infection or problems with plates and screws", "May need antibiotics or removal of hardware.", 2, 5, .moderate),
                    SE.make("Jaw bones don't heal in position, or serious bleeding", "Rare; may need more surgery.", 0.5, 2, .serious),
                    SE.clots(0.1, 0.5),
                ],
                evidence: .limited,
                availability: "Offered by oral and maxillofacial surgeons and some sleep surgery centers; not available everywhere. Insurance coverage varies and often needs prior authorization.",
                sources: ["Holty JE et al. Sleep Med Rev 2010;14:287–97"]),
        ],
        comparisons: [
            ComparisonStudy(name: "SKUP3", compared: "UPPP with tonsillectomy vs waiting (65 people)",
                finding: "Breathing pauses fell by about 60% after surgery vs about 10% in the waiting group at 6 months.", citation: "Browaldh 2013, Thorax"),
            ComparisonStudy(name: "Phillips crossover trial", compared: "CPAP vs oral appliance (126 people)",
                finding: "CPAP lowered breathing pauses more, but better nightly use of oral appliances gave similar health outcomes at 1 month.", citation: "Phillips 2013, Am J Respir Crit Care Med"),
            ComparisonStudy(name: "SURMOUNT-OSA", compared: "Tirzepatide vs placebo (469 people with obesity)",
                finding: "Much larger reduction in breathing pauses with tirzepatide at 1 year.", citation: "Malhotra 2024, N Engl J Med"),
        ],
        questionsToAsk: [
            "Have I had help with different masks and settings so I can give CPAP a real try?",
            "Would an oral appliance, weight loss or positional therapy work for my type of sleep apnea?",
            "Where does my airway collapse, and has a sleep endoscopy been done?",
            "Am I a candidate for hypoglossal nerve stimulation, and what would my insurer require?",
            "How will we measure whether treatment worked — will I have a follow-up sleep study?",
        ],
        specialty: .ent)

    // MARK: - Thyroid nodules and low-risk thyroid cancer

    static let thyroidNodules = ConditionGuide(
        id: "thyroid-nodules-low-risk-cancer",
        name: "Thyroid nodules and low-risk thyroid cancer",
        alsoCalled: "Thyroid lump, goiter, benign thyroid nodule, papillary microcarcinoma, small papillary thyroid cancer",
        symbol: "cross.case",
        summary: "Lumps in the thyroid gland at the front of the neck. Most are harmless (benign) and are found by chance on scans. A small number are cancers, and most of those are slow-growing papillary cancers with an excellent outlook.",
        naturalHistory: [
            "Most benign nodules stay the same size or grow slowly. In an Italian study of nearly 1,000 people, about 1 in 6 nodules grew over 5 years and cancer was found in fewer than 1 in 100 (Durante 2015).",
            "Very small papillary cancers (1 cm or less, called microcarcinomas) are extremely common and often never cause harm. At Kuma Hospital in Japan, only a few in 100 grew meaningfully over 10 years under close watch, and none of the people died of thyroid cancer (Ito 2018).",
            "Low-risk papillary cancer has a survival rate close to that of people without cancer, whichever treatment is chosen.",
        ],
        whenSurgeryIsOffered: [
            "A biopsy that shows or strongly suggests cancer, especially larger than 1 cm, or with spread to lymph nodes.",
            "A benign nodule or goiter that causes pressure, trouble swallowing or breathing, or a visible lump that bothers you.",
            "A biopsy result that is uncertain (indeterminate), where removing half the thyroid is the way to find out.",
        ],
        urgentSigns: [
            "Trouble breathing or noisy breathing, or a rapidly growing neck lump — go to the emergency department.",
            "After thyroid surgery: neck swelling with trouble breathing — call 911. This can be bleeding pressing on the windpipe.",
            "After thyroid surgery: tingling around the mouth or in the fingers, or muscle cramps — call your surgical team now; this can be low calcium and may need urgent treatment.",
        ],
        improvementDefinition: "For benign nodules: relief of pressure or cosmetic symptoms, with the nodule shrinking by at least half, about 1 year after treatment. For low-risk cancer: alive and free of cancer spread needing further surgery, about 10 years after diagnosis.",
        options: [
            TreatmentOption(
                id: "thy-benign-surveillance", name: "Ultrasound monitoring of a benign nodule", tier: .conservative,
                summary: "For a nodule shown to be benign by biopsy, or low-risk on ultrasound, repeat ultrasound scans to check it isn't changing.",
                whatHappens: ["A repeat ultrasound after about 1–2 years, then less often if stable.", "A repeat biopsy only if the nodule grows a lot or looks different.", "Blood tests to check thyroid function."],
                anesthesia: "None", hospitalStay: "None", recovery: "None needed.",
                bestFor: ["Benign nodules that don't cause symptoms"],
                lessSuitableIf: ["Nodules causing pressure, swallowing trouble or cosmetic concern", "Suspicious ultrasound features or biopsy results"],
                outcomes: OptionOutcomes(improvement: nil, seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In a study of 992 people with benign-appearing nodules followed for 5 years, about 15 in 100 nodules grew, most stayed the same or shrank, and thyroid cancer was found in about 3 in 1,000 nodules (Durante 2015).",
                ],
                sideEffects: [
                    SE.make("Nodule grows and causes symptoms", "May lead to treatment later.", 5, 15, .mild),
                    SE.make("A cancer is missed or found later", "Rare when biopsy and ultrasound are both reassuring.", 0.3, 3, .moderate),
                    SE.make("Worry about having a lump", "Many people find a clear follow-up plan reassuring.", 10, 30, .mild),
                ],
                evidence: .moderate,
                availability: "Available everywhere and covered by Medicare and insurers.",
                sources: ["Durante C et al. JAMA 2015;313:926–35", "Haugen BR et al. Thyroid 2016;26:1–133"]),

            TreatmentOption(
                id: "thy-active-surveillance", name: "Active surveillance of low-risk papillary microcarcinoma", tier: .conservative,
                summary: "For a papillary cancer 1 cm or smaller that isn't near the windpipe or voice nerve and hasn't spread, regular ultrasound scans instead of immediate surgery. Surgery is offered if it grows or spreads.",
                whatHappens: ["An ultrasound every 6–12 months at first, then yearly if stable.", "Surgery is recommended if the cancer grows by about 3 mm or more or spreads to lymph nodes.", "You can choose surgery at any time."],
                anesthesia: "None", hospitalStay: "None", recovery: "None needed.",
                bestFor: ["Low-risk papillary cancers 1 cm or smaller with no spread", "Older adults, in whom these cancers grow least often"],
                lessSuitableIf: ["Cancers next to the windpipe or the voice nerve, or with spread to lymph nodes", "Younger people (under about 40), whose cancers grow more often — though surveillance can still be reasonable", "People who would find living with a known cancer too stressful"],
                outcomes: OptionOutcomes(improvement: PercentRange(97, 99.9), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In Kuma Hospital's studies of over 1,000 people, only a small minority of microcarcinomas grew or spread over 10 years; those that did were treated successfully with surgery, and no one died of thyroid cancer (Ito 2018).",
                    "Compared with immediate surgery, active surveillance had far fewer unfavorable events: temporary voice nerve paralysis about 0.6 vs 4 in 100 and permanent low calcium about 1 in 1,000 vs 16 in 1,000 (Oda 2016).",
                    "A US study at Memorial Sloan Kettering found similar low growth rates (Tuttle 2017).",
                ],
                sideEffects: [
                    SE.make("Cancer grows and needs surgery later", "About 3 mm or more; surgery is still usually successful.", 3, 10, .moderate),
                    SE.make("Spread to lymph nodes found during follow-up", "Treated with surgery.", 0.5, 4, .moderate),
                    SE.make("Anxiety about living with a cancer", "Most people's anxiety lessens over time, but for some it doesn't.", 10, 30, .mild),
                ],
                evidence: .moderate,
                availability: "Recognized as an option in American Thyroid Association guidelines, but not offered by every endocrinologist or surgeon. Ultrasound follow-up is covered by Medicare and insurers. A surgeon may not mention it because surgery has long been the standard.",
                sources: ["Ito Y et al. Eur J Surg Oncol 2018;44:307–15", "Oda H et al. Thyroid 2016;26:150–5", "Tuttle RM et al. JAMA Otolaryngol Head Neck Surg 2017;143:1015–20", "Haugen BR et al. Thyroid 2016;26:1–133"]),

            TreatmentOption(
                id: "thy-rfa", name: "Radiofrequency ablation of a benign nodule", tier: .interventional,
                summary: "A thin needle is guided into the nodule with ultrasound and heats it from the inside. The nodule shrinks gradually over months. Used for benign nodules that cause symptoms.",
                whatHappens: ["Done in a clinic or procedure room with ultrasound guidance.", "Numbing medicine in the skin and around the thyroid.", "Takes about 15–60 minutes; you go home the same day."],
                anesthesia: "Local anesthetic, sometimes light sedation", hospitalStay: "Outpatient (home the same day)", recovery: "Usual activities the next day.",
                bestFor: ["Benign nodules (confirmed by two biopsies or one biopsy with reassuring ultrasound) causing pressure or cosmetic concern", "People who want to keep their thyroid and avoid thyroid hormone tablets"],
                lessSuitableIf: ["Suspicious or cancerous nodules (outside research or special situations)", "Very large goiters extending into the chest"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 90), seriousComplications: PercentRange(0.5, 2), furtherTreatment: PercentRange(5, 20)),
                keyFindings: [
                    "Benign nodules usually shrink by about half to four-fifths of their volume within 1 year after ablation, with improvement in symptoms (Papini 2020; Kim 2018).",
                    "Large nodules may need more than one session (approximate).",
                ],
                sideEffects: [
                    SE.make("Neck pain or discomfort", "During the procedure and for a day or two.", 10, 30, .mild),
                    SE.make("Bruising or bleeding around the thyroid", "Usually settles with pressure.", 1, 3, .mild),
                    SE.make("Hoarse voice from heat near the voice nerve", "Usually temporary, recovering over weeks to months.", 0.5, 2, .serious),
                    SE.make("Nodule regrows", "May need another treatment.", 5, 20, .moderate),
                    SE.make("Underactive thyroid", "Uncommon.", 0.1, 1, .moderate),
                ],
                evidence: .limited,
                availability: "Offered by a growing number of US endocrinologists, radiologists and surgeons, but still not widely available. Insurance coverage is inconsistent and it may be self-pay.",
                sources: ["Papini E et al. Eur Thyroid J 2020;9:172–85", "Kim JH et al. Korean J Radiol 2018;19:632–55"]),

            TreatmentOption(
                id: "thy-lobectomy", name: "Thyroid lobectomy (removing half the thyroid)", tier: .lessInvasive,
                summary: "Removing the half of the thyroid that contains the nodule or cancer, through an incision in the lower neck. The other half usually keeps making enough thyroid hormone.",
                whatHappens: ["An incision of about 1.5–2.5 inches in a natural neck crease.", "One lobe is removed while protecting the voice nerve and the parathyroid glands, which control calcium.", "Many people go home the same day."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Back to most activities within 1–2 weeks.",
                bestFor: ["Low-risk papillary cancers 1–4 cm without spread", "Indeterminate biopsy results", "Benign nodules on one side causing symptoms"],
                lessSuitableIf: ["Cancer in both lobes, spread to lymph nodes or beyond the thyroid", "Large goiters affecting both sides"],
                outcomes: OptionOutcomes(improvement: PercentRange(90, 98), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In 61,775 people with papillary cancers 1–4 cm in the US National Cancer Database, survival was similar after lobectomy and total thyroidectomy (Adam 2014).",
                    "American Thyroid Association guidelines allow lobectomy for low-risk cancers 1–4 cm (Haugen 2016).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Temporary hoarse or weak voice", "Recovers over weeks to months.", 2, 5, .moderate),
                    SE.make("Permanent voice change from voice nerve injury", "One vocal cord may not move well; can be improved with voice therapy or procedures.", 0.5, 1, .serious),
                    SE.make("Needing thyroid hormone tablets", "When the remaining half doesn't make enough.", 15, 35, .mild),
                    SE.make("Second operation to remove the other half (completion thyroidectomy)", "If the final pathology shows higher-risk cancer.", 10, 20, .moderate),
                    SE.make("Bleeding in the neck", "Rare but can press on the windpipe; needs an urgent return to the operating room.", 0.5, 1, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available from endocrine surgeons and ENT (head and neck) surgeons and covered by Medicare and insurers. Results are best with surgeons who do many thyroid operations.",
                sources: ["Adam MA et al. Ann Surg 2014;260:601–5", "Haugen BR et al. Thyroid 2016;26:1–133"]),

            TreatmentOption(
                id: "thy-total", name: "Total thyroidectomy", tier: .traditional,
                summary: "Removing the whole thyroid gland through an incision in the lower neck. You need thyroid hormone tablets for life afterward.",
                whatHappens: ["An incision of about 2–3 inches in a natural neck crease.", "Both lobes are removed while protecting both voice nerves and the parathyroid glands.", "Lymph nodes may be removed if cancer has spread.", "Calcium levels are checked after surgery."],
                anesthesia: "General anesthesia", hospitalStay: "Same day to 2 nights", recovery: "Back to most activities within 1–2 weeks.",
                bestFor: ["Cancers larger than 4 cm, or with spread to lymph nodes or beyond the thyroid", "Large goiters affecting both sides", "When radioactive iodine treatment is planned"],
                lessSuitableIf: ["Low-risk cancers or benign nodules on one side, where lobectomy may be enough"],
                outcomes: OptionOutcomes(improvement: PercentRange(90, 98), seriousComplications: PercentRange(2, 6), furtherTreatment: PercentRange(2, 10)),
                keyFindings: [
                    "In a review of 115 studies, temporary low calcium after thyroidectomy occurred in about 27 in 100 people, and permanent low calcium (hypoparathyroidism) in about 1 in 100, with a range of 0–3 in 100 (Edafe 2014).",
                    "For low-risk cancers 1–4 cm, survival was no better after total thyroidectomy than after lobectomy (Adam 2014).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Lifelong thyroid hormone tablets", "Everyone needs them; doses are adjusted with blood tests.", 100, 100, .mild),
                    SE.make("Temporary low calcium", "Tingling or cramps; treated with calcium and vitamin D tablets for weeks.", 15, 30, .moderate),
                    SE.make("Permanent low calcium (hypoparathyroidism)", "Needs lifelong calcium and vitamin D medicines and blood tests.", 1, 3, .serious),
                    SE.make("Temporary hoarse or weak voice", "Recovers over weeks to months.", 3, 8, .moderate),
                    SE.make("Permanent voice change from voice nerve injury", "Rarely, injury to both nerves affects breathing and needs urgent treatment.", 0.5, 2, .serious),
                    SE.make("Bleeding in the neck", "Rare but can press on the windpipe; needs an urgent return to the operating room.", 0.5, 2, .serious),
                ],
                evidence: .moderate,
                availability: "Widely available from endocrine surgeons and ENT (head and neck) surgeons and covered by Medicare and insurers. Complication rates are lower with high-volume thyroid surgeons — ask how many they do each year.",
                sources: ["Edafe O et al. Br J Surg 2014;101:307–20", "Adam MA et al. Ann Surg 2014;260:601–5", "Haugen BR et al. Thyroid 2016;26:1–133"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Kuma Hospital surveillance vs surgery", compared: "Active surveillance (1,179 people) vs immediate surgery (974 people) for low-risk papillary microcarcinoma — not randomized",
                finding: "Similar excellent cancer outcomes with no deaths from thyroid cancer; voice nerve palsy, low calcium and lifelong thyroid hormone were much more common after immediate surgery.", citation: "Oda 2016, Thyroid"),
            ComparisonStudy(name: "National Cancer Database analysis", compared: "Lobectomy vs total thyroidectomy for papillary cancers 1–4 cm (61,775 people, not randomized)",
                finding: "No difference in overall survival.", citation: "Adam 2014, Ann Surg"),
        ],
        questionsToAsk: [
            "Is this nodule benign, uncertain or cancer — and how sure are we?",
            "If it's a small, low-risk cancer, is active surveillance an option for me?",
            "Would removing only half the thyroid be enough? What are the chances I'd need a second operation or thyroid hormone tablets?",
            "For a benign nodule causing symptoms, is radiofrequency ablation available, and would my insurance cover it?",
            "How many thyroid operations do you do each year, and what are your rates of voice nerve injury and permanent low calcium?",
        ],
        specialty: .ent)
}
