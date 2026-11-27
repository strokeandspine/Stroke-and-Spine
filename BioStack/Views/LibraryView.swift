import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(Catalog.self) private var catalog
    @State private var search = ""
    @State private var kind = "all"
    @State private var grade: String? = nil
    var goalFilter: String? = nil

    private var results: [Compound] {
        catalog.all.filter { c in
            (kind == "all" || c.kind == kind)
            && (goalFilter == nil || c.goals.contains(goalFilter!))
            && (grade == nil || c.evidence == grade)
            && (search.isEmpty || c.name.localizedCaseInsensitiveContains(search) || c.category.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        let list = List {
            Section {
                Picker("Type", selection: $kind) {
                    Text("All").tag("all")
                    Text("Supplements").tag("supplement")
                    Text("Clinical").tag("clinical")
                }
                .pickerStyle(.segmented)
                Picker("Evidence", selection: $grade) {
                    Text("Any evidence").tag(String?.none)
                    ForEach(Evidence.allCases, id: \.self) { Text("Grade \($0.rawValue): \($0.label)").tag(Optional($0.rawValue)) }
                }
            }
            Section("\(results.count) results") {
                ForEach(results) { c in
                    NavigationLink(value: c) { CompoundRow(compound: c) }
                }
            }
        }
        .searchable(text: $search, prompt: "Search compounds")
        .navigationDestination(for: Compound.self) { CompoundDetailView(compound: $0) }

        if let goalFilter {
            list.navigationTitle(catalog.goal(goalFilter)?.name ?? "Goal")
        } else {
            NavigationStack { list.navigationTitle("Library") }
        }
    }
}

struct CompoundDetailView: View {
    @Environment(Catalog.self) private var catalog
    let compound: Compound
    @State private var adding = false

    var body: some View {
        List {
            Section {
                HStack { EvidenceBadge(compound: compound); Text(compound.category).foregroundStyle(.secondary) }
            }
            if compound.isClinical {
                fact("Status", compound.status)
                fact("Approved uses", compound.uses)
                fact("How it works", compound.mechanism)
                fact("Evidence", compound.evidence_text)
                fact("Key risks", compound.risks)
                fact("Labs to monitor", compound.labs)
                fact("Dosing", "Set by your prescribing clinician. BioStack doesn't provide doses for prescription or clinical compounds.")
            } else {
                fact("Typical dose", compound.dose)
                fact("Timing", compound.timing)
                fact("Evidence", compound.grade.map { "Grade \($0.rawValue): \($0.label)" })
                fact("Notes and cautions", compound.notes)
            }
            Section("Linked goals") {
                ForEach(compound.goals, id: \.self) { id in
                    if let g = catalog.goal(id) { Label(g.name, systemImage: g.symbol) }
                }
            }
            Section {
                Button { adding = true } label: { Label("Add to my stack", systemImage: "plus.circle.fill") }
            } footer: {
                Text("General information, not medical advice. Choose third-party tested products (NSF Certified for Sport, Informed Sport, USP).")
            }
        }
        .navigationTitle(compound.name)
        .sheet(isPresented: $adding) { AddToStackView(compound: compound) }
    }

    @ViewBuilder private func fact(_ title: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            Section(title) { Text(value) }
        }
    }
}

struct AddToStackView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let compound: Compound
    @State private var dose = ""
    @State private var time = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
    @State private var remind = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(compound.isClinical ? "Dose as prescribed" : "Your dose", text: $dose)
                } footer: {
                    if let d = compound.dose { Text("Typical range: \(d)") }
                }
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                Toggle("Daily reminder", isOn: $remind)
            }
            .navigationTitle(compound.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let c = Calendar.current.dateComponents([.hour, .minute], from: time)
                        let item = StackItem(compoundID: compound.id, name: compound.name, dose: dose,
                                             hour: c.hour ?? 8, minute: c.minute ?? 0, remind: remind)
                        context.insert(item)
                        Task { await Reminders.schedule(item) }
                        dismiss()
                    }.disabled(dose.isEmpty)
                }
            }
        }
    }
}
