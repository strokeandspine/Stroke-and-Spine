import Foundation

enum Nutrient: String, CaseIterable, Codable, Identifiable {
    case calcium, vitaminD, magnesium

    var id: String { rawValue }

    var name: String {
        switch self {
        case .calcium: return "Calcium"
        case .vitaminD: return "Vitamin D"
        case .magnesium: return "Magnesium"
        }
    }

    var unit: String { self == .vitaminD ? "IU" : "mg" }

    func format(_ amount: Double) -> String { "\(Int(amount.rounded()).formatted()) \(unit)" }
}

struct NutrientAmount: Codable, Hashable {
    var nutrient: Nutrient
    var amount: Double
}

enum IntakeSource: String, Codable, CaseIterable, Identifiable {
    case supplement, food

    var id: String { rawValue }
    var label: String { self == .supplement ? "Supplement" : "Food or drink" }
}

/// A preset supplement or food. Amounts are *elemental* calcium and magnesium per serving.
struct SupplementProduct: Identifiable, Hashable {
    let id: String
    let name: String
    let source: IntakeSource
    let servingName: String
    let perServing: [NutrientAmount]
    var note: String = ""

    static func amounts(ca: Double = 0, d: Double = 0, mg: Double = 0) -> [NutrientAmount] {
        var result: [NutrientAmount] = []
        if ca > 0 { result.append(NutrientAmount(nutrient: .calcium, amount: ca)) }
        if d > 0 { result.append(NutrientAmount(nutrient: .vitaminD, amount: d)) }
        if mg > 0 { result.append(NutrientAmount(nutrient: .magnesium, amount: mg)) }
        return result
    }

    static let supplements: [SupplementProduct] = [
        SupplementProduct(id: "ca-carb-600-d-800", name: "Calcium carbonate 600 mg + D3 800 IU", source: .supplement, servingName: "tablet",
                          perServing: amounts(ca: 600, d: 800), note: "Take calcium carbonate with food."),
        SupplementProduct(id: "ca-carb-600-d-800-mg-50", name: "Calcium 600 mg + D3 800 IU + magnesium 50 mg", source: .supplement, servingName: "tablet",
                          perServing: amounts(ca: 600, d: 800, mg: 50), note: "Take with food."),
        SupplementProduct(id: "ca-carb-500", name: "Calcium carbonate 500 mg", source: .supplement, servingName: "tablet",
                          perServing: amounts(ca: 500), note: "Take calcium carbonate with food."),
        SupplementProduct(id: "ca-citrate-315-d-250", name: "Calcium citrate 315 mg + D3 250 IU", source: .supplement, servingName: "caplet",
                          perServing: amounts(ca: 315, d: 250), note: "Calcium citrate can be taken with or without food."),
        SupplementProduct(id: "antacid-750", name: "Antacid chew (750 mg calcium carbonate)", source: .supplement, servingName: "chew",
                          perServing: amounts(ca: 300), note: "Antacid chews are a hidden source of calcium: 750 mg calcium carbonate gives 300 mg calcium."),
        SupplementProduct(id: "d3-1000", name: "Vitamin D3 1,000 IU", source: .supplement, servingName: "softgel", perServing: amounts(d: 1000)),
        SupplementProduct(id: "d3-2000", name: "Vitamin D3 2,000 IU", source: .supplement, servingName: "softgel", perServing: amounts(d: 2000)),
        SupplementProduct(id: "d3-5000", name: "Vitamin D3 5,000 IU", source: .supplement, servingName: "softgel", perServing: amounts(d: 5000)),
        SupplementProduct(id: "d-50000", name: "Vitamin D 50,000 IU (prescription)", source: .supplement, servingName: "capsule",
                          perServing: amounts(d: 50000), note: "Usually prescribed once a week or less often. Take only as your doctor directed."),
        SupplementProduct(id: "mg-glycinate-120", name: "Magnesium glycinate (120 mg magnesium)", source: .supplement, servingName: "capsule", perServing: amounts(mg: 120)),
        SupplementProduct(id: "mg-oxide-400", name: "Magnesium oxide 400 mg (241 mg magnesium)", source: .supplement, servingName: "tablet", perServing: amounts(mg: 241)),
        SupplementProduct(id: "mg-citrate-100", name: "Magnesium citrate (100 mg magnesium)", source: .supplement, servingName: "tablet", perServing: amounts(mg: 100)),
        SupplementProduct(id: "multi-50", name: "Multivitamin 50+ (typical)", source: .supplement, servingName: "tablet",
                          perServing: amounts(ca: 200, d: 1000, mg: 50), note: "Amounts vary by brand. Check your label and use \"Not listed\" if they differ."),
    ]

