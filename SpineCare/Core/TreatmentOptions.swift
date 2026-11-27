import Foundation

// DRAFT CONTENT — the treatment-options module was drafted by Claude and needs review by a
// surgeon in each specialty before release. Numbers are approximate ranges taken from the cited
// studies and reviews, and each one must be checked against its source (see docs/CONTENT_REVIEW.md).
//
// Purpose: help a patient who has been offered surgery see the full range of options —
// conservative care, interventional procedures, minimally invasive and less invasive surgery, and
// traditional open surgery — with outcomes and side effects in plain language and natural frequencies.
// It never recommends a treatment and always sends the patient back to their own clinicians.

enum TreatmentOptionsContent {
    static let version = "Draft 0.1 — not yet clinically reviewed"

    static let disclaimer = "This is general information to help you talk with your surgeon. It is not advice about what you should do. The numbers come from studies of groups of people, so your own chances may be higher or lower. Your health, scans, job and goals all matter, and only your own doctors can weigh those."

    static let differentStudiesCaveat = "These numbers come from different studies, with different patients, follow-up times and definitions of success. Unless a trial below compared options directly, don't read small differences between bars as one option being better."
}

// MARK: - Approach tiers

/// How invasive an approach is, from least to most.
enum ApproachTier: Int, CaseIterable, Identifiable, Comparable {
    case conservative = 0
    case interventional
    case minimallyInvasive
    case lessInvasive
    case traditional

    var id: Int { rawValue }
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .conservative: return "Non-operative and conservative care"
        case .interventional: return "Interventional procedures"
        case .minimallyInvasive: return "Minimally invasive surgery"
        case .lessInvasive: return "Less invasive surgery"
        case .traditional: return "Traditional (open) surgery"
        }
    }

    var shortLabel: String {
        switch self {
        case .conservative: return "Conservative"
        case .interventional: return "Interventional"
        case .minimallyInvasive: return "Minimally invasive"
        case .lessInvasive: return "Less invasive"
        case .traditional: return "Open surgery"
        }
    }

    var explanation: String {
        switch self {
        case .conservative:
            return "No operation. Includes watchful waiting or active monitoring, lifestyle changes, physical therapy, medicines, devices such as braces, pessaries or CPAP, and treating the underlying cause. For many conditions this is the first choice and works for a lot of people."
        case .interventional:
            return "Procedures done through a needle, catheter or natural opening, guided by X-ray, ultrasound, a scope or a laser — usually without a surgical incision. Examples: injections, nerve ablation, angioplasty and stents, embolization, ERCP, lithotripsy and laser treatments."
        case .minimallyInvasive:
            return "Surgery through small incisions using cameras and long instruments (laparoscopic, robotic, thoracoscopic, arthroscopic or endoscopic surgery), or devices placed through the skin or blood vessels. Usually less pain and a shorter stay, though long-term results are often similar to open surgery."
        case .lessInvasive:
            return "Smaller or more limited operations than the traditional approach — removing only part of an organ, preserving a joint, valve or organ instead of replacing or removing it, or using a smaller incision."
        case .traditional:
            return "Standard open surgery through a larger incision, such as an open repair, removal of an organ or a joint replacement. Sometimes this is the most reliable or the only safe option."
        }
    }

    var symbol: String {
        switch self {
        case .conservative: return "figure.walk"
        case .interventional: return "syringe"
        case .minimallyInvasive: return "smallcircle.filled.circle"
        case .lessInvasive: return "scissors"
        case .traditional: return "cross.case"
        }
    }

    /// 1–5 dots shown in comparisons.
    var invasivenessScore: Int { rawValue + 1 }
}

// MARK: - Specialties

enum SurgicalSpecialty: String, CaseIterable, Identifiable {
    case spine, orthopedic, neurosurgery, vascular, cardiothoracic, general, hepatobiliary
    case urologic, gynecologic, ent, ophthalmic, trauma, pediatric

