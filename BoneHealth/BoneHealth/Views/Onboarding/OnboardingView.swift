import SwiftUI
import SwiftData

struct OnboardingView: View {
    var existingProfile: PatientProfile?

    @Environment(\.modelContext) private var context
    @State private var step = 0
    @State private var name = ""
    @State private var birthYear = Calendar.current.component(.year, from: Date()) - 65
    @State private var sex: Sex = .female
    @State private var postmenopausal = true
    @State private var status: BoneStatus = .notSure
    @State private var metric = false
    @State private var isAdult = false
    @State private var acceptsDisclaimer = false

    private var thisYear: Int { Calendar.current.component(.year, from: Date()) }

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
            Image(systemName: "figure.stand")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text("Welcome to \(AppText.appName)").font(.largeTitle.bold())
            Text("For people with osteoporosis or osteopenia, or at risk of them.").foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 14) {
                Label("Keep your DEXA scans, radiology reports and medical history in one place", systemImage: "folder")
                Label("Track your osteoporosis medicines and when the next dose is due", systemImage: "pills")
                Label("Reach your calcium, vitamin D and magnesium targets", systemImage: "chart.bar")
                Label("Bone-safe exercises, falls records and pain scores", systemImage: "figure.walk")
                Label("Your data stays on your iPhone", systemImage: "lock")
            }
            Spacer()
            Button { step = 1 } label: { Text("Get started").frame(maxWidth: .infinity) }
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
                Toggle("I understand this app does not give medical advice", isOn: $acceptsDisclaimer)
            }
            Section {
                Button("Continue") { step = 2 }.bold().disabled(!(isAdult && acceptsDisclaimer))
            }
        }
        .navigationTitle("Important")
    }

    private var aboutYou: some View {
        Form {
            Section {
                TextField("What should we call you? (optional)", text: $name)
                Picker("Year of birth", selection: $birthYear) {
                    ForEach((thisYear - 105)...(thisYear - 18), id: \.self) { Text(String($0)).tag($0) }
                }
                Picker("Sex", selection: $sex) {
                    ForEach(Sex.allCases) { Text($0.label).tag($0) }
                }
                if sex == .female {
                    Toggle("I've been through menopause", isOn: $postmenopausal)
                }
            } header: {
                Text("About you")
            } footer: {
                Text("Age and sex set your daily calcium, vitamin D and magnesium targets, and whether T-scores or Z-scores apply to your DEXA results.")
            }
            Section("What have you been told about your bones?") {
                Picker("Bone health", selection: $status) {
                    ForEach(BoneStatus.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("Units") {
                Picker("Units", selection: $metric) {
                    Text("US (lb, in)").tag(false)
                    Text("Metric (kg, cm)").tag(true)
                }
                .pickerStyle(.segmented)
            }
            Section {
                Button("Finish") { finish() }.bold()
            }
        }
        .navigationTitle("About you")
    }

    private func finish() {
        let profile = existingProfile ?? PatientProfile()
        profile.preferredName = name.trimmingCharacters(in: .whitespaces)
        profile.birthYear = birthYear
        profile.sex = sex
        profile.isPostmenopausal = sex == .female && postmenopausal
        profile.boneStatus = status
        profile.usesMetricUnits = metric
        profile.acceptedDisclaimerAt = Date()
        profile.confirmedAdultAt = Date()
        if existingProfile == nil { context.insert(profile) }
        try? context.save()
    }
}
