import SwiftUI
import SwiftData

struct ExerciseHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExerciseLog.date, order: .reverse) private var logs: [ExerciseLog]
    @State private var logging = false
    @State private var loggingExercise: BoneExercise?

    var body: some View {
        NavigationStack {
            List {
                let week = WeeklyExerciseProgress.compute(logs.map(\.record))
                Section {
                    ProgressRow(title: "Weight-bearing aerobic", valueText: "\(week.aerobicMinutes) of \(WeeklyExerciseProgress.aerobicGoal) min",
                                fraction: Double(week.aerobicMinutes) / Double(WeeklyExerciseProgress.aerobicGoal))
                    ProgressRow(title: "Strength", valueText: "\(week.strengthDays) of \(WeeklyExerciseProgress.strengthGoal) days",
                                fraction: Double(week.strengthDays) / Double(WeeklyExerciseProgress.strengthGoal))
                    ProgressRow(title: "Balance", valueText: "\(week.balanceMinutes) of \(WeeklyExerciseProgress.balanceGoal) min",
                                fraction: Double(week.balanceMinutes) / Double(WeeklyExerciseProgress.balanceGoal))
                    ProgressRow(title: "Posture", valueText: "\(week.postureDays) of \(WeeklyExerciseProgress.postureGoal) days",
                                fraction: Double(week.postureDays) / Double(WeeklyExerciseProgress.postureGoal))
                    Button { logging = true } label: { Label("Log exercise", systemImage: "plus.circle.fill") }
                } header: {
                    Text("Last 7 days")
                } footer: {
                    Text("Goals follow the Too Fit To Fracture recommendations for people with osteoporosis.")
                }

                Section("Exercises") {
                    ForEach(ExerciseCategory.allCases) { category in
                        NavigationLink { ExerciseCategoryView(category: category) } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.name)
                                    Text(category.weeklyGoal).font(.caption).foregroundStyle(.secondary)
                                }
                            } icon: { Image(systemName: category.symbol) }
                        }
                    }
                }

                Section("Move safely") {
                    NavigationLink { SafeMovementView() } label: { Label("Movements to avoid or change", systemImage: "exclamationmark.triangle") }
                    NavigationLink { ExerciseBasicsView() } label: { Label("Exercise and your bones", systemImage: "book") }
                }

                Section("History") {
                    if logs.isEmpty { Text("Nothing logged yet.").foregroundStyle(.secondary) }
                    ForEach(logs.prefix(60)) { log in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Image(systemName: log.category.symbol).foregroundStyle(.tint)
                                Text(log.activity).font(.subheadline.bold())
                                Spacer()
                                Text("\(log.minutes) min").font(.subheadline).monospacedDigit()
                            }
                            HStack(spacing: 8) {
                                Text(log.date.shortDate)
                                Text("Effort \(log.effort)/10")
                                if let b = log.painBefore, let a = log.painAfter { Text("Pain \(b)→\(a)") }
                            }
                            .font(.caption).foregroundStyle(.secondary)
                            if !log.note.isEmpty { Text(log.note).font(.caption) }
                        }
                    }
                    .onDelete { offsets in
                        let shown = Array(logs.prefix(60))
                        for i in offsets { context.delete(shown[i]) }
                        try? context.save()
                    }
                }

                Section {
                    Text(ExerciseLibrary.contentVersion).font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Exercise")
            .sheet(isPresented: $logging) { LogExerciseView() }
        }
    }
}

struct ExerciseCategoryView: View {
    let category: ExerciseCategory

    var body: some View {
        List {
            Section {
                Text(category.why).font(.subheadline)
                Label(category.weeklyGoal, systemImage: "target").font(.subheadline)
            }
            Section("Exercises") {
                ForEach(ExerciseLibrary.exercises(in: category)) { exercise in
                    NavigationLink { ExerciseDetailView(exercise: exercise) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name).font(.subheadline.bold())
                            Text(exercise.dose).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
    }
}

struct ExerciseDetailView: View {
    let exercise: BoneExercise
    @State private var logging = false

    var body: some View {
        List {
            Section {
                Text(exercise.summary)
                Label(exercise.dose, systemImage: "repeat").font(.subheadline.bold())
            }
            if let caution = exercise.caution {
                Section { WarningRow(warning: SafetyWarning(id: "caution", severity: .caution, message: caution)) }
            }
            Section("How to do it") {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(i + 1)").font(.subheadline.bold()).foregroundStyle(.tint)
                        Text(step).font(.subheadline)
                    }
                }
            }
            if !exercise.tips.isEmpty {
                Section("Tips") { BulletList(items: exercise.tips) }
            }
            Section("Stop and get advice if you have") {
                BulletList(items: exercise.stopIf + ExerciseLibrary.generalStopSigns, tint: .orange)
            }
            Section {
                Button { logging = true } label: { Label("I did this", systemImage: "checkmark.circle.fill") }.bold()
            }
        }
        .navigationTitle(exercise.name)
        .sheet(isPresented: $logging) { LogExerciseView(preset: exercise) }
    }
}

struct LogExerciseView: View {
    var preset: BoneExercise?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var category: ExerciseCategory = .weightBearing
    @State private var activity = ""
    @State private var selectedIDs: [String] = []
    @State private var minutes = 20
    @State private var effort = 5
    @State private var date = Date()
    @State private var recordPain = false
    @State private var painBefore = 2
    @State private var painAfter = 2
    @State private var note = ""

