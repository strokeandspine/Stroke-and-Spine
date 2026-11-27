import XCTest
@testable import BoneHealth

private let calendar: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "America/New_York")!
    return c
}()

private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 9, _ min: Int = 0) -> Date {
    calendar.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min))!
}

final class BoneDensityTests: XCTestCase {
    func testWHOCategories() {
        XCTAssertEqual(BoneDensity.category(tScore: 0.5), .normal)
        XCTAssertEqual(BoneDensity.category(tScore: -1.0), .normal)
        XCTAssertEqual(BoneDensity.category(tScore: -1.1), .lowBoneMass)
        XCTAssertEqual(BoneDensity.category(tScore: -2.4), .lowBoneMass)
        XCTAssertEqual(BoneDensity.category(tScore: -2.5), .osteoporosis)
        XCTAssertEqual(BoneDensity.category(tScore: -3.2, hasFragilityFracture: true), .severeOsteoporosis)
        XCTAssertEqual(BoneDensity.category(tScore: -2.0, hasFragilityFracture: true), .lowBoneMass)
    }

    func testOverallUsesLowestSite() {
        let results = [
            DexaSiteResult(site: .lumbarSpine, bmd: 0.9, tScore: -1.8),
            DexaSiteResult(site: .femoralNeck, bmd: 0.6, tScore: -2.6),
            DexaSiteResult(site: .totalHip, bmd: 0.75, tScore: -1.9),
        ]
        XCTAssertEqual(BoneDensity.lowest(results)?.site, .femoralNeck)
        XCTAssertEqual(BoneDensity.overallCategory(results, hasFragilityFracture: false), .osteoporosis)
        XCTAssertNil(BoneDensity.overallCategory([DexaSiteResult(site: .totalHip, bmd: 0.8)], hasFragilityFracture: false))
    }

    func testZScoreAndWhichScoreApplies() {
        XCTAssertTrue(BoneDensity.isZScoreBelowExpected(-2.0))
        XCTAssertFalse(BoneDensity.isZScoreBelowExpected(-1.9))
        XCTAssertTrue(BoneDensity.usesTScore(age: 45, sex: .female, isPostmenopausal: true))
        XCTAssertFalse(BoneDensity.usesTScore(age: 45, sex: .female, isPostmenopausal: false))
        XCTAssertFalse(BoneDensity.usesTScore(age: 40, sex: .male, isPostmenopausal: false))
        XCTAssertTrue(BoneDensity.usesTScore(age: 62, sex: .male, isPostmenopausal: false))
    }

    func testBMDChangeAgainstLSC() throws {
        let old = DexaSiteResult(site: .lumbarSpine, bmd: 0.800)
        let gained = try XCTUnwrap(BoneDensity.change(from: old, to: DexaSiteResult(site: .lumbarSpine, bmd: 0.840)))
        XCTAssertEqual(gained.percent, 5, accuracy: 0.001)
        XCTAssertEqual(gained.direction, .gained)
        let stable = try XCTUnwrap(BoneDensity.change(from: old, to: DexaSiteResult(site: .lumbarSpine, bmd: 0.816)))
        XCTAssertEqual(stable.direction, .stable)
        let hipOld = DexaSiteResult(site: .totalHip, bmd: 0.700)
        let lost = try XCTUnwrap(BoneDensity.change(from: hipOld, to: DexaSiteResult(site: .totalHip, bmd: 0.660)))
        XCTAssertEqual(lost.direction, .lost)
        XCTAssertNil(BoneDensity.change(from: old, to: DexaSiteResult(site: .totalHip, bmd: 0.8)))
    }

    func testFRAXThreshold() {
        XCTAssertTrue(FRAX.meetsUSTreatmentThreshold(major: 21, hip: 1))
        XCTAssertTrue(FRAX.meetsUSTreatmentThreshold(major: 10, hip: 3))
        XCTAssertFalse(FRAX.meetsUSTreatmentThreshold(major: 15, hip: 2.5))
    }
}

final class SupplementTests: XCTestCase {
    func testTargetsByAgeAndSex() {
        let woman60 = NutrientTargets.forPerson(age: 60, sex: .female)
        XCTAssertEqual(woman60.daily[.calcium], 1200)
        XCTAssertEqual(woman60.daily[.vitaminD], 800)
        XCTAssertEqual(woman60.daily[.magnesium], 320)
        XCTAssertEqual(woman60.upperLimit[.calcium], 2000)

        let man60 = NutrientTargets.forPerson(age: 60, sex: .male)
        XCTAssertEqual(man60.daily[.calcium], 1000)
        XCTAssertEqual(man60.daily[.magnesium], 420)

        let man75 = NutrientTargets.forPerson(age: 75, sex: .male)
        XCTAssertEqual(man75.daily[.calcium], 1200)

        let woman40 = NutrientTargets.forPerson(age: 40, sex: .female)
        XCTAssertEqual(woman40.daily[.calcium], 1000)
        XCTAssertEqual(woman40.daily[.vitaminD], 600)
        XCTAssertEqual(woman40.upperLimit[.calcium], 2500)
    }