    var id: String { rawValue }

    var label: String {
        switch self {
        case .spine: return "Spine"
        case .orthopedic: return "Orthopedic (bones and joints)"
        case .neurosurgery: return "Neurosurgery (brain and nerves)"
        case .vascular: return "Vascular (arteries and veins)"
        case .cardiothoracic: return "Heart and chest"
        case .general: return "General surgery"
        case .hepatobiliary: return "Liver, gallbladder and pancreas"
        case .urologic: return "Urologic (kidney, bladder, prostate)"
        case .gynecologic: return "Gynecologic"
        case .ent: return "Ear, nose and throat (ENT)"
        case .ophthalmic: return "Eye surgery"
        case .trauma: return "Injuries (trauma)"
        case .pediatric: return "Children's surgery"
        }
    }

    var symbol: String {
        switch self {
        case .spine: return "figure.stand"
        case .orthopedic: return "figure.walk"
        case .neurosurgery: return "brain.head.profile"
        case .vascular: return "drop"
        case .cardiothoracic: return "heart"
        case .general: return "cross.case"
        case .hepatobiliary: return "leaf"
        case .urologic: return "drop.triangle"
        case .gynecologic: return "staroflife.circle"
        case .ent: return "ear"
        case .ophthalmic: return "eye"
        case .trauma: return "bandage"
        case .pediatric: return "figure.and.child.holdinghands"
        }
    }
}

// MARK: - Numbers

/// A percentage range, for example 5–15% of people.
struct PercentRange: Hashable {
    let low: Double
    let high: Double

    init(_ low: Double, _ high: Double) {
        self.low = low
        self.high = high
    }

    var midpoint: Double { (low + high) / 2 }

    /// "5–15%" or "about 3%".
    var percentText: String {
        if low == high { return "about \(RiskFormat.number(low))%" }
        return "\(RiskFormat.number(low))–\(RiskFormat.number(high))%"
    }

    /// "About 5 to 15 in 100 people".
    var naturalFrequency: String { RiskFormat.naturalFrequency(low: low, high: high) }
}

enum RiskFormat {
    /// Drops a trailing ".0" and keeps one decimal place otherwise.
    static func number(_ value: Double) -> String {
        let tenths = (value * 10).rounded() / 10 // avoids 0.05 × 100 printing as 5.0
        if tenths == tenths.rounded() { return String(Int(tenths)) }
        return String(format: "%.1f", tenths)
    }

    /// Expresses a percentage range as "X in 100", "X in 1,000" or "X in 10,000" — whichever
    /// gives whole numbers that are easy to picture.
    static func naturalFrequency(low: Double, high: Double) -> String {
        let (scale, label): (Double, String)
        if high >= 1 { (scale, label) = (1, "100") }
        else if high >= 0.1 { (scale, label) = (10, "1,000") }
        else { (scale, label) = (100, "10,000") }

        func scaled(_ v: Double) -> String { number(v * scale >= 10 ? (v * scale).rounded() : v * scale) }

        if high * scale < 1 { return "Fewer than 1 in \(label) people" }
        let hi = scaled(high)
        if low * scale < 1 { return "Up to \(hi) in \(label) people" }
        let lo = scaled(low)
        if lo == hi { return "About \(lo) in \(label) people" }
        return "About \(lo) to \(hi) in \(label) people"
    }
}

/// Plain-language frequency bands (the same words used in drug leaflets).
enum FrequencyBand: Int, CaseIterable, Comparable {
    case veryRare, rare, uncommon, common, veryCommon

    init(percent: Double) {
        switch percent {
        case 10...: self = .veryCommon
        case 1..<10: self = .common
        case 0.1..<1: self = .uncommon
        case 0.01..<0.1: self = .rare
        default: self = .veryRare
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .veryCommon: return "Very common"
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .veryRare: return "Very rare"
        }
    }

