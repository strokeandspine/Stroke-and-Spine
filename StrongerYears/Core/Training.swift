import Foundation

// Core training vocabulary: body parts, experience, and the three dials people can adjust —
// duration, intensity and volume. Defaults come from experience; choices outside the
// recommended range are allowed but come with a plain-language caution.

enum BodyPart: String, CaseIterable, Identifiable, Codable, Hashable {
    case legs = "Legs"
    case hips = "Hips and glutes"
    case back = "Back"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case arms = "Arms and grip"
    case core = "Core"
    case balance = "Balance"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .legs: return "figure.strengthtraining.functional"
        case .hips: return "figure.step.training"
        case .back: return "figure.rower"
        case .chest: return "figure.arms.open"
        case .shoulders: return "figure.boxing"
        case .arms: return "dumbbell"
        case .core: return "figure.core.training"
        case .balance: return "figure.stand"
        }
    }

    /// Why this matters, in everyday terms.
    var whyItMatters: String {
        switch self {
        case .legs: return "Getting out of a chair, climbing stairs and walking further."
        case .hips: return "Steady walking, getting up from the floor and protecting your lower back."
        case .back: return "Good posture, carrying groceries and reaching overhead safely."
        case .chest: return "Pushing doors, getting up off the floor and pushing yourself up from a chair."
        case .shoulders: return "Lifting things onto shelves, dressing and reaching."
        case .arms: return "Carrying grocery bags, opening jars and holding on to rails."
        case .core: return "Steadiness, balance and protecting your back when you lift."
        case .balance: return "Fewer falls and more confidence on uneven ground."
        }
    }

    /// Larger muscle groups take slightly bigger weight steps.
    var isLowerBody: Bool { self == .legs || self == .hips }
}

enum Experience: String, CaseIterable, Identifiable, Codable {
    case beginner = "New to strength training"
    case returning = "Returning after a break"
    case experienced = "Train regularly"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .beginner: return "You haven't lifted weights before, or not for many years."
        case .returning: return "You've trained before and are getting back into it, perhaps after illness or time off."
        case .experienced: return "You've done strength training at least twice a week for the past 3 months or more."
        }
    }

    var defaultSettings: TrainingSettings {
        switch self {
        case .beginner: return TrainingSettings(duration: .short, intensity: .gentle, volume: .light)
        case .returning: return TrainingSettings(duration: .standard, intensity: .gentle, volume: .moderate)
        case .experienced: return TrainingSettings(duration: .standard, intensity: .moderate, volume: .moderate)
        }
    }

    var recommendedIntensities: [IntensityLevel] {
        switch self {
        case .beginner: return [.gentle]
        case .returning: return [.gentle, .moderate]
        case .experienced: return [.gentle, .moderate, .challenging]
        }
    }

    var recommendedVolumes: [VolumeLevel] {
        switch self {
        case .beginner: return [.light, .moderate]
        case .returning: return [.light, .moderate]
        case .experienced: return VolumeLevel.allCases
        }
    }

    var recommendedDurations: [DurationLevel] {
        switch self {
        case .beginner: return [.short, .standard]
        case .returning, .experienced: return DurationLevel.allCases
        }
    }

    /// Which exercise difficulties to prefer.
    var preferredDifficulties: [Difficulty] {
        switch self {
        case .beginner: return [.easy]
        case .returning: return [.easy, .medium]
        case .experienced: return [.medium, .harder]
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easier"
    case medium = "Moderate"
    case harder = "Harder"
}

enum DurationLevel: String, CaseIterable, Identifiable, Codable {
    case short, standard, long
    var id: String { rawValue }

    var title: String {
        switch self {
        case .short: return "Short"
        case .standard: return "Standard"
        case .long: return "Long"
        }
    }

    var minutes: Int {
        switch self {
        case .short: return 20
        case .standard: return 35
        case .long: return 50
        }
    }

    var warmUpMinutes: Int {
        switch self {
        case .short: return 5
        case .standard: return 8
        case .long: return 10
        }
    }

    var coolDownMinutes: Int {
        switch self {
        case .short: return 5
        case .standard: return 6
        case .long: return 8
        }
    }

    var summary: String { "About \(minutes) minutes, including \(warmUpMinutes) minutes of warm-up and \(coolDownMinutes) of cool-down." }
}

enum IntensityLevel: String, CaseIterable, Identifiable, Codable {
    case gentle, moderate, challenging
    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: return "Gentle"
        case .moderate: return "Moderate"
        case .challenging: return "Challenging"
        }
    }

    /// Target effort on the 0–10 scale.
    var effortRange: ClosedRange<Int> {
        switch self {
        case .gentle: return 3...4
        case .moderate: return 5...6
        case .challenging: return 7...8
        }
    }

    var repRange: ClosedRange<Int> {
        switch self {
        case .gentle: return 12...15
        case .moderate: return 10...12
        case .challenging: return 8...10
        }
    }

    var restSeconds: Int {
        switch self {
        case .gentle: return 60
        case .moderate: return 90
        case .challenging: return 120
        }
    }

    var feelsLike: String {
        switch self {
        case .gentle: return "Light to somewhat hard. You could easily do 5 or more extra reps and can chat comfortably."
        case .moderate: return "Somewhat hard. The last few reps take effort, but you could do 3–4 more with good form."
        case .challenging: return "Hard. The last 2–3 reps are a real effort, but your form stays perfect and you never strain or hold your breath."
        }
    }

    var summary: String { "Effort \(effortRange.lowerBound)–\(effortRange.upperBound) out of 10, \(repRange.lowerBound)–\(repRange.upperBound) reps, \(restSeconds) seconds rest." }
}

