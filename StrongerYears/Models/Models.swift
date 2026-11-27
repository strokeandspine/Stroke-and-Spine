import Foundation
import SwiftData

enum AppSchema {
    static let models: [any PersistentModel.Type] = [TrainerProfile.self, WorkoutLog.self, SetLog.self, RecoveryLog.self]
}

@Model
final class TrainerProfile {
    var createdAt: Date = Date()
    var name: String = ""
    var isOnboarded: Bool = false
    var experienceRaw: String = Experience.beginner.rawValue
    var durationRaw: String = DurationLevel.short.rawValue
    var intensityRaw: String = IntensityLevel.gentle.rawValue
    var volumeRaw: String = VolumeLevel.light.rawValue
    var equipmentRaw: [String] = []
    var scheduleData: Data = Data()
    /// IDs of "yes" answers on the health check.
    var healthFlags: [String] = []
    var doctorCleared: Bool = false
    var acceptedDisclaimerAt: Date? = nil
    /// Increments each completed workout so exercises vary.
    var rotation: Int = 0
    var largerText: Bool = true

    init() {}

    var experience: Experience {
        get { Experience(rawValue: experienceRaw) ?? .beginner }
        set { experienceRaw = newValue.rawValue }
    }

    var settings: TrainingSettings {
        get {
            TrainingSettings(
                duration: DurationLevel(rawValue: durationRaw) ?? .short,
                intensity: IntensityLevel(rawValue: intensityRaw) ?? .gentle,
                volume: VolumeLevel(rawValue: volumeRaw) ?? .light
            )
        }
        set {
            durationRaw = newValue.duration.rawValue
            intensityRaw = newValue.intensity.rawValue
            volumeRaw = newValue.volume.rawValue
        }
    }

    var equipment: Set<Equipment> {
        get { Set(equipmentRaw.compactMap(Equipment.init(rawValue:))).union(Equipment.always) }
        set { equipmentRaw = newValue.map(\.rawValue).sorted() }
    }

    var schedule: [ScheduledDay] {
        get { (try? JSONDecoder().decode([ScheduledDay].self, from: scheduleData)) ?? [] }
        set { scheduleData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var needsDoctor: Bool { HealthCheck.needsDoctor(answers: Set(healthFlags)) && !doctorCleared }

    func scheduledDay(on date: Date, calendar: Calendar = .current) -> ScheduledDay? {
        let weekday = calendar.component(.weekday, from: date)
        return schedule.first { $0.weekday == weekday }
    }

    /// The next scheduled day on or after `date`.
    func nextScheduledDay(after date: Date, calendar: Calendar = .current) -> (date: Date, day: ScheduledDay)? {
        guard !schedule.isEmpty else { return nil }
        for offset in 0..<7 {
            guard let d = calendar.date(byAdding: .day, value: offset, to: date) else { continue }
            if let day = scheduledDay(on: d, calendar: calendar) { return (d, day) }
        }
        return nil
    }

    func buildWorkout(for day: ScheduledDay, settings override: TrainingSettings? = nil) -> PlannedWorkout {
        WorkoutBuilder.build(
            title: day.name,
            bodyParts: day.bodyParts,
            experience: experience,
            settings: override ?? settings,
            equipment: equipment,
            rotation: rotation
        )
    }
}

@Model
final class WorkoutLog {
    var date: Date = Date()
    var title: String = ""
    var bodyPartsRaw: [String] = []
    var durationMinutes: Int = 0
    var intensityRaw: String = IntensityLevel.gentle.rawValue
    /// Overall session effort 0–10.
    var overallEffort: Int = 5
    /// 1 (rough) – 5 (great).
    var feeling: Int = 3
    var warmedUp: Bool = false
    var cooledDown: Bool = false
    var stretched: Bool = false
    var notes: String = ""
    @Relationship(deleteRule: .cascade, inverse: \SetLog.workout) var sets: [SetLog] = []

    init(date: Date = Date(), title: String, bodyParts: [BodyPart], intensity: IntensityLevel) {
        self.date = date
        self.title = title
        self.bodyPartsRaw = bodyParts.map(\.rawValue)
        self.intensityRaw = intensity.rawValue
    }

    var bodyParts: [BodyPart] { bodyPartsRaw.compactMap(BodyPart.init(rawValue:)) }

    var sortedSets: [SetLog] { sets.sorted { ($0.exerciseOrder, $0.setNumber) < ($1.exerciseOrder, $1.setNumber) } }

    var exerciseCount: Int { Set(sets.map(\.exerciseID)).count }

    var hadPain: Bool { sets.contains { $0.pain } }

    /// Total weight moved, in pounds.
    var totalVolume: Double {
        sets.reduce(0) { total, s in total + (s.weight ?? 0) * Double(s.reps ?? 0) }
    }
}

@Model
final class SetLog {
    var exerciseID: String = ""
    var exerciseName: String = ""
    var exerciseOrder: Int = 0
    var setNumber: Int = 1
    var reps: Int? = nil
    var seconds: Int? = nil
    /// Pounds.
    var weight: Double? = nil
    var effort: Int? = nil
    var pain: Bool = false
    var completedAt: Date = Date()
    var workout: WorkoutLog?

    init(exerciseID: String, exerciseName: String, exerciseOrder: Int, setNumber: Int, reps: Int?, seconds: Int?, weight: Double?, effort: Int?, pain: Bool) {
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.exerciseOrder = exerciseOrder
        self.setNumber = setNumber
        self.reps = reps
        self.seconds = seconds
        self.weight = weight
        self.effort = effort
        self.pain = pain
    }

    var result: SetResult { SetResult(reps: reps, seconds: seconds, weight: weight, effort: effort, pain: pain) }

    var summary: String {
        var parts: [String] = []
        if let weight, weight > 0 { parts.append("\(Progression.formatWeight(weight)) lb") }
        if let reps { parts.append("\(reps) reps") }
        if let seconds { parts.append("\(seconds) sec") }
        if let effort { parts.append("effort \(effort)") }
        return parts.joined(separator: " · ")
    }
}

enum RecoveryKind: String, CaseIterable, Identifiable {
    case sauna = "Sauna"
    case coldPlunge = "Cold plunge"
    case stretching = "Stretching"
    case walk = "Walk"
    case other = "Other"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .sauna: return "thermometer.sun"
        case .coldPlunge: return "snowflake"
        case .stretching: return "figure.flexibility"
        case .walk: return "figure.walk"
        case .other: return "heart"
        }
    }

    var guideID: String? {
        switch self {
        case .sauna: return "sauna"
        case .coldPlunge: return "cold-plunge"
        case .stretching: return "stretching"
        default: return nil
        }
    }

    /// Minutes above which the app shows a gentle caution.
    var cautionMinutes: Int? {
        switch self {
        case .sauna: return 20
        case .coldPlunge: return 3
        default: return nil
        }
    }
}

@Model
final class RecoveryLog {
    var date: Date = Date()
    var kindRaw: String = RecoveryKind.sauna.rawValue
    var minutes: Int = 10
    /// Degrees Fahrenheit, optional.
    var temperature: Int? = nil
    var feltUnwell: Bool = false
    var notes: String = ""

    init(date: Date = Date(), kind: RecoveryKind, minutes: Int) {
        self.date = date
        self.kindRaw = kind.rawValue
        self.minutes = minutes
    }

    var kind: RecoveryKind { RecoveryKind(rawValue: kindRaw) ?? .other }
}
