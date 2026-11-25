import Foundation

/// Active ingredients the app tracks against US over-the-counter (OTC) label limits.
enum Ingredient: String, CaseIterable, Codable, Identifiable {
    case acetaminophen, ibuprofen, naproxen, aspirin

    var id: String { rawValue }

    var name: String {
        switch self {
        case .acetaminophen: return "Acetaminophen"
        case .ibuprofen: return "Ibuprofen"
        case .naproxen: return "Naproxen sodium"
        case .aspirin: return "Aspirin"
        }
    }

    var isNSAID: Bool { self != .acetaminophen }

    /// Default adult maximum per 24 hours from typical US OTC Drug Facts labels.
    /// Patients can lower (never raise above `labelCeilingMg`) to match their own product label
    /// or their doctor's advice.
    var defaultDailyLimitMg: Double {
        switch self {
        case .acetaminophen: return 3000 // Extra Strength labels; some generic labels allow 4,000 mg
        case .ibuprofen: return 1200
        case .naproxen: return 660
        case .aspirin: return 4000
        }
    }

    var labelCeilingMg: Double {
        switch self {
        case .acetaminophen: return 4000
        case .ibuprofen: return 1200
        case .naproxen: return 660
        case .aspirin: return 4000
        }
    }

    /// Shortest usual gap between doses on OTC labels.
    var minimumHoursBetweenDoses: Double {
        switch self {
        case .acetaminophen: return 4
        case .ibuprofen: return 4
        case .naproxen: return 8
        case .aspirin: return 4
        }
    }
}

struct IngredientAmount: Codable, Hashable {
    var ingredient: Ingredient
    var milligrams: Double
}

/// A product as written on its package. Combination products (cold & flu, PM sleep aids,
/// Excedrin) list more than one ingredient so hidden acetaminophen is counted.
struct OTCProduct: Identifiable, Hashable, Codable {
    var id: String { name }
    var name: String
    /// Amount per tablet, caplet, or dose unit.
    var perUnit: [IngredientAmount]
    var unitName: String = "tablet"

    static let presets: [OTCProduct] = [
        OTCProduct(name: "Acetaminophen Regular Strength 325 mg", perUnit: [.init(ingredient: .acetaminophen, milligrams: 325)]),
        OTCProduct(name: "Acetaminophen Extra Strength 500 mg", perUnit: [.init(ingredient: .acetaminophen, milligrams: 500)], unitName: "caplet"),
        OTCProduct(name: "Acetaminophen 8 HR Arthritis 650 mg", perUnit: [.init(ingredient: .acetaminophen, milligrams: 650)], unitName: "caplet"),
        OTCProduct(name: "Ibuprofen 200 mg", perUnit: [.init(ingredient: .ibuprofen, milligrams: 200)]),
        OTCProduct(name: "Naproxen sodium 220 mg", perUnit: [.init(ingredient: .naproxen, milligrams: 220)]),
        OTCProduct(name: "Aspirin 325 mg", perUnit: [.init(ingredient: .aspirin, milligrams: 325)]),
        OTCProduct(name: "Aspirin + acetaminophen + caffeine (migraine/headache)", perUnit: [
            .init(ingredient: .acetaminophen, milligrams: 250), .init(ingredient: .aspirin, milligrams: 250)]),
        OTCProduct(name: "Acetaminophen PM (with diphenhydramine)", perUnit: [.init(ingredient: .acetaminophen, milligrams: 500)], unitName: "caplet"),
        OTCProduct(name: "Ibuprofen PM (with diphenhydramine)", perUnit: [.init(ingredient: .ibuprofen, milligrams: 200)], unitName: "caplet"),
        OTCProduct(name: "Cold & flu liquid (acetaminophen 650 mg per 30 mL)", perUnit: [.init(ingredient: .acetaminophen, milligrams: 650)], unitName: "30 mL dose"),
    ]
}

/// Health conditions that change OTC pain-reliever safety. Stored on the profile.
enum HealthCondition: String, CaseIterable, Codable, Identifiable {
    case kidneyDisease, liverDisease, stomachUlcerOrBleeding, heartDisease, highBloodPressure,
         bloodThinner, pregnant, age60Plus, threeOrMoreDrinksDaily, aspirinAllergyOrAsthma, lowDoseAspirin

    var id: String { rawValue }

