import Foundation

// DRAFT CONTENT — not yet clinically reviewed. See the header of TreatmentOptions.swift.
// Percentages are approximate ranges from the cited sources and must be verified before release.

/// Side effects that appear under several options.
enum SE {
    static func make(_ name: String, _ detail: String, _ low: Double, _ high: Double, _ severity: SideEffect.Severity) -> SideEffect {
        SideEffect(name: name, detail: detail, chance: PercentRange(low, high), severity: severity)
    }

    static let anesthesia = make("Effects of general anesthesia", "Sore throat, sickness, drowsiness or brief confusion for a day or two.", 10, 30, .mild)
    static func woundInfection(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Wound infection", "Most are treated with antibiotics. Deep infections can need another operation to clean the wound.", lo, hi, .moderate)
    }
    static func duralTear(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Tear in the nerve lining (dural tear)", "A leak of the fluid around the nerves. Usually repaired during surgery; may mean lying flat for a day or headaches that are worse when sitting up.", lo, hi, .moderate)
    }
    static func clots(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Blood clot in the leg or lungs", "A clot in a leg vein (DVT) that can travel to the lungs. Moving early and sometimes blood thinners lower the risk.", lo, hi, .serious)
    }
    static func nerveInjury(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Nerve injury", "New weakness, numbness or pain from damage to a nerve during surgery. It can be lasting.", lo, hi, .serious)
    }
    static func death(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Death within 30–90 days", "Usually from heart, lung or clotting problems. The risk rises with age and other health conditions.", lo, hi, .serious)
    }
    static func delirium(_ lo: Double, _ hi: Double) -> SideEffect {
        make("Confusion after surgery (delirium)", "Most common in people over 70. Usually clears within days but can slow recovery.", lo, hi, .moderate)
    }
    static let exerciseSoreness = make("Temporary soreness or a flare", "Muscle soreness or a short-lived increase in pain when starting or progressing exercise.", 10, 30, .mild)
    static let nsaidStomach = make("Stomach upset or heartburn (anti-inflammatories)", "From ibuprofen or naproxen. Taking them with food helps.", 10, 20, .mild)
    static let nsaidBleed = make("Stomach bleeding or ulcer (anti-inflammatories)", "Higher in people over 65, with past ulcers, or taking blood thinners or steroids.", 0.2, 1, .serious)
    static let nsaidKidneyHeart = make("Raised blood pressure, kidney strain or heart risk (anti-inflammatories)", "Mainly with regular use, higher doses or existing heart or kidney disease.", 1, 5, .moderate)
    static let gabapentinoid = make("Dizziness or sleepiness (gabapentin or pregabalin)", "Common, especially when starting. Can raise the risk of falls.", 15, 40, .mild)
    static let steroidFlush = make("Flushing, poor sleep or feeling 'wired' (steroid)", "For a few days after a steroid dose.", 5, 15, .mild)
    static let steroidSugar = make("Raised blood sugar (people with diabetes)", "Usually for 1–3 days after a steroid injection. Check your sugars more often.", 20, 50, .mild)
    static let injectionFlare = make("Temporary pain flare at the injection site or down the leg", "Usually settles within a few days.", 2, 10, .mild)
    static let injectionHeadache = make("Headache from a puncture of the nerve lining", "Positional headache that usually settles in days; sometimes needs a blood patch.", 0.5, 1, .moderate)
    static let injectionInfection = make("Infection or abscess", "Rare after spine injections.", 0.01, 0.1, .serious)
    static let injectionParalysis = make("Spinal cord or nerve injury (stroke of the spinal cord)", "Extremely rare reports, mostly with certain types of steroid injected through the side (transforaminal), especially in the neck.", 0.001, 0.01, .serious)
    static let opioidRisks = make("Constipation, drowsiness or dependence (opioids)", "Opioids are not recommended for more than a few days for back or leg pain because of these risks.", 20, 40, .moderate)
}

extension TreatmentGuides {
    static let lumbar: [SpineConditionGuide] = [discHerniation, stenosis, spondylolisthesis, chronicBackPain]

    // MARK: - Lumbar disc herniation with sciatica

