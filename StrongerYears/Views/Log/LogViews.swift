import SwiftUI
import SwiftData
import Charts

struct LogView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case workouts = "Workouts", recovery = "Recovery", progress = "Progress"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .workouts
    @State private var addingRecovery = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Show", selection: $tab) {
                    ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .padding()
                switch tab {
                case .workouts: WorkoutListView()
                case .recovery: RecoveryListView()
                case .progress: ProgressListView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Training log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { addingRecovery = true } label: { Label("Log recovery", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $addingRecovery) { RecoveryEntryView() }
        }
    }
}

// MARK: Workouts

struct WorkoutListView: View {
    @Query(sort: \WorkoutLog.date, order: .reverse) private var workouts: [WorkoutLog]
    @Environment(\.modelContext) private var context

    var body: some View {
        if workouts.isEmpty {
            ContentUnavailableView("No workouts yet", systemImage: "dumbbell",
                                   description: Text("Your workouts appear here after you finish them."))
        } else {
            List {
                ForEach(groupedByMonth) { group in
                    Section(group.month) {
                        ForEach(group.items) { w in
                            NavigationLink { WorkoutDetailView(workout: w) } label: { WorkoutRow(workout: w) }
                        }
                        .onDelete { offsets in
                            for i in offsets { context.delete(group.items[i]) }
                            try? context.save()
                        }
                    }
                }
            }
        }
    }

    struct MonthGroup: Identifiable {
        let month: String
        var items: [WorkoutLog]
        var id: String { month }
    }

    private var groupedByMonth: [MonthGroup] {
        var result: [MonthGroup] = []
        for w in workouts {
            let month = w.date.formatted(.dateTime.month(.wide).year())
            if result.last?.month == month {
                result[result.count - 1].items.append(w)
            } else {
                result.append(MonthGroup(month: month, items: [w]))
            }
        }
        return result
    }
}

struct WorkoutRow: View {
    let workout: WorkoutLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.title).font(.headline)
                Spacer()
                if workout.hadPain { Image(systemName: "bandage").foregroundStyle(.red).accessibilityLabel("Pain noted") }
            }
            Text(workout.date.formatted(.dateTime.weekday(.wide).month().day()))
                .font(.subheadline)
            Text("\(workout.durationMinutes) min · \(workout.exerciseCount) exercises · effort \(workout.overallEffort)/10")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct WorkoutDetailView: View {
    let workout: WorkoutLog

    struct ExerciseGroup: Identifiable {
        let id: String
        let name: String
        var sets: [SetLog]
    }

    private var byExercise: [ExerciseGroup] {
        var result: [ExerciseGroup] = []
        for s in workout.sortedSets {
            if result.last?.id == s.exerciseID {
                result[result.count - 1].sets.append(s)
            } else {
                result.append(ExerciseGroup(id: s.exerciseID, name: s.exerciseName, sets: [s]))
            }
        }
        return result
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: workout.date.formatted(date: .complete, time: .shortened))
                LabeledContent("Length", value: "\(workout.durationMinutes) minutes")
                LabeledContent("Body parts", value: workout.bodyParts.map(\.rawValue).joined(separator: ", "))
                LabeledContent("Overall effort", value: "\(workout.overallEffort)/10 — \(EffortScale.words(workout.overallEffort))")
                LabeledContent("Feeling", value: ["Rough", "Not great", "OK", "Good", "Great"][max(0, min(4, workout.feeling - 1))])
                LabeledContent("Warm-up", value: workout.warmedUp ? "Done" : "Not recorded")
                LabeledContent("Cool-down and stretching", value: workout.cooledDown ? "Done" : "Not recorded")
                if workout.totalVolume > 0 {
                    LabeledContent("Total weight lifted", value: "\(Progression.formatWeight(workout.totalVolume)) lb")
                }
            }
            ForEach(byExercise) { group in
                Section(group.name) {
                    ForEach(group.sets) { s in
                        HStack {
                            Text("Set \(s.setNumber)")
                            Spacer()
                            Text(s.summary).foregroundStyle(.secondary)
                            if s.pain { Image(systemName: "bandage").foregroundStyle(.red).accessibilityLabel("Pain") }
                        }
                    }
                }
            }
            if !workout.notes.isEmpty {
                Section("Notes") { Text(workout.notes) }
            }
        }
        .navigationTitle(workout.title)
    }
}

