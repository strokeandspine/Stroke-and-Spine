import Foundation

// MARK: - Nutrient values

/// Calories and macronutrients. Ingredients store these per 100 g; recipes sum them per serving.
struct NutrientValues: Codable, Hashable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double

    static let zero = NutrientValues(kcal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0)

    func scaled(by factor: Double) -> NutrientValues {
        NutrientValues(kcal: kcal * factor, protein: protein * factor, carbs: carbs * factor,
                       fat: fat * factor, fiber: fiber * factor, sugar: sugar * factor)
    }

    static func + (lhs: NutrientValues, rhs: NutrientValues) -> NutrientValues {
        NutrientValues(kcal: lhs.kcal + rhs.kcal, protein: lhs.protein + rhs.protein,
                       carbs: lhs.carbs + rhs.carbs, fat: lhs.fat + rhs.fat,
                       fiber: lhs.fiber + rhs.fiber, sugar: lhs.sugar + rhs.sugar)
    }
}

/// Nutrition for one serving of a recipe, with the derived numbers the app shows and filters on.
struct Nutrition: Hashable {
    var values: NutrientValues
    /// Sugar from added sweeteners (honey, maple). Fruit sugar is not counted.
    var addedSugar: Double

    var kcal: Double { values.kcal }
    var protein: Double { values.protein }
    var carbs: Double { values.carbs }
    var fat: Double { values.fat }
    var fiber: Double { values.fiber }
    var sugar: Double { values.sugar }
    var netCarbs: Double { max(0, carbs - fiber) }

    /// Share of calories from protein, using 4 kcal per gram.
    var proteinPercentOfCalories: Double { kcal > 0 ? protein * 4 / kcal * 100 : 0 }

    /// Grams of protein per 100 kcal: the app's main "macro density" measure.
    var proteinPer100kcal: Double { kcal > 0 ? protein / kcal * 100 : 0 }

    /// Protein, carb and fat shares of macro calories, adding up to 1. Used for the macro bar.
    var macroSplit: (protein: Double, carbs: Double, fat: Double) {
        let p = protein * 4, c = carbs * 4, f = fat * 9
        let total = p + c + f
        guard total > 0 else { return (0, 0, 0) }
        return (p / total, c / total, f / total)
    }
}

// MARK: - Ingredients

enum IngredientKind: String, Codable {
    case wholeFood
    case supplement
}

struct Ingredient: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let kind: IngredientKind
    let category: String
    let per100g: NutrientValues
    let isVegan: Bool
    let isAddedSugar: Bool
    let allergens: [String]
    let highlights: [String]

    var isSupplement: Bool { kind == .supplement }
    var containsCaffeine: Bool { highlights.contains("Natural caffeine") }
}

// MARK: - Recipes

struct RecipeIngredient: Codable, Hashable {
    /// Ingredient id in ingredients.json.
    let id: String
    let grams: Double
    /// Kitchen measure shown to the user, e.g. "1 cup, frozen".
    let measure: String
}

struct Recipe: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let flavor: String
    let objectives: [String]
    let servings: Int
    let prepMinutes: Int
    let ingredients: [RecipeIngredient]
    let steps: [String]
    let whyItWorks: String
    let swaps: [String]?
    let timing: String?

    static func == (lhs: Recipe, rhs: Recipe) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Objectives

enum SortMode: String, Codable, CaseIterable, Identifiable {
    case proteinDensity
    case proteinDesc
    case kcalAsc
    case kcalDesc
    case netCarbsAsc
    case carbsDesc
    case name

    var id: String { rawValue }

    var label: String {
        switch self {
        case .proteinDensity: return "Protein per calorie"
        case .proteinDesc: return "Most protein"
        case .kcalAsc: return "Fewest calories"
        case .kcalDesc: return "Most calories"
        case .netCarbsAsc: return "Fewest net carbs"
        case .carbsDesc: return "Most carbs"
        case .name: return "Name"
        }
    }
}

/// Thresholds a recipe must meet, per serving, to be listed under an objective.
/// Values are compared after rounding to whole numbers, matching what the app displays.
struct ObjectiveRules: Codable, Hashable {
    var minKcal: Double?
    var maxKcal: Double?
    var minProtein: Double?
    var maxProtein: Double?
    var minProteinPercent: Double?
    var minCarbs: Double?
    var maxCarbs: Double?
    var maxNetCarbs: Double?
    var maxFat: Double?
    var minFiber: Double?
    var maxFiber: Double?
    var requiresAnyHighlight: [String]?

    /// Reasons the nutrition does not meet these rules. Empty means it qualifies.
    func failures(for n: Nutrition, highlights: Set<String>) -> [String] {
        var out: [String] = []
        func check(_ limit: Double?, _ value: Double, _ label: String, atLeast: Bool) {
            guard let limit else { return }
            let rounded = value.rounded()
            let ok = atLeast ? rounded >= limit : rounded <= limit
            if !ok { out.append("\(label) \(Int(rounded)) \(atLeast ? "below" : "above") \(Int(limit))") }
        }
        check(minKcal, n.kcal, "kcal", atLeast: true)
        check(maxKcal, n.kcal, "kcal", atLeast: false)
        check(minProtein, n.protein, "protein", atLeast: true)
        check(maxProtein, n.protein, "protein", atLeast: false)
        check(minProteinPercent, n.proteinPercentOfCalories, "protein %", atLeast: true)
        check(minCarbs, n.carbs, "carbs", atLeast: true)
        check(maxCarbs, n.carbs, "carbs", atLeast: false)
        check(maxNetCarbs, n.netCarbs, "net carbs", atLeast: false)
        check(maxFat, n.fat, "fat", atLeast: false)
        check(minFiber, n.fiber, "fiber", atLeast: true)
        check(maxFiber, n.fiber, "fiber", atLeast: false)
        if let needed = requiresAnyHighlight, highlights.isDisjoint(with: needed) {
            out.append("needs one of: \(needed.joined(separator: ", "))")
        }
        return out
    }
}

struct Objective: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    /// SF Symbol name.
    let symbol: String
    let colorHex: String
    let sort: SortMode
    let summary: String
    let guidance: String
    let rules: ObjectiveRules

    static func == (lhs: Objective, rhs: Objective) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - App-wide health rules

/// Limits every recipe must respect, whatever its objective (mirrored in tools/validate_recipes.py).
enum HealthRules {
    static let maxAddedSugarGrams: Double = 12
    static let maxKcal: Double = 900
    static let minRecipesPerObjective = 4
}

// MARK: - Filters

enum DietFilter: String, CaseIterable, Identifiable, Hashable {
    case vegan
    case dairyFree
    case nutFree
    case wholeFoodOnly
    case caffeineFree
    case noAddedSugar

    var id: String { rawValue }

    var label: String {
        switch self {
        case .vegan: return "Vegan"
        case .dairyFree: return "Dairy-free"
        case .nutFree: return "Nut-free"
        case .wholeFoodOnly: return "No supplements"
        case .caffeineFree: return "Caffeine-free"
        case .noAddedSugar: return "No added sugar"
        }
    }

    var symbol: String {
        switch self {
        case .vegan: return "leaf"
        case .dairyFree: return "drop.triangle"
        case .nutFree: return "exclamationmark.triangle"
        case .wholeFoodOnly: return "carrot"
        case .caffeineFree: return "moon.zzz"
        case .noAddedSugar: return "cube"
        }
    }
}
