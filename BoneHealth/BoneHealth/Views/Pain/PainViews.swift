import SwiftUI
import SwiftData
import Charts

struct PainHomeView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \PainEntry.date, order: .reverse) private var entries: [PainEntry]
    @State private var logging = false

    private var lastThirtyDays: [PainEntry] {
        let since = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return entries.filter { $0.date >= since }
    }

    private var pegEntries: [PainEntry] { entries.filter { $0.pegScore != nil } }

    var body: some View {
        List {
            Section {
                Button { logging = true } label: { Label("Record a pain score", systemImage: "plus.circle.fill") }.bold()
                if !lastThirtyDays.isEmpty {
                    let avg = Double(lastThirtyDays.map(\.score).reduce(0, +)) / Double(lastThirtyDays.count)
                    LabeledContent("30-day average", value: String(format: "%.1f / 10", avg))
                    LabeledContent("Worst in 30 days", value: "\(lastThirtyDays.map(\.score).max() ?? 0) / 10")
                }
            }

            if lastThirtyDays.count >= 2 {
                Section("Pain over the last 30 days") {
                    Chart(lastThirtyDays) { e in
                        LineMark(x: .value("Date", e.date), y: .value("Pain", e.score))
                        PointMark(x: .value("Date", e.date), y: .value("Pain", e.score))
                            .foregroundStyle(ScaleColor.color(for: e.score))
                    }
                    .chartYScale(domain: 0...10)
                    .frame(height: 180)
                }
            }

            if let latest = pegEntries.first, let score = latest.pegScore {
                Section {
                    LabeledContent("Latest PEG score", value: String(format: "%.1f / 10", score))
                    if pegEntries.count >= 2, let previous = pegEntries[1].pegScore {
                        Text(PEGScale.describeChange(from: previous, to: score)).font(.subheadline)
                    }
                    if pegEntries.count >= 2 {
                        Chart(Array(pegEntries.prefix(20).reversed())) { e in
                            LineMark(x: .value("Date", e.date), y: .value("PEG", e.pegScore ?? 0))
                            PointMark(x: .value("Date", e.date), y: .value("PEG", e.pegScore ?? 0))
                        }
                        .chartYScale(domain: 0...10)
                        .frame(height: 140)
                    }
                } header: {
                    Text("Pain and its impact (PEG)")
                } footer: {
                    Text("PEG combines average pain with how much pain interferes with enjoyment of life and general activity. A drop of 30% or more is a meaningful improvement.")
                }
            }

            Section("History") {
                if entries.isEmpty { Text("No pain scores yet.").foregroundStyle(.secondary) }
                ForEach(entries.prefix(100)) { e in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("\(e.score)/10").font(.subheadline.bold()).foregroundStyle(ScaleColor.color(for: e.score))
                            Text(e.locations.sorted { $0.rawValue < $1.rawValue }.map(\.label).joined(separator: ", ")).font(.subheadline)
                        }
                        HStack(spacing: 8) {
                            Text(e.date.shortDateTime)
                            if e.isNewAndSudden { Text("New, sudden") }
                            if e.afterFall { Text("After a fall") }
                            if let peg = e.pegScore { Text(String(format: "PEG %.1f", peg)) }
                        }
                        .font(.caption).foregroundStyle(.secondary)
                        if !e.helped.isEmpty { Text("Helped: \(e.helped.joined(separator: ", "))").font(.caption) }
                        if !e.note.isEmpty { Text(e.note).font(.caption) }
                    }
                }
                .onDelete { offsets in
                    let shown = Array(entries.prefix(100))
                    for i in offsets { context.delete(shown[i]) }
                    try? context.save()
                }
            }
        }
        .navigationTitle("Pain")
        .sheet(isPresented: $logging) { LogPainView(profile: profile) }
    }
}

struct LogPainView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var plans: [MedicationPlan]

    @State private var score = 3
    @State private var date = Date()
    @State private var locations: [String] = []
    @State private var qualities: [String] = []
    @State private var newAndSudden = false
    @State private var afterFall = false
    @State private var helped: [String] = []
    @State private var includePEG = false
    @State private var peg = [3, 3, 3]
    @State private var note = ""

    private var takesAntiresorptive: Bool {
        plans.contains { $0.isActive && ($0.drug?.isAntiresorptive ?? false) }
    }

    private var warnings: [SafetyWarning] {
        PainAlerts.warnings(PainAlertInput(score: score, locations: Set(locations.compactMap(PainLocation.init(rawValue:))),
                                           isNewAndSudden: newAndSudden, afterFall: afterFall, takesAntiresorptive: takesAntiresorptive))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ScaleSlider(title: "Pain right now", value: $score)
                    DatePicker("When", selection: $date, in: ...Date())
                }
                Section("Where is the pain?") {
                    TagPicker(options: PainLocation.allCases.map(\.rawValue), selection: $locations,
                              labels: Dictionary(uniqueKeysWithValues: PainLocation.allCases.map { ($0.rawValue, $0.label) }))
                }
                Section("What does it feel like?") {
                    TagPicker(options: PainQuality.allCases.map(\.rawValue), selection: $qualities,
                              labels: Dictionary(uniqueKeysWithValues: PainQuality.allCases.map { ($0.rawValue, $0.label) }))
                }
                Section {
                    Toggle("This pain is new and came on suddenly", isOn: $newAndSudden)
                    Toggle("It started after a fall or bump", isOn: $afterFall)
                }
                if !warnings.isEmpty {
                    Section("Please read") { ForEach(warnings) { WarningRow(warning: $0) } }
                }
                Section("What helped?") {
                    TagPicker(options: PainRelief.options, selection: $helped)
                }
                Section {
                    Toggle("Also answer the 3 PEG questions", isOn: $includePEG)
                    if includePEG {
                        ForEach(0..<3, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(PEGScale.questions[i]).font(.subheadline)
                                ScaleSlider(title: "", value: $peg[i], lowLabel: PEGScale.lowLabels[i], highLabel: PEGScale.highLabels[i])
                            }
                        }
                        if let s = PEGScale.score(peg.map { Optional($0) }) {
                            LabeledContent("PEG score", value: String(format: "%.1f / 10", s))
                        }
                    }
                } footer: {
                    Text("Doing the PEG once a week shows how pain is affecting your life over time.")
                }
                Section("Notes") {
                    TextField("Anything else", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("Pain score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
        }
    }

    private func save() {
        let entry = PainEntry(date: date, score: score)
        entry.locationsRaw = locations
        entry.qualitiesRaw = qualities
        entry.isNewAndSudden = newAndSudden
        entry.afterFall = afterFall
        entry.helped = helped
        if includePEG {
            entry.pegAverage = peg[0]
            entry.pegEnjoyment = peg[1]
            entry.pegActivity = peg[2]
        }
        entry.note = note
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
