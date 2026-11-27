import SwiftUI

struct ExerciseLibraryView: View {
    var body: some View {
        List {
            ForEach(BodyPart.allCases) { part in
                Section {
                    ForEach(ExerciseCatalog.exercises(for: part)) { e in
                        NavigationLink {
                            ExerciseDetailView(exercise: e)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(e.name).font(.headline)
                                Text("\(e.difficulty.rawValue) · \(e.equipment.rawValue)")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                } header: {
                    Label(part.rawValue, systemImage: part.symbol).font(.headline)
                } footer: {
                    Text(part.whyItMatters)
                }
            }
            Section {
                Text(ExerciseCatalog.version).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Exercises")
    }
}

struct ExerciseDetailView: View {
    let exercise: StrengthExercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(exercise.bodyPart.rawValue, systemImage: exercise.bodyPart.symbol)
                    .font(.headline).foregroundStyle(Color.accentColor)
                Text(exercise.summary).font(.title3)
                HStack {
                    Label(exercise.difficulty.rawValue, systemImage: "chart.bar")
                    Spacer()
                    Label(exercise.equipment.rawValue, systemImage: "wrench.and.screwdriver")
                }
                .font(.subheadline)

                Card {
                    Text("How to do it").font(.headline)
                    ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(i + 1)")
                                .font(.headline)
                                .frame(width: 32, height: 32)
                                .background(Color.accentColor.opacity(0.15), in: Circle())
                            Text(step)
                        }
                    }
                    if exercise.perSide { Label("Do both sides.", systemImage: "arrow.left.and.right") }
                    if let hold = exercise.holdSeconds { Label("Hold for about \(hold) seconds to start.", systemImage: "timer") }
                    if let start = exercise.startingWeight { Label(start, systemImage: "scalemass") }
                }

                Card {
                    Text("Tips").font(.headline)
                    ForEach(exercise.tips, id: \.self) { Label($0, systemImage: "lightbulb") }
                    Label("Breathe out as you lift or push. Never hold your breath.", systemImage: "wind")
                }

                if !exercise.cautions.isEmpty {
                    Card {
                        Text("Take care").font(.headline).foregroundStyle(.orange)
                        ForEach(exercise.cautions, id: \.self) { Label($0, systemImage: "exclamationmark.triangle.fill") }
                    }
                }

                if exercise.easierID != nil || exercise.harderID != nil {
                    Card {
                        Text("Other versions").font(.headline)
                        if let id = exercise.easierID, let e = ExerciseCatalog.exercise(id) {
                            NavigationLink { ExerciseDetailView(exercise: e) } label: { Label("Easier: \(e.name)", systemImage: "arrow.down.circle") }
                        }
                        if let id = exercise.harderID, let e = ExerciseCatalog.exercise(id) {
                            NavigationLink { ExerciseDetailView(exercise: e) } label: { Label("Harder: \(e.name)", systemImage: "arrow.up.circle") }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name)
    }
}
