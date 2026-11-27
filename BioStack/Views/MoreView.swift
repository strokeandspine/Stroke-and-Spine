import SwiftUI
import SwiftData

struct MoreView: View {
    @Environment(Catalog.self) private var catalog
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\StackItem.hour)]) private var stack: [StackItem]
    @Query(sort: \DoseLog.takenAt, order: .reverse) private var logs: [DoseLog]
    @Query(sort: \EffectNote.date, order: .reverse) private var effects: [EffectNote]
    @State private var confirmWipe = false

    var body: some View {
        NavigationStack {
            List {
                Section("My stack") {
                    ForEach(stack) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("\(item.dose) · \(item.timeText)\(item.remind ? " · reminder on" : "")")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { idx in idx.map { stack[$0] }.forEach { Reminders.cancel($0); context.delete($0) } }
                }
                Section {
                    NavigationLink("Dose log (\(logs.count))") { DoseLogView() }
                    NavigationLink("Side effects (\(effects.count))") {
                        List(effects) { e in
                            VStack(alignment: .leading) {
                                Text(e.text)
                                Text("\(e.severity) · \(e.date.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(.secondary)
                            }
                        }.navigationTitle("Side effects")
                    }
                    NavigationLink("Data apps and wearables") { AppsView() }
                }
                Section {
                    Button("Delete all my data", role: .destructive) { confirmWipe = true }
                } footer: {
                    Text("BioStack stores everything on this iPhone. General information only, not medical advice.")
                }
            }
            .navigationTitle("More")
            .confirmationDialog("Delete all stack items, logs, labs and notes?", isPresented: $confirmWipe, titleVisibility: .visible) {
                Button("Delete everything", role: .destructive) {
                    stack.forEach(Reminders.cancel)
                    try? context.delete(model: StackItem.self)
                    try? context.delete(model: DoseLog.self)
                    try? context.delete(model: LabResult.self)
                    try? context.delete(model: EffectNote.self)
                }
            }
        }
    }
}

struct DoseLogView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DoseLog.takenAt, order: .reverse) private var logs: [DoseLog]
    var body: some View {
        List {
            ForEach(logs) { l in
                VStack(alignment: .leading) {
                    Text(l.name)
                    Text("\(l.dose) · \(l.takenAt.formatted(date: .abbreviated, time: .shortened))\(l.note.isEmpty ? "" : " · \(l.note)")")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .onDelete { $0.map { logs[$0] }.forEach(context.delete) }
        }
        .navigationTitle("Dose log")
    }
}

struct AppsView: View {
    @Environment(Catalog.self) private var catalog
    var body: some View {
        let groups = Dictionary(grouping: catalog.apps, by: \.category).sorted { $0.key < $1.key }
        List {
            ForEach(groups, id: \.key) { cat, apps in
                Section(cat) {
                    ForEach(apps) { app in
                        Link(destination: app.url) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name).foregroundStyle(.primary)
                                Text(app.description).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Data apps")
    }
}
