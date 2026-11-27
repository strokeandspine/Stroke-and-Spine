import Foundation

struct PlannedExercise: Identifiable, Hashable {
    let exercise: StrengthExercise
    let sets: Int
    /// Rep target, or nil for timed holds.
    let reps: ClosedRange<Int>?
    let holdSeconds: Int?
    let restSeconds: Int
    let effort: ClosedRange<Int>

    var id: String { exercise.id }

    var dose: String {
        let setText = sets == 1 ? "1 set" : "\(sets) sets"
        let side = exercise.perSide ? " each side" : ""
        if let holdSeconds { return "\(setText) × \(holdSeconds) seconds\(side)" }
        if let reps { return "\(setText) × \(reps.lowerBound)–\(reps.upperBound) reps\(side)" }
        return setText
    }

    /// Rough time this exercise takes, in seconds, including rests and setting up.
    var estimatedSeconds: Int {
        let sides = exercise.perSide ? 2 : 1
        let workPerSet: Int
        if let holdSeconds {
            workPerSet = holdSeconds * sides + 10
        } else {
            // About 4 seconds a rep (1–2 up, 3 down), using the middle of the range.
            let middle = reps.map { ($0.lowerBound + $0.upperBound) / 2 } ?? 10
            workPerSet = middle * 4 * sides
        }
        let rests = max(sets - 1, 0) * restSeconds
        return sets * workPerSet + rests + 45 // 45 s to set up and move on
    }
}

struct PlannedWorkout: Hashable {
    let title: String
    let bodyParts: [BodyPart]
    let settings: TrainingSettings
    let warmUpMinutes: Int
    let coolDownMinutes: Int
    let exercises: [PlannedExercise]
    /// Body parts that didn't fit in the time available.
    let skippedBodyParts: [BodyPart]

    var estimatedMinutes: Int {
        let main = exercises.reduce(0) { $0 + $1.estimatedSeconds }
        return warmUpMinutes + coolDownMinutes + Int((Double(main) / 60).rounded())
    }
}

enum WorkoutBuilder {
    /// Builds a session for the chosen body parts.
    /// - Parameter rotation: changes which exercises are picked and which body parts come first,
    ///   so repeated sessions get some variety and short sessions cover everything over the week.
    static func build(
        title: String,
        bodyParts: [BodyPart],
        experience: Experience,
        settings: TrainingSettings,
        equipment: Set<Equipment>,
        rotation: Int = 0
    ) -> PlannedWorkout {
        let available = equipment.union(Equipment.always)
        let parts = rotated(bodyParts, by: rotation)
        let budget = (settings.duration.minutes - settings.duration.warmUpMinutes - settings.duration.coolDownMinutes) * 60

        // Candidate exercises per body part, best first.
        var queues: [BodyPart: [StrengthExercise]] = [:]
        for part in parts {
            let choices = candidates(for: part, experience: experience, equipment: available)
            queues[part] = rotated(choices, by: rotation)
        }

        var chosen: [PlannedExercise] = []
        var used = 0
        var covered: Set<BodyPart> = []
        var budgetFull = false

        for round in 0..<settings.volume.exercisesPerBodyPart where !budgetFull {
            for part in parts {
                guard let queue = queues[part], round < queue.count else { continue }
                let planned = prescribe(queue[round], settings: settings)
                if used + planned.estimatedSeconds > budget && !chosen.isEmpty {
                    budgetFull = true
                    break
                }
                chosen.append(planned)
                used += planned.estimatedSeconds
                covered.insert(part)
            }
        }

        return PlannedWorkout(
            title: title,
            bodyParts: bodyParts,
            settings: settings,
            warmUpMinutes: settings.duration.warmUpMinutes,
            coolDownMinutes: settings.duration.coolDownMinutes,
            exercises: chosen,
            skippedBodyParts: parts.filter { !covered.contains($0) }
        )
    }

    static func prescribe(_ exercise: StrengthExercise, settings: TrainingSettings) -> PlannedExercise {
        let intensity = settings.intensity
        var hold: Int? = nil
        if let base = exercise.holdSeconds {
            switch intensity {
            case .gentle: hold = base
            case .moderate: hold = base + 10
            case .challenging: hold = base + 20
            }
        }
        return PlannedExercise(
            exercise: exercise,
            sets: settings.volume.setsPerExercise,
            reps: hold == nil ? intensity.repRange : nil,
            holdSeconds: hold,
            restSeconds: intensity.restSeconds,
            effort: intensity.effortRange
        )
    }

    /// Exercises for a body part the person has the equipment for, ordered by how well
    /// the difficulty matches their experience.
    static func candidates(for part: BodyPart, experience: Experience, equipment: Set<Equipment>) -> [StrengthExercise] {
        let usable = ExerciseCatalog.exercises(for: part).filter { equipment.contains($0.equipment) }
        let preferred = experience.preferredDifficulties
        let matching = usable.filter { preferred.contains($0.difficulty) }
        if !matching.isEmpty { return matching }
        // Nothing at the preferred level: for beginners fall back to the easiest available,
        // for experienced people the hardest available.
        let order: [Difficulty] = experience == .beginner ? [.easy, .medium, .harder] : [.harder, .medium, .easy]
        return usable.sorted { order.firstIndex(of: $0.difficulty)! < order.firstIndex(of: $1.difficulty)! }
    }

    static func rotated<T>(_ items: [T], by amount: Int) -> [T] {
        guard !items.isEmpty else { return items }
        let shift = ((amount % items.count) + items.count) % items.count
        return Array(items[shift...] + items[..<shift])
    }
}