    private var checker: SupplementChecker {
        SupplementChecker(targets: .forPerson(age: 65, sex: .female), calendar: calendar)
    }

    func testDailyTotalsAndLevels() {
        let day = date(2026, 3, 10)
        let records = [
            IntakeRecord(takenAt: date(2026, 3, 10, 8), source: .supplement, amounts: SupplementProduct.amounts(ca: 600, d: 800)),
            IntakeRecord(takenAt: date(2026, 3, 10, 19), source: .food, amounts: SupplementProduct.amounts(ca: 600, mg: 40)),
            IntakeRecord(takenAt: date(2026, 3, 9, 19), source: .food, amounts: SupplementProduct.amounts(ca: 300)),
        ]
        let status = checker.status(records: records, on: day)
        let calcium = status.first { $0.nutrient == .calcium }!
        XCTAssertEqual(calcium.total, 1200)
        XCTAssertEqual(calcium.level, .onTarget)
        XCTAssertEqual(status.first { $0.nutrient == .magnesium }?.level, .low)
    }

    func testCalciumAboveUpperLimitAndLargeDose() {
        let records = [IntakeRecord(takenAt: date(2026, 3, 10, 8), source: .supplement, amounts: SupplementProduct.amounts(ca: 1200))]
        let proposed = IntakeRecord(takenAt: date(2026, 3, 10, 12), source: .supplement, amounts: SupplementProduct.amounts(ca: 1000))
        let ids = checker.warnings(records: records, proposed: proposed, now: date(2026, 3, 10, 12)).map(\.id)
        XCTAssertTrue(ids.contains("calcium-ul"))
        XCTAssertTrue(ids.contains("calcium-dose-size"))
    }

    func testMagnesiumLimitAppliesToSupplementsOnly() {
        let food = IntakeRecord(takenAt: date(2026, 3, 10, 8), source: .food, amounts: SupplementProduct.amounts(mg: 300))
        let supplement = IntakeRecord(takenAt: date(2026, 3, 10, 12), source: .supplement, amounts: SupplementProduct.amounts(mg: 241))
        XCTAssertFalse(checker.warnings(records: [food], proposed: supplement, now: date(2026, 3, 10, 12)).map(\.id).contains("magnesium-ul"))
        let second = IntakeRecord(takenAt: date(2026, 3, 10, 18), source: .supplement, amounts: SupplementProduct.amounts(mg: 241))
        XCTAssertTrue(checker.warnings(records: [food, supplement], proposed: second, now: date(2026, 3, 10, 18)).map(\.id).contains("magnesium-ul"))
    }

    func testMagnesiumWithKidneyDisease() {
        var c = checker
        c.hasKidneyDisease = true
        let supplement = IntakeRecord(takenAt: date(2026, 3, 10, 12), source: .supplement, amounts: SupplementProduct.amounts(mg: 100))
        XCTAssertTrue(c.warnings(records: [], proposed: supplement, now: date(2026, 3, 10, 12)).map(\.id).contains("magnesium-kidney"))
    }

    func testWeeklyHighDoseVitaminDUsesSevenDayAverage() {
        // 50,000 IU once a week averages ~7,143 IU/day — above 4,000 unless prescribed.
        let weekly = IntakeRecord(takenAt: date(2026, 3, 10, 8), source: .supplement, amounts: SupplementProduct.amounts(d: 50000))
        XCTAssertTrue(checker.warnings(records: [], proposed: weekly, now: date(2026, 3, 10, 8)).map(\.id).contains("vitamin-d-ul"))
        var prescribed = checker
        prescribed.prescribedHighDoseVitaminD = true
        XCTAssertFalse(prescribed.warnings(records: [], proposed: weekly, now: date(2026, 3, 10, 8)).map(\.id).contains("vitamin-d-ul"))

        let daily2000 = (0..<7).map { IntakeRecord(takenAt: date(2026, 3, 4 + $0, 8), source: .supplement, amounts: SupplementProduct.amounts(d: 2000)) }
        XCTAssertEqual(checker.sevenDayAverage(.vitaminD, records: daily2000, endingOn: date(2026, 3, 10)), 2000, accuracy: 0.01)
    }