    var label: String {
        switch self {
        case .kidneyDisease: return "Kidney disease"
        case .liverDisease: return "Liver disease"
        case .stomachUlcerOrBleeding: return "Stomach ulcers or stomach bleeding (now or in the past)"
        case .heartDisease: return "Heart disease, heart failure or a past heart attack or stroke"
        case .highBloodPressure: return "High blood pressure"
        case .bloodThinner: return "I take a blood thinner (e.g. warfarin, apixaban, clopidogrel)"
        case .pregnant: return "I am pregnant"
        case .age60Plus: return "I am 60 or older"
        case .threeOrMoreDrinksDaily: return "I usually have 3 or more alcoholic drinks a day"
        case .aspirinAllergyOrAsthma: return "Asthma or allergy to aspirin or other pain relievers"
        case .lowDoseAspirin: return "I take a daily low-dose aspirin for my heart"
        }
    }
}

struct DoseRecord: Hashable {
    var takenAt: Date
    var amounts: [IngredientAmount]
}

struct IngredientStatus: Identifiable, Hashable {
    enum Level: Int, Comparable {
        case ok, approaching, reached, over
        static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }
    }

    var id: Ingredient { ingredient }
    let ingredient: Ingredient
    let totalMg: Double
    let limitMg: Double
    let lastDose: Date?

    var fraction: Double { limitMg > 0 ? totalMg / limitMg : 0 }
    var remainingMg: Double { max(0, limitMg - totalMg) }

    var level: Level {
        if totalMg > limitMg { return .over }
        if totalMg >= limitMg { return .reached }
        if fraction >= 0.75 { return .approaching }
        return .ok
    }
}

struct SafetyWarning: Identifiable, Hashable {
    enum Severity: Int, Comparable {
        case info, caution, stop
        static func < (a: Severity, b: Severity) -> Bool { a.rawValue < b.rawValue }
    }
    var id: String
    var severity: Severity
    var message: String
}

/// Checks logged doses against the person's label limits. It never suggests a dose.
struct MedicationSafetyChecker {
    var limits: [Ingredient: Double] = Dictionary(uniqueKeysWithValues: Ingredient.allCases.map { ($0, $0.defaultDailyLimitMg) })
    var conditions: Set<HealthCondition> = []

    func limit(for ingredient: Ingredient) -> Double {
        min(limits[ingredient] ?? ingredient.defaultDailyLimitMg, ingredient.labelCeilingMg)
    }

    /// Totals for the rolling 24 hours ending at `now`.
    func status(doses: [DoseRecord], now: Date = Date()) -> [IngredientStatus] {
        let window = doses.filter { $0.takenAt <= now && $0.takenAt > now.addingTimeInterval(-24 * 3600) }
        return Ingredient.allCases.compactMap { ingredient in
            let relevant = window.filter { $0.amounts.contains { $0.ingredient == ingredient } }
            guard !relevant.isEmpty else { return nil }
            let total = relevant.flatMap(\.amounts).filter { $0.ingredient == ingredient }.map(\.milligrams).reduce(0, +)
            return IngredientStatus(ingredient: ingredient, totalMg: total, limitMg: limit(for: ingredient),
                                    lastDose: relevant.map(\.takenAt).max())
        }
    }

    /// Warnings about what has been taken (and, optionally, a dose being considered).
    func warnings(doses: [DoseRecord], proposed: DoseRecord? = nil, now: Date = Date()) -> [SafetyWarning] {
        var all = doses
        if let proposed { all.append(proposed) }
        var result: [SafetyWarning] = []

        for s in status(doses: all, now: now) {
            switch s.level {
            case .over:
                result.append(.init(id: "over-\(s.ingredient)", severity: .stop,
                    message: "You've logged \(Int(s.totalMg)) mg of \(s.ingredient.name.lowercased()) in the last 24 hours, which is more than your limit of \(Int(s.limitMg)) mg. Don't take any more. If you have taken too much acetaminophen, call Poison Control at 1-800-222-1222 even if you feel fine."))
            case .reached:
                result.append(.init(id: "reached-\(s.ingredient)", severity: .stop,
                    message: "You've reached your 24-hour limit for \(s.ingredient.name.lowercased()) (\(Int(s.limitMg)) mg)."))
            case .approaching:
                result.append(.init(id: "approaching-\(s.ingredient)", severity: .caution,
                    message: "You're close to your 24-hour limit for \(s.ingredient.name.lowercased()): \(Int(s.remainingMg)) mg left."))
            case .ok:
                break
            }
        }

        if let proposed {
            for amount in proposed.amounts {
                let previous = doses.filter { $0.takenAt <= proposed.takenAt && $0.amounts.contains { $0.ingredient == amount.ingredient } }
                    .map(\.takenAt).max()
                if let previous {
                    let hours = proposed.takenAt.timeIntervalSince(previous) / 3600
                    if hours < amount.ingredient.minimumHoursBetweenDoses {
                        result.append(.init(id: "interval-\(amount.ingredient)", severity: .caution,
                            message: "Your last \(amount.ingredient.name.lowercased()) was \(String(format: "%.1f", hours)) hours ago. Most labels say to wait at least \(Int(amount.ingredient.minimumHoursBetweenDoses)) hours. Check your package."))
                    }
                }
            }
        }

        // More than one NSAID in 24 hours.
        let recent = all.filter { $0.takenAt > now.addingTimeInterval(-24 * 3600) && $0.takenAt <= now }
        let nsaids = Set(recent.flatMap(\.amounts).map(\.ingredient).filter(\.isNSAID))
        if nsaids.count > 1 {
            result.append(.init(id: "multiple-nsaids", severity: .caution,
                message: "You've logged more than one NSAID (\(nsaids.map(\.name).sorted().joined(separator: ", "))) in 24 hours. Taking these together raises the risk of stomach bleeding without adding much pain relief. Ask a pharmacist before combining them."))
        }

        result += conditionWarnings(for: Set(recent.flatMap(\.amounts).map(\.ingredient)))
        return result.sorted { $0.severity > $1.severity }
    }

