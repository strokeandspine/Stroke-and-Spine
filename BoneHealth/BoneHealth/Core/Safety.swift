import Foundation

/// How strongly a message should be shown. Every feature (supplements, medicines, vitals, falls, pain) uses the same scale.
enum WarningSeverity: Int, Comparable, Codable {
    case info, caution, stop

    static func < (lhs: WarningSeverity, rhs: WarningSeverity) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct SafetyWarning: Identifiable, Hashable {
    let id: String
    let severity: WarningSeverity
    let message: String
}

extension Array where Element == SafetyWarning {
    /// Most serious first, then in the order they were added.
    var sortedBySeverity: [SafetyWarning] {
        enumerated().sorted { a, b in
            a.element.severity != b.element.severity ? a.element.severity > b.element.severity : a.offset < b.offset
        }.map(\.element)
    }
}

enum Sex: String, CaseIterable, Codable, Identifiable {
    case female, male, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Prefer not to say"
        }
    }
}

/// What the person has been told about their bones.
enum BoneStatus: String, CaseIterable, Codable, Identifiable {
    case osteoporosis, osteopenia, atRisk, notSure

    var id: String { rawValue }

    var label: String {
        switch self {
        case .osteoporosis: return "Osteoporosis"
        case .osteopenia: return "Osteopenia (low bone mass)"
        case .atRisk: return "At risk, no diagnosis yet"
        case .notSure: return "Not sure"
        }
    }
}

extension Calendar {
    /// Whole calendar days from `from` to `to` (negative if `to` is earlier).
    func daysBetween(_ from: Date, _ to: Date) -> Int {
        dateComponents([.day], from: startOfDay(for: from), to: startOfDay(for: to)).day ?? 0
    }

    func monthsBetween(_ from: Date, _ to: Date) -> Int {
        dateComponents([.month], from: from, to: to).month ?? 0
    }
}
