import Foundation
import Observation

/// Loads the bundled recipe data and answers every question the views ask about it:
/// nutrition, objectives, filtering, sorting and search.
@Observable
final class RecipeStore {
    let ingredients: [String: Ingredient]
    let recipes: [Recipe]
    let objectives: [Objective]
    /// Set if the bundled data could not be read. The UI shows it instead of an empty list.
    let loadError: String?

    @ObservationIgnored private var nutritionCache: [String: Nutrition] = [:]
    @ObservationIgnored private var highlightCache: [String: Set<String>] = [:]

    init(bundle: Bundle = .main) {
        var loadedIngredients: [String: Ingredient] = [:]
        var loadedRecipes: [Recipe] = []
        var loadedObjectives: [Objective] = []
        var error: String?
        do {
            let ingredientList: [Ingredient] = try Self.decode("ingredients", bundle: bundle)
            loadedIngredients = Dictionary(ingredientList.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            loadedRecipes = try Self.decode("recipes", bundle: bundle)
            loadedObjectives = try Self.decode("objectives", bundle: bundle)
        } catch let decodeError {
            loadedIngredients = [:]
            loadedRecipes = []
            loadedObjectives = []
            error = "Couldn't load recipes: \(decodeError.localizedDescription)"
        }
        ingredients = loadedIngredients
        recipes = loadedRecipes
        objectives = loadedObjectives
        loadError = error
        for recipe in recipes {
            nutritionCache[recipe.id] = computeNutrition(recipe)
            highlightCache[recipe.id] = Set(recipe.ingredients.compactMap { ingredients[$0.id] }.flatMap(\.highlights))
        }
    }

    private static func decode<T: Decodable>(_ name: String, bundle: Bundle) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSFilePathErrorKey: "\(name).json"])
        }
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    // MARK: Lookups

    func ingredient(_ id: String) -> Ingredient? { ingredients[id] }

    func objective(_ id: String) -> Objective? { objectives.first { $0.id == id } }

    func recipe(_ id: String) -> Recipe? { recipes.first { $0.id == id } }

    func objectives(for recipe: Recipe) -> [Objective] {
        recipe.objectives.compactMap { objective($0) }
    }

    // MARK: Nutrition

    /// Nutrition for one serving, summed from each ingredient's per-100 g values.
    func nutrition(for recipe: Recipe) -> Nutrition {
        nutritionCache[recipe.id] ?? computeNutrition(recipe)
    }

    private func computeNutrition(_ recipe: Recipe) -> Nutrition {
        var total = NutrientValues.zero
        var added = 0.0
        for line in recipe.ingredients {
            guard let ing = ingredients[line.id] else { continue }
            let part = ing.per100g.scaled(by: line.grams / 100)
            total = total + part
            if ing.isAddedSugar { added += part.sugar }
        }
        let servings = Double(max(recipe.servings, 1))
        return Nutrition(values: total.scaled(by: 1 / servings), addedSugar: added / servings)
    }

    func highlights(for recipe: Recipe) -> Set<String> {
        highlightCache[recipe.id] ?? []
    }

    func allergens(for recipe: Recipe) -> [String] {
        Array(Set(recipe.ingredients.compactMap { ingredients[$0.id] }.flatMap(\.allergens))).sorted()
    }

    func wholeFoodLines(_ recipe: Recipe) -> [RecipeIngredient] {
        recipe.ingredients.filter { ingredients[$0.id]?.isSupplement == false }
    }

    func supplementLines(_ recipe: Recipe) -> [RecipeIngredient] {
        recipe.ingredients.filter { ingredients[$0.id]?.isSupplement == true }
    }

    /// Whether a recipe actually meets an objective's rules (independent of how it is tagged).
    func qualifies(_ recipe: Recipe, for objective: Objective) -> Bool {
        objective.rules.failures(for: nutrition(for: recipe), highlights: highlights(for: recipe)).isEmpty
    }

    // MARK: Filtering, sorting, search

    func matches(_ recipe: Recipe, filters: Set<DietFilter>) -> Bool {
        let items = recipe.ingredients.compactMap { ingredients[$0.id] }
        for filter in filters {
            switch filter {
            case .vegan:
                if items.contains(where: { !$0.isVegan }) { return false }
            case .dairyFree:
                if items.contains(where: { $0.allergens.contains("Dairy") }) { return false }
            case .nutFree:
                if items.contains(where: { $0.allergens.contains("Tree nuts") || $0.allergens.contains("Peanuts") }) { return false }
            case .wholeFoodOnly:
                if items.contains(where: \.isSupplement) { return false }
            case .caffeineFree:
                if items.contains(where: \.containsCaffeine) { return false }
            case .noAddedSugar:
                if items.contains(where: \.isAddedSugar) { return false }
            }
        }
        return true
    }

    func matches(_ recipe: Recipe, query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return true }
        if recipe.name.localizedCaseInsensitiveContains(q) || recipe.flavor.localizedCaseInsensitiveContains(q)
            || recipe.tagline.localizedCaseInsensitiveContains(q) {
            return true
        }
        return recipe.ingredients.contains { ingredients[$0.id]?.name.localizedCaseInsensitiveContains(q) == true }
    }

    func sorted(_ list: [Recipe], by mode: SortMode) -> [Recipe] {
        list.sorted { a, b in
            let na = nutrition(for: a), nb = nutrition(for: b)
            switch mode {
            case .proteinDensity: return na.proteinPer100kcal > nb.proteinPer100kcal
            case .proteinDesc: return na.protein > nb.protein
            case .kcalAsc: return na.kcal < nb.kcal
            case .kcalDesc: return na.kcal > nb.kcal
            case .netCarbsAsc: return na.netCarbs < nb.netCarbs
            case .carbsDesc: return na.carbs > nb.carbs
            case .name: return a.name.localizedCompare(b.name) == .orderedAscending
            }
        }
    }

    func recipes(for objective: Objective?, filters: Set<DietFilter> = [], query: String = "", sort: SortMode) -> [Recipe] {
        let base = objective.map { o in recipes.filter { $0.objectives.contains(o.id) } } ?? recipes
        return sorted(base.filter { matches($0, filters: filters) && matches($0, query: query) }, by: sort)
    }

    /// A recipe that changes once a day, for the Goals screen.
    func recipeOfTheDay(date: Date = .now, calendar: Calendar = .current) -> Recipe? {
        guard !recipes.isEmpty else { return nil }
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return recipes[day % recipes.count]
    }
}
