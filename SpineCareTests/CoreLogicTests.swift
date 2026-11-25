import XCTest
@testable import SpineCare

final class QuestionnaireScoringTests: XCTestCase {
    func testPHQ9TotalsAndSeverity() throws {
        let score = try XCTUnwrap(Questionnaire.phq9.score([1, 1, 1, 1, 1, 1, 1, 1, 0]))
        XCTAssertEqual(score.value, 8)
        XCTAssertEqual(score.severity, "Mild")
        XCTAssertFalse(score.needsCrisisSupport)
    }

    func testPHQ9Item9TriggersCrisisSupport() throws {
        let score = try XCTUnwrap(Questionnaire.phq9.score([0, 0, 0, 0, 0, 0, 0, 0, 1]))
        XCTAssertTrue(score.needsCrisisSupport)
    }

    func testPHQ9SeverityBands() {
        XCTAssertEqual(Scoring.phq9Severity(4), "Minimal")
        XCTAssertEqual(Scoring.phq9Severity(10), "Moderate")
        XCTAssertEqual(Scoring.phq9Severity(15), "Moderately severe")
        XCTAssertEqual(Scoring.phq9Severity(20), "Severe")
    }

    func testGAD7() throws {
        let score = try XCTUnwrap(Questionnaire.gad7.score([3, 3, 3, 3, 3, 3, 3]))
        XCTAssertEqual(score.value, 21)
        XCTAssertEqual(score.severity, "Severe")
    }

    func testISI() throws {
        let score = try XCTUnwrap(Questionnaire.isi.score([2, 2, 2, 2, 2, 2, 2]))
        XCTAssertEqual(score.value, 14)
        XCTAssertEqual(score.severity, "Subthreshold insomnia")
    }

    func testIncompleteRequiredAnswersReturnNil() {
        XCTAssertNil(Questionnaire.gad7.score([1, 1, nil, 1, 1, 1, 1]))
        XCTAssertNil(Questionnaire.gad7.score([1, 1]))
    }

    func testODIPercentageAllSections() throws {
        // 10 sections × 2 = 20 of 50 → 40%
        let score = try XCTUnwrap(Questionnaire.odi.score(Array(repeating: 2, count: 10)))
        XCTAssertEqual(score.value, 40, accuracy: 0.001)
        XCTAssertEqual(score.severity, "Moderate disability")
    }

    func testODISkippedOptionalSectionUsesRemainingSections() throws {
        // Sex life (index 7) skipped: 9 sections × 3 = 27 of 45 → 60%
        var answers: [Int?] = Array(repeating: 3, count: 10)
        answers[7] = nil
        let score = try XCTUnwrap(Questionnaire.odi.score(answers))
        XCTAssertEqual(score.value, 60, accuracy: 0.001)
    }

    func testMCIDChangeDescription() {
        XCTAssertEqual(Scoring.describeChange(from: 40, to: 28, id: .odi), "Meaningfully better than last time")
        XCTAssertEqual(Scoring.describeChange(from: 40, to: 35, id: .odi), "About the same as last time")
        XCTAssertEqual(Scoring.describeChange(from: 5, to: 12, id: .phq9), "Meaningfully worse than last time")
    }

    func testAllItemsHaveOptions() {
        for q in Questionnaire.all {
            for item in q.items {
                XCTAssertFalse(item.options.isEmpty, "\(q.id) item missing options")
                XCTAssertEqual(item.options.map(\.value), Array(0..<item.options.count))
            }
        }
        XCTAssertEqual(Questionnaire.odi.items.count, 10)
        XCTAssertTrue(Questionnaire.odi.items.allSatisfy { $0.options.count == 6 })
        XCTAssertEqual(Questionnaire.phq9.items.count, 9)
        XCTAssertEqual(Questionnaire.gad7.items.count, 7)
        XCTAssertEqual(Questionnaire.isi.items.count, 7)
    }
}

final class RedFlagTests: XCTestCase {
    func testNoFlagsIsNone() {
        XCTAssertEqual(RedFlagScreen.evaluate([]), .none)
    }

    func testMostUrgentFlagWins() {
        XCTAssertEqual(RedFlagScreen.evaluate(["weightLoss", "fever"]), .urgent)
        XCTAssertEqual(RedFlagScreen.evaluate(["weightLoss", "saddle"]), .emergency)
    }

    func testBladderAndBowelAreEmergencies() {
        for id in ["bladder", "bowel", "saddle", "bilateralWeakness", "chestPain"] {
            XCTAssertEqual(RedFlagScreen.flag(id: id)?.urgency, .emergency, id)
        }
    }

    func testFlagIDsAreUnique() {
        let ids = RedFlagScreen.flags.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
}

final class MedicationSafetyTests: XCTestCase {
    let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func dose(_ ingredient: Ingredient, _ mg: Double, hoursAgo: Double) -> DoseRecord {
        DoseRecord(takenAt: now.addingTimeInterval(-hoursAgo * 3600), amounts: [.init(ingredient: ingredient, milligrams: mg)])
    }

