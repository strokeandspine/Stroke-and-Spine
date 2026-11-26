import SwiftUI
import SwiftData

struct MoreView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        NavigationStack {
            List {
                Section("Track") {
                    NavigationLink { TrendsView() } label: { Label("Trends", systemImage: "chart.xyaxis.line") }
                    NavigationLink { QuestionnaireListView() } label: { Label("Questionnaires", systemImage: "list.clipboard") }
                    NavigationLink { RedFlagCheckLauncher() } label: { Label("Check warning signs", systemImage: "exclamationmark.shield") }
                }
                Section("Share with your doctor") {
                    NavigationLink { ReportView(profile: profile) } label: { Label("Appointment report (PDF)", systemImage: "doc.richtext") }
                }
                Section("Support") {
                    NavigationLink { CrisisResourcesView() } label: { Label("Crisis support (988)", systemImage: "heart.circle") }
                }
                Section("Premium") {
                    NavigationLink { SubscriptionStatusView() } label: { Label("Subscription", systemImage: "star.circle") }
                }
                Section("Settings") {
                    NavigationLink { ProfileSettingsView(profile: profile) } label: { Label("Profile and health conditions", systemImage: "person.crop.circle") }
                    NavigationLink { DoseLimitsView(profile: profile) } label: { Label("Medicine label limits", systemImage: "pills") }
                    NavigationLink { PrivacySettingsView(profile: profile) } label: { Label("Privacy, reminders and your data", systemImage: "lock") }
                }
                Section("About") {
                    NavigationLink { AboutView() } label: { Label("About and disclaimer", systemImage: "info.circle") }
                }
            }
            .navigationTitle("More")
        }
    }
}

/// Lets the warning-sign check open from a navigation link.
private struct RedFlagCheckLauncher: View {
    @Query(sort: \RedFlagCheck.date, order: .reverse) private var checks: [RedFlagCheck]
    @State private var showing = false

