import Foundation

/// Lets the app check gated features in one place.
enum PremiumFeature {
    case program(RehabProgram)
    case exercise(Exercise)
    case longTrends

    func isAvailable(isPremium: Bool) -> Bool {
        if isPremium { return true }
        switch self {
        case .program(let p): return p.isFree
        case .exercise(let e): return RehabPrograms.freeExerciseIDs.contains(e.id)
        case .longTrends: return false
        }
    }
}