    /// Label-based "ask a doctor before use" cautions for this person's health conditions.
    func conditionWarnings(for ingredients: Set<Ingredient>) -> [SafetyWarning] {
        var result: [SafetyWarning] = []
        let usesNSAID = ingredients.contains { $0.isNSAID }

        if usesNSAID {
            let nsaidRisks: [(HealthCondition, String)] = [
                (.kidneyDisease, "NSAIDs can harm the kidneys. Ask your doctor before using them with kidney disease."),
                (.stomachUlcerOrBleeding, "NSAIDs raise the risk of stomach bleeding, especially with a history of ulcers or bleeding. Ask your doctor first."),
                (.heartDisease, "NSAIDs (except aspirin) can increase the risk of heart attack and stroke. Ask your doctor before using them with heart disease."),
                (.highBloodPressure, "NSAIDs can raise blood pressure. Ask your doctor before using them regularly."),
                (.bloodThinner, "NSAIDs with a blood thinner greatly increase bleeding risk. Ask your doctor or pharmacist before use."),
                (.pregnant, "NSAIDs are generally avoided from 20 weeks of pregnancy. Ask your doctor before using them while pregnant."),
                (.age60Plus, "People 60 and older have a higher risk of stomach bleeding from NSAIDs."),
                (.threeOrMoreDrinksDaily, "Having 3 or more alcoholic drinks a day while taking NSAIDs raises the risk of stomach bleeding."),
                (.aspirinAllergyOrAsthma, "If you've had an allergic reaction or asthma attack after aspirin or another pain reliever, don't take NSAIDs without asking your doctor."),
            ]
            for (condition, message) in nsaidRisks where conditions.contains(condition) {
                result.append(.init(id: "nsaid-\(condition)", severity: .caution, message: message))
            }
            if conditions.contains(.lowDoseAspirin) && ingredients.contains(.ibuprofen) {
                result.append(.init(id: "ibuprofen-aspirin", severity: .caution,
                    message: "Ibuprofen can stop low-dose aspirin from protecting your heart. Ask your pharmacist how to time them."))
            }
        }

        if ingredients.contains(.acetaminophen) {
            if conditions.contains(.liverDisease) {
                result.append(.init(id: "apap-liver", severity: .caution,
                    message: "With liver disease, ask your doctor what acetaminophen limit is safe for you. It is often lower than the label."))
            }
            if conditions.contains(.threeOrMoreDrinksDaily) {
                result.append(.init(id: "apap-alcohol", severity: .caution,
                    message: "Having 3 or more alcoholic drinks a day while taking acetaminophen increases the risk of liver damage. Ask your doctor first."))
            }
            if conditions.contains(.bloodThinner) {
                result.append(.init(id: "apap-warfarin", severity: .info,
                    message: "If you take warfarin, ask your doctor before using acetaminophen regularly."))
            }
        }
        return result
    }

    /// OTC labels say to stop and ask a doctor if pain lasts more than 10 days.
    func consecutiveDaysUsed(doses: [DoseRecord], now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(doses.map { calendar.startOfDay(for: $0.takenAt) })
        var count = 0
        var day = calendar.startOfDay(for: now)
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }
}
