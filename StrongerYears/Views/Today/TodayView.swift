import SwiftUI
import SwiftData

struct TodayView: View {
    @Bindable var profile: TrainerProfile
    @Query(sort: \WorkoutLog.date, order: .reverse) private var workouts: [WorkoutLog]
    @State private var showingRecovery = false

    private var today: ScheduledDay? { profile.scheduledDay(on: Date()) }
    private var doneToday: Bool { workouts.contains { Calendar.current.isDateInToday($0.date) } }

    private var workoutsThisWeek: Int {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return workouts.filter { week.contains($0.date) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Date().dayAndDate).font(.title3).foregroundStyle(.secondary)

                    if profile.needsDoctor {
                        Card {
                            Label("You told us about a health condition. Please check with your doctor before you start, then mark yourself as cleared in Settings.", systemImage: "stethoscope")
                                .foregroundStyle(.orange)
                        }
                    }

                    todayCard
                    weekCard

                    NavigationLink {
                        QuickWorkoutView(profile: profile)
                    } label: {
                        Label("Choose body parts for a different workout", systemImage: "square.grid.2x2")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false))

                    Button {
                        showingRecovery = true
                    } label: {
                        Label("Log sauna, cold plunge, stretching or a walk", systemImage: "plus.circle")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false))

                    Text("Before you start").font(.title2.bold()).padding(.top, 8)
                    ForEach(["warm-up", "avoiding-injury", "cool-down"], id: \.self) { id in
                        if let guide = GuideLibrary.guide(id) {
                            NavigationLink { GuideDetailView(guide: guide) } label: { GuideRow(guide: guide) }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(profile.name.isEmpty ? "Today" : "Hello, \(profile.name)")
            .sheet(isPresented: $showingRecovery) { RecoveryEntryView() }
        }
    }

    @ViewBuilder private var todayCard: some View {
        Card {
            if doneToday {
                Label("Workout done today. Well done!", systemImage: "checkmark.seal.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                Text("Rest, stretch, or go for a gentle walk. Your muscles get stronger while you recover.")
            } else if let today {
                Text("Today's workout").font(.headline).foregroundStyle(.secondary)
                Text(today.name).font(.title.bold())
                BodyPartBadges(parts: today.bodyParts)
                let plan = profile.buildWorkout(for: today)
                Label("About \(plan.estimatedMinutes) minutes · \(plan.exercises.count) exercises", systemImage: "clock")
                NavigationLink {
                    WorkoutPreviewView(profile: profile, title: today.name, bodyParts: today.bodyParts)
                } label: {
                    Label("Start today's workout", systemImage: "play.fill")
                }
                .buttonStyle(BigButtonStyle())
            } else {
                Text("Rest day").font(.title.bold())
                Text("Rest days are part of getting stronger. A walk, some stretching or balance practice are great today.")
                if let next = profile.nextScheduledDay(after: Date()) {
                    Text("Next workout: \(next.day.name), \(next.date.formatted(.dateTime.weekday(.wide))).")
                        .font(.headline)
                }
            }
        }
    }

    private var weekCard: some View {
        Card {
            Text("This week").font(.headline)
            HStack(alignment: .firstTextBaseline) {
                Text("\(workoutsThisWeek)").font(.largeTitle.bold())
                Text("of \(profile.schedule.count) planned workouts").font(.title3)
            }
            if let last = workouts.first {
                Text("Last workout: \(last.title), \(last.date.formatted(.relative(presentation: .named))).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Pick body parts for a one-off workout.
struct QuickWorkoutView: View {
    @Bindable var profile: TrainerProfile
    @State private var parts: Set<BodyPart> = [.legs, .back]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Which body parts would you like to work?").font(.title3)
                ChipPicker(items: BodyPart.allCases, label: \.rawValue, selection: $parts)
                Button("Whole body") { parts = Set(BodyPart.allCases) }
                    .buttonStyle(BigButtonStyle(prominent: false))
                NavigationLink {
                    WorkoutPreviewView(profile: profile, title: "Custom workout", bodyParts: BodyPart.allCases.filter { parts.contains($0) })
                } label: {
                    Text("Build my workout")
                }
                .buttonStyle(BigButtonStyle())
                .disabled(parts.isEmpty)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Choose a workout")
    }
}
