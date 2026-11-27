import XCTest
@testable import SmoothieLab

/// Checks the bundled recipe data against the same rules the app advertises.
/// tools/validate_recipes.py runs the same checks without Xcode.
final class RecipeDataTests: XCTestCase {
    private var store: RecipeStore!

    override func setUp() {
        super.setUp()
        store = RecipeStore(bundle: Bundle(for: RecipeStore.self))
    }

    func testDataLoads() {
        XCTAssertNil(store.loadError)
        XCTAssertGreaterThanOrEqual(store.recipes.count, 40)
        XCTAssertEqual(store.objectives.count, 11)
    }

    func testRecipeIDsAreUnique() {
        XCTAssertEqual(Set(store.recipes.map(\.id)).count, store.recipes.count)
    }

    func testEveryIngredientAndObjectiveExists() {
        for recipe in store.recipes {
            for line in recipe.ingredients {
                XCTAssertNotNil(store.ingredient(line.id), "\(recipe.id) uses unknown ingredient \(line.id)")
                XCTAssertGreaterThan(line.grams, 0, "\(recipe.id): \(line.id) has no weight")
            }
            for id in recipe.objectives {
                XCTAssertNotNil(store.objective(id), "\(recipe.id) uses unknown objective \(id)")
            }
        }
    }

    func testEveryTaggedRecipeMeetsItsObjectiveRules() {
        for recipe in store.recipes {
            let n = store.nutrition(for: recipe)
            for objective in store.objectives(for: recipe) {
                let failures = objective.rules.failures(for: n, highlights: store.highlights(for: recipe))
                XCTAssertTrue(failures.isEmpty, "\(recipe.id) is listed under \(objective.id) but \(failures)")
            }
        }
    }

    func testEveryObjectiveHasEnoughRecipes() {
        for objective in store.objectives {
            let count = store.recipes(for: objective, sort: objective.sort).count
            XCTAssertGreaterThanOrEqual(count, HealthRules.minRecipesPerObjective, objective.id)
        }
    }

    func testHealthRules() {
        for recipe in store.recipes {
            let n = store.nutrition(for: recipe)
            XCTAssertLessThanOrEqual(n.addedSugar, HealthRules.maxAddedSugarGrams, "\(recipe.id) added sugar")
            XCTAssertLessThanOrEqual(n.kcal, HealthRules.maxKcal, "\(recipe.id) calories")
            XCTAssertGreaterThanOrEqual(n.protein, 2, "\(recipe.id) protein")
        }
    }

    func testRecipesAreMostlyWholeFoods() {
        for recipe in store.recipes {
            let wholeGrams = store.wholeFoodLines(recipe).map(\.grams).reduce(0, +)
            let supplementGrams = store.supplementLines(recipe).map(\.grams).reduce(0, +)
            XCTAssertGreaterThan(wholeGrams, supplementGrams, recipe.id)
        }
    }

    func testCaloriesRoughlyMatchMacros() {
        // Label calories and 4/4/9 estimates differ a little (fiber, rounding) but shouldn't diverge wildly.
        for recipe in store.recipes {
            let n = store.nutrition(for: recipe)
            let estimate = n.protein * 4 + (n.carbs - n.fiber) * 4 + n.fiber * 2 + n.fat * 9
            XCTAssertEqual(n.kcal, estimate, accuracy: max(40, n.kcal * 0.15), recipe.id)
        }
    }

    func testTextIsFilledIn() {
        for recipe in store.recipes {
            XCTAssertFalse(recipe.steps.isEmpty, recipe.id)
            XCTAssertFalse(recipe.whyItWorks.isEmpty, recipe.id)
            XCTAssertFalse(recipe.flavor.isEmpty, recipe.id)
            XCTAssertFalse(recipe.ingredients.map(\.measure).contains(""), recipe.id)
        }
    }
}

final class LogicTests: XCTestCase {
    private var store: RecipeStore!

    override func setUp() {
        super.setUp()
        store = RecipeStore(bundle: Bundle(for: RecipeStore.self))
    }

    func testRulesRoundBeforeComparing() {
        let rules = ObjectiveRules(maxKcal: 250)
        let n = Nutrition(values: NutrientValues(kcal: 250.4, protein: 20, carbs: 20, fat: 5, fiber: 3, sugar: 10), addedSugar: 0)
        XCTAssertTrue(rules.failures(for: n, highlights: []).isEmpty)
        let over = Nutrition(values: NutrientValues(kcal: 250.6, protein: 20, carbs: 20, fat: 5, fiber: 3, sugar: 10), addedSugar: 0)
        XCTAssertFalse(rules.failures(for: over, highlights: []).isEmpty)
    }

    func testHighlightRequirement() {
        let rules = ObjectiveRules(requiresAnyHighlight: ["Electrolytes"])
        let n = Nutrition(values: .zero, addedSugar: 0)
        XCTAssertFalse(rules.failures(for: n, highlights: ["Vitamin C"]).isEmpty)
        XCTAssertTrue(rules.failures(for: n, highlights: ["Electrolytes"]).isEmpty)
    }

    func testMacroSplitAddsUpToOne() {
        for recipe in store.recipes {
            let split = store.nutrition(for: recipe).macroSplit
            XCTAssertEqual(split.protein + split.carbs + split.fat, 1, accuracy: 0.0001)
        }
    }

    func testVeganFilterExcludesAnimalProducts() {
        let vegan = store.recipes(for: nil, filters: [.vegan], sort: .name)
        XCTAssertFalse(vegan.isEmpty)
        for recipe in vegan {
            for line in recipe.ingredients {
                XCTAssertTrue(store.ingredient(line.id)?.isVegan == true, "\(recipe.id) has \(line.id)")
            }
        }
    }

    func testNoSupplementFilter() {
        for recipe in store.recipes(for: nil, filters: [.wholeFoodOnly], sort: .name) {
            XCTAssertTrue(store.supplementLines(recipe).isEmpty, recipe.id)
        }
    }

    func testSearchFindsIngredient() {
        let results = store.recipes(for: nil, query: "matcha", sort: .name)
        XCTAssertTrue(results.contains { $0.id == "iced-matcha-vanilla" })
    }

    func testSortByProteinDensity() {
        let sorted = store.recipes(for: nil, sort: .proteinDensity)
        let values = sorted.map { store.nutrition(for: $0).proteinPer100kcal }
        XCTAssertEqual(values, values.sorted(by: >))
    }

    func testFavoritesPersist() {
        let defaults = UserDefaults(suiteName: "FavoritesTest")!
        defaults.removePersistentDomain(forName: "FavoritesTest")
        let recipe = store.recipes[0]
        Favorites(defaults: defaults).toggle(recipe)
        XCTAssertTrue(Favorites(defaults: defaults).contains(recipe))
    }
}