    var definition: String {
        switch self {
        case .veryCommon: return "more than 1 in 10 people"
        case .common: return "1 to 10 in 100 people"
        case .uncommon: return "1 to 10 in 1,000 people"
        case .rare: return "1 to 10 in 10,000 people"
        case .veryRare: return "fewer than 1 in 10,000 people"
        }
    }
}

// MARK: - Side effects and outcomes

struct SideEffect: Identifiable, Hashable {
    enum Severity: Int, CaseIterable, Comparable {
        case mild, moderate, serious
        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        var label: String {
            switch self {
            case .mild: return "Mild"
            case .moderate: return "Moderate"
            case .serious: return "Serious"
            }
        }

        var explanation: String {
            switch self {
            case .mild: return "Usually short-lived and settles on its own"
            case .moderate: return "May need treatment or slow your recovery"
            case .serious: return "May need more surgery, a hospital stay or cause lasting harm"
            }
        }
    }

    let name: String
    let detail: String
    let chance: PercentRange
    let severity: Severity

    var id: String { name }
    var band: FrequencyBand { FrequencyBand(percent: chance.midpoint) }
}

/// The three numbers compared across options for a condition.
struct OptionOutcomes: Hashable {
    /// Share of people with a meaningful improvement (definition and time point are set per condition).
    var improvement: PercentRange?
    /// Share with a serious or major complication.
    var seriousComplications: PercentRange?
    /// Share who go on to have further surgery or a repeat procedure.
    var furtherTreatment: PercentRange?
}

enum OutcomeMeasure: String, CaseIterable, Identifiable {
    case improvement = "Meaningful improvement"
    case seriousComplications = "Serious complications"
    case furtherTreatment = "Further surgery or repeat procedure"
    var id: String { rawValue }

    var higherIsBetter: Bool { self == .improvement }

    func value(in outcomes: OptionOutcomes) -> PercentRange? {
        switch self {
        case .improvement: return outcomes.improvement
        case .seriousComplications: return outcomes.seriousComplications
        case .furtherTreatment: return outcomes.furtherTreatment
        }
    }
}

enum EvidenceStrength: Int, Comparable {
    case veryLimited, limited, moderate, strong
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .strong: return "Strong"
        case .moderate: return "Moderate"
        case .limited: return "Limited"
        case .veryLimited: return "Very limited"
        }
    }

    var explanation: String {
        switch self {
        case .strong: return "Several good randomized trials agree."
        case .moderate: return "At least one good randomized trial, or several smaller trials that broadly agree."
        case .limited: return "Small trials, trials without a sham or control group, or mostly observational studies."
        case .veryLimited: return "Case series, expert opinion or company-funded studies without a fair comparison."
        }
    }
}

// MARK: - Options and conditions

struct TreatmentOption: Identifiable, Hashable {
    let id: String
    let name: String
    let tier: ApproachTier
    let summary: String
    let whatHappens: [String]
    let anesthesia: String
    let hospitalStay: String
    let recovery: String
    let bestFor: [String]
    let lessSuitableIf: [String]
    let outcomes: OptionOutcomes
    /// Plain-language results with the study they came from.
    let keyFindings: [String]
    let sideEffects: [SideEffect]
    let evidence: EvidenceStrength
    /// Why a surgeon might not have mentioned it: availability, insurance, training.
    let availability: String
    let sources: [String]

    var sideEffectsByRisk: [SideEffect] {
        sideEffects.sorted { ($0.severity, $0.chance.midpoint) > ($1.severity, $1.chance.midpoint) }
    }

    var seriousSideEffects: [SideEffect] { sideEffects.filter { $0.severity == .serious } }
}

/// A trial or review that compared options directly.
struct ComparisonStudy: Identifiable, Hashable {
    let name: String
    let compared: String
    let finding: String
    let citation: String
    var id: String { name }
}