    func testCalciumTooSoonAfterBisphosphonate() {
        let window = EmptyStomachWindow(drugName: "alendronate", takenAt: date(2026, 3, 10, 7, 0), waitMinutes: 30)
        let tooSoon = IntakeRecord(takenAt: date(2026, 3, 10, 7, 15), source: .supplement, amounts: SupplementProduct.amounts(ca: 500))
        let warnings = checker.warnings(records: [], proposed: tooSoon, now: date(2026, 3, 10, 7, 15), emptyStomach: [window])
        XCTAssertEqual(warnings.first?.id, "bisphosphonate-window")
        XCTAssertEqual(warnings.first?.severity, .stop)
        let later = IntakeRecord(takenAt: date(2026, 3, 10, 7, 45), source: .supplement, amounts: SupplementProduct.amounts(ca: 500))
        XCTAssertFalse(checker.warnings(records: [], proposed: later, now: date(2026, 3, 10, 7, 45), emptyStomach: [window]).map(\.id).contains("bisphosphonate-window"))
    }
}

final class MedicationScheduleTests: XCTestCase {
    private let alendronate = OsteoDrugLibrary.drug("alendronate")!
    private let denosumab = OsteoDrugLibrary.drug("denosumab")!
    private let romosozumab = OsteoDrugLibrary.drug("romosozumab")!
    private let teriparatide = OsteoDrugLibrary.drug("teriparatide")!

    func testLibraryIsComplete() {
        XCTAssertGreaterThanOrEqual(OsteoDrugLibrary.all.count, 12)
        XCTAssertEqual(Set(OsteoDrugLibrary.all.map(\.id)).count, OsteoDrugLibrary.all.count, "IDs must be unique")
        for drug in OsteoDrugLibrary.all {
            XCTAssertFalse(drug.frequencies.isEmpty, drug.id)
            XCTAssertFalse(drug.howToTake.isEmpty, drug.id)
        }
    }

    func testWeeklyDueDates() {
        let start = date(2026, 3, 1)
        let lastDose = date(2026, 3, 1, 7)
        XCTAssertEqual(MedicationSchedule.status(drug: alendronate, frequency: .weekly, startedOn: start, doses: [lastDose], now: date(2026, 3, 5), calendar: calendar).state, .dueSoon)
        XCTAssertEqual(MedicationSchedule.status(drug: alendronate, frequency: .weekly, startedOn: start, doses: [lastDose], now: date(2026, 3, 8), calendar: calendar).state, .dueToday)
        XCTAssertEqual(MedicationSchedule.status(drug: alendronate, frequency: .weekly, startedOn: start, doses: [lastDose], now: date(2026, 3, 10), calendar: calendar).state, .overdue)
        XCTAssertEqual(MedicationSchedule.status(drug: alendronate, frequency: .weekly, startedOn: start, doses: [], now: date(2026, 3, 1), calendar: calendar).state, .dueToday)
    }

    func testDailyDoses() {
        let teri = teriparatide
        let start = date(2026, 1, 1)
        XCTAssertEqual(MedicationSchedule.status(drug: teri, frequency: .daily, startedOn: start, doses: [date(2026, 3, 10, 8)], now: date(2026, 3, 10, 20), calendar: calendar).state, .upToDate)
        XCTAssertEqual(MedicationSchedule.status(drug: teri, frequency: .daily, startedOn: start, doses: [date(2026, 3, 9, 8)], now: date(2026, 3, 10, 20), calendar: calendar).state, .dueToday)
        XCTAssertEqual(MedicationSchedule.status(drug: teri, frequency: .daily, startedOn: start, doses: [date(2026, 3, 7, 8)], now: date(2026, 3, 10, 20), calendar: calendar).state, .overdue)
    }

    func testDenosumabLateDoseBecomesUrgent() {
        let last = date(2026, 1, 15)
        let due = MedicationSchedule.status(drug: denosumab, frequency: .every6Months, startedOn: last, doses: [last], now: date(2026, 7, 15), calendar: calendar)
        XCTAssertEqual(due.state, .dueToday)
        XCTAssertEqual(due.nextDue, calendar.startOfDay(for: date(2026, 7, 15)))
        XCTAssertEqual(MedicationSchedule.status(drug: denosumab, frequency: .every6Months, startedOn: last, doses: [last], now: date(2026, 8, 1), calendar: calendar).state, .overdue)
        XCTAssertEqual(MedicationSchedule.status(drug: denosumab, frequency: .every6Months, startedOn: last, doses: [last], now: date(2026, 8, 20), calendar: calendar).state, .urgent)
    }

