import XCTest
@testable import StrongerYears

final class ExerciseCatalogTests: XCTestCase {
    func testIDsAreUnique() {
        let ids = ExerciseCatalog.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testEasierAndHarderLinksExist() {
        for e in ExerciseCatalog.all {
            if let id = e.easierID { XCTAssertNotNil(ExerciseCatalog.exercise(id), "\(e.id) easier → \(id)") }
            if let id = e.harderID { XCTAssertNotNil(ExerciseCatalog.exercise(id), "\(e.id) harder → \(id)") }
        }
    }

    func testEveryBodyPartHasAnEasyNoEquipmentOption() {
        for part in BodyPart.allCases {
            let options = WorkoutBuilder.candidates(for: part, experience: .beginner, equipment: Equipment.always)
            XCTAssertFalse(options.isEmpty, "\(part) has no exercise needing only a chair or body weight")
        }
    }

    func testEveryExerciseHasInstructions() {
        for e in ExerciseCatalog.all {
            XCTAssertFalse(e.steps.isEmpty, e.id)
            XCTAssertFalse(e.summary.isEmpty, e.id)
        }
    }

    func testEveryBodyPartHasAStretch() {
        for part in BodyPart.allCases where part != .balance {
            XCTAssertTrue(GuideLibrary.stretches.contains { $0.bodyParts.contains(part) }, "\(part) has no stretch")
        }
    }

    func testStretchHoldsAreAtLeast20Seconds() {
        for s in GuideLibrary.stretches { XCTAssertGreaterThanOrEqual(s.holdSeconds, 20, s.id) }
    }

    func testRequiredGuidesExist() {
        for id in ["warm-up", "cool-down", "stretching", "sauna", "cold-plunge", "avoiding-injury"] {
            XCTAssertNotNil(GuideLibrary.guide(id), id)
        }
    }
}

final class WorkoutBuilderTests: XCTestCase {
    private let allEquipment = Set(Equipment.allCases)

    func testBeginnerOnlyGetsEasyExercises() {
        let plan = WorkoutBuilder.build(title: "Test", bodyParts: ScheduleTemplates.fullBody, experience: .beginner,
                                        settings: Experience.beginner.defaultSettings, equipment: allEquipment)
        XCTAssertFalse(plan.exercises.isEmpty)
        XCTAssertTrue(plan.exercises.allSatisfy { $0.exercise.difficulty == .easy })
    }

    func testOnlyUsesAvailableEquipment() {
        let plan = WorkoutBuilder.build(title: "Test", bodyParts: ScheduleTemplates.fullBody, experience: .experienced,
                                        settings: TrainingSettings(duration: .long, intensity: .moderate, volume: .full),
                                        equipment: [])
        XCTAssertTrue(plan.exercises.allSatisfy { Equipment.always.contains($0.exercise.equipment) })
    }

    func testVolumeControlsSets() {
        for volume in VolumeLevel.allCases {
            let settings = TrainingSettings(duration: .long, intensity: .gentle, volume: volume)
            let plan = WorkoutBuilder.build(title: "T", bodyParts: [.legs], experience: .returning, settings: settings, equipment: allEquipment)
            XCTAssertTrue(plan.exercises.allSatisfy { $0.sets == volume.setsPerExercise })
        }
    }

    func testIntensityControlsRepsRestAndEffort() {
        let settings = TrainingSettings(duration: .long, intensity: .challenging, volume: .moderate)
        let plan = WorkoutBuilder.build(title: "T", bodyParts: [.legs, .back], experience: .experienced, settings: settings, equipment: allEquipment)
        for item in plan.exercises where !item.exercise.isTimed {
            XCTAssertEqual(item.reps, 8...10)
            XCTAssertEqual(item.restSeconds, 120)
            XCTAssertEqual(item.effort, 7...8)
        }
    }

    func testDurationIsRespected() {
        for duration in DurationLevel.allCases {
            let settings = TrainingSettings(duration: duration, intensity: .moderate, volume: .full)
            let plan = WorkoutBuilder.build(title: "T", bodyParts: ScheduleTemplates.fullBody, experience: .experienced,
                                            settings: settings, equipment: allEquipment)
            XCTAssertLessThanOrEqual(plan.estimatedMinutes, duration.minutes + 1, "\(duration)")
        }
    }

