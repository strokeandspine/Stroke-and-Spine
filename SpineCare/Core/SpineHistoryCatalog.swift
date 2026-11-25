import Foundation

enum HistoryKind: String, CaseIterable, Codable, Identifiable {
    case surgery, procedure, imaging, therapy, other
    var id: String { rawValue }

    var label: String {
        switch self {
        case .surgery: return "Surgery"
        case .procedure: return "Injection or procedure"
        case .imaging: return "Imaging or test"
        case .therapy: return "Therapy course"
        case .other: return "Other"
        }
    }

    var symbol: String {
        switch self {
        case .surgery: return "cross.case"
        case .procedure: return "syringe"
        case .imaging: return "waveform.path.ecg.rectangle"
        case .therapy: return "figure.walk"
        case .other: return "doc.text"
        }
    }
}

/// Plain-language descriptions and general recovery guidance for common spine treatments.
/// All guidance is general. The patient's own surgeon's instructions always come first.
struct TreatmentInfo: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let kind: HistoryKind
    let summary: String
    let whatToExpect: [String]
    /// Extra warning signs specific to this treatment (on top of the general post-procedure list).
    let callYourDoctorIf: [String]
}

enum SpineHistoryCatalog {
    static let spinalLevels = ["T12–L1", "L1–L2", "L2–L3", "L3–L4", "L4–L5", "L5–S1", "Sacroiliac (SI) joint", "Sacrum / coccyx"]
    static let sides = ["", "Left", "Right", "Both", "Center"]

    static let generalDisclaimer = "This is general information to help you understand your recovery. Your surgeon's or doctor's instructions for you always come first."

    /// Warning signs after any spine surgery or procedure.
    static let generalWarningSigns = [
        "Temperature of 101°F (38.3°C) or higher, or shaking chills",
        "Wound that is red, swollen, hot, leaking fluid or pus, or opening up",
        "New or worsening weakness or numbness in your legs",
        "New trouble controlling your bladder or bowels, or numbness around your genitals or bottom — call 911",
        "Pain, swelling or warmth in one calf",
        "Chest pain or sudden shortness of breath — call 911",
        "Pain that is suddenly much worse and not controlled by your medicines",
    ]

