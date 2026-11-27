import SwiftUI
import SwiftData
import UIKit

/// Guided workout: warm-up → exercises (log each set, rest timer) → cool-down → finish and save.
struct WorkoutSessionView: View {
    @Bindable var profile: TrainerProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \SetLog.completedAt, order: .reverse) private var history: [SetLog]

    enum Phase: Hashable { case warmUp, exercise, coolDown, finish }

    struct LoggedSet: Hashable {
        var exerciseIndex: Int
        var setNumber: Int
        var result: SetResult
    }

    @State private var startedAt = Date()
    private let plan: PlannedWorkout
    @State private var exercises: [PlannedExercise]
    @State private var phase: Phase = .warmUp
    @State private var index = 0
    @State private var setNumber = 1
    @State private var logged: [LoggedSet] = []

    // Inputs for the current set
    @State private var weight: Double = 0
    @State private var reps: Int = 10
    @State private var seconds: Int = 20
    @State private var effort: Int = 4
    @State private var pain = false
    @State private var showSteps = false

    // Timers
    @State private var now = Date()
    @State private var restEndsAt: Date? = nil
    @State private var holdStartedAt: Date? = nil

    // Warm-up and cool-down checklists
    @State private var warmUpDone: Set<String> = []
    @State private var stretchesDone: Set<String> = []

    // Finish
    @State private var overallEffort = 5
    @State private var feeling = 4
    @State private var notes = ""
    @State private var confirmingQuit = false
    @State private var showingStopSigns = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(profile: TrainerProfile, plan: PlannedWorkout) {
        _profile = Bindable(profile)
        self.plan = plan
        _exercises = State(initialValue: plan.exercises)
    }

    private var current: PlannedExercise? { exercises.indices.contains(index) ? exercises[index] : nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch phase {
                    case .warmUp: warmUpView
                    case .exercise: exerciseView
                    case .coolDown: coolDownView
                    case .finish: finishView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("End") { confirmingQuit = true }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingStopSigns = true
                    } label: {
                        Label("Feeling unwell", systemImage: "exclamationmark.octagon")
                    }
                    .tint(.red)
                }
            }
            .confirmationDialog("End this workout?", isPresented: $confirmingQuit, titleVisibility: .visible) {
                if !logged.isEmpty {
                    Button("Save what I've done") { phase = .coolDown }
                }
                Button("Discard workout", role: .destructive) { dismiss() }
                Button("Keep going", role: .cancel) {}
            }
            .sheet(isPresented: $showingStopSigns) {
                NavigationStack {
                    ScrollView {
                        StopSignsCard().padding()
                        Text("If you feel unwell but it isn't an emergency, stop for today. Sit down, sip some water, and rest. Let your doctor know if it happens again.")
                            .padding(.horizontal)
                    }
                    .navigationTitle("Feeling unwell?")
                    .toolbar { Button("Close") { showingStopSigns = false } }
                }
            }
            .overlay { if let restEndsAt { restOverlay(endsAt: restEndsAt) } }
            .onReceive(ticker) { tick($0) }
        }
    }

    private var navigationTitle: String {
        switch phase {
        case .warmUp: return "Warm-up"
        case .exercise: return "Exercise \(index + 1) of \(exercises.count)"
        case .coolDown: return "Cool-down"
        case .finish: return "Finished"
        }
    }

    // MARK: Warm-up

    private var warmUpView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Warm up for about \(plan.warmUpMinutes) minutes").font(.title2.bold())
            Text("Gentle movement first. You should be breathing a little faster but able to chat.")
            ForEach(GuideLibrary.warmUpMoves) { move in
                ChecklistRow(title: move.name, detail: move.how, meta: duration(move.seconds), done: warmUpDone.contains(move.name)) {
                    toggle(move.name, in: &warmUpDone)
                }
            }
            Button("Warm-up done — start exercises") {
                phase = .exercise
                prepareInputs()
            }
            .buttonStyle(BigButtonStyle())
        }
    }

    // MARK: Exercise

    @ViewBuilder private var exerciseView: some View {
        if let item = current {
            let exercise = item.exercise
            VStack(alignment: .leading, spacing: 14) {
                Text(exercise.name).font(.largeTitle.bold())
                Text("Set \(setNumber) of \(item.sets) · \(item.dose)").font(.title3)
                Text("Aim for effort \(item.effort.lowerBound)–\(item.effort.upperBound): \(EffortScale.words(item.effort.upperBound).lowercased()).")
                    .foregroundStyle(.secondary)

                DisclosureGroup(isExpanded: $showSteps) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, step in
                            Text("\(i + 1). \(step)")
                        }
                        ForEach(exercise.cautions, id: \.self) { c in
                            Label(c, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                        }
                        if let start = exercise.startingWeight { Label(start, systemImage: "scalemass") }
                    }
                    .padding(.top, 6)
                } label: {
                    Label("How to do it", systemImage: "text.book.closed").font(.headline)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))

                lastTimeCard(for: item)

                Card {
                    if exercise.usesWeight {
                        BigStepper(title: "Weight", value: $weight, step: weightStep(for: exercise), range: 0...500, unit: "lb")
                        Divider()
                    }
                    if exercise.isTimed {
                        holdTimer(target: item.holdSeconds ?? 20)
                        BigIntStepper(title: exercise.perSide ? "Seconds each side" : "Seconds held", value: $seconds, step: 5, range: 0...600)
                    } else {
                        BigIntStepper(title: exercise.perSide ? "Reps each side" : "Reps", value: $reps, range: 0...100)
                    }
                    Divider()
                    EffortPicker(value: $effort, target: item.effort)
                    Toggle(isOn: $pain) {
                        Label("This caused pain", systemImage: "bandage")
                            .font(.headline)
                    }
                    .tint(.red)
                    if pain {
                        Text("Stop this exercise if the pain is sharp. Try the easier version or skip it today.")
                            .font(.subheadline).foregroundStyle(.red)
                    }
                }

                Button(setNumber < item.sets ? "Save set and rest" : "Save set") { saveSet() }
                    .buttonStyle(BigButtonStyle())

                HStack(spacing: 12) {
                    if let easierID = exercise.easierID, let easier = ExerciseCatalog.exercise(easierID) {
                        Button("Make it easier") { swap(to: easier) }
                            .buttonStyle(BigButtonStyle(prominent: false))
                    }
                    Button("Skip exercise") { nextExercise() }
                        .buttonStyle(BigButtonStyle(prominent: false, tint: .secondary))
                }
            }
        } else {
            Text("No exercises in this workout.")
            Button("Go to cool-down") { phase = .coolDown }.buttonStyle(BigButtonStyle())
        }
    }

    @ViewBuilder private func lastTimeCard(for item: PlannedExercise) -> some View {
        let last = ExerciseHistory.lastSession(of: item.exercise.id, in: history)
        if !last.isEmpty {
            let advice = Progression.advice(for: item.exercise, sets: last.map(\.result), targetReps: item.reps,
                                            targetSeconds: item.holdSeconds, targetEffort: item.effort)
            Card {
                Text("Last time").font(.headline)
                ForEach(last) { s in
                    Text("Set \(s.setNumber): \(s.summary)").font(.subheadline)
                }
                Label(advice.message, systemImage: advice.symbol).font(.subheadline)
            }
        }
    }

    private func holdTimer(target: Int) -> some View {
        let elapsed = holdStartedAt.map { Int(now.timeIntervalSince($0)) } ?? 0
        return VStack(spacing: 8) {
            if holdStartedAt != nil {
                Text("\(max(target - elapsed, 0))")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .accessibilityLabel("\(max(target - elapsed, 0)) seconds left")
                Button("Stop timer") {
                    seconds = min(elapsed, 600)
                    holdStartedAt = nil
                }
                .buttonStyle(BigButtonStyle(prominent: false))
            } else {
                Button {
                    now = Date()
                    holdStartedAt = Date()
                } label: {
                    Label("Start \(target)-second timer", systemImage: "timer")
                }
                .buttonStyle(BigButtonStyle(prominent: false))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func restOverlay(endsAt: Date) -> some View {
        let remaining = max(Int(endsAt.timeIntervalSince(now).rounded(.up)), 0)
        return ZStack {
            Color(.systemBackground).opacity(0.97).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Rest").font(.largeTitle.bold())
                Text(duration(remaining))
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .accessibilityLabel("\(remaining) seconds of rest left")
                Text("Breathe slowly. Sip some water. Next: set \(setNumber) of \(current?.exercise.name ?? "").")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                Button("Add 30 seconds") { restEndsAt = endsAt.addingTimeInterval(30) }
                    .buttonStyle(BigButtonStyle(prominent: false))
                Button(remaining == 0 ? "Ready" : "Skip rest") { restEndsAt = nil }
                    .buttonStyle(BigButtonStyle())
            }
            .padding(24)
        }
    }

    // MARK: Cool-down

    private var coolDownView: some View {
        let stretches = GuideLibrary.suggestedStretches(for: plan.bodyParts)
        return VStack(alignment: .leading, spacing: 14) {
            Text("Cool down for about \(plan.coolDownMinutes) minutes").font(.title2.bold())
            Text("Walk slowly for 2–3 minutes until your breathing settles, then stretch. Ease into each stretch — mild tension, never pain.")
            ChecklistRow(title: "Slow walk", detail: "Walk around gently, breathing slowly.", meta: "2–3 min",
                         done: stretchesDone.contains("walk")) { toggle("walk", in: &stretchesDone) }
            ForEach(stretches) { s in
                ChecklistRow(title: s.name, detail: (s.steps + [s.caution].compactMap { $0 }).joined(separator: " "), meta: s.dose,
                             done: stretchesDone.contains(s.id)) { toggle(s.id, in: &stretchesDone) }
            }
            Text("Stand up slowly and pause before walking off.").font(.headline)
            Button("Finish") { phase = .finish }
                .buttonStyle(BigButtonStyle())
        }
    }

    // MARK: Finish

    private var finishView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Well done!", systemImage: "star.fill").font(.largeTitle.bold()).foregroundStyle(Color.accentColor)
            Text("You did \(Set(logged.map(\.exerciseIndex)).count) exercises and \(logged.count) sets in \(minutesSoFar) minutes.")
                .font(.title3)
            Card {
                Text("Overall, how hard was the workout?").font(.headline)
                EffortPicker(value: $overallEffort, target: plan.settings.intensity.effortRange)
            }
            Card {
                Text("How do you feel?").font(.headline)
                HStack {
                    ForEach(1...5, id: \.self) { n in
                        Button { feeling = n } label: {
                            Text(feelingEmoji(n))
                                .font(.system(size: 40))
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(feeling == n ? Color.accentColor.opacity(0.2) : .clear, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(feelingWords(n))
                        .accessibilityAddTraits(feeling == n ? .isSelected : [])
                    }
                }
                Text(feelingWords(feeling)).font(.subheadline).foregroundStyle(.secondary)
            }
            Card {
                Text("Notes").font(.headline)
                TextField("Anything to remember for next time?", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            if logged.contains(where: { $0.result.pain }) {
                Label("You noted pain. If it's sharp, swelling, or still there in a couple of days, check with your doctor or physical therapist.", systemImage: "bandage")
                    .foregroundStyle(.red)
            }
            Button("Save workout") { save() }
                .buttonStyle(BigButtonStyle())
        }
    }

    // MARK: Actions

    private func tick(_ date: Date) {
        now = date
        if let end = restEndsAt, date >= end, date < end.addingTimeInterval(1.5) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        if let start = holdStartedAt, let target = current?.holdSeconds, date.timeIntervalSince(start) >= Double(target) {
            seconds = target
            holdStartedAt = nil
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func prepareInputs() {
        guard let item = current else { return }
        let lastSets = ExerciseHistory.lastSession(of: item.exercise.id, in: history)
        if let lastWeight = ExerciseHistory.lastWeight(of: item.exercise.id, in: history) {
            weight = lastWeight
            // Suggest the next step up if last time earned it.
            let advice = Progression.advice(for: item.exercise, sets: lastSets.map(\.result), targetReps: item.reps,
                                            targetSeconds: item.holdSeconds, targetEffort: item.effort)
            if case .increase = advice { weight += Progression.weightStep(for: item.exercise) }
        } else {
            weight = 0
        }
        reps = item.reps?.lowerBound ?? 10
        seconds = item.holdSeconds ?? 20
        effort = item.effort.lowerBound
        pain = false
        holdStartedAt = nil
        showSteps = lastSets.isEmpty
    }

    private func saveSet() {
        guard let item = current else { return }
        let exercise = item.exercise
        logged.append(LoggedSet(
            exerciseIndex: index,
            setNumber: setNumber,
            result: SetResult(
                reps: exercise.isTimed ? nil : reps,
                seconds: exercise.isTimed ? seconds : nil,
                weight: exercise.usesWeight ? weight : nil,
                effort: effort,
                pain: pain
            )
        ))
        holdStartedAt = nil
        if pain {
            // Don't push on through pain.
            nextExercise()
            return
        }
        if setNumber < item.sets {
            setNumber += 1
            pain = false
            now = Date()
            restEndsAt = Date().addingTimeInterval(TimeInterval(item.restSeconds))
        } else {
            nextExercise()
        }
    }

    private func nextExercise() {
        restEndsAt = nil
        setNumber = 1
        if index + 1 < exercises.count {
            index += 1
            prepareInputs()
            // A short breather between exercises too.
            if !logged.isEmpty {
                now = Date()
                restEndsAt = Date().addingTimeInterval(TimeInterval(min(current?.restSeconds ?? 60, 60)))
            }
        } else {
            phase = .coolDown
        }
    }

    private func swap(to easier: StrengthExercise) {
        exercises[index] = WorkoutBuilder.prescribe(easier, settings: plan.settings)
        setNumber = 1
        logged.removeAll { $0.exerciseIndex == index }
        prepareInputs()
        showSteps = true
    }

    private func save() {
        let workout = WorkoutLog(date: startedAt, title: plan.title, bodyParts: plan.bodyParts, intensity: plan.settings.intensity)
        workout.durationMinutes = minutesSoFar
        workout.overallEffort = overallEffort
        workout.feeling = feeling
        workout.warmedUp = !warmUpDone.isEmpty
        workout.cooledDown = !stretchesDone.isEmpty
        workout.stretched = stretchesDone.contains { $0 != "walk" }
        workout.notes = notes
        context.insert(workout)
        for entry in logged {
            let exercise = exercises[entry.exerciseIndex].exercise
            let set = SetLog(exerciseID: exercise.id, exerciseName: exercise.name, exerciseOrder: entry.exerciseIndex,
                             setNumber: entry.setNumber, reps: entry.result.reps, seconds: entry.result.seconds,
                             weight: entry.result.weight, effort: entry.result.effort, pain: entry.result.pain)
            set.workout = workout
            context.insert(set)
        }
        profile.rotation += 1
        try? context.save()
        dismiss()
    }

    // MARK: Helpers

    private var minutesSoFar: Int { max(1, Int(Date().timeIntervalSince(startedAt) / 60)) }

    private func weightStep(for exercise: StrengthExercise) -> Double {
        exercise.equipment == .machines ? 5 : 1
    }

    private func toggle(_ id: String, in set: inout Set<String>) {
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
    }

    private func duration(_ seconds: Int) -> String {
        seconds >= 60 ? String(format: "%d:%02d", seconds / 60, seconds % 60) : "\(seconds) sec"
    }

    private func feelingEmoji(_ n: Int) -> String { ["😣", "😕", "😐", "🙂", "😄"][n - 1] }

    private func feelingWords(_ n: Int) -> String {
        ["Rough", "Not great", "OK", "Good", "Great"][n - 1]
    }
}

struct ChecklistRow: View {
    let title: String
    let detail: String
    let meta: String
    let done: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(done ? Color.green : Color.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title).font(.headline)
                        Spacer()
                        Text(meta).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Text(detail).font(.subheadline).multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(done ? .isSelected : [])
    }
}