    var body: some View {
        List {
            Section {
                Button("Start a new check") { showing = true }.bold()
            }
            Section("Previous checks") {
                if checks.isEmpty { Text("None yet").foregroundStyle(.secondary) }
                ForEach(checks) { check in
                    HStack {
                        Text(check.date.shortDateTime)
                        Spacer()
                        Text(check.urgency.headline).foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .navigationTitle("Warning signs")
        .sheet(isPresented: $showing) { RedFlagCheckView() }
    }
}

struct ProfileSettingsView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        Form {
            Section("About you") {
                TextField("Name (optional)", text: $profile.preferredName)
                TextField("Goals", text: $profile.goals, axis: .vertical)
            }
            Section {
                ForEach(HealthCondition.allCases) { condition in
                    Toggle(condition.label, isOn: Binding(
                        get: { profile.conditions.contains(condition) },
                        set: { on in
                            var set = profile.conditions
                            if on { set.insert(condition) } else { set.remove(condition) }
                            profile.conditions = set
                        }))
                }
            } header: {
                Text("Health conditions")
            } footer: {
                Text("Used only to show medicine safety warnings.")
            }
        }
        .navigationTitle("Profile")
    }
}

struct PrivacySettingsView: View {
    @Bindable var profile: PatientProfile
    @Environment(\.modelContext) private var context
    @State private var confirmingDelete = false
    @State private var exportURL: URL?
    @State private var reminderTime = Date()

    var body: some View {
        Form {
            Section {
                Toggle("Lock with Face ID or passcode", isOn: $profile.appLockEnabled)
            } footer: {
                Text(AppText.privacy)
            }

            Section("Daily reminder") {
                Toggle("Remind me to check in", isOn: $profile.remindersEnabled)
                if profile.remindersEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            .onChange(of: profile.remindersEnabled) { _, on in updateReminder(on) }
            .onChange(of: reminderTime) { _, time in
                profile.reminderHour = Calendar.current.component(.hour, from: time)
                updateReminder(profile.remindersEnabled)
            }

            Section("Your data") {
                if let exportURL {
                    ShareLink(item: exportURL) { Label("Share export file", systemImage: "square.and.arrow.up") }
                } else {
                    Button("Export all my data (JSON)") { exportURL = try? DataExport.write(context: context) }
                }
                Button("Delete all my data", role: .destructive) { confirmingDelete = true }
            }
        }
        .navigationTitle("Privacy and data")
        .onAppear {
            reminderTime = Calendar.current.date(bySettingHour: profile.reminderHour, minute: 0, second: 0, of: Date()) ?? Date()
        }
        .confirmationDialog("Delete everything?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) { DataExport.deleteAll(context: context) }
        } message: {
            Text("This permanently removes all your check-ins, scores, medicines and history from this iPhone. It can't be undone.")
        }
    }

    private func updateReminder(_ on: Bool) {
        if on {
            Task {
                let ok = await Reminders.schedule(hour: profile.reminderHour)
                if !ok { profile.remindersEnabled = false }
            }
        } else {
            Reminders.cancel()
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section("Disclaimer") { Text(AppText.disclaimer) }
            Section("Privacy") { Text(AppText.privacy) }
            Section("Questionnaires") {
                Text("PHQ-9 and GAD-7 were developed by Drs. Robert L. Spitzer, Janet B.W. Williams, Kurt Kroenke and colleagues, with an educational grant from Pfizer Inc. The Oswestry Disability Index and Insomnia Severity Index are used under licence.")
                    .font(.footnote)
            }
            Section("Sources") {
                ForEach(Sources.all, id: \.self) { Text($0).font(.footnote) }
            }
            Section("Legal and support") {
                Link("Privacy Policy", destination: AppLinks.privacy)
                Link("Terms of Use", destination: AppLinks.terms)
                Link("Apple's Standard EULA", destination: AppLinks.appleEULA)
                Link("Contact support", destination: AppLinks.support)
            }
            Section("Version") {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                Text("Exercise content: \(ExerciseContent.version)").font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

/// Export and delete. Export is a plain JSON file the person can keep or send.
enum DataExport {
    struct Export: Encodable {
        struct CheckIn: Encodable { let date: Date; let backPain, legPain, worstPain, sleepQuality, mood: Int; let painWokeMe, isFlare: Bool; let tags: [String]; let note: String }
        struct Score: Encodable { let date: Date; let instrument: String; let score: Double; let severity: String; let answers: [Int] }
        struct Dose: Encodable { let takenAt: Date; let product: String; let units: Double; let ingredients: [IngredientAmount]; let painBefore: Int? }
        struct History: Encodable { let kind, type: String; let date: Date; let levels: [String]; let side, provider, facility, implants, complications, notes: String; let reliefPercent, reliefWeeks: Int?; let attachmentCount: Int }
        let exportedAt: Date
        let checkIns: [CheckIn]
        let questionnaires: [Score]
        let medicines: [Dose]
        let history: [History]
    }

    static func write(context: ModelContext) throws -> URL {
        let checkIns = try context.fetch(FetchDescriptor<DailyCheckIn>(sortBy: [SortDescriptor(\.date)]))
        let scores = try context.fetch(FetchDescriptor<QuestionnaireResponse>(sortBy: [SortDescriptor(\.date)]))
        let doses = try context.fetch(FetchDescriptor<MedicationDose>(sortBy: [SortDescriptor(\.takenAt)]))
        let history = try context.fetch(FetchDescriptor<SpineHistoryEntry>(sortBy: [SortDescriptor(\.date)]))

        let export = Export(
            exportedAt: Date(),
            checkIns: checkIns.map { Export.CheckIn(date: $0.date, backPain: $0.backPain, legPain: $0.legPain, worstPain: $0.worstPain, sleepQuality: $0.sleepQuality, mood: $0.mood, painWokeMe: $0.painWokeMe, isFlare: $0.isFlare, tags: $0.tags, note: $0.note) },
            questionnaires: scores.map { Export.Score(date: $0.date, instrument: $0.instrumentRaw, score: $0.score, severity: $0.severity, answers: $0.answers) },
            medicines: doses.map { Export.Dose(takenAt: $0.takenAt, product: $0.productName, units: $0.units, ingredients: $0.totalAmounts, painBefore: $0.painBefore) },
            history: history.map { Export.History(kind: $0.kindRaw, type: $0.typeName, date: $0.date, levels: $0.spinalLevels, side: $0.side, provider: $0.provider, facility: $0.facility, implants: $0.implants, complications: $0.complications, notes: $0.notes, reliefPercent: $0.reliefPercent, reliefWeeks: $0.reliefWeeks, attachmentCount: $0.attachments.count) })

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("stroke-and-spine-export.json")
        try encoder.encode(export).write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }

    static func deleteAll(context: ModelContext) {
        try? context.delete(model: DailyCheckIn.self)
        try? context.delete(model: QuestionnaireResponse.self)
        try? context.delete(model: MedicationDose.self)
        try? context.delete(model: HistoryAttachment.self)
        try? context.delete(model: SpineHistoryEntry.self)
        try? context.delete(model: RedFlagCheck.self)
        try? context.delete(model: ExerciseSession.self)
        try? context.delete(model: RehabEnrollment.self)
        try? context.delete(model: PatientProfile.self)
        try? context.save()
    }
}
