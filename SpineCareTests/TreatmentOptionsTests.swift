import XCTest
@testable import SpineCare

final class TreatmentOptionsContentTests: XCTestCase {
    func testConditionIDsAreUnique() {
        let ids = TreatmentGuides.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testOptionIDsAreUniqueWithinEachCondition() {
        for guide in TreatmentGuides.all {
            let ids = guide.options.map(\.id)
            XCTAssertEqual(Set(ids).count, ids.count, guide.id)
        }
    }

    func testEveryConditionCoversConservativeCareAndAtLeastOneProcedure() {
        for guide in TreatmentGuides.all {
            XCTAssertFalse(guide.options(in: .conservative).isEmpty, "\(guide.id) has no conservative option")
            XCTAssertTrue(guide.options.contains { $0.tier != .conservative }, "\(guide.id) has only conservative options")
            XCTAssertFalse(guide.comparisons.isEmpty, "\(guide.id) has no comparison studies")
            XCTAssertFalse(guide.naturalHistory.isEmpty, guide.id)
            XCTAssertFalse(guide.urgentSigns.isEmpty, guide.id)
            XCTAssertFalse(guide.questionsToAsk.isEmpty, guide.id)
        }
    }

    func testEveryTierAppearsSomewhere() {
        let tiers = Set(TreatmentGuides.all.flatMap { $0.options.map(\.tier) })
        XCTAssertEqual(tiers, Set(ApproachTier.allCases))
    }

    func testEveryOptionIsComplete() {
        for guide in TreatmentGuides.all {
            for o in guide.options {
                let name = "\(guide.id)/\(o.id)"
                XCTAssertFalse(o.summary.isEmpty, name)
                XCTAssertFalse(o.whatHappens.isEmpty, name)
                XCTAssertFalse(o.bestFor.isEmpty, name)
                XCTAssertFalse(o.keyFindings.isEmpty, name)
                XCTAssertFalse(o.sideEffects.isEmpty, "\(name) lists no side effects")
                XCTAssertFalse(o.sources.isEmpty, "\(name) has no sources")
                XCTAssertFalse(o.availability.isEmpty, name)
            }
        }
    }

    func testSurgicalOptionsListSeriousRisks() {
        for guide in TreatmentGuides.all {
            for o in guide.options where o.tier >= .minimallyInvasive {
                XCTAssertFalse(o.seriousSideEffects.isEmpty, "\(guide.id)/\(o.id) is surgery but lists no serious risks")
                XCTAssertNotNil(o.outcomes.seriousComplications, "\(guide.id)/\(o.id)")
            }
        }
    }

    func testAllPercentagesAreValidRanges() {
        func check(_ r: PercentRange?, _ label: String) {
            guard let r else { return }
            XCTAssertGreaterThanOrEqual(r.low, 0, label)
            XCTAssertLessThanOrEqual(r.high, 100, label)
            XCTAssertLessThanOrEqual(r.low, r.high, label)
        }
        for guide in TreatmentGuides.all {
            for o in guide.options {
                let name = "\(guide.id)/\(o.id)"
                check(o.outcomes.improvement, "\(name) improvement")
                check(o.outcomes.seriousComplications, "\(name) complications")
                check(o.outcomes.furtherTreatment, "\(name) further treatment")
                for e in o.sideEffects {
                    check(e.chance, "\(name) \(e.name)")
                    XCTAssertFalse(e.detail.isEmpty, "\(name) \(e.name) has no detail")
                }
            }
        }
    }

    func testSideEffectNamesAreUniqueWithinAnOption() {
        for guide in TreatmentGuides.all {
            for o in guide.options {
                let names = o.sideEffects.map(\.name)
                XCTAssertEqual(Set(names).count, names.count, "\(guide.id)/\(o.id)")
            }
        }
    }

    func testEverySpecialtyHasConditions() {
        for specialty in SurgicalSpecialty.allCases {
            XCTAssertGreaterThanOrEqual(TreatmentGuides.guides(for: specialty).count, 2, "\(specialty) has fewer than 2 conditions")
        }
    }

    func testOptionIDsAreGloballyUniqueForShortlist() {
        let keys = TreatmentGuides.all.flatMap { g in g.options.map { OptionShortlist.key(g, $0) } }
        XCTAssertEqual(Set(keys).count, keys.count)
    }

    func testSearchFindsConditionsAndOperations() {
        XCTAssertTrue(TreatmentGuides.search("microdiscectomy").contains { $0.id == "lumbar-disc-herniation" })
        XCTAssertEqual(TreatmentGuides.search("").count, TreatmentGuides.all.count)
        XCTAssertTrue(TreatmentGuides.search("zzzz-no-such-thing").isEmpty)
    }

    func testSideEffectsSortSeriousFirst() throws {
        let option = try XCTUnwrap(TreatmentGuides.guide("lumbar-disc-herniation")?.option("microdiscectomy"))
        let sorted = option.sideEffectsByRisk
        XCTAssertEqual(sorted.first?.severity, .serious)
        XCTAssertEqual(sorted.last?.severity, .mild)
    }
}

final class RiskFormatTests: XCTestCase {
    func testNaturalFrequencyPer100() {
        XCTAssertEqual(PercentRange(5, 15).naturalFrequency, "About 5 to 15 in 100 people")
        XCTAssertEqual(PercentRange(3, 3).naturalFrequency, "About 3 in 100 people")
        XCTAssertEqual(PercentRange(0, 2).naturalFrequency, "Up to 2 in 100 people")
        XCTAssertEqual(PercentRange(0.5, 2).naturalFrequency, "Up to 2 in 100 people")
    }

