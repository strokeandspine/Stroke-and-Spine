import SwiftUI
import SwiftData

/// A guided session: pain before → each exercise (reps or hold timer) → pain after and difficulty.
struct RehabSessionView: View {
    let program: RehabProgram
    let enrollment: RehabEnrollment

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SpineHistoryEntry.date, order: .reverse) private var history: [SpineHistoryEntry]

    private enum Phase { case before, exercising, after, done }

    @State private var phase: Phase = .before
    @State private var painBefore = 3
    @State private var painAfter = 3
    @State private var difficulty: Difficulty = .aboutRight
    @State private var index = 0
    @State private var completed: [String] = []
    @State private var skipped: [String] = []
    @State private var hurt: [String] = []
    @State private var startedAt = Date()

    private var stage: RehabProgram.Stage { program.stages[min(enrollment.stageIndex, program.stages.count - 1)] }
    private var exercises: [Exercise] { stage.exerciseIDs.compactMap(ExerciseLibrary.exercise) }

    /// A fusion in the last 3 months means some exercises show an extra caution.
    private var recentFusion: Bool {
        let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        return history.contains { $0.kind == .surgery && $0.typeName.localizedCaseInsensitiveContains("fusion") && $0.date >= cutoff }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .before: beforeView
                case .exercising: exerciseView(exercises[index])
                case .after: afterView
                case .done: doneView
                }
            }
            .navigationTitle(stage.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if phase != .done {
                    ToolbarItem(placement: .cancellationAction) { Button("End") { dismiss() } }
                }
            }
        }
    }

    private var beforeView: some View {
        Form {
            Section {
                Text("\(program.name) · \(exercises.count) exercises")
                    .font(.headline)
                ScaleSlider(title: "Back pain right now", value: $painBefore)
            }
            Section("Stop and get advice if") {
                ForEach(ExerciseContent.generalStopIf, id: \.self) { Text($0).font(.subheadline) }
            }
            Section {
                Button("Start") {
                    startedAt = Date()
                    phase = exercises.isEmpty ? .after : .exercising
                }
                .bold()
            }
        }
    }

    private func exerciseView(_ exercise: Exercise) -> some View {
        List {
            Section {
                ProgressView(value: Double(index), total: Double(exercises.count))
                Text("Exercise \(index + 1) of \(exercises.count)").font(.caption).foregroundStyle(.secondary)
                Text(exercise.name).font(.title2.bold())
                ExerciseIllustration(exercise: exercise)
                Text(exercise.dosage.description).font(.headline)
                if let seconds = exercise.dosage.holdSeconds {
                    HoldTimer(seconds: seconds).id(exercise.id)
                } else if let minutes = exercise.dosage.minutes {
                    Text("Aim for about \(minutes) minutes today. Log it when you're done — even a shorter walk counts.")
                        .font(.subheadline)
                }
                if recentFusion && exercise.avoidAfterRecentFusion {
                    Label("You've had a fusion in the last 3 months. Skip this unless your surgeon has said it's OK.",
                          systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange).font(.subheadline)
                }
            }
            ExerciseInstructions(exercise: exercise)
            Section {
                Button { next(exercise, outcome: .done) } label: {
                    Label("Done", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                HStack {
                    Button("Skip") { next(exercise, outcome: .skipped) }
                    Spacer()
                    Button("This hurt") { next(exercise, outcome: .hurt) }.foregroundStyle(.orange)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private enum Outcome { case done, skipped, hurt }

    private func next(_ exercise: Exercise, outcome: Outcome) {
        switch outcome {
        case .done: completed.append(exercise.id)
        case .skipped: skipped.append(exercise.id)
        case .hurt: hurt.append(exercise.id)
        }
        if index < exercises.count - 1 {
            index += 1
        } else {
            painAfter = painBefore
            phase = .after
        }
    }

    private var afterView: some View {
        Form {
            Section {
                ScaleSlider(title: "Back pain now", value: $painAfter)
            }
            Section("How did that feel overall?") {
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            if painAfter - painBefore >= 3 {
                Section {
                    Text("Your pain went up \(painAfter - painBefore) points. That's more than we'd like. Next time try fewer reps or the easier versions. If it hasn't settled by tomorrow, check in with your doctor or physical therapist.")
                        .font(.subheadline)
                }
            }
            Section {
                Button("Save session") { save() }.bold()
            }
        }
    }

    private var doneView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 64)).foregroundStyle(.green)
            Text("Session saved").font(.title.bold())
            Text("\(completed.count) of \(exercises.count) exercises done. Nice work.")
                .foregroundStyle(.secondary)
            Button("Close") { dismiss() }.buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func save() {
        context.insert(ExerciseSession(programID: program.id, stageIndex: enrollment.stageIndex,
                                       completedIDs: completed, skippedIDs: skipped, hurtIDs: hurt,
                                       painBefore: painBefore, painAfter: painAfter, difficulty: difficulty,
                                       durationSeconds: Int(Date().timeIntervalSince(startedAt))))
        try? context.save()
        phase = .done
    }
}

/// Countdown for timed holds.
struct HoldTimer: View {
    let seconds: Int
    @State private var remaining: Int
    @State private var running = false
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(seconds: Int) {
        self.seconds = seconds
        _remaining = State(initialValue: seconds)
    }

    var body: some View {
        HStack {
            Text("\(remaining)s")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            Spacer()
            Button(running ? "Pause" : (remaining == seconds ? "Start hold" : "Resume")) { running.toggle() }
                .buttonStyle(.bordered)
            Button("Reset") { running = false; remaining = seconds }
                .buttonStyle(.borderless)
        }
        .onReceive(tick) { _ in
            guard running else { return }
            if remaining > 1 {
                remaining -= 1
            } else {
                remaining = seconds
                running = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
