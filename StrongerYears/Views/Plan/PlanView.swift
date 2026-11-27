import SwiftUI
import SwiftData

struct PlanView: View {
    @Bindable var profile: TrainerProfile
    @State private var editingDays = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly schedule").font(.title2.bold())
                    Text("Each day works different body parts so your muscles get time to recover.")
                        .foregroundStyle(.secondary)

                    ForEach(Weekdays.mondayFirst, id: \.self) { weekday in
                        if let day = profile.schedule.first(where: { $0.weekday == weekday }) {
                            NavigationLink {
                                DayEditorView(profile: profile, weekday: weekday)
                            } label: {
                                ScheduleRow(weekday: weekday, day: day)
                            }
                            .buttonStyle(.plain)
                        } else {
                            ScheduleRow(weekday: weekday, day: nil)
                        }
                    }

                    ForEach(ScheduleTemplates.restWarnings(profile.schedule), id: \.self) { warning in
                        Label(warning, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                    let missing = ScheduleTemplates.missingBodyParts(profile.schedule)
                    if !missing.isEmpty && !profile.schedule.isEmpty {
                        Label("Not in your week: \(missing.map(\.rawValue).joined(separator: ", ")). Tap a day to add them.", systemImage: "info.circle")
                    }

                    Button {
                        editingDays = true
                    } label: {
                        Label("Change training days", systemImage: "calendar.badge.clock")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false))

                    Text("Training level").font(.title2.bold()).padding(.top, 8)
                    Card {
                        Picker("Experience", selection: $profile.experience) {
                            ForEach(Experience.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .font(.headline)
                        Text(profile.experience.detail).font(.subheadline).foregroundStyle(.secondary)
                        Button("Use the recommended settings for my experience") {
                            profile.settings = profile.experience.defaultSettings
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                    Card {
                        SettingsDials(settings: $profile.settings, experience: profile.experience)
                    }
                    Card {
                        Label("Change one thing at a time", systemImage: "lightbulb")
                            .font(.headline)
                        Text("When a workout feels easy for 2 sessions in a row, increase just one of these: duration, intensity or volume. Stay there for 2–3 weeks before changing anything else.")
                            .font(.subheadline)
                    }

                    NavigationLink {
                        ExerciseLibraryView()
                    } label: {
                        Label("Browse all exercises", systemImage: "books.vertical")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My plan")
            .sheet(isPresented: $editingDays) { TrainingDaysEditor(profile: profile) }
        }
    }
}

struct ScheduleRow: View {
    let weekday: Int
    let day: ScheduledDay?

    private var isToday: Bool { Calendar.current.component(.weekday, from: Date()) == weekday }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(Weekdays.shortName(weekday))
                .font(.headline)
                .frame(width: 56, height: 44)
                .foregroundStyle(isToday ? Color.white : Color.primary)
                .background(isToday ? Color.accentColor : Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                if let day {
                    Text(day.name).font(.headline)
                    BodyPartBadges(parts: day.bodyParts)
                } else {
                    Text("Rest day").font(.headline).foregroundStyle(.secondary)
                    Text("Walk, stretch or practice balance").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            if day != nil { Image(systemName: "chevron.right").foregroundStyle(.tertiary) }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(day != nil ? .isButton : [])
    }
}

/// Edit which body parts are trained on one day.
struct DayEditorView: View {
    @Bindable var profile: TrainerProfile
    let weekday: Int
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var parts: Set<BodyPart> = []
    @State private var loaded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Workout name", text: $name)
                    .font(.title3)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                Text("Body parts").font(.title3.bold())
                ChipPicker(items: BodyPart.allCases, label: \.rawValue, selection: $parts)
                ForEach(BodyPart.allCases.filter { parts.contains($0) }) { part in
                    Label("\(part.rawValue): \(part.whyItMatters)", systemImage: part.symbol)
                        .font(.subheadline)
                }
                let preview = previewDays
                ForEach(ScheduleTemplates.restWarnings(preview), id: \.self) { w in
                    Label(w, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                }
                Button("Save") { save() }
                    .buttonStyle(BigButtonStyle())
                    .disabled(parts.isEmpty)
                Button("Make this a rest day", role: .destructive) {
                    profile.schedule.removeAll { $0.weekday == weekday }
                    dismiss()
                }
                .buttonStyle(BigButtonStyle(prominent: false, tint: .red))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(Weekdays.name(weekday))
        .onAppear {
            guard !loaded, let day = profile.schedule.first(where: { $0.weekday == weekday }) else { return }
            name = day.name
            parts = Set(day.bodyParts)
            loaded = true
        }
    }

    private var edited: ScheduledDay {
        ScheduledDay(weekday: weekday,
                     name: name.isEmpty ? "Workout" : name,
                     bodyParts: BodyPart.allCases.filter { parts.contains($0) })
    }

    private var previewDays: [ScheduledDay] {
        profile.schedule.filter { $0.weekday != weekday } + [edited]
    }

    private func save() {
        profile.schedule = previewDays
        dismiss()
    }
}

/// Pick training days; rebuilds the schedule from the recommended split.
struct TrainingDaysEditor: View {
    @Bindable var profile: TrainerProfile
    @Environment(\.dismiss) private var dismiss
    @State private var weekdays: Set<Int> = []

    private var chosen: [Int] { Array(Weekdays.mondayFirst.filter { weekdays.contains($0) }.prefix(4)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose up to 4 days. 2–3 days a week with a rest day between is ideal.").font(.title3)
                    WeekdayPicker(selection: $weekdays)
                    Text("Your new week").font(.headline)
                    ForEach(ScheduleTemplates.schedule(weekdays: chosen)) { day in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(day.weekdayName): \(day.name)").font(.body.weight(.semibold))
                            BodyPartBadges(parts: day.bodyParts)
                        }
                    }
                    ForEach(ScheduleTemplates.restWarnings(ScheduleTemplates.schedule(weekdays: chosen)), id: \.self) { w in
                        Label(w, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    }
                    if weekdays.count > 4 {
                        Label("Only the first 4 days will be used.", systemImage: "info.circle")
                    }
                    Text("This replaces any changes you've made to individual days.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Button("Save schedule") {
                        profile.schedule = ScheduleTemplates.schedule(weekdays: chosen)
                        dismiss()
                    }
                    .buttonStyle(BigButtonStyle())
                    .disabled(weekdays.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Training days")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .onAppear { weekdays = Set(profile.schedule.map(\.weekday)) }
        }
    }
}