    func testRolling24HourTotalsIgnoreOlderDoses() throws {
        let checker = MedicationSafetyChecker()
        let doses = [dose(.acetaminophen, 1000, hoursAgo: 2), dose(.acetaminophen, 1000, hoursAgo: 8), dose(.acetaminophen, 1000, hoursAgo: 30)]
        let status = try XCTUnwrap(checker.status(doses: doses, now: now).first { $0.ingredient == .acetaminophen })
        XCTAssertEqual(status.totalMg, 2000)
        XCTAssertEqual(status.limitMg, 3000)
        XCTAssertEqual(status.level, .ok)
    }

    func testCombinationProductCountsHiddenAcetaminophen() throws {
        let checker = MedicationSafetyChecker()
        let combo = DoseRecord(takenAt: now.addingTimeInterval(-3600), amounts: [
            .init(ingredient: .acetaminophen, milligrams: 500), .init(ingredient: .aspirin, milligrams: 500)])
        let doses = [dose(.acetaminophen, 2000, hoursAgo: 6), combo]
        let status = try XCTUnwrap(checker.status(doses: doses, now: now).first { $0.ingredient == .acetaminophen })
        XCTAssertEqual(status.totalMg, 2500)
        XCTAssertEqual(status.level, .approaching)
    }

    func testOverLimitProducesStopWarningWithPoisonControl() {
        let checker = MedicationSafetyChecker()
        let doses = [dose(.acetaminophen, 2000, hoursAgo: 1), dose(.acetaminophen, 1500, hoursAgo: 5)]
        let warnings = checker.warnings(doses: doses, now: now)
        let stop = warnings.first { $0.severity == .stop }
        XCTAssertNotNil(stop)
        XCTAssertTrue(stop?.message.contains("1-800-222-1222") ?? false)
    }

    func testPatientLimitCannotExceedLabelCeiling() {
        let checker = MedicationSafetyChecker(limits: [.ibuprofen: 3200])
        XCTAssertEqual(checker.limit(for: .ibuprofen), 1200)
        let lower = MedicationSafetyChecker(limits: [.acetaminophen: 2000])
        XCTAssertEqual(lower.limit(for: .acetaminophen), 2000)
    }

    func testMultipleNSAIDsWarning() {
        let checker = MedicationSafetyChecker()
        let warnings = checker.warnings(doses: [dose(.ibuprofen, 400, hoursAgo: 3), dose(.naproxen, 220, hoursAgo: 1)], now: now)
        XCTAssertTrue(warnings.contains { $0.id == "multiple-nsaids" })
    }

    func testShortIntervalWarningForProposedDose() {
        let checker = MedicationSafetyChecker()
        let proposed = DoseRecord(takenAt: now, amounts: [.init(ingredient: .naproxen, milligrams: 220)])
        let warnings = checker.warnings(doses: [dose(.naproxen, 220, hoursAgo: 3)], proposed: proposed, now: now)
        XCTAssertTrue(warnings.contains { $0.id == "interval-naproxen" })
    }

    func testConditionWarnings() {
        let checker = MedicationSafetyChecker(conditions: [.kidneyDisease, .liverDisease, .lowDoseAspirin])
        let nsaid = checker.conditionWarnings(for: [.ibuprofen])
        XCTAssertTrue(nsaid.contains { $0.id == "nsaid-kidneyDisease" })
        XCTAssertTrue(nsaid.contains { $0.id == "ibuprofen-aspirin" })
        XCTAssertFalse(nsaid.contains { $0.id == "apap-liver" })
        let apap = checker.conditionWarnings(for: [.acetaminophen])
        XCTAssertTrue(apap.contains { $0.id == "apap-liver" })
        XCTAssertFalse(apap.contains { $0.id == "nsaid-kidneyDisease" })
    }

    func testConsecutiveDays() {
        let checker = MedicationSafetyChecker()
        let calendar = Calendar(identifier: .gregorian)
        let doses = (0..<11).map { day in
            DoseRecord(takenAt: calendar.date(byAdding: .day, value: -day, to: now)!, amounts: [.init(ingredient: .ibuprofen, milligrams: 200)])
        }
        XCTAssertEqual(checker.consecutiveDaysUsed(doses: doses, now: now, calendar: calendar), 11)
        XCTAssertEqual(checker.consecutiveDaysUsed(doses: Array(doses.dropFirst()), now: now, calendar: calendar), 0)
    }
}

final class InsightsTests: XCTestCase {
    func testWeeklySummaryDetectsMeaningfulImprovement() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var values: [Insights.DailyValue] = []
        for day in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -day, to: now)!
            values.append(.init(date: date, value: day < 7 ? 3 : 6))
        }
        let summary = try XCTUnwrap(Insights.weeklyPainSummary(values, now: now, calendar: calendar))
        XCTAssertTrue(summary.contains("meaningful improvement"), summary)
    }
}
