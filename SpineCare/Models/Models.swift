import Foundation
import SwiftData

// All data is stored on the device with SwiftData. There are no accounts and no server in v1.

@Model
final class PatientProfile {
    var createdAt: Date
    var preferredName: String
    var painStartedOn: Date?
    var goals: String
    /// Raw values of `HealthCondition`.
    var conditionsRaw: [String]
    /// Ingredient raw value → daily limit in mg chosen by the patient (from their label / doctor).
    var dailyLimitsMg: [String: Double]
    var acceptedDisclaimerAt: Date?
    var confirmedAdultAt: Date?
    var appLockEnabled: Bool
    var reminderHour: Int
    var remindersEnabled: Bool

    init(preferredName: String = "") {
        createdAt = Date()
        self.preferredName = preferredName
        goals = ""
        conditionsRaw = []
        dailyLimitsMg = [:]
        appLockEnabled = false
        reminderHour = 20
        remindersEnabled = false
    }

    var conditions: Set<HealthCondition> {
        get { Set(conditionsRaw.compactMap(HealthCondition.init(rawValue:))) }
        set { conditionsRaw = newValue.map(\.rawValue).sorted() }
    }

    var isOnboarded: Bool { acceptedDisclaimerAt != nil && confirmedAdultAt != nil }

    var safetyChecker: MedicationSafetyChecker {
        var limits: [Ingredient: Double] = [:]
        for ingredient in Ingredient.allCases {
            limits[ingredient] = dailyLimitsMg[ingredient.rawValue] ?? ingredient.defaultDailyLimitMg
        }
        return MedicationSafetyChecker(limits: limits, conditions: conditions)
    }
}

/// The quick daily check-in (target: under 30 seconds).
@Model
final class DailyCheckIn {
    var date: Date
    /// 0–10 Numeric Rating Scale, average over the last 24 hours.
    var backPain: Int
    var legPain: Int
    var worstPain: Int
    /// 0–10, how well the person slept last night.
    var sleepQuality: Int
    var painWokeMe: Bool
    /// 0–10, 10 = very good mood.
    var mood: Int
    var tags: [String]
    var isFlare: Bool
    var note: String

    init(date: Date = Date(), backPain: Int = 0, legPain: Int = 0, worstPain: Int = 0, sleepQuality: Int = 5,
         painWokeMe: Bool = false, mood: Int = 5, tags: [String] = [], isFlare: Bool = false, note: String = "") {
        self.date = date
        self.backPain = backPain
        self.legPain = legPain
        self.worstPain = worstPain
        self.sleepQuality = sleepQuality
        self.painWokeMe = painWokeMe
        self.mood = mood
        self.tags = tags
        self.isFlare = isFlare
        self.note = note
    }

    static let suggestedTags = ["Long sitting", "Long standing", "Lifting", "Driving", "Exercise", "Walked a lot",
                                "Poor sleep", "Stress", "Weather", "Work", "Housework", "Travel"]
}

@Model
final class QuestionnaireResponse {
    var date: Date
    var instrumentRaw: String
    /// -1 means "skipped" (optional items only).
    var answers: [Int]
    var score: Double
    var maximum: Double
    var isPercentage: Bool
    var severity: String

    init(date: Date = Date(), instrument: Questionnaire.ID, answers: [Int?], score: QuestionnaireScore) {
        self.date = date
        instrumentRaw = instrument.rawValue
        self.answers = answers.map { $0 ?? -1 }
        self.score = score.value
        maximum = score.maximum
        isPercentage = score.isPercentage
        severity = score.severity
    }

    var instrument: Questionnaire.ID? { Questionnaire.ID(rawValue: instrumentRaw) }

    var display: String {
        isPercentage ? "\(Int(score.rounded()))%" : "\(Int(score)) of \(Int(maximum))"
    }
}

@Model
final class MedicationDose {
    var takenAt: Date
    var productName: String
    var units: Double
    /// JSON-encoded `[IngredientAmount]` per unit.
    var perUnitData: Data
    /// 0–10 pain before taking it, and 2 hours later (optional).
    var painBefore: Int?
    var painAfter: Int?
    var note: String

    init(takenAt: Date = Date(), product: OTCProduct, units: Double, painBefore: Int? = nil, note: String = "") {
        self.takenAt = takenAt
        productName = product.name
        self.units = units
        perUnitData = (try? JSONEncoder().encode(product.perUnit)) ?? Data()
        self.painBefore = painBefore
        self.note = note
    }

    var perUnit: [IngredientAmount] {
        (try? JSONDecoder().decode([IngredientAmount].self, from: perUnitData)) ?? []
    }

    var totalAmounts: [IngredientAmount] {
        perUnit.map { IngredientAmount(ingredient: $0.ingredient, milligrams: $0.milligrams * units) }
    }

    var record: DoseRecord { DoseRecord(takenAt: takenAt, amounts: totalAmounts) }
}

/// One entry in the person's spine history: a surgery, injection/procedure, imaging study or therapy course.
@Model
final class SpineHistoryEntry {
    var kindRaw: String
    var typeName: String
    var date: Date
    var spinalLevels: [String]
    var side: String
    var provider: String
    var facility: String
    var implants: String
    var complications: String
    /// Rough % pain relief afterwards (0–100) and how many weeks it lasted.
    var reliefPercent: Int?
    var reliefWeeks: Int?
    var notes: String
    @Relationship(deleteRule: .cascade, inverse: \HistoryAttachment.entry)
    var attachments: [HistoryAttachment]

    init(kind: HistoryKind, typeName: String, date: Date = Date()) {
        kindRaw = kind.rawValue
        self.typeName = typeName
        self.date = date
        spinalLevels = []
        side = ""
        provider = ""
        facility = ""
        implants = ""
        complications = ""
        notes = ""
        attachments = []
    }

    var kind: HistoryKind {
        get { HistoryKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }
}

@Model
final class HistoryAttachment {
    var createdAt: Date
    var caption: String
    @Attribute(.externalStorage) var imageData: Data
    var entry: SpineHistoryEntry?

    init(caption: String = "", imageData: Data) {
        createdAt = Date()
        self.caption = caption
        self.imageData = imageData
    }
}

@Model
final class RedFlagCheck {
    var date: Date
    var positiveIDs: [String]
    var urgencyRaw: Int

    init(date: Date = Date(), positiveIDs: Set<String>) {
        self.date = date
        self.positiveIDs = positiveIDs.sorted()
        urgencyRaw = RedFlagScreen.evaluate(positiveIDs).rawValue
    }

    var urgency: Urgency { Urgency(rawValue: urgencyRaw) ?? .none }
}

enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        PatientProfile.self, DailyCheckIn.self, QuestionnaireResponse.self, MedicationDose.self,
        SpineHistoryEntry.self, HistoryAttachment.self, RedFlagCheck.self,
    ]
}
