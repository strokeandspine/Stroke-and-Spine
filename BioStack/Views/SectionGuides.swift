import SwiftUI

struct NootropicsView: View {
    @Environment(Catalog.self) private var catalog

    var body: some View {
        let items = catalog.section("nootropics")
        let supplements = items.filter { !$0.isClinical }.sorted { ($0.evidence ?? "", $0.name) < ($1.evidence ?? "", $1.name) }
        let reference = items.filter(\.isClinical)
        List {
            Section {
                Text("Compounds used for focus, memory, alertness and mood. In healthy, well-rested people most effects are small; sleep, exercise and caffeine timing usually matter more.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Section {
                ForEach(supplements) { c in NavigationLink(value: c) { CompoundRow(compound: c) } }
            } header: { Text("Supplements (\(supplements.count))") } footer: { Text("Sorted by strength of evidence. Typical doses are on each entry.") }
            Section {
                ForEach(reference) { c in NavigationLink(value: c) { CompoundRow(compound: c) } }
            } header: { Text("Prescription & unapproved (\(reference.count))") } footer: {
                Text("Reference only. Prescription stimulants and wakefulness drugs need a diagnosis and a prescriber; several unapproved products carry FDA warnings.")
            }
        }
        .navigationTitle("Nootropics")
    }
}

struct PeptidesView: View {
    @Environment(Catalog.self) private var catalog

    var body: some View {
        let peps = catalog.section("peptides")
        let isTrial: (Compound) -> Bool = { $0.tier == "trial" || ($0.kind == "clinical" && ($0.status ?? "").contains("Investigational")) }
        let approved = peps.filter { !isTrial($0) && ($0.kind == "clinical" || $0.tier == "approved") }
        let trials = peps.filter(isTrial)
        List {
            Section {
                Text("What each peptide is, its legal and sport status, how strong the human evidence is, how it works, known risks and which labs a clinician would monitor. BioStack doesn't provide doses, administration or sourcing for peptides.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Section("Before you read the list") {
                ForEach(catalog.peptideGuide, id: \.title) { g in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(g.title).font(.subheadline.weight(.semibold))
                        Text(g.text).font(.callout)
                    }
                    .padding(.vertical, 2)
                }
            }
            ResearchWarningSection()
            group("Approved medicines", approved, "Approved somewhere for a specific condition and prescribed by clinicians.")
            group("In clinical trials", trials, "Promising but not yet approved.")
            ResourcesSection()
        }
        .navigationTitle("Peptides")
    }

    @ViewBuilder private func group(_ title: String, _ items: [Compound], _ footer: String) -> some View {
        Section {
            ForEach(items) { c in NavigationLink(value: c) { CompoundRow(compound: c) } }
        } header: { Text("\(title) (\(items.count))") } footer: { Text(footer) }
    }
}

struct ResearchWarningSection: View {
    @Environment(Catalog.self) private var catalog
    var body: some View {
        Section {
            ForEach(catalog.researchWarning, id: \.title) { g in
                VStack(alignment: .leading, spacing: 4) {
                    Text(g.title).font(.subheadline.weight(.semibold))
                    Text(g.text).font(.callout)
                }
            }
        } header: {
            Label("Warning: research peptides", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        } footer: {
            Text("Unapproved \"research use only\" peptides aren't listed in BioStack. Emergency: call 911. US Poison Control: 1-800-222-1222.")
        }
    }
}

struct ResourcesSection: View {
    @Environment(Catalog.self) private var catalog
    var body: some View {
        Section("Safety and regulation resources") {
            ForEach(catalog.resources) { r in
                Link(destination: r.url) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(r.name).foregroundStyle(.primary)
                        Text(r.description).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