    func testLongerSessionsFitMoreExercises() {
        func count(_ d: DurationLevel) -> Int {
            WorkoutBuilder.build(title: "T", bodyParts: ScheduleTemplates.fullBody, experience: .returning,
                                 settings: TrainingSettings(duration: d, intensity: .gentle, volume: .moderate),
                                 equipment: allEquipment).exercises.count
        }
        XCTAssertLessThan(count(.short), count(.long))
    }

    func testShortSessionReportsSkippedBodyPartsAndRotationCoversThem() {
        let settings = TrainingSettings(duration: .short, intensity: .moderate, volume: .full)
        let first = WorkoutBuilder.build(title: "T", bodyParts: ScheduleTemplates.fullBody, experience: .experienced,
                                         settings: settings, equipment: allEquipment, rotation: 0)
        XCTAssertFalse(first.skippedBodyParts.isEmpty)
        let second = WorkoutBuilder.build(title: "T", bodyParts: ScheduleTemplates.fullBody, experience: .experienced,
                                          settings: settings, equipment: allEquipment, rotation: first.exercises.count)
        let firstParts = Set(first.exercises.map(\.exercise.bodyPart))
        let secondParts = Set(second.exercises.map(\.exercise.bodyPart))
        XCTAssertFalse(secondParts.subtracting(firstParts).isEmpty)
    }

    func testTimedExercisesGetHoldNotReps() {
        let plan = WorkoutBuilder.build(title: "T", bodyParts: [.balance], experience: .beginner,
                                        settings: Experience.beginner.defaultSettings, equipment: allEquipment)
        let item = try? XCTUnwrap(plan.exercises.first)
        XCTAssertNotNil(item?.holdSeconds)
        XCTAssertNil(item?.reps)
    }

    func testRotatedWraps() {
        XCTAssertEqual(WorkoutBuilder.rotated([1, 2, 3], by: 4), [2, 3, 1])
        XCTAssertEqual(WorkoutBuilder.rotated([1, 2, 3], by: -1), [3, 1, 2])
        XCTAssertEqual(WorkoutBuilder.rotated([Int](), by: 2), [])
    }
}

final class SettingsTests: XCTestCase {
    func testDefaultsAreWithinRecommendations() {
        for e in Experience.allCases {
            XCTAssertTrue(e.defaultSettings.cautions(for: e).isEmpty, "\(e) defaults shouldn't trigger cautions")
        }
    }

    func testBeginnerChallengingTriggersCaution() {
        let s = TrainingSettings(duration: .short, intensity: .challenging, volume: .light)
        XCTAssertFalse(s.cautions(for: .beginner).isEmpty)
        XCTAssertTrue(s.cautions(for: .experienced).isEmpty)
    }

    func testIntensityEffortNeverReachesMaximum() {
        for i in IntensityLevel.allCases { XCTAssertLessThanOrEqual(i.effortRange.upperBound, 8) }
    }
}

final class ScheduleTests: XCTestCase {
    func testTemplatesCoverEveryBodyPart() {
        for days in 1...4 {
            let schedule = ScheduleTemplates.schedule(weekdays: Weekdays.suggested(daysPerWeek: days))
            XCTAssertEqual(schedule.count, days)
            XCTAssertEqual(ScheduleTemplates.missingBodyParts(schedule), [], "\(days)-day plan misses body parts")
        }
    }

    func testSuggestedSchedulesHaveNoRestWarnings() {
        for days in 1...4 {
            let schedule = ScheduleTemplates.schedule(weekdays: Weekdays.suggested(daysPerWeek: days))
            XCTAssertEqual(ScheduleTemplates.restWarnings(schedule), [], "\(days)-day plan")
        }
    }

    func testBackToBackFullBodyWarns() {
        let days = [
            ScheduledDay(weekday: 2, name: "A", bodyParts: ScheduleTemplates.fullBody),
            ScheduledDay(weekday: 3, name: "B", bodyParts: ScheduleTemplates.fullBody),
        ]
        XCTAssertEqual(ScheduleTemplates.restWarnings(days).count, 1)
    }