struct ConditionGuide: Identifiable, Hashable {
    let id: String
    let name: String
    let alsoCalled: String
    let symbol: String
    let summary: String
    /// What usually happens without surgery.
    let naturalHistory: [String]
    /// When surgery is usually offered.
    let whenSurgeryIsOffered: [String]
    /// Situations where waiting can cause lasting harm.
    let urgentSigns: [String]
    /// What "meaningful improvement" means for this condition and when it was measured.
    let improvementDefinition: String
    let options: [TreatmentOption]
    let comparisons: [ComparisonStudy]
    let questionsToAsk: [String]
    /// Defaults to spine so the original spine content needs no change.
    var specialty: SurgicalSpecialty = .spine

    func options(in tier: ApproachTier) -> [TreatmentOption] { options.filter { $0.tier == tier } }
    var tiers: [ApproachTier] { ApproachTier.allCases.filter { !options(in: $0).isEmpty } }
    func option(_ id: String) -> TreatmentOption? { options.first { $0.id == id } }
}

enum TreatmentGuides {
    static let all: [ConditionGuide] = {
        var guides = lumbar + otherRegions
        guides += vascular + cardiothoracic + trauma
        guides += generalSurgery + hepatobiliary + pediatric
        guides += orthopedic + neurosurgery + ent
        guides += urologic + gynecologic + ophthalmic
        return guides
    }()

    static func guides(for specialty: SurgicalSpecialty) -> [ConditionGuide] { all.filter { $0.specialty == specialty } }

    static func search(_ text: String) -> [ConditionGuide] {
        let q = text.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { g in
            [g.name, g.alsoCalled, g.specialty.label].contains { $0.lowercased().contains(q) }
                || g.options.contains { $0.name.lowercased().contains(q) }
        }
    }

    static func guide(_ id: String) -> ConditionGuide? { all.first { $0.id == id } }

    /// Questions worth asking about any operation.
    static let generalQuestions = [
        "What is likely to happen if I wait, or don't have surgery at all?",
        "What non-surgical and less invasive options are there for my condition — including ones you don't offer yourself?",
        "Why do you think surgery is the best option for me now?",
        "What are the chances this operation helps my main symptom? Leg pain and back pain often respond differently.",
        "How many of these operations do you do each year, and what are your own complication and repeat-surgery rates?",
        "Could a smaller or less invasive version of this operation work for me? Is any implant really needed?",
        "What will recovery look like — hospital stay, time off work or school, driving, lifting — and who will help me?",
        "Does this operation have to happen now, or is it safe to take time to decide?",
        "What happens if it doesn't work, or my symptoms come back?",
        "Is there a trial of physical therapy or another treatment you'd want me to try first?",
        "Do you have any financial relationship with the company that makes the device or implant?",
        "Would you support me getting a second opinion?",
    ]

    /// Reasons a surgeon may not have mentioned an option. Shown so patients know to ask, not to sow distrust.
    static let whyNotMentioned = [
        "It isn't suitable for your scans, symptoms or other health conditions.",
        "Your surgeon doesn't perform it, or it isn't available nearby.",
        "The evidence for it is weak, or newer studies found it works no better than a sham (placebo) procedure.",
        "Your insurance or Medicare may not cover it.",
        "It's an emergency, and there isn't time or it isn't safe to try other options first.",
        "You've already tried it, or it's usually tried by your primary care doctor or physical therapist rather than a surgeon.",
    ]

    static let readingTheNumbers = [
        "\"5 in 100 people\" means that if 100 people like those in the studies had this treatment, about 5 would have that result. It doesn't tell you whether you'll be one of the 5.",
        "Ranges (for example 5–15 in 100) show that different studies found different numbers. Hospitals, surgeons and patients vary.",
        "Randomized trials are the fairest comparison. Sham-controlled trials — where some people get a fake procedure — show how much of the benefit comes from the treatment itself rather than expectation and time.",
        "Many people get better over time whatever treatment they have. That's why comparing with no treatment, or with a sham, matters.",
        "In surgery-versus-non-surgery trials, many people switch groups. That can make the two groups look more alike than the treatments really are.",
        "Studies paid for by device makers aren't necessarily wrong, but independent studies are more trustworthy.",
        "Ask your surgeon for their own numbers. Their results may be better or worse than the averages here.",
    ]