    static let discHerniation = SpineConditionGuide(
        id: "lumbar-disc-herniation",
        name: "Lumbar disc herniation with sciatica",
        alsoCalled: "Slipped disc, herniated or prolapsed disc, sciatica, lumbar radiculopathy",
        symbol: "bolt.horizontal",
        summary: "Part of the soft center of a disc pushes out and presses on or irritates a nerve, causing pain down the leg, often with numbness, tingling or weakness.",
        naturalHistory: [
            "Most people improve a lot within 6 to 12 weeks without surgery.",
            "In about 2 of 3 people the herniated disc shrinks or disappears on later MRI scans. Large fragments that have broken off shrink most often.",
            "In trials, people who waited instead of having early surgery recovered more slowly, but after a year most were doing about as well as those who had surgery.",
        ],
        whenSurgeryIsOffered: [
            "Leg pain that is severe and not improving after about 6–12 weeks of non-surgical care.",
            "Pain that you can't manage day to day, even if it hasn't been 6 weeks.",
            "Weakness that is significant or getting worse.",
        ],
        urgentSigns: [
            "New trouble passing urine or controlling your bladder or bowels, or numbness around your genitals or bottom (cauda equina syndrome) — go to the emergency department now.",
            "Rapidly worsening weakness, such as a new foot drop.",
        ],
        improvementDefinition: "Meaningful improvement in leg pain and function about 1 year after starting treatment.",
        options: [
            TreatmentOption(
                id: "watchful-waiting", name: "Watchful waiting and staying active", tier: .conservative,
                summary: "Giving the disc time to settle while staying as active as pain allows, using heat, short rests and pain relief as needed.",
                whatHappens: ["Keep walking and doing normal activities within comfort.", "Avoid long bed rest — it slows recovery.", "Track your symptoms and check in with your doctor if they get worse."],
                anesthesia: "None", hospitalStay: "None", recovery: "Usually 6–12 weeks for most of the improvement; numbness can take longer.",
                bestFor: ["Leg pain that is manageable and slowly improving", "No significant or worsening weakness"],
                lessSuitableIf: ["Severe pain you can't manage", "Significant or worsening weakness", "Any cauda equina symptoms"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(25, 40)),
                keyFindings: [
                    "In the Leiden–The Hague trial, people offered prolonged non-surgical care recovered more slowly (about 12 weeks vs 4 weeks), but at 1 year about 95 in 100 in both groups reported a satisfactory recovery. About 4 in 10 of the waiting group had surgery during that year (Peul 2007).",
                    "In the SPORT study both surgery and non-surgery groups improved substantially, and many people did well without an operation (Weinstein 2006; Lurie 2014).",
                ],
                sideEffects: [
                    SE.make("Pain lasting longer", "Recovery is slower than with early surgery for many people.", 30, 50, .mild),
                    SE.make("Going on to need surgery anyway", "Because pain doesn't settle well enough.", 25, 40, .moderate),
                    SE.make("New serious nerve compression (cauda equina)", "Rare. This is why you need to know the warning signs.", 0, 0.5, .serious),
                ],
                evidence: .strong,
                availability: "Always available. It may not be discussed in detail at a surgical appointment because it's usually started by a primary care doctor.",
                sources: ["Peul WC et al. N Engl J Med 2007;356:2245–56", "Weinstein JN et al. JAMA 2006;296:2441–50", "Lurie JD et al. Spine 2014;39:3–16", "Chiu CC et al. Clin Rehabil 2015;29:184–95"]),

            TreatmentOption(
                id: "physical-therapy", name: "Physical therapy", tier: .conservative,
                summary: "A physical therapist guides exercises, nerve glides and movements that ease leg pain, and helps you return to activity safely.",
                whatHappens: ["An assessment of how movement affects your symptoms.", "Usually 4–12 visits plus a home exercise program.", "Some therapists use 'directional preference' exercises that move pain out of the leg and back toward the spine."],
                anesthesia: "None", hospitalStay: "None", recovery: "Usually 6–12 weeks of exercise.",
                bestFor: ["Most people with sciatica, alone or before and after surgery"],
                lessSuitableIf: ["Severe or worsening weakness, or cauda equina symptoms (needs urgent assessment first)"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 80), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(20, 40)),
                keyFindings: [
                    "Exercise therapy gives small-to-moderate short-term improvements in leg pain and function compared with advice alone. The evidence is of low to moderate quality (Fernandez 2016 review).",
                    "Physical therapy is usually part of 'non-surgical care' in the surgery trials, so its results overlap with watchful waiting.",
                ],
                sideEffects: [SE.exerciseSoreness],
                evidence: .moderate,
                availability: "Widely available and covered by Medicare and most insurers, sometimes with a visit limit or copay. Most states allow you to see a physical therapist without a referral.",
                sources: ["Fernandez M et al. Br J Sports Med 2016;50:1103–11", "Stochkendahl MJ et al. Eur Spine J 2018;27:60–75"]),

            TreatmentOption(
                id: "medicines", name: "Pain medicines", tier: .conservative,
                summary: "Anti-inflammatories, a short course of oral steroids or nerve-pain medicines to make the pain manageable while the disc settles.",
                whatHappens: ["Anti-inflammatories (ibuprofen, naproxen) for a limited time.", "Sometimes a short course of oral steroids (prednisone).", "Nerve-pain medicines such as gabapentin or pregabalin are often prescribed, but trials show little benefit for sciatica."],
                anesthesia: "None", hospitalStay: "None", recovery: "Used for days to weeks.",
                bestFor: ["Making pain manageable while waiting for natural recovery"],
                lessSuitableIf: ["Stomach ulcers, kidney disease, heart disease or blood thinners (anti-inflammatories)", "Diabetes (steroids raise blood sugar)"],
                outcomes: OptionOutcomes(improvement: nil, seriousComplications: PercentRange(0.2, 1), furtherTreatment: nil),
                keyFindings: [
                    "Pregabalin worked no better than placebo for sciatica at 8 weeks or 1 year, and caused more dizziness (Mathieson 2017).",
                    "A 15-day course of prednisone modestly improved function but not leg pain compared with placebo (Goldberg 2015).",
                    "Anti-inflammatories give a small short-term reduction in pain at best for sciatica (Rasmussen-Barr 2016 review).",
                ],
                sideEffects: [SE.nsaidStomach, SE.nsaidKidneyHeart, SE.nsaidBleed, SE.gabapentinoid, SE.steroidFlush, SE.opioidRisks],
                evidence: .moderate,
                availability: "Widely available. Usually managed by your primary care doctor.",
                sources: ["Mathieson S et al. N Engl J Med 2017;376:1111–20", "Goldberg H et al. JAMA 2015;313:1915–23", "Rasmussen-Barr E et al. Cochrane 2016;CD012382"]),

            TreatmentOption(
                id: "epidural-steroid", name: "Epidural steroid injection", tier: .interventional,
                summary: "A steroid and numbing medicine injected next to the irritated nerve under X-ray guidance, to calm inflammation for a few weeks to months.",
                whatHappens: ["You lie face down while a doctor guides a thin needle using X-ray.", "Takes about 15–30 minutes; you go home the same day.", "Can be repeated, usually no more than 3–4 times a year."],
                anesthesia: "Local anesthetic, sometimes light sedation", hospitalStay: "Outpatient (home the same day)", recovery: "Rest for the day; usual activities the next day.",
                bestFor: ["Severe leg pain while waiting for natural recovery", "People who want to avoid or delay surgery"],
                lessSuitableIf: ["Infection, bleeding problems or blood thinners that can't be paused", "Poorly controlled diabetes"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: [
                    "Epidural steroids give a small, short-term reduction in leg pain (weeks to about 3 months) compared with placebo injections, and little effect after a year (Pinto 2012; Oliveira 2020 review).",
                    "Some people avoid surgery after an injection, but whether injections reliably reduce the need for surgery is uncertain (Riew 2000; Bicket 2015).",
                ],
                sideEffects: [SE.injectionFlare, SE.steroidFlush, SE.steroidSugar, SE.injectionHeadache, SE.injectionInfection, SE.injectionParalysis],
                evidence: .moderate,
                availability: "Widely available from pain medicine, physiatry and some spine surgery practices. Medicare and most insurers cover it, usually with limits on how often.",
                sources: ["Pinto RZ et al. Ann Intern Med 2012;157:865–77", "Oliveira CB et al. Cochrane 2020;CD013577", "Riew KD et al. J Bone Joint Surg Am 2000;82:1589–93", "Bicket MC et al. Spine J 2015;15:348–62"]),

            TreatmentOption(
                id: "endoscopic-discectomy", name: "Endoscopic discectomy", tier: .minimallyInvasive,
                summary: "The herniated disc fragment is removed through a tube about 1 cm wide using a camera, often from the side of the spine.",
                whatHappens: ["A small incision and a working tube with a camera are placed beside the nerve.", "The piece of disc pressing on the nerve is removed.", "Often done as day surgery."],
                anesthesia: "Local anesthetic with sedation, or general anesthesia", hospitalStay: "Same day or overnight", recovery: "Light activity within days; desk work often within 1–3 weeks.",
                bestFor: ["A single herniation in a position the endoscope can reach", "People who want the smallest incision and fastest early recovery"],
                lessSuitableIf: ["Some herniations are hard to reach endoscopically, especially at L5–S1 or with very large fragments", "Narrowing of the spinal canal (stenosis) as well as the herniation"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 12)),
                keyFindings: [
                    "In a Dutch randomized trial, endoscopic transforaminal discectomy was as good as standard microdiscectomy for leg pain at 1 year, with less blood loss and a shorter stay, but slightly more repeat herniations (Gadjradj 2022).",
                    "Results depend heavily on the surgeon's experience with the technique.",
                ],
                sideEffects: [
                    SE.make("Burning or tingling in the leg (dysesthesia)", "From irritation of the nerve; usually settles over weeks.", 3, 10, .mild),
                    SE.make("Disc herniates again", "May need a repeat operation.", 5, 12, .moderate),
                    SE.duralTear(0.5, 2),
                    SE.woundInfection(0.1, 1),
                    SE.nerveInjury(0.1, 1),
                ],
                evidence: .moderate,
                availability: "Offered at a growing number of US centers, but many surgeons aren't trained in it. Usually covered when microdiscectomy would be.",
                sources: ["Gadjradj PS et al. BMJ 2022;376:e065846", "Ruan W et al. Int J Surg 2016;31:86–92"]),

            TreatmentOption(
                id: "tubular-microdiscectomy", name: "Tubular microdiscectomy", tier: .minimallyInvasive,
                summary: "The same operation as a microdiscectomy, done through a narrow tube that pushes muscle aside instead of a slightly larger opening.",
                whatHappens: ["An incision of about 2 cm and a series of tubes that spread the muscle.", "A microscope is used to remove the disc fragment."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Similar to microdiscectomy: desk work often within 1–4 weeks.",
                bestFor: ["Similar to microdiscectomy"],
                lessSuitableIf: ["Similar to microdiscectomy"],
                outcomes: OptionOutcomes(improvement: PercentRange(75, 90), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In a randomized trial of 328 people, tubular discectomy was not better than conventional microdiscectomy: recovery was similar, with slightly more leg and back pain in the tubular group at 1 year (Arts 2009).",
                ],
                sideEffects: [SE.anesthesia, SE.duralTear(1, 5), SE.make("Disc herniates again", "May need a repeat operation.", 5, 15, .moderate), SE.woundInfection(0.5, 1), SE.nerveInjury(0.1, 1)],
                evidence: .moderate,
                availability: "Widely available. Many surgeons use either technique and describe both as 'microdiscectomy'.",
                sources: ["Arts MP et al. JAMA 2009;302:149–58"]),

            TreatmentOption(
                id: "microdiscectomy", name: "Microdiscectomy", tier: .lessInvasive,
                summary: "The most common operation for sciatica. Through a small incision, the surgeon removes only the part of the disc pressing on the nerve, using a microscope.",
                whatHappens: ["An incision of about 2–4 cm in the middle of the lower back.", "A little bone and ligament may be removed to reach the disc.", "The loose disc fragment is removed; most of the disc is left in place."],
                anesthesia: "General anesthesia", hospitalStay: "Same day or overnight", recovery: "Walking the same day; desk work often within 1–4 weeks; heavy work 6–12 weeks.",
                bestFor: ["Severe leg pain (more than back pain) that hasn't improved after 6–12 weeks", "A herniation on MRI that matches your symptoms"],
                lessSuitableIf: ["Back pain without much leg pain — surgery helps leg pain much more reliably than back pain"],
                outcomes: OptionOutcomes(improvement: PercentRange(80, 95), seriousComplications: PercentRange(1, 3), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "Surgery relieves leg pain faster than non-surgical care: in the Leiden–The Hague trial median recovery was about 4 weeks vs 12 weeks. By 1 year outcomes were similar (Peul 2007).",
                    "In a Canadian trial of people with sciatica for 4–12 months, microdiscectomy reduced leg pain more than continued non-surgical care at 6 months (Bailey 2020).",
                    "Over 8 years in SPORT, about 1 in 6 people who had surgery had another back operation (Lurie 2014).",
                ],
                sideEffects: [
                    SE.anesthesia,
                    SE.make("Numbness that doesn't fully recover", "Leg pain usually improves first; numbness may persist, especially if it was there a long time.", 10, 30, .mild),
                    SE.make("Disc herniates again", "Most often in the first 1–2 years. About half of these people need a repeat operation.", 5, 15, .moderate),
                    SE.duralTear(1, 7),
                    SE.woundInfection(0.5, 2),
                    SE.clots(0.1, 1),
                    SE.nerveInjury(0.1, 1),
                ],
                evidence: .strong,
                availability: "Widely available and usually what's offered. Covered by Medicare and most insurers, often after a period of non-surgical care.",
                sources: ["Peul WC et al. N Engl J Med 2007;356:2245–56", "Bailey CS et al. N Engl J Med 2020;382:1093–102", "Lurie JD et al. Spine 2014;39:3–16", "Weinstein JN et al. JAMA 2006;296:2441–50"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Leiden–The Hague Spine Intervention Prognostic Study", compared: "Early microdiscectomy vs prolonged non-surgical care (283 people, sciatica 6–12 weeks)",
                finding: "Surgery gave faster relief (about 4 vs 12 weeks to recovery). At 1 year, about 95 in 100 in both groups had recovered satisfactorily; 39 in 100 of the non-surgical group had surgery during the year.", citation: "Peul 2007, N Engl J Med"),
            ComparisonStudy(name: "SPORT (Spine Patient Outcomes Research Trial)", compared: "Discectomy vs non-surgical care (randomized and observational groups)",
                finding: "Both groups improved a lot. People who had surgery did somewhat better on average out to 8 years, but many switched groups, which makes the difference hard to measure.", citation: "Weinstein 2006, JAMA; Lurie 2014, Spine"),
            ComparisonStudy(name: "Canadian microdiscectomy trial", compared: "Microdiscectomy vs non-surgical care for sciatica lasting 4–12 months (128 people)",
                finding: "Less leg pain at 6 months with surgery. Shows that for longer-lasting sciatica, waiting longer may not help as much.", citation: "Bailey 2020, N Engl J Med"),
            ComparisonStudy(name: "PTED trial", compared: "Endoscopic vs standard microdiscectomy (613 people)",
                finding: "Leg pain at 1 year was about the same, with less blood loss and shorter stay after endoscopic surgery.", citation: "Gadjradj 2022, BMJ"),
        ],
        questionsToAsk: [
            "Is my main problem leg pain or back pain? How likely is surgery to help each?",
            "How long would you suggest waiting, and what would make you advise surgery sooner?",
            "Am I a candidate for an endoscopic or tubular approach? Do you do them?",
            "What's my chance of the disc herniating again?",
        ])

    // MARK: - Lumbar spinal stenosis

    static let stenosis = SpineConditionGuide(
        id: "lumbar-stenosis",
        name: "Lumbar spinal stenosis",
        alsoCalled: "Spinal stenosis, neurogenic claudication, narrowing of the spinal canal",
        symbol: "arrow.down.right.and.arrow.up.left",
        summary: "Wear-and-tear changes (bulging discs, enlarged joints and thick ligaments) narrow the space for the nerves in the lower back. It typically causes pain, heaviness or numbness in the legs when standing or walking that eases when sitting or bending forward.",
        naturalHistory: [
            "Stenosis usually changes slowly. In one long-term study, over about 4 years roughly 70 in 100 people stayed about the same, 15 improved and 15 got worse without surgery.",
            "Sudden serious nerve damage is uncommon.",
            "Many people manage well for years with activity changes, exercise and occasional injections.",
        ],
        whenSurgeryIsOffered: [
            "Walking distance or standing time that limits your life despite non-surgical care.",
            "Progressive weakness or numbness.",
        ],
        urgentSigns: [
            "New bladder or bowel control problems or numbness around the genitals or bottom — go to the emergency department now.",
            "Rapidly worsening leg weakness.",
        ],
        improvementDefinition: "Meaningful improvement in walking, leg symptoms and function 1–2 years after treatment.",
        options: [
            TreatmentOption(
                id: "self-management", name: "Activity changes and self-management", tier: .conservative,
                summary: "Using positions and activities that open up the spinal canal — like cycling, walking with a cart or poles, and sitting breaks — to stay active.",
                whatHappens: ["Learning which positions ease symptoms (usually bending forward slightly).", "Stationary cycling, water walking or walking with a rollator.", "Weight management and general fitness."],
                anesthesia: "None", hospitalStay: "None", recovery: "Ongoing.",
                bestFor: ["Mild to moderate symptoms", "People who want to avoid or delay surgery", "People with health problems that make surgery riskier"],
                lessSuitableIf: ["Progressive weakness"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(20, 40)),
                keyFindings: ["Without surgery, most people's symptoms stay about the same for years rather than getting steadily worse (Johnsson 1992; Wessberg 2017)."],
                sideEffects: [SE.make("Symptoms gradually worsening", "About 1 in 6 over several years.", 10, 20, .moderate)],
                evidence: .limited,
                availability: "Always available.",
                sources: ["Johnsson KE et al. Clin Orthop 1992;279:82–6", "Wessberg P, Frennered K. Eur Spine J 2017;26:2536–42"]),

            TreatmentOption(
                id: "stenosis-pt", name: "Physical therapy", tier: .conservative,
                summary: "A structured program of flexion-based exercise, strengthening, conditioning and manual therapy.",
                whatHappens: ["Usually twice a week for about 6 weeks, plus home exercises.", "Often uses stationary cycling or a treadmill with body-weight support."],
                anesthesia: "None", hospitalStay: "None", recovery: "6–12 weeks of exercise.",
                bestFor: ["Most people with stenosis, especially before deciding on surgery"],
                lessSuitableIf: ["Progressive weakness (needs surgical review)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(0, 0.1), furtherTreatment: PercentRange(30, 57)),
                keyFindings: [
                    "In a randomized trial, people who had physical therapy had similar physical function at 2 years to those who had decompression surgery. But 57 in 100 of the therapy group chose to have surgery during the study (Delitto 2015).",
                    "A trial of a combined program (manual therapy, exercise, education) improved walking more than medical care or group exercise at 2 months (Schneider 2019).",
                ],
                sideEffects: [SE.exerciseSoreness],
                evidence: .moderate,
                availability: "Widely available and covered by Medicare and most insurers.",
                sources: ["Delitto A et al. Ann Intern Med 2015;162:465–73", "Schneider MJ et al. JAMA Netw Open 2019;2:e186828"]),

            TreatmentOption(
                id: "stenosis-epidural", name: "Epidural steroid injection", tier: .interventional,
                summary: "Steroid and numbing medicine injected into the spinal canal under X-ray guidance.",
                whatHappens: ["A needle is guided into the space around the nerves; takes 15–30 minutes.", "You go home the same day."],
                anesthesia: "Local anesthetic", hospitalStay: "Outpatient", recovery: "Usual activities the next day.",
                bestFor: ["Short-term relief, for example for a trip or while deciding on surgery"],
                lessSuitableIf: ["Diabetes that is hard to control", "Osteoporosis (repeated steroids weaken bone)"],
                outcomes: OptionOutcomes(improvement: PercentRange(20, 40), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: [
                    "In the LESS trial of 400 people, adding steroid to a numbing-medicine injection made little or no difference to pain or function at 6 weeks (Friedly 2014). Both groups improved somewhat.",
                ],
                sideEffects: [SE.injectionFlare, SE.steroidFlush, SE.steroidSugar, SE.make("Bone thinning with repeated steroid injections", "Mainly with frequent injections over years.", 1, 5, .moderate), SE.injectionHeadache, SE.injectionInfection],
                evidence: .strong,
                availability: "Widely available and covered, usually with limits on frequency.",
                sources: ["Friedly JL et al. N Engl J Med 2014;371:11–21"]),

            TreatmentOption(
                id: "mild", name: "Percutaneous image-guided lumbar decompression (mild)", tier: .interventional,
                summary: "Through a needle-sized opening, small pieces of thickened ligament at the back of the canal are removed under X-ray guidance. No implant is left behind.",
                whatHappens: ["Done face down through a 5 mm skin opening.", "Takes under an hour; home the same day."],
                anesthesia: "Local anesthetic with sedation", hospitalStay: "Outpatient", recovery: "Light activity within a day or two.",
                bestFor: ["Stenosis caused mainly by a thickened ligament (seen on MRI)", "People who want to avoid open surgery or have health risks for it"],
                lessSuitableIf: ["Stenosis mainly from disc or bone", "Instability or a slipped vertebra greater than grade 1"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 60), seriousComplications: PercentRange(0, 1), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In the MiDAS ENCORE trial, more people improved by at least 10 points on the ODI questionnaire after mild plus usual care than with usual care alone at 1 year. The trial was funded by the manufacturer and had no sham group (Staats 2018).",
                ],
                sideEffects: [SE.make("Soreness at the needle site", "Short-lived.", 5, 15, .mild), SE.duralTear(0, 1), SE.make("Bleeding or nerve injury", "Rare.", 0.1, 1, .serious)],
                evidence: .limited,
                availability: "Offered by some interventional pain specialists. Medicare covers it for patients in approved studies or registries; private insurance varies.",
                sources: ["Staats PS et al. Pain Pract 2018;18:1034–45", "Benyamin RM et al. Pain Physician 2016;19:229–42"]),

            TreatmentOption(
                id: "interspinous-spacer", name: "Interspinous spacer (without fusion)", tier: .minimallyInvasive,
                summary: "A small implant placed between two bony points at the back of the spine to hold the space open when you stand upright.",
                whatHappens: ["Inserted through a small incision.", "Often done as day surgery."],
                anesthesia: "Local with sedation or general anesthesia", hospitalStay: "Same day or overnight", recovery: "Light activity within days; avoid heavy lifting for several weeks.",
                bestFor: ["Moderate stenosis at one or two levels with symptoms that ease when bending forward"],
                lessSuitableIf: ["Osteoporosis (risk of fracture of the bone the spacer sits against)", "Spondylolisthesis greater than grade 1", "Severe stenosis"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 80), seriousComplications: PercentRange(1, 5), furtherTreatment: PercentRange(15, 30)),
                keyFindings: [
                    "In a European randomized trial, spacers gave similar early results to decompression but needed repeat surgery much more often (about 3 in 10 vs 1 in 12 within 2 years) (Moojen 2013).",
                    "In the US trial that led to approval, the Superion spacer did about as well as an older spacer at 2–5 years (Patel 2015; Nunley 2017, company-funded).",
                ],
                sideEffects: [SE.make("Fracture of the spinous process (the bony point)", "Can cause pain and the spacer to stop working.", 1, 10, .moderate), SE.make("Implant moves or symptoms return", "Often leads to repeat surgery.", 10, 25, .moderate), SE.woundInfection(0.5, 2), SE.nerveInjury(0.1, 1)],
                evidence: .limited,
                availability: "Available from some spine surgeons and pain specialists. Coverage varies between insurers.",
                sources: ["Moojen WA et al. BMJ 2013;347:f6415", "Nunley PD et al. J Pain Res 2017;10:1909–17"]),

            TreatmentOption(
                id: "mis-decompression", name: "Minimally invasive decompression (tubular or endoscopic)", tier: .minimallyInvasive,
                summary: "Bone and ligament pressing on the nerves are removed through a tube or endoscope from one side, which can decompress both sides while disturbing less muscle.",
                whatHappens: ["A small incision and tube on one side of the spine.", "The surgeon tilts the tube to clear both sides of the canal."],
                anesthesia: "General anesthesia", hospitalStay: "Same day to 2 days", recovery: "Walking the same day; light work 2–4 weeks.",
                bestFor: ["Stenosis without instability", "Older adults who may benefit from less blood loss and a shorter stay"],
                lessSuitableIf: ["Instability or significant slip that may need fusion"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(2, 5), furtherTreatment: PercentRange(5, 15)),
                keyFindings: ["In the NORDSTEN trial, three different decompression techniques (including muscle-sparing ones) gave similar results at 2 years (Hermansen 2019)."],
                sideEffects: [SE.anesthesia, SE.duralTear(2, 8), SE.woundInfection(0.5, 2), SE.delirium(2, 10), SE.clots(0.2, 1), SE.nerveInjury(0.1, 1)],
                evidence: .moderate,
                availability: "Offered by many but not all spine surgeons.",
                sources: ["Hermansen E et al. Eur Spine J 2019;28:2312–22", "Phan K, Mobbs RJ. Spine 2016;41:E91–100"]),

            TreatmentOption(
                id: "laminectomy", name: "Open laminectomy (decompression)", tier: .traditional,
                summary: "The standard operation for stenosis. The back part of the vertebra (lamina) and thickened ligament are removed to make room for the nerves.",
                whatHappens: ["An incision in the middle of the back over the affected levels.", "Muscles are moved aside and bone and ligament are removed."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "Walking the next day; light work 4–6 weeks; full recovery about 3 months.",
                bestFor: ["Stenosis that limits walking despite non-surgical care", "Multiple levels"],
                lessSuitableIf: ["Mainly back pain rather than leg symptoms", "Severe health problems that raise surgical risk"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(3, 8), furtherTreatment: PercentRange(10, 20)),
                keyFindings: [
                    "In SPORT, people who had surgery had greater improvement in pain and function than those treated without surgery, out to 8 years (Weinstein 2008; Lurie 2015).",
                    "About 1 in 10 to 1 in 5 people have another operation within 5–10 years, often for stenosis at a new level (Försth 2016; Lurie 2015).",
                ],
                sideEffects: [SE.anesthesia, SE.duralTear(5, 10), SE.delirium(5, 15), SE.woundInfection(1, 3), SE.clots(0.5, 2), SE.make("Slip or instability after surgery", "The spine can become less stable over time and may need a fusion.", 2, 10, .serious), SE.nerveInjury(0.5, 1), SE.death(0.1, 0.5)],
                evidence: .strong,
                availability: "Widely available. Covered by Medicare and most insurers.",
                sources: ["Weinstein JN et al. N Engl J Med 2008;358:794–810", "Lurie JD et al. Spine 2015;40:63–76", "Försth P et al. N Engl J Med 2016;374:1413–23"]),

            TreatmentOption(
                id: "decompression-fusion", name: "Decompression with fusion", tier: .traditional,
                summary: "Laminectomy plus joining the vertebrae with screws, rods and bone graft so they heal into one bone.",
                whatHappens: ["Decompression as above, then screws and rods are placed and bone graft is added.", "Bone takes 6–12 months to fuse."],
                anesthesia: "General anesthesia", hospitalStay: "2–5 days", recovery: "Light work 6–12 weeks; full recovery 6–12 months.",
                bestFor: ["Stenosis with an unstable spine, significant curve (scoliosis) or a slip that moves on X-rays"],
                lessSuitableIf: ["Stenosis without instability — trials show fusion usually adds risk without extra benefit"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(8, 15), furtherTreatment: PercentRange(15, 25)),
                keyFindings: [
                    "In the Swedish Spinal Stenosis Study of 247 people, adding fusion to decompression gave no better results at 2 or 5 years, but meant longer surgery, a longer stay and higher cost (Försth 2016).",
                ],
                sideEffects: [SE.anesthesia, SE.make("Blood transfusion", "More likely with multi-level fusion.", 5, 20, .moderate), SE.duralTear(5, 10), SE.delirium(5, 15), SE.woundInfection(2, 5), SE.make("Screws misplaced or loosening", "May need repeat surgery.", 1, 5, .serious), SE.make("Bones don't fuse (nonunion)", "May cause pain and need another operation.", 5, 15, .serious), SE.make("Wear at the next level (adjacent segment disease)", "The levels next to the fusion take more strain over the years.", 10, 20, .moderate), SE.clots(0.5, 2), SE.death(0.2, 1)],
                evidence: .strong,
                availability: "Widely available.",
                sources: ["Försth P et al. N Engl J Med 2016;374:1413–23", "Deyo RA et al. JAMA 2010;303:1259–65"]),
        ],
        comparisons: [
            ComparisonStudy(name: "Physical therapy vs surgery trial", compared: "Decompression vs a 6-week physical therapy program (169 people)",
                finding: "Physical function was similar at 2 years. 57 in 100 of the physical therapy group crossed over to surgery.", citation: "Delitto 2015, Ann Intern Med"),
            ComparisonStudy(name: "SPORT stenosis", compared: "Decompression vs non-surgical care",
                finding: "Surgery gave greater improvement in pain and function that lasted to 8 years in the 'as treated' analysis.", citation: "Weinstein 2008, N Engl J Med; Lurie 2015, Spine"),
            ComparisonStudy(name: "Swedish Spinal Stenosis Study", compared: "Decompression alone vs decompression with fusion (247 people)",
                finding: "No extra benefit from fusion at 2 or 5 years; fusion took longer, cost more and needed a longer stay.", citation: "Försth 2016, N Engl J Med"),
            ComparisonStudy(name: "LESS trial", compared: "Epidural steroid plus numbing medicine vs numbing medicine alone (400 people)",
                finding: "Little or no added benefit from the steroid at 6 weeks.", citation: "Friedly 2014, N Engl J Med"),
        ],
        questionsToAsk: [
            "Do I need a fusion, or would decompression alone be enough? Why?",
            "Is my spine unstable on X-rays taken while bending forward and back?",
            "Could a structured physical therapy program be tried first?",
            "Can this be done with a minimally invasive approach?",
        ])

    // MARK: - Degenerative spondylolisthesis

    static let spondylolisthesis = SpineConditionGuide(
        id: "degenerative-spondylolisthesis",
        name: "Degenerative spondylolisthesis",
        alsoCalled: "Slipped vertebra (usually at L4–L5), often with spinal stenosis",
        symbol: "square.stack.3d.down.forward",
        summary: "Wear in the joints lets one vertebra slide forward on the one below. It often narrows the canal and causes stenosis symptoms in the legs, sometimes with back pain.",
        naturalHistory: [
            "The slip gets bigger over time in about 1 in 3 people, but symptoms don't closely follow the size of the slip.",
            "In a 10-year study, about 3 in 4 people without nerve weakness did not get worse without surgery.",
        ],
        whenSurgeryIsOffered: ["Leg symptoms that limit walking or standing despite non-surgical care.", "Progressive weakness."],
        urgentSigns: ["New bladder or bowel control problems or saddle numbness — go to the emergency department now.", "Rapidly worsening weakness."],
        improvementDefinition: "At least a 30% improvement in disability (ODI questionnaire) or similar at about 2 years.",
        options: [
            TreatmentOption(
                id: "ds-conservative", name: "Physical therapy, activity changes and medicines", tier: .conservative,
                summary: "Exercise focused on core and hip strength and flexion-based positions, with pain relief as needed.",
                whatHappens: ["A 6–12 week physical therapy program and home exercises.", "Short-term anti-inflammatories if safe for you.", "A brace is sometimes used briefly for flares."],
                anesthesia: "None", hospitalStay: "None", recovery: "Ongoing.",
                bestFor: ["Mild to moderate symptoms", "Stable slip without weakness"],
                lessSuitableIf: ["Progressive weakness"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(30, 50)),
                keyFindings: ["In SPORT, people with spondylolisthesis treated without surgery improved modestly; surgery gave bigger improvements on average (Weinstein 2007, 2009)."],
                sideEffects: [SE.exerciseSoreness, SE.nsaidStomach, SE.nsaidBleed],
                evidence: .limited,
                availability: "Widely available.",
                sources: ["Matsunaga S et al. J Neurosurg 2000;93:194–8", "Weinstein JN et al. N Engl J Med 2007;356:2257–70"]),

            TreatmentOption(
                id: "ds-epidural", name: "Epidural steroid injection", tier: .interventional,
                summary: "Steroid injected around the nerves for short-term relief of leg symptoms.",
                whatHappens: ["X-ray guided needle; home the same day."],
                anesthesia: "Local anesthetic", hospitalStay: "Outpatient", recovery: "Next day.",
                bestFor: ["Short-term relief of leg pain"],
                lessSuitableIf: ["Poorly controlled diabetes", "Osteoporosis"],
                outcomes: OptionOutcomes(improvement: PercentRange(20, 40), seriousComplications: PercentRange(0.01, 0.1), furtherTreatment: PercentRange(30, 50)),
                keyFindings: ["Evidence comes mainly from stenosis studies, where the steroid adds little beyond numbing medicine alone (Friedly 2014)."],
                sideEffects: [SE.injectionFlare, SE.steroidFlush, SE.steroidSugar, SE.injectionHeadache, SE.injectionInfection],
                evidence: .limited,
                availability: "Widely available.",
                sources: ["Friedly JL et al. N Engl J Med 2014;371:11–21"]),

            TreatmentOption(
                id: "ds-decompression", name: "Decompression alone (open or minimally invasive)", tier: .lessInvasive,
                summary: "Removing the bone and ligament pressing on the nerves without fusing the slipped vertebra.",
                whatHappens: ["Similar to a laminectomy, often preserving the central bony structures to protect stability."],
                anesthesia: "General anesthesia", hospitalStay: "Same day to 2 days", recovery: "Light work 2–6 weeks.",
                bestFor: ["A stable slip (not moving much on bending X-rays) with mainly leg symptoms"],
                lessSuitableIf: ["A slip that moves a lot on X-rays", "Significant back pain from the slip itself"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 75), seriousComplications: PercentRange(2, 6), furtherTreatment: PercentRange(10, 34)),
                keyFindings: [
                    "In the NORDSTEN-DS trial of 267 people, decompression alone was as good as decompression with fusion at 2 years: about 71 in 100 vs 76 in 100 improved by at least 30%. Decompression alone meant shorter surgery and a shorter stay (Austevoll 2021).",
                    "In the US SLIP trial of 66 people, fusion gave slightly better physical health scores and fewer repeat operations (14% vs 34%) over 4 years (Ghogawala 2016).",
                ],
                sideEffects: [SE.anesthesia, SE.duralTear(3, 8), SE.delirium(3, 10), SE.woundInfection(0.5, 2), SE.make("Slip worsens and needs fusion later", "The main reason for repeat surgery after decompression alone.", 5, 20, .moderate), SE.clots(0.2, 1)],
                evidence: .strong,
                availability: "Widely available, but practice varies — many US surgeons routinely recommend fusion for spondylolisthesis.",
                sources: ["Austevoll IM et al. N Engl J Med 2021;385:526–38", "Ghogawala Z et al. N Engl J Med 2016;374:1424–34", "Försth P et al. N Engl J Med 2016;374:1413–23"]),

            TreatmentOption(
                id: "ds-interlaminar", name: "Decompression with interlaminar stabilization device", tier: .lessInvasive,
                summary: "After decompression, a U-shaped implant is placed between the bony points at the back of the spine to add some support without fusing.",
                whatHappens: ["Decompression, then the device is placed at the same level."],
                anesthesia: "General anesthesia", hospitalStay: "1–2 days", recovery: "Light work 4–6 weeks.",
                bestFor: ["Stenosis with a low-grade (grade 1) slip at one or two levels"],
                lessSuitableIf: ["Osteoporosis", "Higher-grade slip or significant instability"],
                outcomes: OptionOutcomes(improvement: PercentRange(60, 75), seriousComplications: PercentRange(3, 8), furtherTreatment: PercentRange(10, 20)),
                keyFindings: ["In the company-funded approval trial, decompression with the device did at least as well as decompression with fusion at 2–5 years, with a shorter operation (Davis 2013; Bae 2016)."],
                sideEffects: [SE.anesthesia, SE.make("Fracture of the spinous process", "The bone the device grips can break.", 3, 10, .moderate), SE.duralTear(2, 6), SE.woundInfection(1, 3), SE.nerveInjury(0.1, 1)],
                evidence: .limited,
                availability: "FDA-approved, but offered by relatively few surgeons. Coverage varies.",
                sources: ["Davis RJ et al. J Neurosurg Spine 2013;19:174–84", "Bae HW et al. Spine 2016;41:S1–9"]),

            TreatmentOption(
                id: "ds-mis-tlif", name: "Minimally invasive fusion (MIS-TLIF)", tier: .minimallyInvasive,
                summary: "Fusion done through small incisions with screws placed through the skin and a spacer (cage) put in the disc space through a tube.",
                whatHappens: ["Small incisions on each side; muscles are spread rather than stripped.", "Disc removed and replaced with a cage and bone graft; screws and rods placed."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "Light work 4–8 weeks; fusion takes 6–12 months.",
                bestFor: ["When fusion is needed, people who'd benefit from less blood loss and a shorter stay"],
                lessSuitableIf: ["When decompression alone would be enough"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 80), seriousComplications: PercentRange(4, 10), furtherTreatment: PercentRange(8, 15)),
                keyFindings: ["Compared with open fusion, minimally invasive fusion has less blood loss, a shorter stay and fewer infections, with similar results at 1–2 years, mostly from non-randomized studies (Goldstein 2016 review)."],
                sideEffects: [SE.anesthesia, SE.make("Leg pain or numbness from the cage or screws", "Often temporary.", 2, 8, .moderate), SE.make("Bones don't fuse (nonunion)", "May need repeat surgery.", 3, 10, .serious), SE.make("Cage sinks or shifts", "May need repeat surgery.", 1, 5, .moderate), SE.duralTear(1, 4), SE.woundInfection(0.5, 2), SE.clots(0.2, 1)],
                evidence: .limited,
                availability: "Offered by many surgeons; covered when fusion is covered.",
                sources: ["Goldstein CL et al. J Neurosurg Spine 2016;24:416–27"]),

            TreatmentOption(
                id: "ds-open-fusion", name: "Open decompression and fusion", tier: .traditional,
                summary: "The traditional operation: decompression plus screws, rods and bone graft through a midline incision.",
                whatHappens: ["Decompression, then screws and rods, sometimes with a cage in the disc space."],
                anesthesia: "General anesthesia", hospitalStay: "2–5 days", recovery: "Light work 6–12 weeks; full recovery 6–12 months.",
                bestFor: ["A slip that moves on X-rays, higher-grade slips, scoliosis or significant back pain from the slip"],
                lessSuitableIf: ["Stable slip with leg symptoms only, where decompression alone may be enough"],
                outcomes: OptionOutcomes(improvement: PercentRange(65, 80), seriousComplications: PercentRange(8, 15), furtherTreatment: PercentRange(10, 22)),
                keyFindings: [
                    "SLIP trial: slightly better physical health scores and fewer repeat operations than decompression alone (Ghogawala 2016).",
                    "NORDSTEN-DS and the Swedish Spinal Stenosis Study: no clear extra benefit over decompression alone at 2 years, with longer surgery and stays (Austevoll 2021; Försth 2016).",
                ],
                sideEffects: [SE.anesthesia, SE.make("Blood transfusion", "More likely with longer or multi-level operations.", 5, 15, .moderate), SE.duralTear(3, 8), SE.delirium(5, 15), SE.woundInfection(2, 5), SE.make("Bones don't fuse (nonunion)", "May need repeat surgery.", 5, 15, .serious), SE.make("Wear at the next level (adjacent segment disease)", "The levels next to the fusion take more strain over the years and may need surgery later.", 10, 20, .moderate), SE.clots(0.5, 2), SE.death(0.2, 1)],
                evidence: .strong,
                availability: "Widely available; the most commonly offered operation for this condition in the US.",
                sources: ["Ghogawala Z et al. N Engl J Med 2016;374:1424–34", "Austevoll IM et al. N Engl J Med 2021;385:526–38"]),
        ],
        comparisons: [
            ComparisonStudy(name: "NORDSTEN-DS", compared: "Decompression alone vs decompression with fusion (267 people)",
                finding: "71 in 100 vs 76 in 100 reached a 30% improvement at 2 years — decompression alone was non-inferior, with shorter surgery and stay.", citation: "Austevoll 2021, N Engl J Med"),
            ComparisonStudy(name: "SLIP trial", compared: "Laminectomy alone vs laminectomy with fusion (66 people)",
                finding: "Fusion gave slightly better physical health scores and fewer repeat operations (14% vs 34%) over 4 years.", citation: "Ghogawala 2016, N Engl J Med"),
            ComparisonStudy(name: "Swedish Spinal Stenosis Study", compared: "Decompression with vs without fusion, including people with a slip",
                finding: "No extra benefit from fusion at 2 years, including in the spondylolisthesis group.", citation: "Försth 2016, N Engl J Med"),
        ],
        questionsToAsk: [
            "Does my slip move on bending X-rays? Is it stable?",
            "Have you considered decompression alone? What do the NORDSTEN-DS and SLIP trials mean for me?",
            "Can the fusion be done minimally invasively?",
        ])

    // MARK: - Chronic low back pain

    static let chronicBackPain = SpineConditionGuide(
        id: "chronic-low-back-pain",
        name: "Chronic low back pain from disc degeneration",
        alsoCalled: "Degenerative disc disease, discogenic pain, vertebrogenic pain (Modic changes), facet joint pain",
        symbol: "figure.stand",
        summary: "Back pain lasting more than 3 months, mainly in the back rather than the legs, often blamed on worn discs or joints seen on scans. These changes are very common in people without pain too, so it can be hard to know which, if any, is the cause.",
        naturalHistory: [
            "Chronic back pain usually goes up and down rather than steadily worsening.",
            "Disc wear on MRI is common in people with no pain: about 1 in 3 people in their 20s and 9 in 10 people in their 60s.",
            "Many people improve with active rehabilitation, even after years of pain.",
        ],
        whenSurgeryIsOffered: ["Disabling back pain for more than 1–2 years despite a full trial of active rehabilitation, with changes at one or two levels."],
        urgentSigns: ["Back pain with fever, weight loss, a history of cancer, or new bladder or bowel problems — get checked promptly."],
        improvementDefinition: "Meaningful improvement in pain or disability (for example at least 30% better) at 1–2 years.",
        options: [
            TreatmentOption(
                id: "active-rehab", name: "Active rehabilitation and exercise", tier: .conservative,
                summary: "A graded exercise program, often supervised, building strength, fitness and confidence in movement.",
                whatHappens: ["Supervised exercise for 8–12 weeks, then a home or gym program.", "Any type of exercise you enjoy and keep up works — walking, Pilates, yoga, strength training."],
                anesthesia: "None", hospitalStay: "None", recovery: "Ongoing.",
                bestFor: ["Almost everyone with chronic back pain"],
                lessSuitableIf: ["Warning signs that haven't been checked"],
                outcomes: OptionOutcomes(improvement: PercentRange(35, 55), seriousComplications: PercentRange(0, 0.1), furtherTreatment: nil),
                keyFindings: ["Exercise reduces pain and improves function compared with no treatment, by a modest amount on average (Hayden 2021 Cochrane review)."],
                sideEffects: [SE.exerciseSoreness],
                evidence: .strong,
                availability: "Widely available. This app's Exercise tab has programs you can start today.",
                sources: ["Hayden JA et al. Cochrane 2021;CD009790", "Qaseem A et al. Ann Intern Med 2017;166:514–30"]),

            TreatmentOption(
                id: "multidisciplinary", name: "Pain psychology and multidisciplinary programs", tier: .conservative,
                summary: "Cognitive behavioral therapy, pain reprocessing or a combined program with exercise, education and psychology, aimed at reducing pain's grip on daily life.",
                whatHappens: ["Weekly sessions for 8–12 weeks, in person or online.", "Combined programs may be several days a week for a few weeks."],
                anesthesia: "None", hospitalStay: "None", recovery: "8–12 weeks.",
                bestFor: ["Long-standing pain, fear of movement, poor sleep or low mood linked to pain"],
                lessSuitableIf: [],
                outcomes: OptionOutcomes(improvement: PercentRange(35, 65), seriousComplications: nil, furtherTreatment: nil),
                keyFindings: [
                    "Multidisciplinary rehabilitation improves pain and disability more than usual care (Kamper 2015 review).",
                    "In a randomized trial, about 2 in 3 people who had pain reprocessing therapy were pain-free or nearly pain-free after treatment, vs about 1 in 10 with usual care (Ashar 2022).",
                    "Intensive rehabilitation with CBT gave similar results to spinal fusion in UK and Norwegian trials (Fairbank 2005; Brox 2003).",
                ],
                sideEffects: [SE.make("Temporary increase in distress", "Talking about pain can be uncomfortable at first.", 5, 15, .mild)],
                evidence: .moderate,
                availability: "Psychology for pain is increasingly available, including online; dedicated multidisciplinary programs are limited in some areas. Coverage varies.",
                sources: ["Kamper SJ et al. BMJ 2015;350:h444", "Ashar YK et al. JAMA Psychiatry 2022;79:13–23", "Fairbank J et al. BMJ 2005;330:1233"]),

            TreatmentOption(
                id: "clbp-medicines", name: "Medicines", tier: .conservative,
                summary: "Anti-inflammatories for flares and, for some people, duloxetine. Opioids are not recommended for long-term back pain.",
                whatHappens: ["Short courses of anti-inflammatories.", "Duloxetine (an antidepressant that also treats pain) taken daily."],
                anesthesia: "None", hospitalStay: "None", recovery: "—",
                bestFor: ["Short-term flares", "Pain with poor sleep or low mood (duloxetine)"],
                lessSuitableIf: ["Ulcers, kidney or heart disease (anti-inflammatories)"],
                outcomes: OptionOutcomes(improvement: PercentRange(20, 40), seriousComplications: PercentRange(0.2, 1), furtherTreatment: nil),
                keyFindings: ["Anti-inflammatories and duloxetine give small benefits on average (Qaseem 2017 guideline)."],
                sideEffects: [SE.nsaidStomach, SE.nsaidKidneyHeart, SE.nsaidBleed, SE.make("Nausea, dry mouth or sleepiness (duloxetine)", "Often eases after the first weeks.", 10, 30, .mild), SE.opioidRisks],
                evidence: .moderate,
                availability: "Widely available.",
                sources: ["Qaseem A et al. Ann Intern Med 2017;166:514–30"]),

            TreatmentOption(
                id: "facet-rfa", name: "Facet joint radiofrequency ablation", tier: .interventional,
                summary: "Heat from a needle tip disables the small nerves that carry pain from the facet joints. Usually done after test injections numb the joints and relieve pain.",
                whatHappens: ["One or two diagnostic numbing injections first.", "Then needles are placed under X-ray and the nerves are heated for about 90 seconds each."],
                anesthesia: "Local anesthetic, sometimes sedation", hospitalStay: "Outpatient", recovery: "Soreness for 1–2 weeks; effect can last 6–12 months before nerves regrow.",
                bestFor: ["Back pain that improved a lot after numbing injections of the facet nerves"],
                lessSuitableIf: ["Mainly leg pain", "No relief from test injections"],
                outcomes: OptionOutcomes(improvement: PercentRange(30, 50), seriousComplications: PercentRange(0, 0.5), furtherTreatment: PercentRange(30, 60)),
                keyFindings: [
                    "In the MINT trials (681 people), adding radiofrequency ablation to an exercise program made no clinically important difference at 3 months (Juch 2017).",
                    "Some smaller sham-controlled trials in carefully selected people have shown benefit; results are mixed.",
                ],
                sideEffects: [SE.make("Increased pain or burning for a few weeks", "From the treated nerves.", 5, 15, .mild), SE.make("Numb or tender patch of skin", "Usually temporary.", 1, 5, .mild), SE.injectionInfection],
                evidence: .moderate,
                availability: "Widely available; covered by Medicare with criteria (including successful test injections).",
                sources: ["Juch JNS et al. JAMA 2017;318:68–81", "Maas ET et al. Cochrane 2015;CD008572"]),

            TreatmentOption(
                id: "basivertebral", name: "Basivertebral nerve ablation", tier: .interventional,
                summary: "A probe passed into the vertebra under X-ray heats the nerve inside the bone that carries pain from the vertebral endplates. Only for people with specific MRI changes (Modic type 1 or 2).",
                whatHappens: ["Through small needle openings in the back, under X-ray.", "About 1 hour; home the same day."],
                anesthesia: "Sedation or general anesthesia", hospitalStay: "Outpatient", recovery: "A few days of soreness.",
                bestFor: ["Chronic back pain for at least 6 months with Modic type 1 or 2 changes at L3–S1"],
                lessSuitableIf: ["No Modic changes on MRI", "Mainly leg pain"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 70), seriousComplications: PercentRange(0, 1), furtherTreatment: PercentRange(5, 15)),
                keyFindings: [
                    "In a sham-controlled trial, real ablation improved disability more than sham at 3 months, but the difference was modest (Fischgrund 2018).",
                    "Compared with standard care (not sham), disability improved about 25 points vs 4 points on the ODI questionnaire at 3 months (Khalil 2019). Both trials were company-funded.",
                ],
                sideEffects: [SE.make("Temporary increased back pain", "For days to a few weeks after the procedure.", 5, 15, .mild), SE.make("Temporary leg pain or numbness", "From heat near a nerve; usually settles.", 1, 5, .mild), SE.make("Bone or nerve injury", "Rare.", 0.1, 1, .serious)],
                evidence: .limited,
                availability: "Newer procedure offered at selected pain and spine centers. Medicare covers it in many regions; private insurance varies.",
                sources: ["Fischgrund JS et al. Eur Spine J 2018;27:1146–56", "Khalil JG et al. Spine J 2019;19:1620–32"]),

            TreatmentOption(
                id: "disc-replacement", name: "Lumbar total disc replacement", tier: .lessInvasive,
                summary: "The worn disc is removed through the abdomen and replaced with an artificial disc that keeps movement at that level.",
                whatHappens: ["Surgery through the front (abdomen), with an access surgeon moving organs and blood vessels aside.", "The disc is removed and the implant placed."],
                anesthesia: "General anesthesia", hospitalStay: "1–3 days", recovery: "Light work 4–8 weeks.",
                bestFor: ["Pain from one or two discs in younger people without facet joint arthritis, after a full trial of rehabilitation"],
                lessSuitableIf: ["Osteoporosis, facet arthritis, slipped vertebra or previous abdominal surgery"],
                outcomes: OptionOutcomes(improvement: PercentRange(50, 65), seriousComplications: PercentRange(3, 10), furtherTreatment: PercentRange(5, 15)),
                keyFindings: ["Disc replacement gives results similar to or slightly better than fusion over 2–5 years, but neither is clearly better than intensive rehabilitation (Jacobs 2012 Cochrane review)."],
                sideEffects: [SE.anesthesia, SE.make("Blood vessel injury", "During the approach through the abdomen.", 1, 5, .serious), SE.make("Retrograde ejaculation (men)", "Semen goes into the bladder; may be permanent.", 1, 5, .moderate), SE.make("Implant moves or wears", "May need difficult revision surgery.", 1, 5, .serious), SE.make("Bowel slow to restart (ileus)", "Can mean a longer hospital stay.", 1, 5, .moderate), SE.clots(0.5, 2)],
                evidence: .moderate,
                availability: "Offered at selected centers. Many insurers don't cover it, and Medicare doesn't cover it for people over 60.",
                sources: ["Jacobs W et al. Cochrane 2012;CD008326"]),

            TreatmentOption(
                id: "clbp-fusion", name: "Lumbar fusion", tier: .traditional,
                summary: "Joining one or two vertebrae so the painful level no longer moves, with screws, rods, cages and bone graft.",
                whatHappens: ["Done from the back, side or front, open or minimally invasive.", "Bone takes 6–12 months to fuse."],
                anesthesia: "General anesthesia", hospitalStay: "2–5 days", recovery: "Light work 6–12 weeks; full recovery 6–12 months.",
                bestFor: ["Severe, long-standing pain from one or two levels after rehabilitation has truly been tried"],
                lessSuitableIf: ["Pain at many levels", "Untreated depression or anxiety, smoking, or compensation claims (linked to poorer results)"],
                outcomes: OptionOutcomes(improvement: PercentRange(40, 60), seriousComplications: PercentRange(10, 20), furtherTreatment: PercentRange(10, 25)),
                keyFindings: [
                    "In UK (349 people) and Norwegian trials, fusion was no better than intensive rehabilitation with CBT at 2 years (Fairbank 2005; Brox 2003). Long-term follow-up found no difference (Mannion 2013).",
                    "A Swedish trial found fusion better than usual physical therapy (Fritzell 2001).",
                ],
                sideEffects: [SE.anesthesia, SE.make("Blood transfusion", "More likely with longer or multi-level operations.", 5, 15, .moderate), SE.woundInfection(2, 5), SE.make("Bones don't fuse (nonunion)", "May cause pain and need another operation. Smoking raises the risk.", 5, 15, .serious), SE.make("Wear at the next level (adjacent segment disease)", "The levels next to the fusion take more strain over the years and may need surgery later.", 10, 20, .moderate), SE.duralTear(2, 6), SE.nerveInjury(0.5, 2), SE.clots(0.5, 2), SE.make("Back pain not improved", "Fusion helps back pain less reliably than decompression helps leg pain.", 30, 50, .moderate)],
                evidence: .strong,
                availability: "Widely available. Many insurers require documented rehabilitation and psychological screening first.",
                sources: ["Fairbank J et al. BMJ 2005;330:1233", "Brox JI et al. Spine 2003;28:1913–21", "Fritzell P et al. Spine 2001;26:2521–32", "Mannion AF et al. Ann Rheum Dis 2013;72:1882–8"]),
        ],
        comparisons: [
            ComparisonStudy(name: "UK MRC spine stabilisation trial", compared: "Fusion vs intensive rehabilitation with CBT (349 people)",
                finding: "No clinically important difference at 2 years.", citation: "Fairbank 2005, BMJ"),
            ComparisonStudy(name: "Norwegian fusion trial", compared: "Fusion vs cognitive intervention and exercise",
                finding: "Similar results at 1 year and in long-term follow-up.", citation: "Brox 2003, Spine; Mannion 2013, Ann Rheum Dis"),
            ComparisonStudy(name: "Swedish Lumbar Spine Study", compared: "Fusion vs usual physical therapy (294 people)",
                finding: "Fusion gave better results than usual care at 2 years.", citation: "Fritzell 2001, Spine"),
            ComparisonStudy(name: "MINT trials", compared: "Radiofrequency ablation plus exercise vs exercise alone (681 people)",
                finding: "No clinically important added benefit from ablation at 3 months.", citation: "Juch 2017, JAMA"),
        ],
        questionsToAsk: [
            "How sure are we that this disc or joint is the source of my pain?",
            "Have I had a full trial of active rehabilitation and pain psychology?",
            "What are the chances fusion will reduce my back pain, not just change it?",
            "Do I have Modic changes that might make basivertebral nerve ablation an option?",
        ])
}