// MARK: Recovery

struct RecoveryListView: View {
    @Query(sort: \RecoveryLog.date, order: .reverse) private var entries: [RecoveryLog]
    @Environment(\.modelContext) private var context

    var body: some View {
        if entries.isEmpty {
            ContentUnavailableView("Nothing logged yet", systemImage: "thermometer.sun",
                                   description: Text("Log sauna sessions, cold plunges, stretching and walks with the + button."))
        } else {
            List {
                ForEach(entries) { e in
                    HStack(spacing: 12) {
                        Image(systemName: e.kind.symbol).font(.title2).frame(width: 36).foregroundStyle(Color.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(e.kind.rawValue) · \(e.minutes) min").font(.headline)
                            Text(e.date.formatted(date: .abbreviated, time: .shortened)).font(.subheadline)
                            if let t = e.temperature { Text("\(t)°F").font(.subheadline).foregroundStyle(.secondary) }
                            if e.feltUnwell { Text("Felt unwell").font(.subheadline).foregroundStyle(.red) }
                            if !e.notes.isEmpty { Text(e.notes).font(.subheadline).foregroundStyle(.secondary) }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(entries[i]) }
                    try? context.save()
                }
            }
        }
    }
}

struct RecoveryEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var kind: RecoveryKind = .sauna
    @State private var date = Date()
    @State private var minutes = 10
    @State private var recordTemperature = false
    @State private var temperature = 170
    @State private var feltUnwell = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(RecoveryKind.allCases) { Label($0.rawValue, systemImage: $0.symbol).tag($0) }
                    }
                    .onChange(of: kind) { _, new in
                        minutes = new == .coldPlunge ? 1 : 10
                        temperature = new == .coldPlunge ? 59 : 170
                    }
                    DatePicker("When", selection: $date)
                    Stepper("\(minutes) minutes", value: $minutes, in: 1...180)
                        .font(.headline)
                    if kind == .sauna || kind == .coldPlunge {
                        Toggle("Record temperature", isOn: $recordTemperature)
                        if recordTemperature {
                            Stepper("\(temperature)°F", value: $temperature, in: kind == .coldPlunge ? 33...80 : 100...220)
                        }
                    }
                    Toggle("I felt unwell (dizzy, faint, chest pain, very cold)", isOn: $feltUnwell)
                }
                if let limit = kind.cautionMinutes, minutes > limit {
                    Section {
                        Label(kind == .sauna
                              ? "Older adults are advised to keep sauna sessions to 15–20 minutes at most."
                              : "1–3 minutes is plenty for a cold plunge. Longer raises the risk of getting too cold.",
                              systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
                if feltUnwell {
                    Section {
                        Label("If you had chest pain, fainted or still feel unwell, get medical help. Call 911 in an emergency. Talk to your doctor before your next session.", systemImage: "stethoscope")
                            .foregroundStyle(.red)
                    }
                }
                Section("Notes") {
                    TextField("Optional", text: $notes, axis: .vertical)
                }
                if let id = kind.guideID, let guide = GuideLibrary.guide(id) {
                    Section {
                        NavigationLink("Read: \(guide.title)") { GuideDetailView(guide: guide) }
                    }
                }
            }
            .navigationTitle("Log recovery")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
        }
    }

    private func save() {
        let entry = RecoveryLog(date: date, kind: kind, minutes: minutes)
        entry.temperature = (recordTemperature && (kind == .sauna || kind == .coldPlunge)) ? temperature : nil
        entry.feltUnwell = feltUnwell
        entry.notes = notes
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}