    /// Approximate values from the NIH Office of Dietary Supplements fact sheets.
    static let foods: [SupplementProduct] = [
        SupplementProduct(id: "milk", name: "Milk", source: .food, servingName: "cup (8 oz)", perServing: amounts(ca: 300, d: 120, mg: 25)),
        SupplementProduct(id: "yogurt", name: "Yogurt, plain low-fat", source: .food, servingName: "cup (8 oz)", perServing: amounts(ca: 415, mg: 40)),
        SupplementProduct(id: "cheddar", name: "Cheddar cheese", source: .food, servingName: "1.5 oz", perServing: amounts(ca: 307, mg: 12)),
        SupplementProduct(id: "soy-milk", name: "Soy milk, calcium-fortified", source: .food, servingName: "cup", perServing: amounts(ca: 300, d: 110, mg: 40)),
        SupplementProduct(id: "oj", name: "Orange juice, calcium-fortified", source: .food, servingName: "cup", perServing: amounts(ca: 349, d: 100, mg: 27)),
        SupplementProduct(id: "tofu", name: "Tofu, firm, made with calcium", source: .food, servingName: "½ cup", perServing: amounts(ca: 253, mg: 37)),
        SupplementProduct(id: "sardines", name: "Sardines, canned with bones", source: .food, servingName: "3 oz", perServing: amounts(ca: 325, d: 164, mg: 33)),
        SupplementProduct(id: "salmon", name: "Salmon, canned with bones", source: .food, servingName: "3 oz", perServing: amounts(ca: 181, mg: 25)),
        SupplementProduct(id: "almonds", name: "Almonds", source: .food, servingName: "1 oz", perServing: amounts(ca: 76, mg: 80)),
        SupplementProduct(id: "pumpkin-seeds", name: "Pumpkin seeds, roasted", source: .food, servingName: "1 oz", perServing: amounts(mg: 156)),
        SupplementProduct(id: "spinach", name: "Spinach, boiled", source: .food, servingName: "½ cup", perServing: amounts(mg: 78),
                          note: "Spinach contains calcium, but very little of it is absorbed."),
        SupplementProduct(id: "black-beans", name: "Black beans, cooked", source: .food, servingName: "½ cup", perServing: amounts(ca: 23, mg: 60)),
        SupplementProduct(id: "egg", name: "Egg", source: .food, servingName: "large egg", perServing: amounts(ca: 28, d: 44, mg: 6)),
    ]

    static let all = supplements + foods
}

/// Daily recommended amounts (RDA) and upper limits (UL) from the NIH Office of Dietary Supplements.
struct NutrientTargets: Equatable {
    var daily: [Nutrient: Double]
    /// Calcium and vitamin D limits apply to food plus supplements. The magnesium limit applies to supplements only.
    var upperLimit: [Nutrient: Double]

    static func forPerson(age: Int?, sex: Sex) -> NutrientTargets {
        let age = age ?? 50
        // Calcium: 1,000 mg for adults 19–50 and men 51–70; 1,200 mg for women 51+ and everyone 71+.
        // "Prefer not to say" uses the higher (female) calcium value.
        let calcium: Double = (age >= 71 || (age >= 51 && sex != .male)) ? 1200 : 1000
        let calciumUL: Double = age >= 51 ? 2000 : 2500
        // Vitamin D: RDA 600 IU to age 70, 800 IU from 71. The Bone Health & Osteoporosis Foundation advises
        // 800–1,000 IU for adults 50 and older, so the target is 800 IU from 50.
        let vitaminD: Double = age >= 50 ? 800 : 600
        // Magnesium: men 400 mg (19–30) / 420 mg (31+); women 310 / 320 mg. "Prefer not to say" uses the female value.
        let magnesium: Double
        if sex == .male { magnesium = age >= 31 ? 420 : 400 } else { magnesium = age >= 31 ? 320 : 310 }
        return NutrientTargets(daily: [.calcium: calcium, .vitaminD: vitaminD, .magnesium: magnesium],
                               upperLimit: [.calcium: calciumUL, .vitaminD: 4000, .magnesium: 350])
    }
}

/// A plain value for one logged intake, so the checker can be unit tested without SwiftData.
struct IntakeRecord: Hashable {
    var takenAt: Date
    var source: IntakeSource
    var amounts: [NutrientAmount]

    func amount(of nutrient: Nutrient) -> Double {
        amounts.filter { $0.nutrient == nutrient }.reduce(0) { $0 + $1.amount }
    }
}

struct NutrientDayStatus: Identifiable, Hashable {
    enum Level { case low, onTarget, overLimit }
    let nutrient: Nutrient
    let total: Double
    let target: Double
    let level: Level
    var id: Nutrient { nutrient }
    var fraction: Double { target > 0 ? total / target : 0 }
}

/// A recent oral bisphosphonate dose, which nothing but plain water should follow for 30–60 minutes.
struct EmptyStomachWindow: Hashable {
    var drugName: String
    var takenAt: Date
    var waitMinutes: Int

    var endsAt: Date { takenAt.addingTimeInterval(TimeInterval(waitMinutes * 60)) }
}

struct SupplementChecker {
    var targets: NutrientTargets
    var prescribedHighDoseVitaminD = false
    var hasKidneyDisease = false
    var calendar = Calendar.current

