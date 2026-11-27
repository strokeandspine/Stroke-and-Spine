import SwiftUI

struct GoalsView: View {
    @Environment(Catalog.self) private var catalog

    var body: some View {
        NavigationStack {
            List(catalog.goals) { goal in
                let items = catalog.compounds(for: goal.id)
                let strong = items.filter { $0.evidence == "A" || $0.evidence == "B" }
                NavigationLink {
                    LibraryView(goalFilter: goal.id)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(goal.name, systemImage: goal.symbol).font(.headline)
                        Text("\(items.count) compounds · \(strong.count) with moderate or strong evidence")
                            .font(.caption).foregroundStyle(.secondary)
                        if !strong.isEmpty {
                            Text(strong.prefix(4).map(\.name).joined(separator: ", "))
                                .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Goals")
        }
    }
}
