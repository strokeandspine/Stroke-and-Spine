import Foundation
import SwiftData

// All data is stored on the device with SwiftData. There is no account and no server.

@Model
final class PatientProfile {
    var createdAt: Date
    var preferredName: String
    var birthYear: Int?
    var sexRaw: String
    var isPostmenopausal: Bool
    var boneStatusRaw: String
    var usesMetricUnits: Bool
    /// The tallest height the person remembers as a young adult, for height-loss checks.
    var tallestAdultHeightCm: Double?
    var riskFactorsRaw: [String]
    var prescribedHighDoseVitaminD: Bool
    var calciumTargetOverride: Double?
    var vitaminDTargetOverride: Double?
    var magnesiumTargetOverride: Double?
    /// FRAX 10-year probabilities from the doctor or DEXA report.
    var fraxMajorPercent: Double?
    var fraxHipPercent: Double?
    var fraxDate: Date?
    var homeSafetyDoneIDs: [String]
    var acceptedDisclaimerAt: Date?
    var confirmedAdultAt: Date?
    var appLockEnabled: Bool
    var supplementRemindersEnabled: Bool
    var supplementReminderHour: Int

    init(preferredName: String = "") {
        createdAt = Date()
        self.preferredName = preferredName
        sexRaw = Sex.female.rawValue
        isPostmenopausal = false
        boneStatusRaw = BoneStatus.notSure.rawValue
        usesMetricUnits = false
        riskFactorsRaw = []
        prescribedHighDoseVitaminD = false
        homeSafetyDoneIDs = []
        appLockEnabled = false
        supplementRemindersEnabled = false
        supplementReminderHour = 9
    }

    var sex: Sex {
        get { Sex(rawValue: sexRaw) ?? .other }
        set { sexRaw = newValue.rawValue }
    }

    var boneStatus: BoneStatus {
        get { BoneStatus(rawValue: boneStatusRaw) ?? .notSure }
        set { boneStatusRaw = newValue.rawValue }
    }

    var riskFactors: Set<RiskFactor> {
        get { Set(riskFactorsRaw.compactMap(RiskFactor.init(rawValue:))) }
        set { riskFactorsRaw = newValue.map(\.rawValue).sorted() }
    }

    var age: Int? {
        guard let birthYear else { return nil }
        return Calendar.current.component(.year, from: Date()) - birthYear
    }

    var isOnboarded: Bool { acceptedDisclaimerAt != nil && confirmedAdultAt != nil }

    var nutrientTargets: NutrientTargets {
        var targets = NutrientTargets.forPerson(age: age, sex: sex)
        if let v = calciumTargetOverride { targets.daily[.calcium] = v }
        if let v = vitaminDTargetOverride { targets.daily[.vitaminD] = v }
        if let v = magnesiumTargetOverride { targets.daily[.magnesium] = v }
        return targets
    }

    var supplementChecker: SupplementChecker {
        SupplementChecker(targets: nutrientTargets, prescribedHighDoseVitaminD: prescribedHighDoseVitaminD,
                          hasKidneyDisease: riskFactors.contains(.chronicKidneyDisease))
    }
}

// MARK: - Records

@Model
final class VitalReading {
    var date: Date
    var systolic: Int?
    var diastolic: Int?
    var heartRate: Int?
    var weightKg: Double?
    var heightCm: Double?
    var note: String

    init(date: Date = Date()) {
        self.date = date
        note = ""
    }

    var bloodPressureCategory: BloodPressureCategory? {
        guard let systolic, let diastolic else { return nil }
        return BloodPressureCategory.classify(systolic: systolic, diastolic: diastolic)
    }
}

@Model
final class MedicalHistoryEntry {
    var kindRaw: String
    var title: String
    var date: Date?
    var isOngoing: Bool
    var details: String

    init(kind: HistoryKind, title: String) {
        kindRaw = kind.rawValue
        self.title = title
        isOngoing = false
        details = ""
    }

    var kind: HistoryKind {
        get { HistoryKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }
}

@Model
final class FractureRecord {
    var date: Date
    var siteRaw: String
    var causeRaw: String
    var treatment: String
    var notes: String

    init(date: Date = Date(), site: FractureSite = .wrist, cause: FractureCause = .lowTrauma) {
        self.date = date
        siteRaw = site.rawValue
        causeRaw = cause.rawValue
        treatment = ""
        notes = ""
    }

    var site: FractureSite {
        get { FractureSite(rawValue: siteRaw) ?? .other }
        set { siteRaw = newValue.rawValue }
    }

