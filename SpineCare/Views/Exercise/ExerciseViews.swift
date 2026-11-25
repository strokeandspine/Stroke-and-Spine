import SwiftUI
import SwiftData

struct ExerciseHomeView: View {
    @Environment(Store.self) private var store
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<RehabEnrollment> { $0.isActive }, sort: \RehabEnrollment.startedAt, order: .reverse)
    private var enrollments: [RehabEnrollment]
    @Query(sort: \ExerciseSession.date, order: .reverse) private var sessions: [ExerciseSession]

    @State private var showingSession = false

    private var enrollment: RehabEnrollment? { enrollments.first }

    var body: some View {
        NavigationStack {
            List {
                if let enrollment, let program = enrollment.program {
                    currentProgramSection(enrollment, program)
                }

                Section {
                    ForEach(RehabPrograms.all) { program in
                        if PremiumFeature.program(program).isAvailable(isPremium: store.isPremium) {
                            NavigationLink { ProgramDetailView(program: program) } label: { ProgramRow(program: program) }
                        } else {
                            PremiumLockedRow(title: program.name)
                        }
                    }
                } header: {
                    Text(enrollment == nil ? "Choose a program" : "All programs")
                }

                Section {
                    NavigationLink { ExerciseLibraryView() } label: { Label("Exercise library", systemImage: "books.vertical") }
                    NavigationLink { PainGuideView() } label: { Label("How much pain is OK?", systemImage: "light.beacon.min") }
                }

                Section {
                    Text("Exercise content: \(ExerciseContent.version)").font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Exercise")
            .fullScreenCover(isPresented: $showingSession) {
                if let enrollment, let program = enrollment.program {
                    RehabSessionView(program: program, enrollment: enrollment)
                }
            }
        }
    }

    @ViewBuilder
    private func currentProgramSection(_ enrollment: RehabEnrollment, _ program: RehabProgram) -> some View {
        let stageIndex = min(enrollment.stageIndex, program.stages.count - 1)
        let stage = program.stages[stageIndex]
        let programSessions = sessions.filter { $0.programID == program.id }
        let thisWeek = programSessions.filter { $0.date > Calendar.current.date(byAdding: .day, value: -7, to: Date())! }.count
        let advice = RehabProgression.advice(program: program, stageIndex: stageIndex, sessions: programSessions.map(\.summary))

        Section("Your program") {
            VStack(alignment: .leading, spacing: 6) {
                Text(program.name).font(.title3.bold())
                Text("\(stage.name): \(stage.goal)").foregroundStyle(.secondary)
                ProgressView(value: Double(min(thisWeek, program.sessionsPerWeek)), total: Double(program.sessionsPerWeek)) {
                    Text("\(thisWeek) of \(program.sessionsPerWeek) sessions this week").font(.caption)
                }
            }
            .padding(.vertical, 4)

            Button { showingSession = true } label: {
                Label("Start today's session", systemImage: "play.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if !programSessions.isEmpty {
                adviceRow(advice, enrollment: enrollment)
            }
        }
    }

    @ViewBuilder
    private func adviceRow(_ advice: ProgressionAdvice, enrollment: RehabEnrollment) -> some View {
        switch advice {
        case .keepGoing:
            Label(advice.message, systemImage: "hand.thumbsup").font(.subheadline)
        case .stepBack(_, let easier):
            VStack(alignment: .leading, spacing: 4) {
                Label(advice.message, systemImage: "arrow.uturn.down").font(.subheadline).foregroundStyle(.orange)
                ForEach(easier.keys.sorted(), id: \.self) { key in
                    if let from = ExerciseLibrary.exercise(key), let toID = easier[key], let to = ExerciseLibrary.exercise(toID) {
                        Text("Instead of \(from.name), try \(to.name).").font(.caption)
                    }
                }
            }
        case .readyToProgress(let next):
            VStack(alignment: .leading, spacing: 8) {
                Label(advice.message, systemImage: "arrow.up.forward.circle").font(.subheadline).foregroundStyle(.green)
                Button("Move to the next stage") {
                    enrollment.stageIndex = next
                    try? context.save()
                }
            }
        case .programComplete:
            Label(advice.message, systemImage: "star.fill").font(.subheadline).foregroundStyle(.green)
        }
    }
}

struct ProgramRow: View {
    let program: RehabProgram

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(program.name).font(.headline)
            Text(program.summary).font(.subheadline).foregroundStyle(.secondary)
            Text("\(program.stages.count) stage\(program.stages.count == 1 ? "" : "s") · \(program.sessionsPerWeek)× per week")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct ProgramDetailView: View {
    let program: RehabProgram

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<RehabEnrollment> { $0.isActive }) private var active: [RehabEnrollment]
    @State private var surgeonCleared = false

    private var isCurrent: Bool { active.contains { $0.programID == program.id } }

    var body: some View {
        List {
            Section {
                Text(program.summary)
                LabeledContent("Who it's for") { Text(program.whoItsFor).multilineTextAlignment(.trailing) }
                LabeledContent("How often", value: "\(program.sessionsPerWeek) times a week")
            }
            ForEach(Array(program.stages.enumerated()), id: \.offset) { _, stage in
                Section("\(stage.name) — \(stage.goal)") {
                    ForEach(stage.exerciseIDs, id: \.self) { id in
                        if let exercise = ExerciseLibrary.exercise(id) {
                            NavigationLink { ExerciseDetailView(exercise: exercise) } label: { ExerciseRow(exercise: exercise) }
                        }
                    }
                }
            }
            Section {
                if program.requiresSurgeonClearance && !isCurrent {
                    Toggle("My surgeon has said I can start gentle exercise", isOn: $surgeonCleared)
                }
                if isCurrent {
                    Label("This is your current program", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                } else {
                    Button("Start this program") { start() }
                        .bold()
                        .disabled(program.requiresSurgeonClearance && !surgeonCleared)
                }
            } footer: {
                Text("Check with your doctor or physical therapist before starting a new exercise program, especially after surgery or if your pain is severe.")
            }
        }
        .navigationTitle(program.name)
    }

    private func start() {
        for enrollment in active { enrollment.isActive = false }
        let enrollment = RehabEnrollment(programID: program.id)
        if program.requiresSurgeonClearance { enrollment.surgeonClearanceConfirmedAt = Date() }
        context.insert(enrollment)
        try? context.save()
        dismiss()
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.category.symbol).foregroundStyle(.tint).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                Text(exercise.dosage.description).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct ExerciseLibraryView: View {
    @Environment(Store.self) private var store

    var body: some View {
        List {
            ForEach(Exercise.Category.allCases) { category in
                let items = ExerciseLibrary.all.filter { $0.category == category }
                if !items.isEmpty {
                    Section(category.rawValue) {
                        ForEach(items) { exercise in
                            if PremiumFeature.exercise(exercise).isAvailable(isPremium: store.isPremium) {
                                NavigationLink { ExerciseDetailView(exercise: exercise) } label: { ExerciseRow(exercise: exercise) }
                            } else {
                                PremiumLockedRow(title: exercise.name)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise library")
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        List {
            Section {
                ExerciseIllustration(exercise: exercise)
                Text(exercise.purpose)
                LabeledContent("Position", value: exercise.position.rawValue)
                LabeledContent("How much", value: exercise.dosage.description)
            }
            ExerciseInstructions(exercise: exercise)
        }
        .navigationTitle(exercise.name)
    }
}

/// Placeholder until exercise videos are filmed. Swap for a VideoPlayer when they exist.
struct ExerciseIllustration: View {
    let exercise: Exercise

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(Color.accentColor.opacity(0.12))
            VStack(spacing: 6) {
                Image(systemName: exercise.category.symbol).font(.system(size: 44)).foregroundStyle(.tint)
                Text("Video coming soon").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(height: 160)
        .accessibilityHidden(true)
    }
}

struct ExerciseInstructions: View {
    let exercise: Exercise

    var body: some View {
        Section("How to do it") {
            ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(i + 1)").font(.headline).foregroundStyle(.tint).frame(width: 20)
                    Text(step)
                }
            }
        }
        if !exercise.cues.isEmpty {
            Section("Tips") { ForEach(exercise.cues, id: \.self) { Label($0, systemImage: "checkmark").font(.subheadline) } }
        }
        if !exercise.mistakes.isEmpty {
            Section("Avoid") { ForEach(exercise.mistakes, id: \.self) { Label($0, systemImage: "xmark").font(.subheadline) } }
        }
        Section("Stop if") {
            ForEach(exercise.stopIf + ExerciseContent.generalStopIf, id: \.self) {
                Label($0, systemImage: "exclamationmark.triangle").font(.subheadline).foregroundStyle(.orange)
            }
        }
        if let easier = exercise.easierID.flatMap(ExerciseLibrary.exercise) {
            Section { LabeledContent("Easier version", value: easier.name) }
        }
        if exercise.avoidAfterRecentFusion {
            Section {
                Text("If you've had a spinal fusion in the last 3 months, skip this unless your surgeon has said it's OK.")
                    .font(.subheadline)
            }
        }
    }
}

struct PainGuideView: View {
    var body: some View {
        List {
            Section {
                Text("Some discomfort while exercising is normal and usually safe. Back pain often improves with gradual, regular movement — even when it's a bit sore at first.")
            }
            Section("The traffic-light guide") {
                ForEach(ExerciseContent.painGuide, id: \.self) { Text($0) }
            }
            Section("Stop and get advice if") {
                ForEach(ExerciseContent.generalStopIf, id: \.self) { Label($0, systemImage: "exclamationmark.triangle") }
            }
        }
        .navigationTitle("How much pain is OK?")
    }
}