    func testRomosozumabCompletesAfterTwelveDoses() {
        let doses = (0..<12).map { calendar.date(byAdding: .month, value: $0, to: date(2025, 1, 10))! }
        XCTAssertEqual(MedicationSchedule.status(drug: romosozumab, frequency: .monthly, startedOn: doses[0], doses: doses, now: date(2026, 1, 20), calendar: calendar).state, .completed)
        XCTAssertNotEqual(MedicationSchedule.status(drug: romosozumab, frequency: .monthly, startedOn: doses[0], doses: Array(doses.prefix(11)), now: date(2025, 12, 1), calendar: calendar).state, .completed)
    }

    func testDurationNotes() {
        XCTAssertTrue(MedicationSchedule.durationNotes(drug: alendronate, startedOn: date(2020, 1, 1), now: date(2026, 1, 1), calendar: calendar).map(\.id).contains("alendronate-review"))
        XCTAssertTrue(MedicationSchedule.durationNotes(drug: alendronate, startedOn: date(2023, 1, 1), now: date(2026, 1, 1), calendar: calendar).isEmpty)
        XCTAssertTrue(MedicationSchedule.durationNotes(drug: teriparatide, startedOn: date(2024, 1, 1), now: date(2026, 2, 1), calendar: calendar).map(\.id).contains("teriparatide-limit"))
        XCTAssertTrue(MedicationSchedule.durationNotes(drug: teriparatide, startedOn: date(2024, 1, 1), now: date(2025, 11, 1), calendar: calendar).map(\.id).contains("teriparatide-limit-soon"))
    }

    func testFrequencyArithmetic() {
        let d = date(2026, 1, 31)
        XCTAssertEqual(DoseFrequency.monthly.nextDue(after: d, calendar: calendar), calendar.startOfDay(for: date(2026, 2, 28)))
        XCTAssertEqual(DoseFrequency.yearly.nextDue(after: d, calendar: calendar), calendar.startOfDay(for: date(2027, 1, 31)))
    }
}

final class FallsAndPainTests: XCTestCase {
    func testStayIndependentScoring() {
        XCTAssertEqual(FallRiskChecklist.items.count, 12)
        XCTAssertEqual(FallRiskChecklist.items.reduce(0) { $0 + $1.points }, FallRiskChecklist.maximum)
        XCTAssertEqual(FallRiskChecklist.score([1, 2]), 4)
        XCTAssertTrue(FallRiskChecklist.isAtRisk(score: 4))
        XCTAssertEqual(FallRiskChecklist.score([3, 4, 5]), 3)
        XCTAssertFalse(FallRiskChecklist.isAtRisk(score: 3))
    }

    func testFallRecommendations() {
        let now = date(2026, 6, 1)
        let two = [FallSummaryInput(date: date(2026, 1, 1), isNearMiss: false, injured: false),
                   FallSummaryInput(date: date(2026, 4, 1), isNearMiss: false, injured: false)]
        XCTAssertTrue(FallRisk.recommendations(falls: two, latestChecklistScore: nil, now: now, calendar: calendar).map(\.id).contains("falls-assessment"))
        let oneInjured = [FallSummaryInput(date: date(2026, 4, 1), isNearMiss: false, injured: true)]
        XCTAssertTrue(FallRisk.recommendations(falls: oneInjured, latestChecklistScore: nil, now: now, calendar: calendar).map(\.id).contains("falls-assessment"))
        let old = [FallSummaryInput(date: date(2024, 4, 1), isNearMiss: false, injured: true)]
        XCTAssertTrue(FallRisk.recommendations(falls: old, latestChecklistScore: 2, now: now, calendar: calendar).isEmpty)
        XCTAssertTrue(FallRisk.recommendations(falls: [], latestChecklistScore: 5, now: now, calendar: calendar).map(\.id).contains("falls-checklist"))
    }

    func testPEG() throws {
        XCTAssertEqual(try XCTUnwrap(PEGScale.score([6, 3, 3])), 4, accuracy: 0.001)
        XCTAssertNil(PEGScale.score([6, nil, 3]))
        XCTAssertEqual(PEGScale.describeChange(from: 6, to: 4), "Meaningfully better than last time")
        XCTAssertEqual(PEGScale.describeChange(from: 6, to: 5.5), "About the same as last time")
        XCTAssertEqual(PEGScale.describeChange(from: 4, to: 6), "Meaningfully worse than last time")
    }

