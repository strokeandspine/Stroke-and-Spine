import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Environment(HealthService.self) private var health
    @Query(sort: [SortDescriptor(\StackItem.hour), SortDescriptor(\StackItem.minute)]) private var stack: [StackItem]
    @Query(sort: \DoseLog.takenAt, order: .reverse) private var logs: [DoseLog]
    @State private var showQuickLog = false
    @State private var showEffect = false

    private var todaysLogs: [DoseLog] { logs.filter { Calendar.current.isDateInToday($0.takenAt) } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if health.metrics.isEmpty {
                        Button {
                            Task { await health.connect() }
                        } label: {
                            Label("Show sleep, HRV and resting heart rate from Apple Health", systemImage: "heart.text.square")
                        }
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))], alignment: .leading, spacing: 12) {
                            ForEach(health.metrics) { m in
                                VStack(alignment: .leading) {
                                    Text(m.label).font(.caption).foregroundStyle(.secondary)
                                    Text(m.value).font(.headline.monospacedDigit())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: { Text("Body") } footer: {
                    Text("Oura, WHOOP, Garmin, Withings and most wearables can write to Apple Health.")
                }

                Section("Scheduled") {
                    if stack.isEmpty {
                        Text("Your stack is empty. Add items from the Library tab.").foregroundStyle(.secondary)
                    }
                    ForEach(stack) { item in
                        let taken = todaysLogs.contains { $0.stackItemID == item.persistentModelID }
                        Button { toggle(item, taken: taken) } label: {
                            HStack(spacing: 12) {
                                Image(systemName: taken ? "checkmark.circle.fill" : "circle")
                                    .font(.title2).foregroundStyle(taken ? .teal : .secondary)
                                VStack(alignment: .leading) {
                                    Text(item.name).foregroundStyle(.primary)
                                    Text("\(item.dose) · \(item.timeText)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                WeekDots(item: item, logs: logs)
                            }
                        }
                    }
                }

                Section("Logged today") {
                    if todaysLogs.isEmpty { Text("Nothing yet.").foregroundStyle(.secondary) }
                    ForEach(todaysLogs) { log in
                        HStack {
                            Text(log.name)
                            Spacer()
                            Text("\(log.dose) · \(log.takenAt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { showEffect = true } label: { Label("Side effect", systemImage: "exclamationmark.bubble") }
                    Button { showQuickLog = true } label: { Label("Log", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $showQuickLog) { QuickLogView() }
            .sheet(isPresented: $showEffect) { EffectView() }
            .task { if health.authorized { await health.refresh() } }
        }
    }

    private func toggle(_ item: StackItem, taken: Bool) {
        if taken {
            todaysLogs.filter { $0.stackItemID == item.persistentModelID }.forEach(context.delete)
        } else {
            context.insert(DoseLog(stackItemID: item.persistentModelID, name: item.name, dose: item.dose))
        }
    }
}

struct WeekDots: View {
    let item: StackItem
    let logs: [DoseLog]
    var body: some View {
        HStack(spacing: 3) {
            ForEach((0..<7).reversed(), id: \.self) { offset in
                let day = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                let on = logs.contains { $0.stackItemID == item.persistentModelID && Calendar.current.isDate($0.takenAt, inSameDayAs: day) }
                RoundedRectangle(cornerRadius: 2).fill(on ? Color.teal : Color.secondary.opacity(0.25)).frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("Last 7 days adherence")
    }
}

struct QuickLogView: View {
    @Environment(Catalog.self) private var catalog
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dose = ""
    @State private var time = Date()
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item", text: $name)
                TextField("Dose (as you took it or as prescribed)", text: $dose)
                DatePicker("Time", selection: $time)
                TextField("Notes", text: $note, axis: .vertical)
                if name.count > 2 && !catalog.isListed(name) {
                    ResearchWarningSection()
                }
            }
            .navigationTitle("Log a dose")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        context.insert(DoseLog(stackItemID: nil, name: name, dose: dose, takenAt: time, note: note))
                        dismiss()
                    }.disabled(name.isEmpty)
                }
            }
        }
    }
}

struct EffectView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var severity = "Mild"

    var body: some View {
        NavigationStack {
            Form {
                TextField("What happened?", text: $text, axis: .vertical)
                Picker("Severity", selection: $severity) {
                    ForEach(["Mild", "Moderate", "Severe"], id: \.self, content: Text.init)
                }
                Section {
                    Text("If a symptom is severe or worrying, stop and contact a clinician. For emergencies call 911. US Poison Control: 1-800-222-1222.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Side effect")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { context.insert(EffectNote(text: text, severity: severity)); dismiss() }.disabled(text.isEmpty)
                }
            }
        }
    }
}
