import SwiftUI
import SwiftData

struct OnboardingView: View {
    var existingProfile: PatientProfile?

    @Environment(\.modelContext) private var context
    @State private var step = 0
    @State private var name = ""
    @State private var knowsStart = false
    @State private var painStarted = Date()
    @State private var goals = ""
    @State private var conditions: Set<HealthCondition> = []
    @State private var isAdult = false
    @State private var acceptsDisclaimer = false

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case 0: welcome
                case 1: disclaimer
                default: aboutYou
                }
            }
            .animation(.default, value: step)
        }
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text("Welcome to Stroke & Spine").font(.largeTitle.bold())
            VStack(alignment: .leading, spacing: 14) {
                Label("Track pain, sleep and mood in under 30 seconds a day", systemImage: "checkmark.circle")
                Label("Use the same questionnaires spine doctors use", systemImage: "list.clipboard")
                Label("Keep over-the-counter medicines within label limits", systemImage: "pills")
                Label("Keep a record of your surgeries and procedures", systemImage: "cross.case")
                Label("Your data stays on your iPhone", systemImage: "lock")
            }
            .font(.body)
            Spacer()
            Button { step = 1 } label: {
                Text("Get started").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
    }

    private var disclaimer: some View {
        Form {
            Section("Before you start") {
                Text(AppText.disclaimer)
                Text(AppText.privacy).foregroundStyle(.secondary)
            }
            Section {
                Toggle("I am 18 or older", isOn: $isAdult)
                Toggle("I understand this app does not give medical advice and is not for emergencies", isOn: $acceptsDisclaimer)
            }
            Section {
                Button("Continue") { step = 2 }
                    .disabled(!(isAdult && acceptsDisclaimer))
            }
        }
        .navigationTitle("Important")
    }

    private var aboutYou: some View {
        Form {
            Section("About you") {
                TextField("What should we call you? (optional)", text: $name)
                Toggle("I know roughly when my back pain started", isOn: $knowsStart)
                if knowsStart {
                    DatePicker("Pain started", selection: $painStarted, in: ...Date(), displayedComponents: .date)
                }
                TextField("A goal, e.g. \"walk 30 minutes\" (optional)", text: $goals, axis: .vertical)
            }
            Section {
                ForEach(HealthCondition.allCases) { condition in
                    Toggle(condition.label, isOn: Binding(
                        get: { conditions.contains(condition) },
                        set: { if $0 { conditions.insert(condition) } else { conditions.remove(condition) } }))
                }
            } header: {
                Text("Medicine safety")
            } footer: {
                Text("These help the app show the right warnings for over-the-counter pain relievers. You can change them later in More → Settings.")
            }
            Section {
                Button("Finish") { finish() }
                    .bold()
            }
        }
        .navigationTitle("About you")
    }

    private func finish() {
        let profile = existingProfile ?? PatientProfile()
        profile.preferredName = name.trimmingCharacters(in: .whitespaces)
        profile.painStartedOn = knowsStart ? painStarted : nil
        profile.goals = goals
        profile.conditions = conditions
        profile.confirmedAdultAt = Date()
        profile.acceptedDisclaimerAt = Date()
        if existingProfile == nil { context.insert(profile) }
        try? context.save()
    }
}