    static let treatments: [TreatmentInfo] = [
        // Surgeries
        TreatmentInfo(name: "Microdiscectomy", kind: .surgery,
            summary: "Removal of the part of a disc that is pressing on a nerve, usually to relieve leg pain (sciatica).",
            whatToExpect: [
                "Leg pain often improves quickly. Numbness and tingling can take weeks to months to settle.",
                "Short walks are usually encouraged from the first day. Build up gradually.",
                "Many surgeons advise avoiding heavy lifting, bending and twisting for the first few weeks.",
                "Desk work is often possible after 1–4 weeks; physical jobs usually take longer.",
                "Physical therapy commonly starts a few weeks after surgery.",
            ],
            callYourDoctorIf: ["Leg pain comes back suddenly and severely, as it did before surgery", "Clear fluid leaks from the wound or you have a headache that is worse when sitting up"]),
        TreatmentInfo(name: "Laminectomy / decompression", kind: .surgery,
            summary: "Removal of bone and/or thickened ligament to make more room for the nerves, often for spinal stenosis.",
            whatToExpect: [
                "Walking tolerance often improves over the first weeks to months.",
                "Walking is usually encouraged from the first day.",
                "Lifting, bending and twisting are often limited for several weeks.",
                "Recovery is usually faster than after a fusion.",
            ],
            callYourDoctorIf: ["Clear fluid leaks from the wound or you have a headache that is worse when sitting up"]),
        TreatmentInfo(name: "Spinal fusion (TLIF / PLIF / ALIF / XLIF / LLIF)", kind: .surgery,
            summary: "Joining two or more vertebrae with a bone graft and usually screws, rods or a cage so they heal into one solid bone.",
            whatToExpect: [
                "Bone fusion takes months — often 6 to 12 months to become solid.",
                "Many surgeons use \"BLT\" precautions early on: no Bending, Lifting (often more than 10 lb) or Twisting.",
                "Walking is usually the main exercise in the first weeks. Increase a little each day.",
                "Not smoking or vaping nicotine is one of the most important things you can do — nicotine makes fusion less likely to heal.",
                "Your surgeon may ask you to avoid NSAIDs (like ibuprofen or naproxen) for a while because they may slow bone healing. Ask before taking them.",
                "Good protein, calcium and vitamin D intake supports bone healing.",
                "Follow-up X-rays are usually taken to check healing.",
            ],
            callYourDoctorIf: ["You hear or feel a click or pop with a sudden increase in pain"]),
        TreatmentInfo(name: "Artificial disc replacement", kind: .surgery,
            summary: "Replacing a worn disc with a moving implant to keep motion at that level.",
            whatToExpect: [
                "Walking is usually encouraged early.",
                "Your surgeon will advise on movement limits while the implant settles.",
                "Tell anyone who orders an MRI or other scan that you have a disc implant.",
            ],
            callYourDoctorIf: []),
        TreatmentInfo(name: "Kyphoplasty / vertebroplasty", kind: .surgery,
            summary: "Injecting bone cement into a fractured vertebra to stabilize it and reduce pain.",
            whatToExpect: [
                "Pain relief often begins within days.",
                "Ask your doctor about bone density testing and osteoporosis treatment to prevent further fractures.",
            ],
            callYourDoctorIf: ["New sudden back pain at a different level"]),
        TreatmentInfo(name: "Sacroiliac (SI) joint fusion", kind: .surgery,
            summary: "Fusing the joint between the spine and pelvis with implants.",
            whatToExpect: ["You may be asked to limit weight on the operated side, sometimes with crutches or a walker, for a few weeks."],
            callYourDoctorIf: []),
        TreatmentInfo(name: "Spinal cord stimulator implant", kind: .surgery,
            summary: "A device that sends mild electrical pulses to the spinal cord to change how pain signals are felt.",
            whatToExpect: [
                "Avoid raising your arms over your head, bending and twisting for about 6 weeks while the leads settle, unless told otherwise.",
                "Keep your device ID card with you and check MRI safety with your device company before any scan.",
            ],
            callYourDoctorIf: ["The stimulation feels very different or stops working", "Redness or swelling over the battery site"]),

        // Procedures
        TreatmentInfo(name: "Epidural steroid injection", kind: .procedure,
            summary: "A steroid and numbing medicine injected near the irritated nerve roots to reduce inflammation and leg or back pain.",
            whatToExpect: [
                "Numbness or relief right after may be from the local anesthetic and can wear off within hours.",
                "The steroid usually starts working in 2–7 days.",
                "Relief can last weeks to months and varies a lot from person to person.",
                "Steroids can raise blood sugar for a few days. If you have diabetes, check your sugars more often.",
                "Some people have facial flushing, trouble sleeping or a temporary increase in pain.",
                "Logging your pain for 2 weeks afterwards helps your doctor decide on next steps.",
            ],
            callYourDoctorIf: ["Severe headache that is worse when sitting or standing", "Fever, or redness or swelling at the injection site"]),
        TreatmentInfo(name: "Facet joint injection", kind: .procedure,
            summary: "Steroid and/or numbing medicine injected into the small joints at the back of the spine.",
            whatToExpect: ["Track how much relief you get in the hours and days afterwards — this helps your doctor understand where the pain comes from."],
            callYourDoctorIf: ["Fever, or redness or swelling at the injection site"]),
        TreatmentInfo(name: "Medial branch block", kind: .procedure,
            summary: "A test injection that numbs the small nerves to the facet joints to see whether they are the source of pain.",
            whatToExpect: [
                "This is a diagnostic test. Relief usually lasts only hours.",
                "Record your pain (0–10) before the block and every hour or so for 6–8 hours afterwards. Your doctor uses the % relief to decide whether radiofrequency ablation might help.",
            ],
            callYourDoctorIf: []),
        TreatmentInfo(name: "Radiofrequency ablation (RFA)", kind: .procedure,
            summary: "Heat is used to switch off the small nerves that carry pain from the facet or SI joints.",
            whatToExpect: [
                "Soreness or a sunburn-like feeling for 1–3 weeks is common.",
                "Full benefit usually shows within 2–4 weeks.",
                "Relief often lasts 6–12 months or longer. The nerves can regrow, and the procedure can usually be repeated.",
            ],
            callYourDoctorIf: ["New numbness or weakness in a leg"]),
        TreatmentInfo(name: "Sacroiliac (SI) joint injection", kind: .procedure,
            summary: "Steroid and numbing medicine injected into the joint between the spine and pelvis.",
            whatToExpect: ["Track relief in the first hours (numbing) and after several days (steroid)."],
            callYourDoctorIf: []),
        TreatmentInfo(name: "Spinal cord stimulator trial", kind: .procedure,
            summary: "Temporary leads are placed for about a week to test whether a stimulator helps before a permanent implant.",
            whatToExpect: ["Keep the dressing dry and avoid bending and twisting during the trial.", "Log your pain, sleep and activity daily — the trial is judged on how much these improve."],
            callYourDoctorIf: ["Fluid leaking from the lead site, or fever"]),
        TreatmentInfo(name: "Basivertebral nerve ablation", kind: .procedure,
            summary: "Heat is used to switch off a nerve inside the vertebra that can carry pain from the vertebral endplates.",
            whatToExpect: ["Some soreness for a few days is common. Benefit is usually judged over weeks to months."],
            callYourDoctorIf: []),
        TreatmentInfo(name: "Trigger point injection", kind: .procedure,
            summary: "Numbing medicine (sometimes with a steroid) injected into a tight, tender muscle knot.",
            whatToExpect: ["Gentle stretching after the injection can help."],
            callYourDoctorIf: []),

        // Imaging and tests
        TreatmentInfo(name: "MRI", kind: .imaging,
            summary: "Detailed pictures of discs, nerves and soft tissues.",
            whatToExpect: ["Many MRI findings, like disc bulges and degeneration, are common in people without any pain and become more common with age. Your doctor will explain what matters for you."],
            callYourDoctorIf: []),
        TreatmentInfo(name: "X-ray", kind: .imaging, summary: "Pictures of the bones, alignment and, after fusion, how the bone is healing.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "CT scan", kind: .imaging, summary: "Detailed pictures of bone.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "EMG / nerve conduction study", kind: .imaging, summary: "Tests how well nerves and muscles are working.", whatToExpect: [], callYourDoctorIf: []),

        // Therapy
        TreatmentInfo(name: "Physical therapy", kind: .therapy, summary: "A course of exercise-based treatment with a physical therapist.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "Chiropractic care", kind: .therapy, summary: "Spinal manipulation and related treatments.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "Acupuncture", kind: .therapy, summary: "Fine needles placed at specific points.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "Massage therapy", kind: .therapy, summary: "Hands-on soft tissue treatment.", whatToExpect: [], callYourDoctorIf: []),
        TreatmentInfo(name: "Pain psychology / CBT", kind: .therapy, summary: "Talking therapy that teaches skills to cope with and reduce the impact of pain.", whatToExpect: [], callYourDoctorIf: []),
    ]

    static func treatments(for kind: HistoryKind) -> [TreatmentInfo] {
        treatments.filter { $0.kind == kind }
    }

    static func info(named name: String) -> TreatmentInfo? {
        treatments.first { $0.name == name }
    }
}
