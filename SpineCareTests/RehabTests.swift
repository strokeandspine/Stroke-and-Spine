import XCTest
@testable import SpineCare

final class ExerciseContentTests: XCTestCase {
    func testExerciseIDsAreUnique() {
        let ids = ExerciseLibrary.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testEveryProgramExerciseExists() {
        for program in RehabPrograms.all {
            for stage in program.stages {
                for id in stage.exerciseIDs {
                    XCTAssertNotNil(ExerciseLibrary.exercise(id), "\(program.id) references missing exercise \(id)")
                }
            }
        }
    }

    func testEasierAndHarderLinksExist() {
        for e in ExerciseLibrary.all {
            if let id = e.easierID { XCTAssertNotNil(ExerciseLibrary.exercise(id), "\(e.id) easier → \(id)") }
            if let id = e.harderID { XCTAssertNotNil(ExerciseLibrary.exercise(id), "\(e.id) harder → \(id)") }
        }
    }

    func testEveryExerciseHasInstructions() {
        for e in ExerciseLibrary.all {
            XCTAssertFalse(e.steps.isEmpty, e.id)
            XCTAssertFalse(e.purpose.isEmpty, e.id)
            XCTAssertFalse(e.dosage.description.isEmpty, e.id)
        }
    }

    func testEarlyPostOpProgramOnlyUsesGentleExercises() throws {
        let program = try XCTUnwrap(RehabPrograms.program("after-surgery-early"))
        XCTAssertTrue(program.requiresSurgeonClearance)
        for id in program.stages.flatMap(\.exerciseIDs) {
            XCTAssertEqual(ExerciseLibrary.exercise(id)?.earlyPostOpOK, true, "\(id) is not marked safe for early post-op")
        }
    }

    func testFreeTier() {
        XCTAssertTrue(RehabPrograms.freeExerciseIDs.contains("walking"))
        XCTAssertFalse(RehabPrograms.freeExerciseIDs.contains("side-plank"))
        let free = RehabPrograms.all.filter(\.isFree).map(\.id)
        XCTAssertEqual(Set(free), ["getting-started", "after-surgery-early"])
    }

    func testPremiumGating() throws {
        let premiumProgram = try XCTUnwrap(RehabPrograms.program("core-strength"))
        XCTAssertFalse(PremiumFeature.program(premiumProgram).isAvailable(isPremium: false))
        XCTAssertTrue(PremiumFeature.program(premiumProgram).isAvailable(isPremium: true))
        XCTAssertFalse(PremiumFeature.longTrends.isAvailable(isPremium: false))
    }

    func testDosageDescriptions() {
        XCTAssertEqual(Exercise.Dosage(reps: 10, sets: 2).description, "10 reps, 2 sets")
        XCTAssertEqual(Exercise.Dosage(reps: 8, perSide: true).description, "8 reps each side")
        XCTAssertEqual(Exercise.Dosage(minutes: 10).description, "10 minutes")
        XCTAssertEqual(Exercise.Dosage(reps: 10, holdSeconds: 10).description, "10 reps, hold 10 seconds")
    }
}

final class ProgressionTests: XCTestCase {
    let program = RehabPrograms.program("getting-started")!
    let day: TimeInterval = 86_400

    private func session(_ n: Int, stage: Int = 0, before: Int = 4, after: Int = 4,
                         difficulty: Difficulty = .aboutRight, hurt: [String] = []) -> SessionSummary {
        SessionSummary(date: Date(timeIntervalSince1970: Double(n) * day), stageIndex: stage,
                       painBefore: before, painAfter: after, difficulty: difficulty, hurtExerciseIDs: hurt)
    }

    func testNoSessionsKeepGoing() {
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 0, sessions: []), .keepGoing)
    }

    func testBigPainJumpStepsBack() {
        let advice = RehabProgression.advice(program: program, stageIndex: 0, sessions: [session(1, before: 3, after: 6)])
        guard case .stepBack = advice else { return XCTFail("Expected step back, got \(advice)") }
    }

    func testHurtExerciseSuggestsEasierVersion() {
        // Getting started doesn't include press-ups, but the rule works on any exercise with an easier version.
        let advice = RehabProgression.advice(program: program, stageIndex: 0, sessions: [session(1, hurt: ["press-up"])])
        guard case .stepBack(_, let easier) = advice else { return XCTFail("Expected step back") }
        XCTAssertEqual(easier["press-up"], "prone-lying")
    }

    func testTooFewSessionsKeepGoing() {
        let sessions = (1...3).map { session($0) }
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 0, sessions: sessions), .keepGoing)
    }

    func testEnoughComfortableSessionsProgress() {
        let sessions = (1...5).map { session($0, after: 5) } // +1 pain is in the green zone
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 0, sessions: sessions), .readyToProgress(nextStage: 1))
    }

    func testRecentAmberSessionBlocksProgression() {
        var sessions = (1...5).map { session($0) }
        sessions[3] = session(4, after: 7)  // +3, but not the latest session
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 0, sessions: sessions), .keepGoing)
    }

    func testFinalStageCompletesProgram() {
        let sessions = (1...6).map { session($0, stage: 1) }
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 1, sessions: sessions), .programComplete)
    }

    func testOtherStageSessionsAreIgnored() {
        let sessions = (1...5).map { session($0, stage: 0) }
        XCTAssertEqual(RehabProgression.advice(program: program, stageIndex: 1, sessions: sessions), .keepGoing)
    }
}