// MARK: Progress

struct ProgressListView: View {
    @Query(sort: \SetLog.completedAt, order: .reverse) private var sets: [SetLog]

    struct ExerciseSummary: Identifiable {
        let id: String
        let name: String
        let count: Int
    }

    private var exercises: [ExerciseSummary] {
        var seen: [String: (name: String, workouts: Set<PersistentIdentifier>)] = [:]
        var order: [String] = []
        for s in sets {
            if seen[s.exerciseID] == nil { order.append(s.exerciseID); seen[s.exerciseID] = (s.exerciseName, []) }
            if let w = s.workout { seen[s.exerciseID]?.workouts.insert(w.persistentModelID) }
        }
        return order.compactMap { id in seen[id].map { ExerciseSummary(id: id, name: $0.name, count: $0.workouts.count) } }
    }

    var body: some View {
        if sets.isEmpty {
            ContentUnavailableView("No progress yet", systemImage: "chart.line.uptrend.xyaxis",
                                   description: Text("After a few workouts you'll see how each exercise is improving."))
        } else {
            List(exercises) { e in
                NavigationLink {
                    ExerciseProgressView(exerciseID: e.id, name: e.name)
                } label: {
                    VStack(alignment: .leading) {
                        Text(e.name).font(.headline)
                        Text(e.count == 1 ? "1 workout" : "\(e.count) workouts").font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct ExerciseProgressView: View {
    let exerciseID: String
    let name: String
    @Query(sort: \SetLog.completedAt) private var allSets: [SetLog]

    struct Point: Identifiable {
        let date: Date
        let value: Double
        var id: Date { date }
    }

    private var sets: [SetLog] { allSets.filter { $0.exerciseID == exerciseID } }

    private var metric: (label: String, unit: String, value: (SetLog) -> Double?) {
        if sets.contains(where: { ($0.weight ?? 0) > 0 }) { return ("Heaviest weight", "lb", { $0.weight }) }
        if sets.contains(where: { $0.seconds != nil }) { return ("Longest hold", "sec", { $0.seconds.map(Double.init) }) }
        return ("Most reps", "reps", { $0.reps.map(Double.init) })
    }

    private var points: [Point] {
        let grouped = Dictionary(grouping: sets) { Calendar.current.startOfDay(for: $0.workout?.date ?? $0.completedAt) }
        return grouped.compactMap { day, daySets in
            daySets.compactMap(metric.value).max().map { Point(date: day, value: $0) }
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        List {
            Section(metric.label) {
                if points.count >= 2 {
                    Chart(points) { p in
                        LineMark(x: .value("Date", p.date), y: .value(metric.label, p.value))
                        PointMark(x: .value("Date", p.date), y: .value(metric.label, p.value))
                    }
                    .frame(height: 220)
                    .accessibilityLabel("\(metric.label) over time")
                } else {
                    Text("Do this exercise again to see a chart.")
                }
                if let first = points.first, let last = points.last, points.count >= 2 {
                    let change = last.value - first.value
                    Text(change > 0
                         ? "Up \(Progression.formatWeight(change)) \(metric.unit) since \(first.date.formatted(date: .abbreviated, time: .omitted)). Great progress!"
                         : "Steady since \(first.date.formatted(date: .abbreviated, time: .omitted)). Consistency is what counts.")
                        .font(.headline)
                }
            }
            Section("History") {
                ForEach(Array(points.reversed())) { p in
                    LabeledContent(p.date.formatted(date: .abbreviated, time: .omitted), value: "\(Progression.formatWeight(p.value)) \(metric.unit)")
                }
            }
            if let exercise = ExerciseCatalog.exercise(exerciseID) {
                Section {
                    NavigationLink("How to do \(exercise.name)") { ExerciseDetailView(exercise: exercise) }
                }
            }
        }
        .navigationTitle(name)
    }
}
