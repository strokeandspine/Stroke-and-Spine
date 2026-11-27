import Foundation

enum PainLocation: String, CaseIterable, Codable, Identifiable {
    case upperBack, midBack, lowerBack, neck, hip, groin, thigh, knee, wrist, shoulder, ribs, jaw, feet, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .upperBack: return "Upper back"
        case .midBack: return "Mid back"
        case .lowerBack: return "Lower back"
        case .neck: return "Neck"
        case .hip: return "Hip"
        case .groin: return "Groin"
        case .thigh: return "Thigh"
        case .knee: return "Knee"
        case .wrist: return "Wrist"
        case .shoulder: return "Shoulder"
        case .ribs: return "Ribs"
        case .jaw: return "Jaw or mouth"
        case .feet: return "Feet"
        case .other: return "Other"
        }
    }

    var isBack: Bool { [.upperBack, .midBack, .lowerBack].contains(self) }
}

/// PEG: a 3-item pain scale (Krebs et al., J Gen Intern Med 2009). Public domain.
enum PEGScale {
    static let questions = [
        "What number best describes your pain on average in the past week?",
        "What number best describes how, during the past week, pain has interfered with your enjoyment of life?",
        "What number best describes how, during the past week, pain has interfered with your general activity?",
    ]

    static let lowLabels = ["No pain", "Does not interfere", "Does not interfere"]
    static let highLabels = ["Pain as bad as you can imagine", "Completely interferes", "Completely interferes"]

    /// The mean of the three items (0–10). Returns nil unless all three are answered.
    static func score(_ answers: [Int?]) -> Double? {
        let values = answers.compactMap { $0 }
        guard answers.count == 3, values.count == 3, values.allSatisfy({ (0...10).contains($0) }) else { return nil }
        return Double(values.reduce(0, +)) / 3
    }

    /// A 30% drop is generally considered a meaningful improvement.
    static func describeChange(from old: Double, to new: Double) -> String {
        guard old > 0 else { return new > 0 ? "Higher than last time" : "About the same as last time" }
        let change = (new - old) / old
        if change <= -0.3 { return "Meaningfully better than last time" }
        if change >= 0.3 { return "Meaningfully worse than last time" }
        return "About the same as last time"
    }
}

struct PainAlertInput {
    var score: Int
    var locations: Set<PainLocation>
    var isNewAndSudden: Bool
    var afterFall: Bool
    var takesAntiresorptive: Bool
}

enum PainAlerts {
    static func warnings(_ input: PainAlertInput) -> [SafetyWarning] {
        var result: [SafetyWarning] = []
        let back = input.locations.contains { $0.isBack } || input.locations.contains(.ribs)
        if input.afterFall && (input.locations.contains(.hip) || input.locations.contains(.groin)) && input.score >= 5 {
            result.append(SafetyWarning(id: "pain-hip-after-fall", severity: .stop,
                message: "Hip or groin pain after a fall can mean a broken hip. If you can't put weight on the leg, call 911. Otherwise, get seen today."))
        }
        if back && input.isNewAndSudden && input.score >= 4 {
            result.append(SafetyWarning(id: "pain-vertebral", severity: .caution,
                message: "Sudden new back pain — especially after bending, lifting, coughing or a minor fall — can be a sign of a spine (compression) fracture. Contact your doctor; they may order an X-ray."))
        } else if input.afterFall && input.score >= 4 && !input.locations.isEmpty {
            result.append(SafetyWarning(id: "pain-after-fall", severity: .caution,
                message: "New pain after a fall can mean a broken bone, even when the fall seemed minor. Contact your doctor today."))
        }
        if input.takesAntiresorptive && (input.locations.contains(.thigh) || input.locations.contains(.groin)) {
            result.append(SafetyWarning(id: "pain-aff", severity: .caution,
                message: "New thigh or groin pain in someone taking a bisphosphonate or denosumab can, rarely, be an early sign of an unusual thigh bone fracture. Tell your doctor."))
        }
        if input.takesAntiresorptive && input.locations.contains(.jaw) {
            result.append(SafetyWarning(id: "pain-onj", severity: .caution,
                message: "Jaw pain, a loose tooth or exposed bone in the mouth can, rarely, be a side effect of bone medicines. Tell your dentist and doctor."))
        }
        return result.sortedBySeverity
    }
}

enum PainQuality: String, CaseIterable, Codable, Identifiable {
    case aching, sharp, burning, throbbing, stabbing, stiff, shooting

    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum PainRelief {
    static let options = ["Rest", "Heat", "Ice", "Gentle movement", "Walking", "Pain reliever", "Stretching", "Brace or support", "Physical therapy", "Nothing helped"]
}
