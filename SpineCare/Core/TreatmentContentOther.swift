import Foundation

// DRAFT CONTENT — not yet clinically reviewed. See the header of TreatmentOptions.swift.
// Percentages are approximate ranges from the cited sources and must be verified before release.

extension TreatmentGuides {
    static let otherRegions: [ConditionGuide] = [compressionFracture, cervicalRadiculopathy, cervicalMyelopathy, sacroiliac]

    // MARK: - Osteoporotic vertebral compression fracture

    static let compressionFracture = ConditionGuide(
        id: "compression-fracture",
        name: "Osteoporotic vertebral compression fracture",
        alsoCalled: "Spinal compression fracture, collapsed vertebra",
        symbol: "square.split.bottomrightquarter",
        summary: "A vertebra weakened by osteoporosis collapses, sometimes after a minor fall or lift, or with no clear cause. It causes sudden back pain that is often worse when standing or moving.",
        naturalHistory: [
            "Most fractures heal on their own in 6–12 weeks, and pain improves a lot for most people within about 3 months.",
            "Having one fracture raises the chance of another, which is why osteoporosis treatment matters whatever else you choose.",
        ],
        whenSurgeryIsOffered: [
            "Cement procedures (vertebroplasty or kyphoplasty) are sometimes offered for severe pain that isn't improving after a few weeks.",
            "Open surgery is rarely needed — mainly when bone fragments press on the nerves or spinal cord, or the spine is unstable.",
        ],
        urgentSigns: ["New leg weakness, numbness, or bladder or bowel problems — go to the emergency department now.", "A fracture with fever, weight loss or a history of cancer needs prompt assessment."],
        improvementDefinition: "Meaningful pain relief at about 1–3 months.",
        options: [
            TreatmentOption(
                id: "vcf-conservative", name: "Pain relief, activity and time", tier: .conservative,
                summary: "Pain medicines, short rest followed by gentle walking, sometimes a brace, and physical therapy as pain settles.",
                whatHappens: ["Acetaminophen and, if safe, short courses of anti-inflammatories; sometimes calcitonin for a few weeks.", "Gentle walking as soon as you can; avoid long bed rest.", "Physical therapy for posture, balance and back-extensor strength."],
                anesthesia: "None", hospitalStay: "None, unless pain is unmanageable at home", recovery: "Most improvement within 6–12 weeks.",
                bestFor: ["Almost everyone, at least initially"],
                lessSuitableIf: ["Nerve symptoms or an unstable fracture"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0, 1), furtherTreatment: PercentRange(10, 20)),
                keyFindings: ["In sham-controlled trials of vertebroplasty, the sham groups (who had no cement) improved substantially over 1–3 months — showing how much recovery happens with time (Buchbinder 2009; Firanescu 2018)."],
                sideEffects: [SE.nsaidStomach, SE.nsaidBleed, SE.opioidRisks, SE.make("Weakness, bone loss or clots from long bed rest", "Why getting moving early matters.", 5, 15, .moderate)],
                evidence: .moderate,
                availability: "Always available.",
                sources: ["Buchbinder R et al. N Engl J Med 2009;361:557–68", "Firanescu CE et al. BMJ 2018;361:k1551"]),

            TreatmentOption(
                id: "osteoporosis-treatment", name: "Osteoporosis treatment", tier: .conservative,
                summary: "Medicines that strengthen bone to prevent the next fracture — the most important long-term treatment after any osteoporotic fracture.",
                whatHappens: ["A bone density scan and blood tests.", "Medicines such as alendronate, zoledronic acid, denosumab, teriparatide or romosozumab, plus calcium, vitamin D and exercise."],
                anesthesia: "None", hospitalStay: "None", recovery: "—",
                bestFor: ["Everyone with an osteoporotic vertebral fracture"],
                lessSuitableIf: [],
                outcomes: OptionOutcomes(improvement: nil, seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: nil),
                keyFindings: ["Osteoporosis medicines lower the chance of new vertebral fractures by about 40–70% (Qaseem 2023 guideline). Many people never get this treatment after a fracture — ask about it."],
                sideEffects: [SE.make("Heartburn or stomach upset (tablets)", "With alendronate or risedronate.", 5, 15, .mild), SE.make("Flu-like symptoms after first infusion", "With zoledronic acid; lasts 1–3 days.", 10, 30, .mild), SE.make("Jaw bone problems (osteonecrosis)", "Very rare in people taking osteoporosis doses.", 0.001, 0.01, .serious), SE.make("Unusual thigh bone fracture", "Rare, mainly after many years of treatment.", 0.01, 0.1, .serious)],
                evidence: .strong,
                availability: "Widely available; usually prescribed by a primary care doctor, endocrinologist or rheumatologist.",
                sources: ["Qaseem A et al. Ann Intern Med 2023;176:224–38"]),

            TreatmentOption(
                id: "vertebroplasty", name: "Vertebroplasty", tier: .interventional,
                summary: "Bone cement is injected into the broken vertebra through a needle to stabilize it.",
                whatHappens: ["Done face down under X-ray, through one or two needles.", "Takes about an hour; often home the same day."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Same day or overnight", recovery: "Many people walk within hours.",
                bestFor: ["Severe pain from a recent fracture (under about 6 weeks old) in people in hospital because of pain — where the evidence is most positive"],
                lessSuitableIf: ["Older, healed fractures", "Fractures with bone pushed into the spinal canal", "Infection"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 70), seriousComplications: PercentRange(0.5, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "Four sham-controlled trials found vertebroplasty was no better than a sham procedure for most people (Buchbinder 2009; Kallmes 2009; Firanescu 2018; Cochrane 2018 review).",
                    "One trial in people with fractures under 6 weeks old found more pain relief than sham at 2 weeks: 44 in 100 vs 21 in 100 had low pain (Clark 2016).",
                ],
                sideEffects: [SE.make("Cement leaks outside the bone (seen on scans)", "Usually causes no symptoms.", 20, 70, .mild), SE.make("Cement leak pressing on a nerve or spinal cord", "Can need surgery.", 0.1, 1, .serious), SE.make("Cement travels to the lungs", "Usually seen only on scans; rarely causes symptoms.", 1, 10, .moderate), SE.make("New fracture in a nearby vertebra", "Common after osteoporotic fractures anyway; unclear whether cement raises the risk.", 10, 20, .moderate), SE.injectionInfection],
                evidence: .strong,
                availability: "Widely available from interventional radiologists and spine specialists. Medicare covers it in many regions with criteria.",
                sources: ["Buchbinder R et al. Cochrane 2018;CD006349", "Kallmes DF et al. N Engl J Med 2009;361:569–79", "Clark W et al. Lancet 2016;388:1408–16", "Firanescu CE et al. BMJ 2018;361:k1551"]),

            TreatmentOption(
                id: "kyphoplasty", name: "Balloon kyphoplasty", tier: .interventional,
                summary: "A balloon is inflated inside the broken vertebra to make a space, then filled with cement.",
                whatHappens: ["Similar to vertebroplasty, with a balloon step before the cement."],
                anesthesia: "Sedation or general anesthesia", hospitalStay: "Same day or overnight", recovery: "Many people walk within hours.",
                bestFor: ["Similar to vertebroplasty"],
                lessSuitableIf: ["Similar to vertebroplasty"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(0.5, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the FREE trial (300 people), kyphoplasty improved quality of life more than non-surgical care at 1 month; the difference shrank by 1–2 years. There was no sham group and the trial was company-funded (Wardlaw 2009; Boonen 2011).",
                    "Unlike vertebroplasty, kyphoplasty has little or no sham-controlled evidence, so how much of the benefit comes from the procedure itself is uncertain.",
                ],
                sideEffects: [SE.make("Cement leaks outside the bone (seen on scans)", "Usually causes no symptoms; less common than with vertebroplasty.", 10, 30, .mild), SE.make("Cement leak pressing on a nerve or spinal cord", "Can need surgery.", 0.1, 1, .serious), SE.make("New fracture in a nearby vertebra", "Common after osteoporotic fractures anyway; unclear whether the procedure raises the risk.", 10, 20, .moderate), SE.anesthesia],
                evidence: .limited,
                availability: "Widely available. Costs more than vertebroplasty.",
                sources: ["Wardlaw D et al. Lancet 2009;373:1016–24", "Boonen S et al. J Bone Miner Res 2011;26:1627–37"]),

            TreatmentOption(
                id: "vcf-open-surgery", name: "Open decompression and fusion", tier: .traditional,
                summary: "Surgery to remove bone pressing on the nerves and hold the spine with screws and rods. Rarely needed.",
                whatHappens: ["Major surgery, often over several levels because osteoporotic bone holds screws poorly."],
                anesthesia: "General anesthesia", hospitalStay: "3–7 days", recovery: "Several months.",
                bestFor: ["Fractures causing nerve or spinal cord compression, or an unstable spine"],
                lessSuitableIf: ["Pain alone without instability or nerve problems"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(10, 25), furtherTreatment: PercentRange(10, 30)),
                keyFindings: ["Evidence is from case series; complication rates are high in older people with osteoporosis."],
                sideEffects: [SE.anesthesia, SE.make("Screws loosen in weak bone", "Osteoporotic bone holds screws poorly; may need more surgery.", 5, 20, .serious), SE.delirium(10, 25), SE.woundInfection(2, 6), SE.clots(1, 3), SE.death(1, 3)],
                evidence: .veryLimited,
                availability: "Spine surgeons at larger centers.",
                sources: ["Prost S et al. Orthop Traumatol Surg Res 2021;107:102779"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Cochrane review of vertebroplasty", compared: "Vertebroplasty vs sham procedure (several trials)",
                finding: "High- to moderate-quality evidence of no important benefit over sham for pain, function or quality of life.", citation: "Buchbinder 2018, Cochrane"),
            ComparisonStudy(name: "VAPOUR", compared: "Vertebroplasty vs sham for fractures under 6 weeks old (120 people)",
                finding: "44 in 100 vs 21 in 100 had low pain at 2 weeks.", citation: "Clark 2016, Lancet"),
            ComparisonStudy(name: "FREE", compared: "Kyphoplasty vs non-surgical care (300 people, no sham)",
                finding: "Better quality of life at 1 month, with the difference narrowing by 2 years.", citation: "Wardlaw 2009, Lancet"),
        ],
        questionsToAsk: [
            "How old is my fracture? Is it still healing (does it show swelling on MRI)?",
            "What do the sham-controlled trials mean for someone like me?",
            "Who will treat my osteoporosis to prevent the next fracture?",
        ])

    // MARK: - Cervical radiculopathy

    static let cervicalRadiculopathy = ConditionGuide(
        id: "cervical-radiculopathy",
        name: "Cervical radiculopathy (pinched nerve in the neck)",
        alsoCalled: "Cervical disc herniation, cervical foraminal stenosis, pinched nerve",
        symbol: "person.bust",
        summary: "A disc or bone spur in the neck presses on a nerve, causing pain, numbness, tingling or weakness in the shoulder, arm or hand.",
        naturalHistory: [
            "Most people — around 75 to 90 in 100 — improve substantially without surgery, usually within weeks to a few months.",
            "In trials, surgery relieved symptoms faster, but at 1 year non-surgical care often gave similar results.",
        ],
        whenSurgeryIsOffered: ["Severe arm pain not improving after 6–12 weeks.", "Significant or worsening weakness."],
        urgentSigns: ["Clumsy hands, trouble walking or balance problems, or symptoms in both arms or legs — these can mean spinal cord compression (myelopathy) and need prompt assessment."],
        improvementDefinition: "Meaningful improvement in arm pain and function at about 1–2 years.",
        options: [
            TreatmentOption(
                id: "cr-conservative", name: "Time, medicines and physical therapy", tier: .conservative,
                summary: "Pain relief, staying active, and physical therapy with neck and shoulder exercises, sometimes with a short period in a soft collar.",
                whatHappens: ["Anti-inflammatories if safe, sometimes a short course of oral steroids.", "Physical therapy: neck strengthening, posture, nerve glides."],
                anesthesia: "None", hospitalStay: "None", recovery: "Weeks to a few months.",
                bestFor: ["Most people, especially without significant weakness"],
                lessSuitableIf: ["Signs of spinal cord compression", "Significant or worsening weakness"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 85), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(10, 30)),
                keyFindings: [
                    "In a Swedish trial of surgery vs physical therapy vs a collar, surgery helped faster but at 1 year results were similar across groups (Persson 1997).",
                    "In a later trial, surgery plus physical therapy improved neck pain and overall outcome more than physical therapy alone at 2 years, though both groups improved (Engquist 2013).",
                ],
                sideEffects: [SE.exerciseSoreness, SE.nsaidStomach, SE.nsaidBleed, SE.gabapentinoid],
                evidence: .moderate,
                availability: "Widely available.",
                sources: ["Persson LC et al. Spine 1997;22:751–8", "Engquist M et al. Spine 2013;38:1715–22"]),

            TreatmentOption(
                id: "cr-epidural", name: "Cervical epidural steroid injection", tier: .interventional,
                summary: "Steroid injected into the space around the nerves in the neck, usually between the vertebrae from the back (interlaminar), under X-ray guidance.",
                whatHappens: ["Face down; a needle is guided into the epidural space.", "Home the same day."],
                anesthesia: "Local anesthetic", hospitalStay: "Outpatient", recovery: "Next day.",
                bestFor: ["Severe arm pain while waiting for natural recovery"],
                lessSuitableIf: ["Blood thinners that can't be paused", "Severe narrowing at the injection level"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: ["In a randomized trial, epidural steroid, physical therapy and the two combined gave similar results at 1–3 months (Cohen 2014)."],
                sideEffects: [SE.injectionFlare, SE.steroidFlush, SE.steroidSugar, SE.injectionHeadache, SE.injectionInfection, SE.injectionParalysis],
                evidence: .limited,
                availability: "Widely available. FDA warns about rare but serious neurological injury; many specialists use only the interlaminar route in the neck.",
                sources: ["Cohen SP et al. Anesthesiology 2014;121:1045–55", "FDA Drug Safety Communication 2014: epidural corticosteroid injections"]),

            TreatmentOption(
                id: "posterior-foraminotomy", name: "Posterior foraminotomy (open or minimally invasive)", tier: .minimallyInvasive,
                summary: "Through a small incision at the back of the neck, bone and disc pressing on the nerve are removed without a fusion, so the neck keeps its movement.",
                whatHappens: ["Done through a tube or a small open incision.", "No implant is usually needed."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Desk work 1–3 weeks.",
                bestFor: ["Nerve compression on one side, from a soft disc or bone spur at the side of the canal"],
                lessSuitableIf: ["A central disc herniation pressing on the spinal cord", "Neck instability or a forward-curved neck (kyphosis)"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 10)),
                keyFindings: ["In the Dutch FACET trial (265 people), posterior foraminotomy was as good as anterior discectomy and fusion for arm pain at 1 year (Broekema 2020)."],
                sideEffects: [SE.anesthesia, SE.make("Neck muscle pain", "More than after front-of-neck surgery; usually settles.", 10, 30, .mild), SE.woundInfection(0.5, 2), SE.duralTear(0.5, 2), SE.nerveInjury(0.5, 2)],
                evidence: .moderate,
                availability: "Offered by many spine surgeons, though fusion through the front is more commonly recommended in the US.",
                sources: ["Broekema AEH et al. BMJ 2020;369:m2116"]),

            TreatmentOption(
                id: "cervical-disc-replacement", name: "Cervical disc replacement", tier: .lessInvasive,
                summary: "Through the front of the neck, the disc is removed and replaced with an artificial disc that keeps movement at that level instead of fusing it.",
                whatHappens: ["An incision at the front of the neck; the windpipe and gullet are moved aside.", "The disc and spurs are removed and the implant is placed."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Desk work 1–3 weeks.",
                bestFor: ["One or two levels with arm symptoms, good bone quality and little joint arthritis"],
                lessSuitableIf: ["Osteoporosis, severe arthritis of the facet joints, or instability"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 90), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(4, 10)),
                keyFindings: ["In FDA trials followed for 7–10 years, disc replacement was at least as good as fusion, with fewer repeat operations at the same or next level (Gornet 2019; Burkus 2014)."],
                sideEffects: [SE.anesthesia, SE.make("Trouble swallowing", "Common in the first weeks; usually goes away.", 10, 40, .mild), SE.make("Hoarse voice", "Usually temporary.", 1, 5, .moderate), SE.make("Bone forms around the implant (heterotopic ossification)", "Can reduce movement at that level.", 10, 40, .mild), SE.make("Implant problems needing revision", "The implant moves, wears or fails; revision surgery is more complex.", 1, 3, .serious), SE.make("Bleeding in the neck", "Rare but can affect breathing.", 0.2, 1, .serious)],
                evidence: .strong,
                availability: "FDA-approved and widely available; covered by most insurers for one- or two-level disease.",
                sources: ["Gornet MF et al. J Neurosurg Spine 2019;31:508–18", "Burkus JK et al. J Neurosurg Spine 2014;21:516–28"]),

            TreatmentOption(
                id: "acdf", name: "Anterior cervical discectomy and fusion (ACDF)", tier: .traditional,
                summary: "The standard neck operation. Through the front of the neck, the disc and bone spurs are removed and the level is fused with a spacer, often with a small plate and screws.",
                whatHappens: ["A 3–5 cm incision at the front of the neck.", "Disc removed, a spacer (bone or cage) inserted, often with a plate."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Desk work 2–4 weeks; fusion takes 3–12 months.",
                bestFor: ["Arm pain or weakness from a disc or spur, especially pressing centrally", "Multiple levels or a forward-curved neck"],
                lessSuitableIf: ["Mainly neck pain without arm symptoms"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 92), seriousComplications: PercentRange(1, 4), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "Surgery relieves arm pain faster than non-surgical care; at 1 year differences are smaller (Persson 1997; Engquist 2013).",
                    "Repeat surgery for wear at the next level is about 1–3 in 100 people per year, so about 1 in 4 over 10 years in older studies (Hilibrand 1999).",
                ],
                sideEffects: [SE.anesthesia, SE.make("Trouble swallowing", "Very common early; lasts more than a year in a few people.", 10, 50, .mild), SE.make("Trouble swallowing lasting more than a year", "More likely after multi-level surgery.", 3, 6, .moderate), SE.make("Hoarse voice", "From stretching of the voice-box nerve; usually temporary.", 1, 5, .moderate), SE.make("Shoulder weakness (C5 palsy)", "Usually recovers over months.", 1, 3, .moderate), SE.make("Bones don't fuse (nonunion)", "Higher with more levels and smoking.", 2, 10, .moderate), SE.make("Bleeding in the neck", "Rare but can affect breathing; may need urgent surgery.", 0.2, 1, .serious), SE.make("Injury to the gullet (esophagus)", "Very rare.", 0.02, 0.2, .serious), SE.make("Spinal cord injury", "Very rare.", 0.05, 0.5, .serious)],
                evidence: .strong,
                availability: "Widely available; the most common neck operation in the US.",
                sources: ["Hilibrand AS et al. J Bone Joint Surg Am 1999;81:519–28", "Fountas KN et al. Spine 2007;32:2310–7", "Engquist M et al. Spine 2013;38:1715–22"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Swedish neck trial", compared: "Surgery vs physical therapy vs collar (81 people)",
                finding: "Surgery was faster at 4 months; at 1 year the three groups were similar.", citation: "Persson 1997, Spine"),
            ComparisonStudy(name: "FACET trial", compared: "Posterior foraminotomy vs ACDF (265 people)",
                finding: "Foraminotomy was as good as ACDF for arm pain at 1 year, without a fusion.", citation: "Broekema 2020, BMJ"),
            ComparisonStudy(name: "FDA disc replacement trials", compared: "Cervical disc replacement vs ACDF",
                finding: "Disc replacement at least as good over 7–10 years, with fewer repeat operations.", citation: "Gornet 2019; Burkus 2014, J Neurosurg Spine"),
        ],
        questionsToAsk: [
            "Am I a candidate for a posterior foraminotomy or disc replacement instead of a fusion?",
            "How long would it be reasonable to keep trying non-surgical care?",
            "Is my spinal cord affected, or only the nerve?",
        ])

    // MARK: - Cervical myelopathy

    static let cervicalMyelopathy = ConditionGuide(
        id: "cervical-myelopathy",
        name: "Degenerative cervical myelopathy",
        alsoCalled: "Cervical spondylotic myelopathy, spinal cord compression in the neck",
        symbol: "brain.head.profile",
        summary: "Narrowing in the neck presses on the spinal cord itself. It can cause clumsy hands, trouble with buttons or handwriting, balance and walking problems, and sometimes bladder changes.",
        naturalHistory: [
            "This condition is different from most others here: nerve damage from cord compression often does not recover fully once it has happened.",
            "Without surgery, about 20 to 60 in 100 people get worse over 3–6 years. It's hard to predict who will.",
            "Some people with mild myelopathy stay stable for years with close monitoring.",
        ],
        whenSurgeryIsOffered: ["Guidelines recommend surgery for moderate or severe myelopathy.", "For mild myelopathy, surgery or a supervised trial of non-surgical care with close monitoring are both reasonable, with surgery if symptoms worsen."],
        urgentSigns: ["Rapidly worsening hand or walking problems, falls, or new bladder or bowel problems — seek urgent assessment.", "A fall or neck injury with new arm or leg symptoms — go to the emergency department."],
        improvementDefinition: "Stable or improved spinal cord function (mJOA score) at 1–2 years.",
        options: [
            TreatmentOption(
                id: "dcm-monitoring", name: "Supervised non-surgical care with close monitoring", tier: .conservative,
                summary: "For mild myelopathy only: regular checks of hand and walking function, physical therapy, and avoiding activities with a high risk of neck injury.",
                whatHappens: ["Regular appointments (for example every 3–6 months) and sometimes repeat MRI.", "Physical therapy for balance and strength.", "Avoid contact sports, high-risk activities and neck manipulation."],
                anesthesia: "None", hospitalStay: "None", recovery: "Ongoing monitoring.",
                bestFor: ["Mild myelopathy that is stable, especially in people with high surgical risk"],
                lessSuitableIf: ["Moderate or severe myelopathy", "Symptoms that are getting worse"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 80), seriousComplications: PercentRange(1, 5), furtherTreatment: PercentRange(20, 60)),
                keyFindings: ["A systematic review found 20–62% of people deteriorate within 3–6 years without surgery (Karadimas 2013). Guidelines support monitoring only for mild, stable cases (Fehlings 2017)."],
                sideEffects: [SE.make("Myelopathy gets worse", "May not fully recover even after later surgery.", 20, 60, .serious), SE.make("Spinal cord injury after a fall or neck injury", "The narrowed canal makes the cord more vulnerable.", 1, 5, .serious)],
                evidence: .limited,
                availability: "Available, but needs a clinician willing to monitor you closely.",
                sources: ["Karadimas SK et al. Spine 2013;38:S21–36", "Fehlings MG et al. Global Spine J 2017;7:70S–83S"]),

            TreatmentOption(
                id: "laminoplasty", name: "Laminoplasty", tier: .lessInvasive,
                summary: "From the back of the neck, the bony arches are hinged open like a door to widen the canal, without a fusion, so neck movement is largely kept.",
                whatHappens: ["An incision at the back of the neck.", "The laminae are cut on one side and hinged on the other, held open with small plates."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "Light activity 2–6 weeks; neck stiffness for some months.",
                bestFor: ["Cord compression at three or more levels with a normal neck curve"],
                lessSuitableIf: ["A forward-curved neck (kyphosis)", "Severe neck pain or instability"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(3, 8), furtherTreatment: PercentRange(2, 8)),
                keyFindings: ["Laminoplasty and laminectomy with fusion give similar improvement in cord function; laminoplasty is often cheaper with fewer complications (Fehlings 2017 review)."],
                sideEffects: [SE.anesthesia, SE.make("Neck pain and stiffness", "Common for the first months; usually improves.", 10, 30, .mild), SE.make("Shoulder weakness (C5 palsy)", "Usually recovers over months.", 3, 8, .moderate), SE.woundInfection(1, 3), SE.make("Spinal cord injury", "Rare.", 0.2, 1, .serious)],
                evidence: .moderate,
                availability: "Widely used in Japan and Asia; offered by many but not all US surgeons.",
                sources: ["Fehlings MG et al. Global Spine J 2017;7:70S–83S", "Ghogawala Z et al. JAMA 2021;325:942–51"]),

            TreatmentOption(
                id: "anterior-decompression", name: "Anterior decompression and fusion (ACDF or corpectomy)", tier: .traditional,
                summary: "From the front of the neck, the discs, spurs or part of the vertebra pressing on the cord are removed and the levels are fused.",
                whatHappens: ["An incision at the front of the neck.", "Discs (ACDF) or a vertebral body (corpectomy) removed, replaced with a spacer, plate and screws."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "Desk work 2–6 weeks; fusion 3–12 months.",
                bestFor: ["Compression at one to three levels, especially with a forward-curved neck"],
                lessSuitableIf: ["Many levels involved"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In the international AOSpine study of 479 people, surgery improved spinal cord function, disability and quality of life at 1–2 years across all severities (Fehlings 2013).",
                    "In the CSM-S trial (163 people), anterior surgery was not better than posterior surgery for physical function at 1 year (Ghogawala 2021).",
                ],
                sideEffects: [SE.anesthesia, SE.make("Trouble swallowing", "Very common early; lasts longer in a few people, especially after multi-level surgery.", 10, 50, .mild), SE.make("Hoarse voice", "From stretching of the voice-box nerve; usually temporary.", 1, 5, .moderate), SE.make("Shoulder weakness (C5 palsy)", "Usually recovers over months.", 2, 5, .moderate), SE.make("Bones don't fuse", "More likely with corpectomy, multiple levels and smoking.", 3, 10, .moderate), SE.make("Bleeding in the neck", "Can affect breathing.", 0.2, 1, .serious), SE.make("Spinal cord injury", "Rare.", 0.2, 1, .serious)],
                evidence: .moderate,
                availability: "Widely available.",
                sources: ["Fehlings MG et al. J Bone Joint Surg Am 2013;95:1651–8", "Ghogawala Z et al. JAMA 2021;325:942–51"]),

            TreatmentOption(
                id: "laminectomy-fusion", name: "Posterior laminectomy and fusion", tier: .traditional,
                summary: "From the back, the bony arches are removed to decompress the cord, and screws and rods fuse the levels to prevent a forward curve developing.",
                whatHappens: ["An incision at the back of the neck; laminae removed; screws and rods placed."],
                anesthesia: "General anesthesia", hospitalStay: "2–4 days", recovery: "Light activity 4–6 weeks; fusion 6–12 months.",
                bestFor: ["Compression at many levels, or when laminoplasty isn't suitable"],
                lessSuitableIf: ["One or two levels where front surgery is simpler"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(5, 12), furtherTreatment: PercentRange(5, 15)),
                keyFindings: ["Similar improvement in cord function to anterior surgery and laminoplasty in most studies (Ghogawala 2021; Fehlings 2017)."],
                sideEffects: [SE.anesthesia, SE.make("Neck pain and stiffness", "Movement at the fused levels is lost.", 20, 40, .mild), SE.make("Shoulder weakness (C5 palsy)", "Usually recovers over months.", 5, 12, .moderate), SE.woundInfection(2, 5), SE.make("Spinal cord injury", "Rare.", 0.2, 1, .serious), SE.clots(0.5, 2)],
                evidence: .moderate,
                availability: "Widely available.",
                sources: ["Ghogawala Z et al. JAMA 2021;325:942–51", "Fehlings MG et al. Global Spine J 2017;7:70S–83S"]),
        ],
        comparisons: [
            ComparisonStudy(name: "AOSpine CSM-North America and International", compared: "Surgery for mild, moderate and severe myelopathy (observational)",
                finding: "Surgery improved spinal cord function and quality of life at 1–2 years across all severities.", citation: "Fehlings 2013, J Bone Joint Surg Am"),
            ComparisonStudy(name: "CSM-S trial", compared: "Anterior vs posterior surgery (163 people)",
                finding: "No difference in physical function at 1 year; anterior surgery had more swallowing problems, posterior more wound and readmission issues.", citation: "Ghogawala 2021, JAMA"),
        ],
        questionsToAsk: [
            "How severe is my myelopathy (what is my mJOA score)?",
            "What are the risks of waiting for me specifically?",
            "Should the surgery be from the front or the back, and why?",
        ])

    // MARK: - Sacroiliac joint pain

    static let sacroiliac = ConditionGuide(
        id: "sacroiliac-joint",
        name: "Sacroiliac (SI) joint pain",
        alsoCalled: "SI joint dysfunction, sacroiliitis",
        symbol: "figure.cooldown",
        summary: "Pain from the joint between the base of the spine and the pelvis, usually felt low in the back or buttock on one side, sometimes into the thigh. It's more common after a lumbar fusion, pregnancy or a fall.",
        naturalHistory: [
            "Diagnosis relies on examination tests plus relief from a numbing injection into the joint, since scans are often normal.",
            "Many people improve with physical therapy and a pelvic belt.",
        ],
        whenSurgeryIsOffered: ["Pain for more than 6 months despite non-surgical care, with strong relief from diagnostic SI joint injections."],
        urgentSigns: ["Fever with buttock pain, or new weakness or numbness — get checked promptly."],
        improvementDefinition: "Meaningful pain reduction (for example at least 20 points on a 0–100 scale) at about 6 months.",
        options: [
            TreatmentOption(
                id: "si-conservative", name: "Physical therapy, pelvic belt and medicines", tier: .conservative,
                summary: "Exercises for the hips, pelvis and core, a supportive SI belt, and short-term pain relief.",
                whatHappens: ["6–12 weeks of physical therapy.", "A pelvic belt worn during activity.", "Anti-inflammatories if safe."],
                anesthesia: "None", hospitalStay: "None", recovery: "6–12 weeks.",
                bestFor: ["Everyone at first, especially after pregnancy"],
                lessSuitableIf: [],
                outcomes: OptionOutcomes(improvement: PercentRange(25, 50), seriousComplications: PercentRange(0, 0.5), furtherTreatment: nil),
                keyFindings: ["In the INSITE and iMIA trials, about 1 in 4 people in the non-surgical groups (which included physical therapy) met the success criteria at 6 months (Polly 2015; Dengler 2019)."],
                sideEffects: [SE.exerciseSoreness, SE.nsaidStomach, SE.nsaidBleed],
                evidence: .limited,
                availability: "Widely available.",
                sources: ["Polly DW et al. Neurosurgery 2015;77:674–91", "Dengler J et al. J Bone Joint Surg Am 2019;101:400–11"]),

            TreatmentOption(
                id: "si-injection", name: "SI joint steroid injection", tier: .interventional,
                summary: "Steroid and numbing medicine injected into the joint under X-ray guidance. Also used to confirm the SI joint is the source of pain.",
                whatHappens: ["Face down; a needle is guided into the joint. Home the same day."],
                anesthesia: "Local anesthetic", hospitalStay: "Outpatient", recovery: "Next day.",
                bestFor: ["Confirming the diagnosis and short-term relief"],
                lessSuitableIf: ["Poorly controlled diabetes"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 60), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(30, 60)),
                keyFindings: ["Relief often lasts weeks to a few months; high-quality evidence is limited (Kennedy 2015 review)."],
                sideEffects: [SE.injectionFlare, SE.steroidFlush, SE.steroidSugar, SE.make("Temporary leg numbness or weakness", "From numbing medicine spreading; wears off in hours.", 1, 5, .mild), SE.injectionInfection],
                evidence: .limited,
                availability: "Widely available.",
                sources: ["Kennedy DJ et al. Pain Med 2015;16:1500–18"]),

            TreatmentOption(
                id: "si-rfa", name: "Lateral branch radiofrequency ablation", tier: .interventional,
                summary: "Heat disables the small nerves that carry pain from the SI joint. Effects can last 6–12 months.",
                whatHappens: ["Several needles placed beside the base of the spine under X-ray; nerves heated."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Outpatient", recovery: "Soreness for 1–2 weeks.",
                bestFor: ["SI pain confirmed by numbing injections"],
                lessSuitableIf: [],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 55), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(30, 60)),
                keyFindings: [
                    "Small sham-controlled trials of cooled radiofrequency showed benefit at 3 months (Cohen 2008; Patel 2016).",
                    "In the MINT SI joint trial, adding ablation to exercise made no clinically important difference (Juch 2017).",
                ],
                sideEffects: [SE.make("Increased pain or numbness in the buttock", "For a few weeks.", 5, 15, .mild), SE.injectionInfection],
                evidence: .limited,
                availability: "Offered by many pain specialists; insurer coverage varies and some don't cover it.",
                sources: ["Cohen SP et al. Anesthesiology 2008;109:279–88", "Patel N et al. Pain Med 2016;17:2021–33", "Juch JNS et al. JAMA 2017;318:68–81"]),

            TreatmentOption(
                id: "mis-si-fusion", name: "Minimally invasive SI joint fusion", tier: .minimallyInvasive,
                summary: "Through a small incision in the buttock, two or three implants are placed across the SI joint under X-ray guidance to stop it moving.",
                whatHappens: ["Done on your front through a 3–5 cm incision.", "Implants are tapped across the joint."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Crutches and limited weight-bearing for about 3 weeks; normal activity 3–6 months.",
                bestFor: ["SI pain for more than 6 months confirmed by injections, not helped by non-surgical care"],
                lessSuitableIf: ["Unclear diagnosis", "Inflammatory arthritis that hasn't been treated"],
                outcomes: OptionOutcomes(improvement: PercentRange(70, 85), seriousComplications: PercentRange(1, 5), furtherTreatment: PercentRange(3, 8)),
                keyFindings: [
                    "In the INSITE trial (148 people), 81 in 100 met the success criteria at 6 months after fusion, vs 26 in 100 with non-surgical care (Polly 2015).",
                    "In the European iMIA trial (103 people), fusion reduced pain and disability more than non-surgical care at 2 years (Dengler 2019).",
                    "Both trials were funded by the implant maker and couldn't be blinded.",
                ],
                sideEffects: [SE.anesthesia, SE.make("Nerve irritation from an implant", "May need an implant to be repositioned.", 1, 5, .moderate), SE.make("Wound problems or infection", "Most settle with wound care or antibiotics.", 1, 4, .moderate), SE.make("Revision surgery", "For pain, a misplaced implant or the joint not fusing.", 3, 8, .moderate), SE.make("New pain in the hip or the other SI joint", "Often settles; sometimes the other side needs treatment.", 3, 10, .mild), SE.clots(0.1, 1), SE.nerveInjury(0.1, 1)],
                evidence: .moderate,
                availability: "Offered by some spine surgeons and interventional specialists. Medicare covers it; many private insurers now do with criteria.",
                sources: ["Polly DW et al. Neurosurgery 2015;77:674–91", "Dengler J et al. J Bone Joint Surg Am 2019;101:400–11"]),
        ],
        comparisons: [
            ComparisonStudy(name: "INSITE", compared: "MIS SI fusion vs non-surgical care (148 people)",
                finding: "81 in 100 vs 26 in 100 met success criteria at 6 months. Company-funded; not blinded.", citation: "Polly 2015, Neurosurgery"),
            ComparisonStudy(name: "iMIA", compared: "MIS SI fusion vs conservative management (103 people)",
                finding: "Greater improvement in pain and disability after fusion, lasting to 2 years. Company-funded.", citation: "Dengler 2019, J Bone Joint Surg Am"),
        ],
        questionsToAsk: [
            "How was my SI joint confirmed as the source of my pain? How much relief did the test injection give?",
            "Have I had a full trial of physical therapy aimed at the SI joint?",
            "How many SI fusions have you done, and how often do you need to revise them?",
        ])
}