    private var resolvedActivity: String {
        let trimmed = activity.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        let names = selectedIDs.compactMap { ExerciseLibrary.exercise($0)?.name }
        return names.isEmpty ? category.name : names.joined(separator: ", ")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $category) {
                        ForEach(ExerciseCategory.allCases) { Label($0.name, systemImage: $0.symbol).tag($0) }
                    }
                    TextField("Activity (e.g. walk in the park, tai chi class)", text: $activity)
                    Stepper("\(minutes) minutes", value: $minutes, in: 1...300, step: minutes < 10 ? 1 : 5)
                    DatePicker("When", selection: $date, in: ...Date())
                }
                Section("Exercises from the library (optional)") {
                    TagPicker(options: ExerciseLibrary.exercises(in: category).map(\.id), selection: $selectedIDs,
                              labels: Dictionary(uniqueKeysWithValues: ExerciseLibrary.all.map { ($0.id, $0.name) }))
                }
                Section {
                    ScaleSlider(title: "How hard was it?", value: $effort, lowLabel: "Very easy", highLabel: "Maximum effort")
                } footer: {
                    Text("Aim for about 5–6 for moderate activity: you can talk but not sing.")
                }
                Section {
                    Toggle("Record pain before and after", isOn: $recordPain)
                    if recordPain {
                        ScaleSlider(title: "Pain before", value: $painBefore)
                        ScaleSlider(title: "Pain after", value: $painAfter)
                    }
                }
                if recordPain && painAfter - painBefore >= 3 {
                    Section {
                        WarningRow(warning: SafetyWarning(id: "pain-up", severity: .caution,
                            message: "Your pain went up a lot. Ease off next time, and check with your doctor or physical therapist if it doesn't settle within a day — especially new back pain."))
                    }
                }
                Section("Notes") {
                    TextField("How did it go?", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("Log exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
            .onAppear {
                if let preset {
                    category = preset.category
                    selectedIDs = [preset.id]
                    minutes = preset.category == .weightBearing ? 30 : 10
                }
            }
            .onChange(of: category) { _, newValue in
                selectedIDs.removeAll { ExerciseLibrary.exercise($0)?.category != newValue }
            }
        }
    }

    private func save() {
        let log = ExerciseLog(date: date, category: category, activity: resolvedActivity, minutes: minutes, effort: effort)
        log.exerciseIDs = selectedIDs
        if recordPain {
            log.painBefore = painBefore
            log.painAfter = painAfter
        }
        log.note = note
        context.insert(log)
        try? context.save()
        dismiss()
    }
}

struct SafeMovementView: View {
    var body: some View {
        List {
            Section {
                Text("With osteoporosis, how you move matters as much as how much you move. These movements put extra strain on the spine. You don't have to stop being active — just change how you do things.")
                    .font(.subheadline)
            }
            ForEach(ExerciseLibrary.movementsToAvoid) { item in
                Section(item.title) { Text(item.detail).font(.subheadline) }
            }
            Section("Everyday tips") {
                BulletList(items: [
                    "Use the hip hinge to bend: push your hips back and keep your back straight.",
                    "Carry shopping in two bags, one in each hand, close to your body.",
                    "Get out of bed by rolling onto your side first, then pushing up with your arms.",
                    "Cough or sneeze with a straight back, or put a hand on your thigh for support.",
                    "Ask a physical therapist to tailor a program for you, especially if you've had a spine fracture.",
                ])
            }
        }
        .navigationTitle("Move safely")
    }
}

struct ExerciseBasicsView: View {
    var body: some View {
        List {
            Section("Why exercise helps") {
                Text("Exercise can't replace medicine for osteoporosis, but it slows bone loss, strengthens muscles, improves posture and — most importantly — reduces falls. Fewer falls means fewer broken bones.")
                    .font(.subheadline)
            }
            ForEach(ExerciseCategory.allCases) { c in
                Section(c.name) {
                    Text(c.why).font(.subheadline)
                    Label(c.weeklyGoal, systemImage: "target").font(.caption)
                }
            }
            Section("Getting started") {
                BulletList(items: [
                    "Check with your doctor before starting a new exercise program, especially if you've had a recent fracture, heart problems, or have fallen.",
                    "Start low and go slow. Mild muscle soreness for a day or two is normal; sharp or lasting pain is not.",
                    "Exercise near something sturdy to hold, and wear supportive shoes.",
                    "Physical therapists can design a safe program — ask your doctor for a referral.",
                ])
            }
        }
        .navigationTitle("Exercise and bones")
    }
}
