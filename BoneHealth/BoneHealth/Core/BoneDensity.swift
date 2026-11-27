import Foundation

/// The skeletal sites reported on a DEXA scan.
enum DexaSite: String, CaseIterable, Codable, Identifiable {
    case lumbarSpine, totalHip, femoralNeck, forearm

    var id: String { rawValue }

    var name: String {
        switch self {
        case .lumbarSpine: return "Lumbar spine (L1–L4)"
        case .totalHip: return "Total hip"
        case .femoralNeck: return "Femoral neck"
        case .forearm: return "Forearm (1/3 radius)"
        }
    }

    var shortName: String {
        switch self {
        case .lumbarSpine: return "Spine"
        case .totalHip: return "Total hip"
        case .femoralNeck: return "Fem. neck"
        case .forearm: return "Forearm"
        }
    }

    /// Typical least significant change (LSC) in BMD at 95% confidence. The real value depends on the scanning
    /// centre's precision; the person can replace it with the number on their report.
    var typicalLSCPercent: Double {
        switch self {
        case .lumbarSpine: return 3
        case .totalHip: return 5
        case .femoralNeck: return 7
        case .forearm: return 5
        }
    }
}

struct DexaSiteResult: Codable, Hashable, Identifiable {
    var id = UUID()
    var site: DexaSite
    /// "Left", "Right" or "" for the spine or when not stated.
    var side: String = ""
    /// Bone mineral density in g/cm².
    var bmd: Double?
    var tScore: Double?
    var zScore: Double?

    var label: String { side.isEmpty ? site.name : "\(site.name), \(side.lowercased())" }
}

/// WHO categories, which apply to T-scores in postmenopausal women and men aged 50 and older.
enum BoneDensityCategory: Int, Comparable, CaseIterable {
    case normal, lowBoneMass, osteoporosis, severeOsteoporosis

    static func < (lhs: BoneDensityCategory, rhs: BoneDensityCategory) -> Bool { lhs.rawValue < rhs.rawValue }

    var title: String {
        switch self {
        case .normal: return "Normal bone density"
        case .lowBoneMass: return "Low bone mass (osteopenia)"
        case .osteoporosis: return "Osteoporosis range"
        case .severeOsteoporosis: return "Severe (established) osteoporosis"
        }
    }

    var range: String {
        switch self {
        case .normal: return "T-score −1.0 or higher"
        case .lowBoneMass: return "T-score between −1.0 and −2.5"
        case .osteoporosis: return "T-score −2.5 or lower"
        case .severeOsteoporosis: return "T-score −2.5 or lower, plus a fracture from a minor fall or bump"
        }
    }
}

enum BoneDensity {
    /// T-scores are reported to one decimal place, so classify the rounded value.
    static func category(tScore: Double, hasFragilityFracture: Bool = false) -> BoneDensityCategory {
        let t = (tScore * 10).rounded() / 10
        if t <= -2.5 { return hasFragilityFracture ? .severeOsteoporosis : .osteoporosis }
        if t < -1.0 { return .lowBoneMass }
        return .normal
    }

    /// The diagnosis is based on the lowest T-score at the spine, total hip, femoral neck (or forearm if used).
    static func lowest(_ results: [DexaSiteResult]) -> DexaSiteResult? {
        results.filter { $0.tScore != nil }.min { ($0.tScore ?? 0) < ($1.tScore ?? 0) }
    }

    static func overallCategory(_ results: [DexaSiteResult], hasFragilityFracture: Bool) -> BoneDensityCategory? {
        guard let t = lowest(results)?.tScore else { return nil }
        return category(tScore: t, hasFragilityFracture: hasFragilityFracture)
    }

    /// For premenopausal women and men under 50 the Z-score is used instead. −2.0 or lower is "below the expected range for age".
    static func isZScoreBelowExpected(_ z: Double) -> Bool { (z * 10).rounded() / 10 <= -2.0 }

    static func usesTScore(age: Int?, sex: Sex, isPostmenopausal: Bool) -> Bool {
        if sex == .female && isPostmenopausal { return true }
        guard let age else { return true }
        return age >= 50
    }

    struct Change: Hashable {
        enum Direction { case gained, lost, stable }
        let site: DexaSite
        let percent: Double
        let lscPercent: Double
        var direction: Direction {
            if abs(percent) < lscPercent { return .stable }
            return percent > 0 ? .gained : .lost
        }

        var summary: String {
            let value = String(format: "%+.1f%%", percent)
            switch direction {
            case .stable: return "\(value) — within the normal measurement variation (about ±\(Int(lscPercent))%), so likely stable"
            case .gained: return "\(value) — a real increase in bone density"
            case .lost: return "\(value) — a real decrease in bone density. Ask your doctor whether your treatment needs reviewing."
            }
        }
    }

    /// Compares BMD (not T-scores) between two scans at the same site. Returns nil if BMD is missing on either.
    static func change(from old: DexaSiteResult, to new: DexaSiteResult, lscPercent: Double? = nil) -> Change? {
        guard old.site == new.site, let a = old.bmd, let b = new.bmd, a > 0 else { return nil }
        return Change(site: new.site, percent: (b - a) / a * 100, lscPercent: lscPercent ?? new.site.typicalLSCPercent)
    }

    static let explanation = """
    A DEXA scan measures bone mineral density (BMD). Your T-score compares your BMD with a healthy young adult: 0 is average, and each point below is one standard deviation lower. Your Z-score compares you with people of your own age and sex.

    Your diagnosis is based on your lowest T-score. A doctor can also diagnose osteoporosis after a hip or spine fracture from a minor fall, whatever the T-score.

    To see whether bone density has really changed, compare the BMD number (g/cm²), ideally on the same machine at the same centre. Small changes are often just measurement variation.
    """
}

/// FRAX is calculated by your doctor or on your DEXA report; the app only stores and explains it.
enum FRAX {
    /// US (BHOF) guidance: in people with low bone mass, treatment is often considered at these 10-year probabilities.
    static let majorThreshold = 20.0
    static let hipThreshold = 3.0

    static func meetsUSTreatmentThreshold(major: Double?, hip: Double?) -> Bool {
        (major ?? 0) >= majorThreshold || (hip ?? 0) >= hipThreshold
    }
}
