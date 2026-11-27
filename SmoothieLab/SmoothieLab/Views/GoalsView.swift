import SwiftUI

/// Home tab: pick a goal, see the recipes for it.
struct GoalsView: View {
    @Environment(RecipeStore.self) private var store
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let featured = store.recipeOfTheDay() {
                        NavigationLink(value: featured) {
                            FeaturedCard(recipe: featured)
                        }
                        .buttonStyle(.plain)
                    }

                    Text("What's your goal?").font(.title2.bold())

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.objectives) { objective in
                            NavigationLink(value: objective) {
                                ObjectiveCard(objective: objective,
                                              count: store.recipes(for: objective, sort: objective.sort).count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Smoothie Lab")
            .navigationDestination(for: Objective.self) { ObjectiveRecipesView(objective: $0) }
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }
}

struct ObjectiveCard: View {
    let objective: Objective
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: objective.symbol).font(.title2)
                Spacer()
                Text("\(count)").font(.caption.weight(.bold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.white.opacity(0.25), in: Capsule())
                    .accessibilityLabel("\(count) recipes")
            }
            Spacer(minLength: 0)
            Text(objective.title).font(.headline)
            Text(objective.subtitle).font(.caption).opacity(0.9).lineLimit(2, reservesSpace: true)
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .background(LinearGradient(colors: [objective.color, objective.color.opacity(0.7)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

struct FeaturedCard: View {
    @Environment(RecipeStore.self) private var store
    let recipe: Recipe

    var body: some View {
        let n = store.nutrition(for: recipe)
        VStack(alignment: .leading, spacing: 10) {
            Text("TODAY'S BLEND").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text(recipe.name).font(.title3.bold())
            Text(recipe.tagline).font(.subheadline).foregroundStyle(.secondary)
            HStack {
                StatTile(value: whole(n.kcal), unit: "kcal", label: "Calories")
                StatTile(value: whole(n.protein), unit: "g", label: "Protein", color: .protein)
                StatTile(value: whole(n.carbs), unit: "g", label: "Carbs", color: .carbs)
                StatTile(value: whole(n.fat), unit: "g", label: "Fat", color: .fat)
            }
            MacroBar(nutrition: n, height: 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Recipes for one objective, with its guidance and sort/filter controls.
struct ObjectiveRecipesView: View {
    @Environment(RecipeStore.self) private var store
    let objective: Objective
    @State private var filters: Set<DietFilter> = []
    @State private var sort: SortMode
    @State private var showGuidance = false

    init(objective: Objective) {
        self.objective = objective
        _sort = State(initialValue: objective.sort)
    }

    var body: some View {
        let list = store.recipes(for: objective, filters: filters, sort: sort)
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(objective.subtitle, systemImage: objective.symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(objective.color)
                    Text(objective.summary).font(.subheadline)
                    DisclosureGroup("Tips for this goal", isExpanded: $showGuidance) {
                        Text(objective.guidance).font(.footnote).foregroundStyle(.secondary).padding(.top, 4)
                    }
                    .font(.subheadline)
                    ActiveFilterBar(filters: $filters)
                }
            }

            Section("\(list.count) recipes · \(sort.label.lowercased())") {
                if list.isEmpty {
                    Text("No recipes match these filters.").foregroundStyle(.secondary)
                }
                ForEach(list) { recipe in
                    NavigationLink(value: recipe) { RecipeRow(recipe: recipe) }
                }
            }
        }
        .navigationTitle(objective.title)
        .toolbar { FilterMenu(filters: $filters, sort: $sort) }
    }
}
