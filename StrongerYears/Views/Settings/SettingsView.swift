import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var profile: TrainerProfile
    @Environment(\.modelContext) private var context
    @Query private var workouts: [WorkoutLog]
    @Query private var recovery: [RecoveryLog]
    @State private var confirmingDelete = false

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    TextField("First name", text: $profile.name)
                    Toggle("Larger text", isOn: $profile.largerText)
                }

                Section {
                    ChipPicker(items: Equipment.allCases.filter { !Equipment.always.contains($0) }, label: \.rawValue,
                               selection: Binding(get: { profile.equipment.subtracting(Equipment.always) },
                                                  set: { profile.equipment = $0 }))
                        .padding(.vertical, 6)
                } header: {
                    Text("Equipment I have")
                } footer: {
                    Text("Workouts only use equipment you have. A sturdy chair and your body weight are always included.")
                }

                Section {
                    NavigationLink("Health check (\(profile.healthFlags.count) noted)") {
                        HealthCheckEditor(profile: profile)
                    }
                    if !profile.healthFlags.isEmpty {
                        Toggle("My doctor has said it's OK to start", isOn: $profile.doctorCleared)
                    }
                } header: {
                    Text("Health")
                } footer: {
                    Text("Talk to your doctor again if your health changes, or after any illness, fall or surgery.")
                }

                Section("Your data") {
                    ShareLink(item: exportJSON(), preview: SharePreview("Stronger Years training log")) {
                        Label("Export my training log", systemImage: "square.and.arrow.up")
                    }
                    Button("Delete all my data", role: .destructive) { confirmingDelete = true }
                }

                Section("About") {
                    Text(AppInfo.disclaimer).font(.subheadline)
                    Text("Your information stays on this iPhone. There's no account and nothing is sent anywhere.")
                        .font(.subheadline)
                    Text(ExerciseCatalog.version).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete everything? This can't be undone.", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete all data", role: .destructive) { deleteAll() }
            }
        }
    }

    private func exportJSON() -> String {
        let iso = ISO8601DateFormatter()
        var workoutItems: [[String: Any]] = []
        for w in workouts.sorted(by: { $0.date < $1.date }) {
            var setItems: [[String: Any]] = []
            for s in w.sortedSets {
                var item: [String: Any] = ["exercise": s.exerciseName, "set": s.setNumber, "pain": s.pain]
                item["reps"] = s.reps
                item["seconds"] = s.seconds
                item["weightLb"] = s.weight
                item["effort"] = s.effort
                setItems.append(item)
            }
            let item: [String: Any] = [
                "date": iso.string(from: w.date),
                "title": w.title,
                "bodyParts": w.bodyPartsRaw,
                "minutes": w.durationMinutes,
                "overallEffort": w.overallEffort,
                "feeling": w.feeling,
                "notes": w.notes,
                "sets": setItems,
            ]
            workoutItems.append(item)
        }
        var recoveryItems: [[String: Any]] = []
        for r in recovery.sorted(by: { $0.date < $1.date }) {
            var item: [String: Any] = [
                "date": iso.string(from: r.date),
                "type": r.kindRaw,
                "minutes": r.minutes,
                "feltUnwell": r.feltUnwell,
                "notes": r.notes,
            ]
            item["temperatureF"] = r.temperature
            recoveryItems.append(item)
        }
        let data: [String: Any] = ["exportedAt": iso.string(from: Date()), "workouts": workoutItems, "recovery": recoveryItems]
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]) else { return "{}" }
        return String(decoding: json, as: UTF8.self)
    }

    private func deleteAll() {
        try? context.delete(model: SetLog.self)
        try? context.delete(model: WorkoutLog.self)
        try? context.delete(model: RecoveryLog.self)
        try? context.delete(model: TrainerProfile.self)
        try? context.save()
    }
}

struct HealthCheckEditor: View {
    @Bindable var profile: TrainerProfile

    var body: some View {
        List {
            Section {
                ForEach(HealthCheck.questions) { q in
                    let yes = profile.healthFlags.contains(q.id)
                    Button {
                        if yes { profile.healthFlags.removeAll { $0 == q.id } } else { profile.healthFlags.append(q.id) }
                        if profile.healthFlags.isEmpty { profile.doctorCleared = false }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: yes ? "checkmark.square.fill" : "square").font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(q.text)
                                if yes { Text(q.advice).font(.subheadline).foregroundStyle(.orange) }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text(profile.healthFlags.isEmpty ? HealthCheck.allClearMessage : HealthCheck.seeDoctorMessage)
            }
        }
        .navigationTitle("Health check")
    }
}
