import SwiftUI
import SwiftData

struct MoreView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        NavigationStack {
            List {
                Section("Track") {
                    NavigationLink { PainHomeView(profile: profile) } label: { Label("Pain scores", systemImage: "bolt.heart") }
                    NavigationLink { FallsHomeView(profile: profile) } label: { Label("Falls", systemImage: "figure.fall") }
                    NavigationLink { SupplementHistoryView(profile: profile) } label: { Label("Supplements", systemImage: "chart.bar") }
                }
                Section("Share with your doctor") {
                    NavigationLink { ReportView(profile: profile) } label: { Label("Bone health summary (PDF)", systemImage: "doc.richtext") }
                }
                Section("Learn") {
                    NavigationLink { DexaExplainerView() } label: { Label("Understanding DEXA", systemImage: "figure.stand") }
                    NavigationLink { DrugLibraryView(profile: profile) } label: { Label("Osteoporosis medicines", systemImage: "books.vertical") }
                    NavigationLink { SupplementGuideView(profile: profile) } label: { Label("Calcium, vitamin D and magnesium", systemImage: "leaf") }
                    NavigationLink { SafeMovementView() } label: { Label("Moving safely", systemImage: "figure.walk") }
                    NavigationLink { AfterFallView() } label: { Label("After a fall", systemImage: "cross.case") }
                }
                Section("Settings") {
                    NavigationLink { ProfileSettingsView(profile: profile) } label: { Label("Profile", systemImage: "person.crop.circle") }
                    NavigationLink { SupplementTargetsView(profile: profile) } label: { Label("Supplement targets", systemImage: "target") }
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

struct ProfileSettingsView: View {
    @Bindable var profile: PatientProfile
    private var thisYear: Int { Calendar.current.component(.year, from: Date()) }

    var body: some View {
        Form {
            Section("About you") {
                TextField("Name (optional)", text: $profile.preferredName)
                Picker("Year of birth", selection: Binding(get: { profile.birthYear ?? thisYear - 65 }, set: { profile.birthYear = $0 })) {
                    ForEach((thisYear - 105)...(thisYear - 18), id: \.self) { Text(String($0)).tag($0) }
                }
                Picker("Sex", selection: Binding(get: { profile.sex }, set: { profile.sex = $0 })) {
                    ForEach(Sex.allCases) { Text($0.label).tag($0) }
                }
                if profile.sex == .female {
                    Toggle("I've been through menopause", isOn: $profile.isPostmenopausal)
                }
            }
            Section("Bone health") {
                Picker("Diagnosis", selection: Binding(get: { profile.boneStatus }, set: { profile.boneStatus = $0 })) {
                    ForEach(BoneStatus.allCases) { Text($0.label).tag($0) }
                }
                NavigationLink("Risk factors and FRAX") { RiskFactorsView(profile: profile) }
                NavigationLink("Tallest adult height") { HeightSettingsView(profile: profile) }
            }
            Section("Units") {
                Picker("Units", selection: $profile.usesMetricUnits) {
                    Text("US (lb, in)").tag(false)
                    Text("Metric (kg, cm)").tag(true)
                }
                .pickerStyle(.segmented)
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

            Section {
                Toggle("Daily supplement reminder", isOn: $profile.supplementRemindersEnabled)
                if profile.supplementRemindersEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Reminders")
            } footer: {
                Text("Reminders for each osteoporosis medicine are set on that medicine's page.")
            }
            .onChange(of: profile.supplementRemindersEnabled) { _, on in update(on) }
            .onChange(of: reminderTime) { _, time in
                profile.supplementReminderHour = Calendar.current.component(.hour, from: time)
                update(profile.supplementRemindersEnabled)
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
            reminderTime = Calendar.current.date(bySettingHour: profile.supplementReminderHour, minute: 0, second: 0, of: Date()) ?? Date()
        }
        .confirmationDialog("Delete everything?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) { DataExport.deleteAll(context: context) }
        } message: {
            Text("This permanently removes all your records, scans, medicines, supplements, exercise, falls and pain scores from this iPhone. It can't be undone.")
        }
    }

    private func update(_ on: Bool) {
        if on {
            Task {
                let ok = await Reminders.scheduleSupplements(hour: profile.supplementReminderHour)
                if !ok { profile.supplementRemindersEnabled = false }
            }
        } else {
            Reminders.cancelSupplements()
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section("Disclaimer") { Text(AppText.disclaimer) }
            Section("Privacy") { Text(AppText.privacy) }
            Section("Questionnaires") {
                Text("The Stay Independent fall risk checklist is from the CDC STEADI initiative and is in the public domain. The PEG pain scale (Krebs et al., 2009) is in the public domain.")
                    .font(.footnote)
            }
            Section("Content status") {
                Text(OsteoDrugLibrary.contentVersion).font(.footnote)
                Text(ExerciseLibrary.contentVersion).font(.footnote)
            }
            Section("Sources") {
                ForEach(Sources.all, id: \.self) { Text($0).font(.footnote) }
            }
            Section("Legal and support") {
                Link("Privacy Policy", destination: AppLinks.privacy)
                Link("Terms of Use", destination: AppLinks.terms)
                Link("Contact support", destination: AppLinks.support)
            }
            Section("Version") {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
            }
        }
        .navigationTitle("About")
    }
}

/// Export and delete. Export is a plain JSON file the person can keep or send.
enum DataExport {
    struct Export: Encodable {
        struct Profile: Encodable { let birthYear: Int?; let sex, boneStatus: String; let isPostmenopausal: Bool; let riskFactors: [String]; let tallestAdultHeightCm, fraxMajor, fraxHip: Double? }
        struct Vital: Encodable { let date: Date; let systolic, diastolic, heartRate: Int?; let weightKg, heightCm: Double?; let note: String }
        struct History: Encodable { let kind, title: String; let date: Date?; let ongoing: Bool; let details: String }
        struct Fracture: Encodable { let date: Date; let site, cause, treatment, notes: String }
        struct Imaging: Encodable { let kind: String; let date: Date; let bodyPart, facility, orderedBy, machine, impression, notes: String; let dexa: [DexaSiteResult]; let tbs, fraxMajor, fraxHip: Double?; let photoCount: Int }
        struct Lab: Encodable { let date: Date; let test: String; let value: Double; let unit, note: String }
        struct Intake: Encodable { let takenAt: Date; let product, source: String; let servings: Double; let amounts: [NutrientAmount] }
        struct Medicine: Encodable { let drug, frequency: String; let startedOn: Date; let stoppedOn: Date?; let prescriber, notes: String; let doses: [Date] }
        struct Exercise: Encodable { let date: Date; let category, activity: String; let minutes, effort: Int; let painBefore, painAfter: Int?; let note: String }
        struct Fall: Encodable { let date: Date; let nearMiss: Bool; let location, activity: String; let causes, injuries: [String]; let hitHead, gotUpAlone, longLie: Bool; let care, notes: String }
        struct Screen: Encodable { let date: Date; let score: Int; let yesItems: [Int] }
        struct Pain: Encodable { let date: Date; let score: Int; let locations, qualities, helped: [String]; let newAndSudden, afterFall: Bool; let peg: Double?; let note: String }

        let exportedAt: Date
        let profile: Profile?
        let vitals: [Vital]
        let medicalHistory: [History]
        let fractures: [Fracture]
        let imaging: [Imaging]
        let labs: [Lab]
        let supplements: [Intake]
        let medicines: [Medicine]
        let exercise: [Exercise]
        let falls: [Fall]
        let fallChecklists: [Screen]
        let pain: [Pain]
    }

    static func write(context: ModelContext) throws -> URL {
        let p = try context.fetch(FetchDescriptor<PatientProfile>()).first
        let vitals = try context.fetch(FetchDescriptor<VitalReading>(sortBy: [SortDescriptor(\.date)])).map { Export.Vital(date: $0.date, systolic: $0.systolic, diastolic: $0.diastolic, heartRate: $0.heartRate, weightKg: $0.weightKg, heightCm: $0.heightCm, note: $0.note) }
        let medicalHistory = try context.fetch(FetchDescriptor<MedicalHistoryEntry>()).map { Export.History(kind: $0.kindRaw, title: $0.title, date: $0.date, ongoing: $0.isOngoing, details: $0.details) }
        let fractures = try context.fetch(FetchDescriptor<FractureRecord>(sortBy: [SortDescriptor(\.date)])).map { Export.Fracture(date: $0.date, site: $0.siteRaw, cause: $0.causeRaw, treatment: $0.treatment, notes: $0.notes) }
        let imaging = try context.fetch(FetchDescriptor<RadiologyReport>(sortBy: [SortDescriptor(\.date)])).map { Export.Imaging(kind: $0.kindRaw, date: $0.date, bodyPart: $0.bodyPart, facility: $0.facility, orderedBy: $0.orderedBy, machine: $0.machine, impression: $0.impression, notes: $0.notes, dexa: $0.dexaResults, tbs: $0.trabecularBoneScore, fraxMajor: $0.fraxMajorPercent, fraxHip: $0.fraxHipPercent, photoCount: $0.attachments.count) }
        let labs = try context.fetch(FetchDescriptor<LabResult>(sortBy: [SortDescriptor(\.date)])).map { Export.Lab(date: $0.date, test: $0.testRaw, value: $0.value, unit: $0.test.unit, note: $0.note) }
        let supplements = try context.fetch(FetchDescriptor<SupplementIntake>(sortBy: [SortDescriptor(\.takenAt)])).map { Export.Intake(takenAt: $0.takenAt, product: $0.productName, source: $0.sourceRaw, servings: $0.servings, amounts: $0.totalAmounts) }
        let medicines = try context.fetch(FetchDescriptor<MedicationPlan>(sortBy: [SortDescriptor(\.startedOn)])).map { Export.Medicine(drug: $0.drugID, frequency: $0.frequencyRaw, startedOn: $0.startedOn, stoppedOn: $0.stoppedOn, prescriber: $0.prescriber, notes: $0.notes, doses: $0.doseDates.sorted()) }
        let exercise = try context.fetch(FetchDescriptor<ExerciseLog>(sortBy: [SortDescriptor(\.date)])).map { Export.Exercise(date: $0.date, category: $0.categoryRaw, activity: $0.activity, minutes: $0.minutes, effort: $0.effort, painBefore: $0.painBefore, painAfter: $0.painAfter, note: $0.note) }
        let falls = try context.fetch(FetchDescriptor<FallRecord>(sortBy: [SortDescriptor(\.date)])).map { Export.Fall(date: $0.date, nearMiss: $0.isNearMiss, location: $0.locationRaw, activity: $0.activity, causes: $0.causesRaw, injuries: $0.injuriesRaw, hitHead: $0.hitHead, gotUpAlone: $0.couldGetUpAlone, longLie: $0.longLie, care: $0.careRaw, notes: $0.notes) }
        let fallChecklists = try context.fetch(FetchDescriptor<FallRiskScreen>(sortBy: [SortDescriptor(\.date)])).map { Export.Screen(date: $0.date, score: $0.score, yesItems: $0.yesItemIDs) }
        let pain = try context.fetch(FetchDescriptor<PainEntry>(sortBy: [SortDescriptor(\.date)])).map { Export.Pain(date: $0.date, score: $0.score, locations: $0.locationsRaw, qualities: $0.qualitiesRaw, helped: $0.helped, newAndSudden: $0.isNewAndSudden, afterFall: $0.afterFall, peg: $0.pegScore, note: $0.note) }
        let profile = p.map { Export.Profile(birthYear: $0.birthYear, sex: $0.sexRaw, boneStatus: $0.boneStatusRaw, isPostmenopausal: $0.isPostmenopausal, riskFactors: $0.riskFactorsRaw, tallestAdultHeightCm: $0.tallestAdultHeightCm, fraxMajor: $0.fraxMajorPercent, fraxHip: $0.fraxHipPercent) }
        let export = Export(exportedAt: Date(), profile: profile, vitals: vitals, medicalHistory: medicalHistory, fractures: fractures, imaging: imaging, labs: labs, supplements: supplements, medicines: medicines, exercise: exercise, falls: falls, fallChecklists: fallChecklists, pain: pain)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("bone-health-export.json")
        try encoder.encode(export).write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }

    static func deleteAll(context: ModelContext) {
        try? context.delete(model: VitalReading.self)
        try? context.delete(model: MedicalHistoryEntry.self)
        try? context.delete(model: FractureRecord.self)
        try? context.delete(model: ReportAttachment.self)
        try? context.delete(model: RadiologyReport.self)
        try? context.delete(model: LabResult.self)
        try? context.delete(model: SupplementIntake.self)
        try? context.delete(model: MedicationDoseLog.self)
        try? context.delete(model: MedicationPlan.self)
        try? context.delete(model: ExerciseLog.self)
        try? context.delete(model: FallRecord.self)
        try? context.delete(model: FallRiskScreen.self)
        try? context.delete(model: PainEntry.self)
        try? context.delete(model: PatientProfile.self)
        try? context.save()
        Reminders.cancelSupplements()
        for drug in OsteoDrugLibrary.all { Reminders.cancelMedication(drugID: drug.id) }
    }
}