    func testNaturalFrequencySmallerRisks() {
        XCTAssertEqual(PercentRange(0.2, 0.5).naturalFrequency, "About 2 to 5 in 1,000 people")
        XCTAssertEqual(PercentRange(0.01, 0.05).naturalFrequency, "About 1 to 5 in 10,000 people")
        XCTAssertEqual(PercentRange(0.001, 0.005).naturalFrequency, "Fewer than 1 in 10,000 people")
        XCTAssertEqual(PercentRange(0.001, 0.01).naturalFrequency, "Up to 1 in 10,000 people")
    }

    func testPercentText() {
        XCTAssertEqual(PercentRange(5, 15).percentText, "5–15%")
        XCTAssertEqual(PercentRange(0.5, 2).percentText, "0.5–2%")
        XCTAssertEqual(PercentRange(4, 4).percentText, "about 4%")
    }

    func testFrequencyBands() {
        XCTAssertEqual(FrequencyBand(percent: 25), .veryCommon)
        XCTAssertEqual(FrequencyBand(percent: 10), .veryCommon)
        XCTAssertEqual(FrequencyBand(percent: 3), .common)
        XCTAssertEqual(FrequencyBand(percent: 0.5), .uncommon)
        XCTAssertEqual(FrequencyBand(percent: 0.05), .rare)
        XCTAssertEqual(FrequencyBand(percent: 0.005), .veryRare)
    }
}

final class ShortlistTests: XCTestCase {
    func testToggleAndRoundTrip() throws {
        let guide = try XCTUnwrap(TreatmentGuides.guide("lumbar-stenosis"))
        let option = try XCTUnwrap(guide.option("laminectomy"))
        var list = OptionShortlist(stored: "")
        list.toggle(guide, option)
        XCTAssertTrue(list.contains(guide, option))
        let restored = OptionShortlist(stored: list.stored)
        XCTAssertEqual(restored.items.map(\.option.id), ["laminectomy"])
        list.toggle(guide, option)
        XCTAssertTrue(list.items.isEmpty)
    }

    func testUnknownKeysAreSkipped() {
        let list = OptionShortlist(stored: "nope/nothing,lumbar-stenosis/stenosis-pt")
        XCTAssertEqual(list.items.map(\.option.id), ["stenosis-pt"])
    }

    func testDiscussionSheetIncludesOptionsAndQuestions() throws {
        let guide = try XCTUnwrap(TreatmentGuides.guide("lumbar-disc-herniation"))
        var list = OptionShortlist(stored: "")
        list.toggle(guide, try XCTUnwrap(guide.option("microdiscectomy")))
        let text = DiscussionSheet.text(for: list, name: "Sam")
        XCTAssertTrue(text.contains("Microdiscectomy"))
        XCTAssertTrue(text.contains("Sam"))
        XCTAssertTrue(text.contains(TreatmentGuides.generalQuestions[0]))
        XCTAssertTrue(text.contains("about 80 to 95 in 100 people"))
    }
}