    static let secondOpinion = [
        "It's normal and expected to get a second opinion before planned (non-emergency) surgery. Most surgeons welcome it.",
        "Medicare and many insurers cover a second surgical opinion. Check with your plan.",
        "Consider asking a different kind of specialist too — for example an interventional radiologist, cardiologist, gastroenterologist, physiatrist or physical therapist — who can explain the non-operative and interventional options.",
        "In an emergency, don't delay treatment to get a second opinion. Ask the team to explain the options and the risks of waiting.",
        "Bring your scans (the images, not just the reports), test results, your symptom history and your questions.",
    ]
}

// MARK: - Shortlist and discussion sheet

/// Options the patient has saved to discuss with their surgeon. Stored as "conditionID/optionID".
struct OptionShortlist: Equatable {
    private(set) var keys: [String]

    init(stored: String) {
        keys = stored.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }

    var stored: String { keys.joined(separator: ",") }

    static func key(_ guide: ConditionGuide, _ option: TreatmentOption) -> String { "\(guide.id)/\(option.id)" }

    func contains(_ guide: ConditionGuide, _ option: TreatmentOption) -> Bool { keys.contains(Self.key(guide, option)) }

    mutating func toggle(_ guide: ConditionGuide, _ option: TreatmentOption) {
        let k = Self.key(guide, option)
        if let i = keys.firstIndex(of: k) { keys.remove(at: i) } else { keys.append(k) }
    }

    struct Item: Identifiable {
        let guide: ConditionGuide
        let option: TreatmentOption
        var id: String { OptionShortlist.key(guide, option) }
    }

    /// Resolves stored keys to content, skipping any that no longer exist.
    var items: [Item] {
        keys.compactMap { key in
            let parts = key.split(separator: "/").map(String.init)
            guard parts.count == 2, let g = TreatmentGuides.guide(parts[0]), let o = g.option(parts[1]) else { return nil }
            return Item(guide: g, option: o)
        }
    }
}

enum DiscussionSheet {
    /// Plain text the patient can share, print or read from at the appointment.
    static func text(for shortlist: OptionShortlist, name: String = "") -> String {
        var lines: [String] = []
        lines.append("Treatment options I'd like to discuss" + (name.isEmpty ? "" : " — \(name)"))
        lines.append("")
        let items = shortlist.items
        if items.isEmpty {
            lines.append("(No options saved yet.)")
        }
        for item in items {
            let guide = item.guide, option = item.option
            lines.append("• \(option.name) (\(option.tier.shortLabel)) — for \(guide.name)")
            if let imp = option.outcomes.improvement { lines.append("   Meaningful improvement: \(imp.naturalFrequency.lowercasedFirst)") }
            if let ser = option.outcomes.seriousComplications { lines.append("   Serious complications: \(ser.naturalFrequency.lowercasedFirst)") }
            if let fur = option.outcomes.furtherTreatment { lines.append("   Further surgery or repeat procedure: \(fur.naturalFrequency.lowercasedFirst)") }
            lines.append("   Is this suitable for me? Why or why not?")
        }
        lines.append("")
        lines.append("Questions")
        for q in TreatmentGuides.generalQuestions { lines.append("• \(q)") }
        lines.append("")
        lines.append("Numbers are approximate averages from published studies (Stroke & Spine, \(TreatmentOptionsContent.version)). They are not personal advice.")
        return lines.joined(separator: "\n")
    }
}

extension String {
    var lowercasedFirst: String { prefix(1).lowercased() + dropFirst() }
}