    func total(_ nutrient: Nutrient, records: [IntakeRecord], on day: Date, supplementsOnly: Bool = false) -> Double {
        records
            .filter { calendar.isDate($0.takenAt, inSameDayAs: day) && (!supplementsOnly || $0.source == .supplement) }
            .reduce(0) { $0 + $1.amount(of: nutrient) }
    }

    /// Average per day over the 7 days ending on `day`. Used for vitamin D, which is often taken weekly.
    func sevenDayAverage(_ nutrient: Nutrient, records: [IntakeRecord], endingOn day: Date) -> Double {
        let end = calendar.startOfDay(for: day)
        guard let start = calendar.date(byAdding: .day, value: -6, to: end),
              let endExclusive = calendar.date(byAdding: .day, value: 1, to: end) else { return 0 }
        let sum = records.filter { $0.takenAt >= start && $0.takenAt < endExclusive }.reduce(0) { $0 + $1.amount(of: nutrient) }
        return sum / 7
    }

    func status(records: [IntakeRecord], on day: Date) -> [NutrientDayStatus] {
        Nutrient.allCases.map { nutrient in
            let amount = total(nutrient, records: records, on: day)
            let target = targets.daily[nutrient] ?? 0
            let overLimit: Bool
            switch nutrient {
            case .calcium: overLimit = amount > (targets.upperLimit[.calcium] ?? .infinity)
            case .vitaminD: overLimit = !prescribedHighDoseVitaminD && sevenDayAverage(.vitaminD, records: records, endingOn: day) > (targets.upperLimit[.vitaminD] ?? .infinity)
            case .magnesium: overLimit = total(.magnesium, records: records, on: day, supplementsOnly: true) > (targets.upperLimit[.magnesium] ?? .infinity)
            }
            let level: NutrientDayStatus.Level = overLimit ? .overLimit : (amount >= target ? .onTarget : .low)
            return NutrientDayStatus(nutrient: nutrient, total: amount, target: target, level: level)
        }
    }

    /// Warnings for the day, including a `proposed` intake that hasn't been saved yet.
    func warnings(records: [IntakeRecord], proposed: IntakeRecord? = nil, now: Date = Date(),
                  emptyStomach: [EmptyStomachWindow] = []) -> [SafetyWarning] {
        let all = records + (proposed.map { [$0] } ?? [])
        let day = proposed?.takenAt ?? now
        var result: [SafetyWarning] = []

        if let proposed {
            let time = proposed.takenAt
            if let window = emptyStomach.first(where: { time >= $0.takenAt && time < $0.endsAt }) {
                result.append(SafetyWarning(id: "bisphosphonate-window", severity: .stop,
                    message: "You took \(window.drugName) at \(window.takenAt.formatted(date: .omitted, time: .shortened)). Wait until \(window.endsAt.formatted(date: .omitted, time: .shortened)) before any food, drink (other than plain water), calcium, magnesium, antacids or other medicines, or the medicine won't be absorbed."))
            }
            if proposed.source == .supplement && proposed.amount(of: .calcium) > 500 {
                result.append(SafetyWarning(id: "calcium-dose-size", severity: .info,
                    message: "Your body absorbs calcium best in doses of 500 mg or less. Consider splitting it between meals."))
            }
        }

        let calcium = total(.calcium, records: all, on: day)
        if let limit = targets.upperLimit[.calcium], calcium > limit {
            result.append(SafetyWarning(id: "calcium-ul", severity: .caution,
                message: "That's \(Nutrient.calcium.format(calcium)) of calcium today, above the \(Nutrient.calcium.format(limit)) upper limit. Too much calcium from supplements can raise the risk of kidney stones. Check with your doctor."))
        }

        let supplementalMg = total(.magnesium, records: all, on: day, supplementsOnly: true)
        if let limit = targets.upperLimit[.magnesium], supplementalMg > limit {
            result.append(SafetyWarning(id: "magnesium-ul", severity: .caution,
                message: "That's \(Nutrient.magnesium.format(supplementalMg)) of magnesium from supplements today, above the \(Nutrient.magnesium.format(limit)) limit for supplements. Too much can cause diarrhea and cramping. Check with your doctor."))
        }
        if hasKidneyDisease && supplementalMg > 0 {
            result.append(SafetyWarning(id: "magnesium-kidney", severity: .caution,
                message: "With kidney disease, magnesium can build up in the body. Only take magnesium supplements if your doctor has said it's OK."))
        }

        let vitaminDAverage = sevenDayAverage(.vitaminD, records: all, endingOn: day)
        if !prescribedHighDoseVitaminD, let limit = targets.upperLimit[.vitaminD], vitaminDAverage > limit {
            result.append(SafetyWarning(id: "vitamin-d-ul", severity: .caution,
                message: "Your vitamin D has averaged \(Nutrient.vitaminD.format(vitaminDAverage)) a day this week, above the \(Nutrient.vitaminD.format(limit)) upper limit. If your doctor prescribed this, turn on \"Doctor prescribed high-dose vitamin D\" in Settings. Otherwise, check with your doctor."))
        }

        return result.sortedBySeverity
    }
}