    func testSaturdayToSundayCountsAsBackToBack() {
        let days = [
            ScheduledDay(weekday: 7, name: "A", bodyParts: [.legs]),
            ScheduledDay(weekday: 1, name: "B", bodyParts: [.legs]),
        ]
        XCTAssertEqual(ScheduleTemplates.restWarnings(days).count, 1)
    }

    func testBalanceAndCoreOnConsecutiveDaysIsFine() {
        let days = [
            ScheduledDay(weekday: 2, name: "A", bodyParts: [.legs, .core, .balance]),
            ScheduledDay(weekday: 3, name: "B", bodyParts: [.chest, .core, .balance]),
        ]
        XCTAssertEqual(ScheduleTemplates.restWarnings(days), [])
    }

    func testScheduleIsMondayFirst() {
        let schedule = ScheduleTemplates.schedule(weekdays: [1, 4, 2])
        XCTAssertEqual(schedule.map(\.weekday), [2, 4, 1])
    }
}

final class ProgressionTests: XCTestCase {
    private let curl = ExerciseCatalog.exercise("biceps-curl")!
    private let legPress = ExerciseCatalog.exercise("leg-press")!
    private let stand = ExerciseCatalog.exercise("tandem-stand")!

    func testHittingTopOfRangeWithEffortToSpareIncreases() {
        let sets = [SetResult(reps: 15, weight: 5, effort: 4), SetResult(reps: 15, weight: 5, effort: 4)]
        let advice = Progression.advice(for: curl, sets: sets, targetReps: 12...15, targetSeconds: nil, targetEffort: 3...4)
        guard case .increase(let message) = advice else { return XCTFail("\(advice)") }
        XCTAssertTrue(message.contains("2 lb"))
    }

    func testLowerBodyMachineStepIsBigger() {
        XCTAssertEqual(Progression.weightStep(for: legPress), 10)
        XCTAssertEqual(Progression.weightStep(for: curl), 2)
    }

    func testPainAlwaysDecreases() {
        let sets = [SetResult(reps: 15, weight: 5, effort: 3, pain: true)]
        let advice = Progression.advice(for: curl, sets: sets, targetReps: 12...15, targetSeconds: nil, targetEffort: 3...4)
        guard case .decrease = advice else { return XCTFail("\(advice)") }
    }

    func testTooHardDecreases() {
        let sets = [SetResult(reps: 12, weight: 10, effort: 9)]
        let advice = Progression.advice(for: curl, sets: sets, targetReps: 10...12, targetSeconds: nil, targetEffort: 5...6)
        guard case .decrease = advice else { return XCTFail("\(advice)") }
    }

    func testInRangeHolds() {
        let sets = [SetResult(reps: 11, weight: 5, effort: 5), SetResult(reps: 10, weight: 5, effort: 6)]
        let advice = Progression.advice(for: curl, sets: sets, targetReps: 10...12, targetSeconds: nil, targetEffort: 5...6)
        guard case .hold = advice else { return XCTFail("\(advice)") }
    }

    func testTopOfRangeButTooHardDoesNotIncrease() {
        let sets = [SetResult(reps: 15, weight: 5, effort: 6)]
        let advice = Progression.advice(for: curl, sets: sets, targetReps: 12...15, targetSeconds: nil, targetEffort: 3...4)
        if case .increase = advice { XCTFail("Should not increase when effort is above target") }
    }

    func testTimedHoldIncreasesAndSuggestsHarderVersion() {
        let sets = [SetResult(seconds: 20, effort: 3)]
        let advice = Progression.advice(for: stand, sets: sets, targetReps: nil, targetSeconds: 20, targetEffort: 3...4)
        guard case .increase(let message) = advice else { return XCTFail("\(advice)") }
        XCTAssertTrue(message.contains("Stand on one leg"))
    }

    func testFormatWeight() {
        XCTAssertEqual(Progression.formatWeight(5), "5")
        XCTAssertEqual(Progression.formatWeight(7.5), "7.5")
    }
}