enum VolumeLevel: String, CaseIterable, Identifiable, Codable {
    case light, moderate, full
    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .full: return "Full"
        }
    }

    var setsPerExercise: Int {
        switch self {
        case .light: return 1
        case .moderate: return 2
        case .full: return 3
        }
    }

    var exercisesPerBodyPart: Int {
        switch self {
        case .light, .moderate: return 1
        case .full: return 2
        }
    }

    var summary: String {
        let sets = setsPerExercise == 1 ? "1 set" : "\(setsPerExercise) sets"
        let ex = exercisesPerBodyPart == 1 ? "1 exercise" : "up to \(exercisesPerBodyPart) exercises"
        return "\(sets) of each exercise, \(ex) per body part."
    }
}

struct TrainingSettings: Codable, Equatable, Hashable {
    var duration: DurationLevel
    var intensity: IntensityLevel
    var volume: VolumeLevel

    /// Plain-language cautions when a choice is above what's recommended for the person's experience.
    func cautions(for experience: Experience) -> [String] {
        var notes: [String] = []
        if !experience.recommendedIntensities.contains(intensity) {
            notes.append("\(intensity.title) intensity is a big step for someone \(experience == .beginner ? "new to strength training" : "returning after a break"). Most people do best spending 4–8 weeks at a lower intensity first while they learn the movements.")
        }
        if !experience.recommendedVolumes.contains(volume) {
            notes.append("\(volume.title) volume means more total work. Build up one set at a time over several weeks.")
        }
        if !experience.recommendedDurations.contains(duration) {
            notes.append("Longer sessions can leave you very tired at first. Start shorter and add time as you feel ready.")
        }
        return notes
    }

    /// Increase only one dial at a time.
    func changedDials(from other: TrainingSettings) -> Int {
        [duration != other.duration, intensity != other.intensity, volume != other.volume].filter { $0 }.count
    }
}

enum Equipment: String, CaseIterable, Identifiable, Codable, Hashable {
    case bodyweight = "No equipment"
    case chair = "Sturdy chair"
    case dumbbells = "Dumbbells"
    case bands = "Resistance bands"
    case ankleWeights = "Ankle weights"
    case machines = "Gym machines"

    var id: String { rawValue }

    /// Things everyone can be assumed to have.
    static let always: Set<Equipment> = [.bodyweight, .chair]
}

/// The 0–10 effort scale with everyday words.
enum EffortScale {
    static func words(_ value: Int) -> String {
        switch value {
        case ...0: return "Resting"
        case 1...2: return "Very easy"
        case 3...4: return "Easy to somewhat hard"
        case 5...6: return "Somewhat hard"
        case 7...8: return "Hard"
        case 9: return "Very hard"
        default: return "Maximum — too hard"
        }
    }
}
