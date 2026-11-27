import Foundation

/// One completed set, independent of storage so the rules are easy to test.
struct SetResult: Hashable {
    var reps: Int?
    var seconds: Int?
    var weight: Double?
    /// 0–10 effort.
    var effort: Int?
    var pain: Bool = false
}

enum ProgressionAdvice: Equatable {
    case increase(String)
    case hold(String)
    case decrease(String)

    var message: String {
        switch self {
        case .increase(let m), .hold(let m), .decrease(let m): return m
        }
    }

    var title: String {
        switch self {
        case .increase: return "Ready to progress"
        case .hold: return "Stay where you are"
        case .decrease: return "Ease off a little"
        }
    }

    var symbol: String {
        switch self {
        case .increase: return "arrow.up.circle.fill"
        case .hold: return "equal.circle.fill"
        case .decrease: return "arrow.down.circle.fill"
        }
    }
}

enum Progression {
    /// Smallest sensible weight step in pounds.
    static func weightStep(for exercise: StrengthExercise) -> Double {
        if exercise.equipment == .ankleWeights { return 1 }
        if exercise.equipment == .machines { return exercise.bodyPart.isLowerBody ? 10 : 5 }
        return exercise.bodyPart.isLowerBody ? 5 : 2
    }

    /// Advice for next time, based on the last session's sets of one exercise.
    /// Uses the "2-for-2" idea: progress only when every set hits the top of the target with effort to spare.
    static func advice(
        for exercise: StrengthExercise,
        sets: [SetResult],
        targetReps: ClosedRange<Int>?,
        targetSeconds: Int?,
        targetEffort: ClosedRange<Int>
    ) -> ProgressionAdvice {
        guard !sets.isEmpty else { return .hold("No sets logged yet.") }

        if sets.contains(where: \.pain) {
            return .decrease("You noted pain. Next time go lighter or try the easier version. If the pain is sharp, lasts more than a day or two, or keeps coming back, check with your doctor or physical therapist.")
        }

        let efforts = sets.compactMap(\.effort)
        let maxEffort = efforts.max() ?? targetEffort.lowerBound
        if maxEffort >= 9 || maxEffort > targetEffort.upperBound + 1 {
            return .decrease("That felt harder than planned (effort \(maxEffort)/10). Go lighter or do fewer reps next time so you finish each set with a few reps to spare.")
        }

        if let targetReps {
            let reps = sets.compactMap(\.reps)
            guard reps.count == sets.count else { return .hold("Log your reps to get advice on when to progress.") }
            if reps.contains(where: { $0 < targetReps.lowerBound }) {
                if maxEffort >= targetEffort.upperBound {
                    return .decrease("Some sets fell short of \(targetReps.lowerBound) reps. Try a slightly lighter weight so you can reach the target with good form.")
                }
                return .hold("Keep the same weight and aim for \(targetReps.lowerBound)–\(targetReps.upperBound) reps on every set.")
            }
            let hitTop = reps.allSatisfy { $0 >= targetReps.upperBound }
            if hitTop && maxEffort <= targetEffort.upperBound {
                return .increase(increaseMessage(for: exercise, reps: targetReps))
            }
            return .hold("Good work. Stay at this level until every set reaches \(targetReps.upperBound) reps feeling comfortable.")
        }

        if let targetSeconds {
            let seconds = sets.compactMap(\.seconds)
            guard seconds.count == sets.count else { return .hold("Log how long you held to get advice on when to progress.") }
            if seconds.allSatisfy({ $0 >= targetSeconds }) && maxEffort <= targetEffort.upperBound {
                if let harder = exercise.harderID.flatMap(ExerciseCatalog.exercise) {
                    return .increase("You held for the full time. Add 5–10 seconds next time, or try \(harder.name).")
                }
                return .increase("You held for the full time. Add 5–10 seconds next time.")
            }
            return .hold("Keep practicing until you can hold for \(targetSeconds) seconds on every set.")
        }

        return .hold("Keep going at this level.")
    }

    private static func increaseMessage(for exercise: StrengthExercise, reps: ClosedRange<Int>) -> String {
        if exercise.usesWeight {
            let step = weightStep(for: exercise)
            return "Every set reached \(reps.upperBound) reps with effort to spare. Next time add \(formatWeight(step)) lb and aim for \(reps.lowerBound) reps again. Change only one thing at a time."
        }
        if exercise.usesBand {
            return "Every set reached \(reps.upperBound) reps with effort to spare. Next time use a firmer band, or hold it shorter, and aim for \(reps.lowerBound) reps again."
        }
        if let harder = exercise.harderID.flatMap(ExerciseCatalog.exercise) {
            return "Every set reached \(reps.upperBound) reps with effort to spare. You could try \(harder.name) next time, or slow each rep down to 3 seconds up and 3 down."
        }
        return "Every set reached \(reps.upperBound) reps with effort to spare. Make it harder by moving more slowly or pausing for 2 seconds in the hardest position."
    }

    static func formatWeight(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}