    var cause: FractureCause {
        get { FractureCause(rawValue: causeRaw) ?? .lowTrauma }
        set { causeRaw = newValue.rawValue }
    }
}

@Model
final class RadiologyReport {
    var kindRaw: String
    var date: Date
    var bodyPart: String
    var facility: String
    var orderedBy: String
    /// DEXA machine make (e.g. Hologic, GE Lunar). Scans are only directly comparable on the same machine.
    var machine: String
    var impression: String
    var notes: String
    /// JSON-encoded `[DexaSiteResult]` (DEXA only).
    var dexaData: Data
    var trabecularBoneScore: Double?
    var fraxMajorPercent: Double?
    var fraxHipPercent: Double?
    @Relationship(deleteRule: .cascade, inverse: \ReportAttachment.report)
    var attachments: [ReportAttachment]

    init(kind: RadiologyKind, date: Date = Date()) {
        kindRaw = kind.rawValue
        self.date = date
        bodyPart = ""
        facility = ""
        orderedBy = ""
        machine = ""
        impression = ""
        notes = ""
        dexaData = Data()
        attachments = []
    }

    var kind: RadiologyKind {
        get { RadiologyKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    var dexaResults: [DexaSiteResult] {
        get { (try? JSONDecoder().decode([DexaSiteResult].self, from: dexaData)) ?? [] }
        set { dexaData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var title: String {
        if kind == .dexa || bodyPart.isEmpty { return kind.label }
        return "\(kind.label) — \(bodyPart)"
    }
}

@Model
final class ReportAttachment {
    var createdAt: Date
    var caption: String
    @Attribute(.externalStorage) var imageData: Data
    var report: RadiologyReport?

    init(caption: String = "", imageData: Data) {
        createdAt = Date()
        self.caption = caption
        self.imageData = imageData
    }
}

@Model
final class LabResult {
    var date: Date
    var testRaw: String
    var value: Double
    var note: String

    init(date: Date = Date(), test: LabTest, value: Double) {
        self.date = date
        testRaw = test.rawValue
        self.value = value
        note = ""
    }

    var test: LabTest { LabTest(rawValue: testRaw) ?? .calcium }
}

// MARK: - Supplements

@Model
final class SupplementIntake {
    var takenAt: Date
    var productName: String
    var sourceRaw: String
    var servings: Double
    /// JSON-encoded `[NutrientAmount]` per serving.
    var perServingData: Data

    init(takenAt: Date = Date(), productName: String, source: IntakeSource, servings: Double, perServing: [NutrientAmount]) {
        self.takenAt = takenAt
        self.productName = productName
        sourceRaw = source.rawValue
        self.servings = servings
        perServingData = (try? JSONEncoder().encode(perServing)) ?? Data()
    }

    var source: IntakeSource { IntakeSource(rawValue: sourceRaw) ?? .supplement }

    var perServing: [NutrientAmount] {
        (try? JSONDecoder().decode([NutrientAmount].self, from: perServingData)) ?? []
    }

    var totalAmounts: [NutrientAmount] {
        perServing.map { NutrientAmount(nutrient: $0.nutrient, amount: $0.amount * servings) }
    }

    var record: IntakeRecord { IntakeRecord(takenAt: takenAt, source: source, amounts: totalAmounts) }
}

// MARK: - Osteoporosis medicines

@Model
final class MedicationPlan {
    var drugID: String
    var frequencyRaw: String
    var startedOn: Date
    var stoppedOn: Date?
    var prescriber: String
    var notes: String
    var remindersEnabled: Bool
    @Relationship(deleteRule: .cascade, inverse: \MedicationDoseLog.plan)
    var doses: [MedicationDoseLog]

    init(drug: OsteoDrug, frequency: DoseFrequency? = nil, startedOn: Date = Date()) {
        drugID = drug.id
        frequencyRaw = (frequency ?? drug.defaultFrequency).rawValue
        self.startedOn = startedOn
        prescriber = ""
        notes = ""
        remindersEnabled = false
        doses = []
    }

    var drug: OsteoDrug? { OsteoDrugLibrary.drug(drugID) }
    var isActive: Bool { stoppedOn == nil }

    var frequency: DoseFrequency {
        get { DoseFrequency(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }

    var doseDates: [Date] { doses.map(\.takenAt) }
    var lastDose: Date? { doseDates.max() }

    func status(now: Date = Date()) -> ScheduleStatus? {
        guard let drug, isActive else { return nil }
        return MedicationSchedule.status(drug: drug, frequency: frequency, startedOn: startedOn, doses: doseDates, now: now)
    }
}

@Model
final class MedicationDoseLog {
    var takenAt: Date
    var sideEffects: [String]
    var note: String
    var plan: MedicationPlan?

    init(takenAt: Date = Date(), sideEffects: [String] = [], note: String = "") {
        self.takenAt = takenAt
        self.sideEffects = sideEffects
        self.note = note
    }
}

// MARK: - Exercise, falls and pain

@Model
final class ExerciseLog {
    var date: Date
    var categoryRaw: String
    var activity: String
    var minutes: Int
    /// 0–10 effort (0 = rest, 10 = maximal).
    var effort: Int
    var painBefore: Int?
    var painAfter: Int?
    var exerciseIDs: [String]
    var note: String

    init(date: Date = Date(), category: ExerciseCategory, activity: String, minutes: Int, effort: Int = 5) {
        self.date = date
        categoryRaw = category.rawValue
        self.activity = activity
        self.minutes = minutes
        self.effort = effort
        exerciseIDs = []
        note = ""
    }

    var category: ExerciseCategory { ExerciseCategory(rawValue: categoryRaw) ?? .weightBearing }
    var record: ExerciseRecord { ExerciseRecord(date: date, category: category, minutes: minutes) }
}

@Model
final class FallRecord {
    var date: Date
    var isNearMiss: Bool
    var locationRaw: String
    var activity: String
    var causesRaw: [String]
    var injuriesRaw: [String]
    var fractureSite: String
    var hitHead: Bool
    var couldGetUpAlone: Bool
    /// On the floor for an hour or more.
    var longLie: Bool
    var careRaw: String
    var notes: String

    init(date: Date = Date(), isNearMiss: Bool = false) {
        self.date = date
        self.isNearMiss = isNearMiss
        locationRaw = FallLocation.homeInside.rawValue
        activity = ""
        causesRaw = []
        injuriesRaw = []
        fractureSite = ""
        hitHead = false
        couldGetUpAlone = true
        longLie = false
        careRaw = CareSought.none.rawValue
        notes = ""
    }

    var location: FallLocation { FallLocation(rawValue: locationRaw) ?? .other }
    var causes: [FallCause] { causesRaw.compactMap(FallCause.init(rawValue:)) }
    var injuries: [FallInjury] { injuriesRaw.compactMap(FallInjury.init(rawValue:)) }
    var care: CareSought { CareSought(rawValue: careRaw) ?? CareSought.none }
    var wasInjured: Bool { hitHead || injuries.contains { $0 != FallInjury.none } }

    var summaryInput: FallSummaryInput { FallSummaryInput(date: date, isNearMiss: isNearMiss, injured: wasInjured) }
}

@Model
final class FallRiskScreen {
    var date: Date
    var yesItemIDs: [Int]
    var score: Int

    init(date: Date = Date(), yesItemIDs: Set<Int>) {
        self.date = date
        self.yesItemIDs = yesItemIDs.sorted()
        score = FallRiskChecklist.score(yesItemIDs)
    }
}

@Model
final class PainEntry {
    var date: Date
    /// 0–10 Numeric Rating Scale, pain right now.
    var score: Int
    var locationsRaw: [String]
    var qualitiesRaw: [String]
    var isNewAndSudden: Bool
    var afterFall: Bool
    var helped: [String]
    /// PEG items 2 and 3 (enjoyment of life, general activity). Item 1 is `pegAverage`.
    var pegAverage: Int?
    var pegEnjoyment: Int?
    var pegActivity: Int?
    var note: String

    init(date: Date = Date(), score: Int) {
        self.date = date
        self.score = score
        locationsRaw = []
        qualitiesRaw = []
        isNewAndSudden = false
        afterFall = false
        helped = []
        note = ""
    }

    var locations: Set<PainLocation> {
        get { Set(locationsRaw.compactMap(PainLocation.init(rawValue:))) }
        set { locationsRaw = newValue.map(\.rawValue).sorted() }
    }

    var pegScore: Double? { PEGScale.score([pegAverage, pegEnjoyment, pegActivity]) }
}

enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        PatientProfile.self, VitalReading.self, MedicalHistoryEntry.self, FractureRecord.self, RadiologyReport.self,
        ReportAttachment.self, LabResult.self, SupplementIntake.self, MedicationPlan.self, MedicationDoseLog.self,
        ExerciseLog.self, FallRecord.self, FallRiskScreen.self, PainEntry.self,
    ]
}
