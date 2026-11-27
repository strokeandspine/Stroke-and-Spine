import SwiftUI

/// Plain-language background on macros, supplements and how the numbers are worked out.
struct GuideView: View {
    @Environment(RecipeStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Section("How we build recipes") {
                    GuideRow(title: "Whole foods first",
                             text: "Every recipe is mostly fruit, vegetables, dairy or soy, oats, nuts and seeds. Supplements are added only where they make a real difference, such as protein powder to reach 30 g+ of protein without extra calories.")
                    GuideRow(title: "Protein per calorie",
                             text: "We rank recipes by grams of protein per 100 kcal. Above 8 g is excellent, 5–8 g is good. Protein keeps you full and supports muscle, so a high ratio means more benefit per calorie.")
                    GuideRow(title: "Little added sugar",
                             text: "No recipe has more than \(whole(HealthRules.maxAddedSugarGrams)) g of added sugar from honey or maple syrup. Sweetness comes from fruit, dates, vanilla and cinnamon.")
                    GuideRow(title: "How the numbers are calculated",
                             text: "Calories and macros are added up from each ingredient's weight, using USDA FoodData Central values for whole foods and typical label values for supplements. Brands differ, especially protein powders, so check your labels if you track closely.")
                }

                Section("Macros in one minute") {
                    GuideRow(title: "Protein — 4 kcal per gram",
                             text: "Builds and repairs muscle and is the most filling macro. Most active adults do well with 0.7–1 g per pound of body weight a day.")
                    GuideRow(title: "Carbs — 4 kcal per gram",
                             text: "Your muscles' preferred fuel for hard exercise. Net carbs are total carbs minus fiber.")
                    GuideRow(title: "Fat — 9 kcal per gram",
                             text: "Needed for hormones and absorbing vitamins A, D, E and K. It's calorie-dense, so small amounts of nut butter or avocado go a long way.")
                    GuideRow(title: "Fiber",
                             text: "Slows digestion and keeps you full. Adults need about 25–38 g a day; most get half that. Keep fiber low right before or during exercise to avoid stomach upset.")
                }

                Section("Supplements used in recipes") {
                    GuideRow(title: "Protein powders",
                             text: "Whey isolate is fast-digesting and high in leucine. Casein digests slowly, which suits bedtime. Pea and rice blends are complete vegan options. Collagen is not a complete protein, so we always pair it with another protein. Look for third-party tested products (for example NSF Certified for Sport or Informed Sport).")
                    GuideRow(title: "Creatine monohydrate",
                             text: "3–5 g a day is the most researched supplement for strength and power. Take it every day; the timing doesn't matter much. Talk to your doctor first if you have kidney disease.")
                    GuideRow(title: "Electrolytes",
                             text: "Sodium and potassium replace what you lose in sweat during long or hot sessions. Choose a low- or no-sugar mix. If you have high blood pressure or are on a low-sodium diet, ask your doctor.")
                    GuideRow(title: "Vitamins and greens",
                             text: "Vitamin C, vitamin D and greens powders can fill gaps but don't replace vegetables. Don't take more than the label dose, and count vitamins you already take in other supplements.")
                    GuideRow(title: "Omega-3 fish oil",
                             text: "EPA and DHA support heart and brain health. Ask your doctor if you take blood thinners.")
                    GuideRow(title: "Caffeine and beetroot",
                             text: "Coffee, matcha and green tea provide caffeine; up to 400 mg a day is considered safe for most healthy adults. Beets and beetroot powder supply nitrates that may help endurance.")
                }

                Section("Safety") {
                    GuideRow(title: "Not medical advice",
                             text: "These recipes are general nutrition information. If you have diabetes, kidney disease, food allergies, an eating disorder, or are pregnant or nursing, ask your doctor or a registered dietitian which recipes suit you.")
                    GuideRow(title: "Allergens",
                             text: "Each recipe lists dairy, egg, fish, soy, peanut, tree nut and gluten ingredients. Always check product labels, because supplements can contain hidden allergens.")
                    GuideRow(title: "Food safety",
                             text: "Use only pasteurized egg whites, never raw eggs. Keep blended smoothies in the fridge and drink within 24 hours.")
                }

                Section {
                    LabeledContent("Recipes", value: "\(store.recipes.count)")
                    LabeledContent("Ingredients", value: "\(store.ingredients.count)")
                    LabeledContent("Goals", value: "\(store.objectives.count)")
                } header: {
                    Text("About")
                } footer: {
                    Text("Smoothie Lab \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")")
                }
            }
            .navigationTitle("Guide")
        }
    }
}

private struct GuideRow: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
