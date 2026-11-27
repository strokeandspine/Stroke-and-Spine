import SwiftUI
import SwiftData

struct OnboardingView: View {
    let existingProfile: TrainerProfile?
    @Environment(\.modelContext) private var context

    @State private var step = 0
    @State private var acceptedDisclaimer = false
    @State private var name = ""
    @State private var experience: Experience = .beginner
    @State private var healthYes: Set<String> = []
    @State private var weekdays: Set<Int> = Set(Weekdays.suggested(daysPerWeek: 2))
    @State private var equipment: Set<Equipment> = []

    private let lastStep = 4

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProgressView(value: Double(step), total: Double(lastStep))
                        .accessibilityLabel("Step \(step + 1) of \(lastStep + 1)")
                    switch step {
                    case 0: welcome
                    case 1: experienceStep
                    case 2: healthStep
                    case 3: daysStep
                    default: summaryStep
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) { buttons }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "figure.strengthtraining.functional")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("Welcome to \(AppInfo.name)")
                .font(.largeTitle.bold())
            Text("Strength training made simple and safe for older adults. Build the strength to stay independent, steady on your feet and doing the things you enjoy.")
                .font(.title3)
            Card {
                Label("A plan based on body parts and your schedule", systemImage: "calendar")
                Label("Adjust the length, intensity and amount to suit you", systemImage: "slider.horizontal.3")
                Label("A simple log of every workout", systemImage: "list.bullet.clipboard")
                Label("Guides to warming up, stretching, sauna, cold plunge and avoiding injury", systemImage: "book")
            }
            Card {
                Text("Important").font(.headline)
                Text(AppInfo.disclaimer).font(.subheadline)
                Toggle("I understand", isOn: $acceptedDisclaimer)
                    .font(.headline)
            }
        }
    }

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About you").font(.largeTitle.bold())
            TextField("Your first name (optional)", text: $name)
                .font(.title3)
                .textContentType(.givenName)
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            Text("How much strength training have you done?").font(.title3.bold())
            ForEach(Experience.allCases) { level in
                Button { experience = level } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: experience == level ? "largecircle.fill.circle" : "circle")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(level.rawValue).font(.headline)
                            Text(level.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .background(experience == level ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(experience == level ? Color.accentColor : .clear, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(experience == level ? .isSelected : [])
            }
            Text("You can change this, and fine-tune your settings, at any time.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var healthStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before you start").font(.largeTitle.bold())
            Text("Tap any that apply to you.").font(.title3)
            ForEach(HealthCheck.questions) { q in
                let yes = healthYes.contains(q.id)
                Button {
                    if yes { healthYes.remove(q.id) } else { healthYes.insert(q.id) }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: yes ? "checkmark.square.fill" : "square")
                            .font(.title2)
                        Text(q.text).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .background(yes ? Color.orange.opacity(0.15) : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(yes ? .isSelected : [])
            }
            Card {
                if healthYes.isEmpty {
                    Label(HealthCheck.allClearMessage, systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Label(HealthCheck.seeDoctorMessage, systemImage: "stethoscope")
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var daysStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your week").font(.largeTitle.bold())
            Text("Which days would you like to train? 2–3 days a week, with a rest day between, is ideal.")
                .font(.title3)
            WeekdayPicker(selection: $weekdays)
            if weekdays.count > 4 {
                Label("The app plans up to 4 strength days. Walking, stretching or balance practice are great on other days.", systemImage: "info.circle")
                    .font(.subheadline)
            }
            Text("What equipment do you have?").font(.title3.bold())
            Text("A sturdy chair and your own body weight are all you need to start.")
                .font(.subheadline).foregroundStyle(.secondary)
            ChipPicker(items: Equipment.allCases.filter { !Equipment.always.contains($0) }, label: \.rawValue, selection: $equipment)
        }
    }

    private var summaryStep: some View {
        let settings = experience.defaultSettings
        let days = ScheduleTemplates.schedule(weekdays: chosenWeekdays)
        return VStack(alignment: .leading, spacing: 16) {
            Text("Your starting plan").font(.largeTitle.bold())
            Card {
                Text("Settings for \(experience.rawValue.lowercased())").font(.headline)
                Label("\(settings.duration.title): \(settings.duration.summary)", systemImage: "clock")
                Label("\(settings.intensity.title): \(settings.intensity.summary)", systemImage: "gauge.with.dots.needle.33percent")
                Label("\(settings.volume.title): \(settings.volume.summary)", systemImage: "square.stack.3d.up")
            }
            Card {
                Text("Your week").font(.headline)
                ForEach(days) { day in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(day.weekdayName): \(day.name)").font(.body.weight(.semibold))
                        BodyPartBadges(parts: day.bodyParts)
                    }
                }
            }
            if !healthYes.isEmpty {
                Card {
                    Label("Please check with your doctor before your first workout.", systemImage: "stethoscope")
                        .foregroundStyle(.orange)
                        .font(.headline)
                }
            }
            Text("You can change everything in My plan.").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    /// Up to 4 days, Monday first.
    private var chosenWeekdays: [Int] {
        Array(Weekdays.mondayFirst.filter { weekdays.contains($0) }.prefix(4))
    }

    // MARK: Navigation

    private var canContinue: Bool {
        switch step {
        case 0: return acceptedDisclaimer
        case 3: return !weekdays.isEmpty
        default: return true
        }
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button("Back") { step -= 1 }
                    .buttonStyle(BigButtonStyle(prominent: false))
                    .frame(maxWidth: 140)
            }
            Button(step == lastStep ? "Start" : "Continue") {
                if step == lastStep { finish() } else { step += 1 }
            }
            .buttonStyle(BigButtonStyle())
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.5)
        }
        .padding()
        .background(.bar)
    }

    private func finish() {
        let profile = existingProfile ?? TrainerProfile()
        if existingProfile == nil { context.insert(profile) }
        profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.experience = experience
        profile.settings = experience.defaultSettings
        profile.equipment = equipment
        profile.healthFlags = Array(healthYes).sorted()
        profile.schedule = ScheduleTemplates.schedule(weekdays: chosenWeekdays)
        profile.acceptedDisclaimerAt = Date()
        profile.isOnboarded = true
        try? context.save()
    }
}

/// Seven large toggles, Monday first.
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
            ForEach(Weekdays.mondayFirst, id: \.self) { day in
                let on = selection.contains(day)
                Button {
                    if on { selection.remove(day) } else { selection.insert(day) }
                } label: {
                    Text(Weekdays.shortName(day))
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .foregroundStyle(on ? Color.white : Color.primary)
                        .background(on ? Color.accentColor : Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Weekdays.name(day))
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
    }
}
