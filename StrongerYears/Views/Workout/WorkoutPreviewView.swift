import SwiftUI
import SwiftData

/// Shows the workout before starting, with today-only adjustments to duration, intensity and volume.
struct WorkoutPreviewView: View {
    @Bindable var profile: TrainerProfile
    let title: String
    let bodyParts: [BodyPart]

    @Query(sort: \SetLog.completedAt, order: .reverse) private var allSets: [SetLog]
    @State private var settings: TrainingSettings? = nil
    @State private var started = false

    private var current: TrainingSettings { settings ?? profile.settings }

    private var plan: PlannedWorkout {
        WorkoutBuilder.build(title: title, bodyParts: bodyParts, experience: profile.experience,
                             settings: current, equipment: profile.equipment, rotation: profile.rotation)
    }

    var body: some View {
        let plan = self.plan
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Card {
                    Text(plan.title).font(.title.bold())
                    BodyPartBadges(parts: plan.bodyParts)
                    Label("About \(plan.estimatedMinutes) minutes", systemImage: "clock").font(.headline)
                    Label("\(plan.warmUpMinutes) min warm-up · \(plan.exercises.count) exercises · \(plan.coolDownMinutes) min cool-down", systemImage: "list.number")
                    Label("Aim for effort \(current.intensity.effortRange.lowerBound)–\(current.intensity.effortRange.upperBound) out of 10", systemImage: "gauge.with.dots.needle.33percent")
                }

                if profile.needsDoctor {
                    Card {
                        Label("Please get the OK from your doctor before your first workout.", systemImage: "stethoscope")
                            .foregroundStyle(.orange)
                    }
                }

                DisclosureGroup {
                    SettingsDials(settings: Binding(get: { current }, set: { settings = $0 }), experience: profile.experience)
                        .padding(.top, 8)
                } label: {
                    Label("Adjust today's workout", systemImage: "slider.horizontal.3").font(.headline)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))

                if !plan.skippedBodyParts.isEmpty {
                    Label("Not enough time for: \(plan.skippedBodyParts.map(\.rawValue).joined(separator: ", ")). Choose a longer duration to include them, or they'll come first next time.", systemImage: "info.circle")
                        .font(.subheadline)
                }

                Text("Exercises").font(.title2.bold())
                ForEach(plan.exercises) { item in
                    NavigationLink {
                        ExerciseDetailView(exercise: item.exercise)
                    } label: {
                        PlannedExerciseRow(item: item, lastTime: ExerciseHistory.lastSession(of: item.exercise.id, in: allSets))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    started = true
                } label: {
                    Label("Start workout", systemImage: "play.fill")
                }
                .buttonStyle(BigButtonStyle())
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your workout")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $started) {
            WorkoutSessionView(profile: profile, plan: plan)
        }
    }
}

struct PlannedExerciseRow: View {
    let item: PlannedExercise
    var lastTime: [SetLog] = []

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.exercise.bodyPart.symbol)
                .font(.title2)
                .frame(width: 40)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.exercise.name).font(.headline)
                Text(item.dose).font(.subheadline)
                if let last = lastTime.first {
                    Text("Last time: \(last.summary)").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

/// The three adjustable dials, with recommendations for the person's experience.
struct SettingsDials: View {
    @Binding var settings: TrainingSettings
    let experience: Experience

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            dial("Duration", symbol: "clock", options: DurationLevel.allCases, selection: $settings.duration,
                 title: \.title, recommended: experience.recommendedDurations, detail: settings.duration.summary)
            dial("Intensity", symbol: "gauge.with.dots.needle.33percent", options: IntensityLevel.allCases, selection: $settings.intensity,
                 title: \.title, recommended: experience.recommendedIntensities,
                 detail: "\(settings.intensity.summary)\n\(settings.intensity.feelsLike)")
            dial("Volume", symbol: "square.stack.3d.up", options: VolumeLevel.allCases, selection: $settings.volume,
                 title: \.title, recommended: experience.recommendedVolumes, detail: settings.volume.summary)

            ForEach(settings.cautions(for: experience), id: \.self) { caution in
                Label(caution, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
        }
    }

    private func dial<T: Hashable & Identifiable>(
        _ name: String, symbol: String, options: [T], selection: Binding<T>,
        title: KeyPath<T, String>, recommended: [T], detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(name, systemImage: symbol).font(.headline)
            Picker(name, selection: selection) {
                ForEach(options) { option in
                    Text(option[keyPath: title]).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
            Text("Recommended for you: \(recommended.map { $0[keyPath: title] }.joined(separator: " or "))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

enum ExerciseHistory {
    /// Sets from the most recent workout that included this exercise. `sets` must be newest first.
    static func lastSession(of exerciseID: String, in sets: [SetLog]) -> [SetLog] {
        guard let latest = sets.first(where: { $0.exerciseID == exerciseID }) else { return [] }
        if let workout = latest.workout {
            return workout.sets.filter { $0.exerciseID == exerciseID }.sorted { $0.setNumber < $1.setNumber }
        }
        return [latest]
    }

    static func lastWeight(of exerciseID: String, in sets: [SetLog]) -> Double? {
        sets.first(where: { $0.exerciseID == exerciseID && ($0.weight ?? 0) > 0 })?.weight
    }
}
