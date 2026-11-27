import SwiftUI

/// Every recipe, searchable by name, flavor or ingredient.
struct BrowseView: View {
    @Environment(RecipeStore.self) private var store
    @State private var query = ""
    @State private var filters: Set<DietFilter> = []
    @State private var sort: SortMode = .proteinDensity
    @State private var objectiveID: String?

    var body: some View {
        let objective = objectiveID.flatMap { store.objective($0) }
        let list = store.recipes(for: objective, filters: filters, query: query, sort: sort)
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button { objectiveID = nil } label: {
                                Chip(text: "All", filled: objectiveID == nil)
                            }
                            ForEach(store.objectives) { o in
                                Button { objectiveID = (objectiveID == o.id) ? nil : o.id } label: {
                                    Chip(text: o.title, symbol: o.symbol, color: o.color, filled: objectiveID == o.id)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    ActiveFilterBar(filters: $filters)
                }
                .listRowSeparator(.hidden)

                Section("\(list.count) recipes · \(sort.label.lowercased())") {
                    if list.isEmpty {
                        if query.isEmpty {
                            Text("No recipes match these filters.").foregroundStyle(.secondary)
                        } else {
                            ContentUnavailableView.search(text: query)
                        }
                    }
                    ForEach(list) { recipe in
                        NavigationLink(value: recipe) { RecipeRow(recipe: recipe) }
                    }
                }
            }
            .searchable(text: $query, prompt: "Recipe, flavor or ingredient")
            .navigationTitle("Recipes")
            .toolbar { FilterMenu(filters: $filters, sort: $sort) }
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }
}

struct SavedView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(Favorites.self) private var favorites

    var body: some View {
        let saved = store.sorted(store.recipes.filter { favorites.contains($0) }, by: .name)
        NavigationStack {
            Group {
                if saved.isEmpty {
                    ContentUnavailableView("No saved smoothies",
                                           systemImage: "heart",
                                           description: Text("Tap the heart on any recipe to keep it here."))
                } else {
                    List(saved) { recipe in
                        NavigationLink(value: recipe) { RecipeRow(recipe: recipe) }
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }
}