    func testPainAlerts() {
        let vertebral = PainAlerts.warnings(PainAlertInput(score: 7, locations: [.midBack], isNewAndSudden: true, afterFall: false, takesAntiresorptive: false))
        XCTAssertEqual(vertebral.map(\.id), ["pain-vertebral"])
        let hip = PainAlerts.warnings(PainAlertInput(score: 8, locations: [.hip], isNewAndSudden: true, afterFall: true, takesAntiresorptive: false))
        XCTAssertEqual(hip.first?.severity, .stop)
        let thigh = PainAlerts.warnings(PainAlertInput(score: 3, locations: [.thigh], isNewAndSudden: false, afterFall: false, takesAntiresorptive: true))
        XCTAssertTrue(thigh.map(\.id).contains("pain-aff"))
        let jaw = PainAlerts.warnings(PainAlertInput(score: 2, locations: [.jaw], isNewAndSudden: false, afterFall: false, takesAntiresorptive: true))
        XCTAssertTrue(jaw.map(\.id).contains("pain-onj"))
        XCTAssertTrue(PainAlerts.warnings(PainAlertInput(score: 3, locations: [.knee], isNewAndSudden: false, afterFall: false, takesAntiresorptive: true)).isEmpty)
    }
}

final class VitalsAndExerciseTests: XCTestCase {
    func testBloodPressureCategories() {
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 115, diastolic: 75), .normal)
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 125, diastolic: 75), .elevated)
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 125, diastolic: 85), .stage1)
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 145, diastolic: 85), .stage2)
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 185, diastolic: 100), .severe)
        XCTAssertEqual(BloodPressureCategory.classify(systolic: 85, diastolic: 55), .low)
    }

    func testBMI() throws {
        XCTAssertEqual(try XCTUnwrap(BodyMeasures.bmi(weightKg: 50, heightCm: 165)), 18.37, accuracy: 0.01)
        XCTAssertEqual(BodyMeasures.bmiLabel(18.37), "Underweight")
    }

    func testHeightLoss() {
        XCTAssertEqual(BodyMeasures.heightLossWarning(latestCm: 160, tallestMeasuredCm: 162.5, rememberedPeakCm: nil, metric: true)?.id, "height-loss-measured")
        XCTAssertNil(BodyMeasures.heightLossWarning(latestCm: 160, tallestMeasuredCm: 161, rememberedPeakCm: 163, metric: true))
        XCTAssertEqual(BodyMeasures.heightLossWarning(latestCm: 160, tallestMeasuredCm: 160, rememberedPeakCm: 164.5, metric: false)?.id, "height-loss-peak")
    }

    func testWeeklyExerciseProgress() {
        let day = date(2026, 3, 10)
        let records = [
            ExerciseRecord(date: date(2026, 3, 10), category: .weightBearing, minutes: 30),
            ExerciseRecord(date: date(2026, 3, 8), category: .weightBearing, minutes: 45),
            ExerciseRecord(date: date(2026, 3, 2), category: .weightBearing, minutes: 60), // outside the 7 days
            ExerciseRecord(date: date(2026, 3, 9, 8), category: .strength, minutes: 20),
            ExerciseRecord(date: date(2026, 3, 9, 18), category: .strength, minutes: 20), // same day counts once
            ExerciseRecord(date: date(2026, 3, 6), category: .strength, minutes: 20),
            ExerciseRecord(date: date(2026, 3, 7), category: .balance, minutes: 15),
        ]
        let p = WeeklyExerciseProgress.compute(records, endingOn: day, calendar: calendar)
        XCTAssertEqual(p.aerobicMinutes, 75)
        XCTAssertEqual(p.strengthDays, 2)
        XCTAssertEqual(p.balanceMinutes, 15)
    }

    func testExerciseLibraryCoversEveryCategory() {
        for category in ExerciseCategory.allCases {
            XCTAssertFalse(ExerciseLibrary.exercises(in: category).isEmpty, category.rawValue)
        }
        XCTAssertEqual(Set(ExerciseLibrary.all.map(\.id)).count, ExerciseLibrary.all.count)
    }

    func testLabNotes() {
        XCTAssertNotNil(LabTest.vitaminD.note(for: 15))
        XCTAssertNotNil(LabTest.egfr.note(for: 28))
        XCTAssertNil(LabTest.egfr.note(for: 75))
        XCTAssertNil(LabTest.calcium.note(for: 9.4))
    }
}
