import SwiftUI

// MARK: - Colors

extension Color {
    /// Creates a color from "#RRGGBB".
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255)
    }

    static let protein = Color(red: 0.86, green: 0.25, blue: 0.36)
    static let carbs = Color(red: 0.95, green: 0.62, blue: 0.15)
    static let fat = Color(red: 0.23, green: 0.51, blue: 0.86)
}

extension Objective {
    var color: Color { Color(hex: colorHex) }
}

/// Whole-number formatting used everywhere so numbers match the objective rules.
func whole(_ value: Double) -> String { String(Int(value.rounded())) }

/// Gram amounts: one decimal place below 10 g, whole numbers above.
func grams(_ value: Double) -> String {
    if value < 10 {
        let rounded = (value * 10).rounded() / 10
        return rounded == rounded.rounded() ? "\(Int(rounded)) g" : String(format: "%.1f g", rounded)
    }
    return "\(Int(value.rounded())) g"
}

// MARK: - Macro bar

struct MacroBar: View {
    let nutrition: Nutrition
    var height: CGFloat = 10

    var body: some View {
        let split = nutrition.macroSplit
        GeometryReader { geo in
            HStack(spacing: 2) {
                Rectangle().fill(Color.protein).frame(width: max(0, geo.size.width * split.protein - 2))
                Rectangle().fill(Color.carbs).frame(width: max(0, geo.size.width * split.carbs - 2))
                Rectangle().fill(Color.fat)
            }
        }
        .frame(height: height)
        .clipShape(Capsule())
        .accessibilityElement()
        .accessibilityLabel("Calories from protein \(whole(split.protein * 100)) percent, carbs \(whole(split.carbs * 100)) percent, fat \(whole(split.fat * 100)) percent")
    }
}

struct MacroLegend: View {
    let nutrition: Nutrition

    var body: some View {
        let split = nutrition.macroSplit
        HStack(spacing: 14) {
            legend("Protein", split.protein, .protein)
            legend("Carbs", split.carbs, .carbs)
            legend("Fat", split.fat, .fat)
        }
        .font(.caption)
    }

    private func legend(_ label: String, _ share: Double, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(label) \(whole(share * 100))%").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Stat tile

struct StatTile: View {
    let value: String
    let unit: String
    let label: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value).font(.title3.weight(.bold)).foregroundStyle(color)
                Text(unit).font(.caption2).foregroundStyle(.secondary)
            }
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Chips

struct Chip: View {
    let text: String
    var symbol: String? = nil
    var color: Color = .accentColor
    var filled = false

    var body: some View {
        HStack(spacing: 4) {
            if let symbol { Image(systemName: symbol).imageScale(.small) }
            Text(text)
        }
        .font(.caption.weight(.medium))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(filled ? Color.white : color)
        .background(filled ? color : color.opacity(0.12), in: Capsule())
    }
}

/// Wraps its children onto as many lines as needed.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if needed > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            var row = rows[rows.count - 1]
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            rows[rows.count - 1] = row
        }
        return rows.filter { !$0.indices.isEmpty }
    }
}

// MARK: - Recipe row

struct RecipeRow: View {
    @Environment(RecipeStore.self) private var store
    @Environment(Favorites.self) private var favorites
    let recipe: Recipe

    var body: some View {
        let n = store.nutrition(for: recipe)
        let primary = store.objectives(for: recipe).first
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [(primary?.color ?? .accentColor).opacity(0.9), (primary?.color ?? .accentColor).opacity(0.55)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: primary?.symbol ?? "cup.and.saucer.fill").foregroundStyle(.white).font(.title3))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name).font(.headline).lineLimit(2)
                    if favorites.contains(recipe) {
                        Image(systemName: "heart.fill").foregroundStyle(.pink).imageScale(.small)
                            .accessibilityLabel("Saved")
                    }
                }
                Text(recipe.flavor).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                HStack(spacing: 10) {
                    Label("\(whole(n.kcal)) kcal", systemImage: "flame").foregroundStyle(.primary)
                    Text("P \(whole(n.protein))g").foregroundStyle(Color.protein)
                    Text("C \(whole(n.carbs))g").foregroundStyle(Color.carbs)
                    Text("F \(whole(n.fat))g").foregroundStyle(Color.fat)
                }
                .font(.caption.weight(.semibold))
                .labelStyle(.titleAndIcon)
                MacroBar(nutrition: n, height: 5)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter menu

struct FilterMenu: View {
    @Binding var filters: Set<DietFilter>
    @Binding var sort: SortMode

    var body: some View {
        Menu {
            Section("Sort by") {
                Picker("Sort by", selection: $sort) {
                    ForEach(SortMode.allCases) { Text($0.label).tag($0) }
                }
            }
            Section("Show only") {
                ForEach(DietFilter.allCases) { filter in
                    Toggle(isOn: Binding(
                        get: { filters.contains(filter) },
                        set: { on in if on { filters.insert(filter) } else { filters.remove(filter) } }
                    )) {
                        Label(filter.label, systemImage: filter.symbol)
                    }
                }
            }
            if !filters.isEmpty {
                Button("Clear filters", role: .destructive) { filters.removeAll() }
            }
        } label: {
            Image(systemName: filters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .accessibilityLabel("Sort and filter")
        }
    }
}

struct ActiveFilterBar: View {
    @Binding var filters: Set<DietFilter>

    var body: some View {
        if !filters.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(DietFilter.allCases.filter { filters.contains($0) }) { filter in
                        Button {
                            filters.remove(filter)
                        } label: {
                            Chip(text: filter.label, symbol: "xmark", filled: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Remove filter \(filter.label)")
                    }
                }
            }
        }
    }
}
