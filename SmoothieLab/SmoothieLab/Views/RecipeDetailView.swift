import SwiftUI

struct RecipeDetailView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(Favorites.self) private var favorites
    let recipe: Recipe
    /// How many glasses to make. Ingredient amounts scale; nutrition stays per glass.
    @State private var batch = 1
    @State private var showGrams = false

    var body: some View {
        let n = store.nutrition(for: recipe)
        let goals = store.objectives(for: recipe)
        let accent = goals.first?.color ?? .accentColor

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(goals: goals, accent: accent)
                NutritionCard(nutrition: n, accent: accent)
                ingredientsSection
                stepsSection
                infoSection(title: "Why it works", symbol: "sparkles", text: recipe.whyItWorks)
                if let timing = recipe.timing {
                    infoSection(title: "When to drink it", symbol: "clock", text: timing)
                }
                if let swaps = recipe.swaps, !swaps.isEmpty {
                    swapsSection(swaps)
                }
                highlightsSection
                Text("Nutrition is estimated from USDA FoodData Central values for whole foods and typical label values for supplements. Brands vary, so check your labels.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: shareText(n)) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share recipe")
                Button {
                    favorites.toggle(recipe)
                } label: {
                    Image(systemName: favorites.contains(recipe) ? "heart.fill" : "heart")
                        .foregroundStyle(.pink)
                }
                .accessibilityLabel(favorites.contains(recipe) ? "Remove from saved" : "Save recipe")
            }
        }
    }

    // MARK: Sections

    private func header(goals: [Objective], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recipe.name).font(.largeTitle.bold())
            Text(recipe.tagline).font(.title3).foregroundStyle(.secondary)
            Label(recipe.flavor, systemImage: "fork.knife").font(.subheadline)
            Label("\(recipe.prepMinutes) min · makes \(recipe.servings) glass", systemImage: "timer")
                .font(.subheadline).foregroundStyle(.secondary)
            FlowLayout {
                ForEach(goals) { goal in
                    Chip(text: goal.title, symbol: goal.symbol, color: goal.color)
                }
            }
        }
    }

    private var ingredientsSection: some View {
        let wholeFoods = store.wholeFoodLines(recipe)
        let supplements = store.supplementLines(recipe)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Ingredients", symbol: "basket")
                Spacer()
                Stepper("\(batch) \(batch == 1 ? "glass" : "glasses")", value: $batch, in: 1...6)
                    .font(.subheadline)
                    .fixedSize()
            }
            Toggle("Show grams", isOn: $showGrams).font(.subheadline)

            ingredientGroup("Whole foods", lines: wholeFoods)
            if !supplements.isEmpty {
                ingredientGroup("Supplements", lines: supplements)
            }
        }
    }

    private func ingredientGroup(_ title: String, lines: [RecipeIngredient]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased()).font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(lines, id: \.id) { line in
                if let ing = store.ingredient(line.id) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: ing.isSupplement ? "pills.fill" : "leaf.fill")
                            .foregroundStyle(ing.isSupplement ? Color.purple : Color.green)
                            .imageScale(.small)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(ing.name)
                            Text(amountText(line))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(whole(ing.per100g.kcal * line.grams / 100 * Double(batch))) kcal")
                            .font(.caption).foregroundStyle(.secondary).monospacedDigit()
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func amountText(_ line: RecipeIngredient) -> String {
        let scaled = grams(line.grams * Double(batch))
        if batch == 1 {
            return showGrams ? "\(line.measure) · \(scaled)" : line.measure
        }
        // Kitchen measures don't scale cleanly as text, so show the multiplier plus grams.
        return "\(batch) × \(line.measure) · \(scaled)"
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Method", symbol: "list.number")
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.bold))
                        .frame(width: 26, height: 26)
                        .background(Color.accentColor.opacity(0.15), in: Circle())
                    Text(step).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func infoSection(title: String, symbol: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle(title, symbol: symbol)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func swapsSection(_ swaps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("Swaps", symbol: "arrow.left.arrow.right")
            ForEach(swaps, id: \.self) { swap in
                Label(swap, systemImage: "circle.fill")
                    .labelStyle(BulletLabelStyle())
            }
        }
    }

    private var highlightsSection: some View {
        let highlights = store.highlights(for: recipe).sorted()
        let allergens = store.allergens(for: recipe)
        return VStack(alignment: .leading, spacing: 10) {
            if !highlights.isEmpty {
                sectionTitle("Nutrient highlights", symbol: "star")
                FlowLayout {
                    ForEach(highlights, id: \.self) { Chip(text: $0, color: .green) }
                }
            }
            if !allergens.isEmpty {
                sectionTitle("Contains", symbol: "exclamationmark.triangle")
                FlowLayout {
                    ForEach(allergens, id: \.self) { Chip(text: $0, color: .orange) }
                }
            }
        }
    }

    private func sectionTitle(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol).font(.title3.bold())
    }

    private func shareText(_ n: Nutrition) -> String {
        var lines = ["\(recipe.name) — \(recipe.tagline)",
                     "\(whole(n.kcal)) kcal · \(whole(n.protein)) g protein · \(whole(n.carbs)) g carbs · \(whole(n.fat)) g fat",
                     "",
                     "Ingredients:"]
        for line in recipe.ingredients {
            if let ing = store.ingredient(line.id) {
                lines.append("• \(ing.name): \(line.measure)")
            }
        }
        lines.append("")
        lines.append(contentsOf: recipe.steps.enumerated().map { "\($0.offset + 1). \($0.element)" })
        lines.append("")
        lines.append("From Smoothie Lab")
        return lines.joined(separator: "\n")
    }
}

private struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            configuration.icon.font(.system(size: 5)).foregroundStyle(.secondary)
            configuration.title
        }
    }
}

/// Calories, macro split and the full nutrition breakdown for one glass.
struct NutritionCard: View {
    let nutrition: Nutrition
    let accent: Color

    var body: some View {
        let n = nutrition
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(whole(n.kcal)).font(.system(size: 44, weight: .bold, design: .rounded))
                Text("kcal per glass").foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(String(format: "%.1f g", n.proteinPer100kcal)).font(.headline).foregroundStyle(Color.protein)
                    Text("protein / 100 kcal").font(.caption2).foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
            MacroBar(nutrition: n, height: 12)
            MacroLegend(nutrition: n)
            Divider()
            HStack {
                StatTile(value: whole(n.protein), unit: "g", label: "Protein", color: .protein)
                StatTile(value: whole(n.carbs), unit: "g", label: "Carbs", color: .carbs)
                StatTile(value: whole(n.fat), unit: "g", label: "Fat", color: .fat)
            }
            HStack {
                StatTile(value: whole(n.fiber), unit: "g", label: "Fiber")
                StatTile(value: whole(n.netCarbs), unit: "g", label: "Net carbs")
                StatTile(value: whole(n.sugar), unit: "g", label: "Sugars")
                StatTile(value: whole(n.addedSugar), unit: "g", label: "Added sugar")
            }
        }
        .padding()
        .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.25)))
    }
}
