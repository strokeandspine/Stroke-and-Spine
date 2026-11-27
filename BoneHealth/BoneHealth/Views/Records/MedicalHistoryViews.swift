import SwiftUI
import SwiftData

struct MedicalHistoryView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \MedicalHistoryEntry.title) private var entries: [MedicalHistoryEntry]
    @State private var editing: MedicalHistoryEntry?
    @State private var adding = false

    var body: some View {
        List {
            Section {
                Button { adding = true } label: { Label("Add to medical history", systemImage: "plus.circle.fill") }
                NavigationLink { RiskFactorsView(profile: profile) } label: { Label("Bone risk factors checklist", systemImage: "exclamationmark.shield") }
                NavigationLink { FractureListView() } label: { Label("Broken bones", systemImage: "bandage") }
            }
            ForEach(HistoryKind.allCases) { kind in
                let items = entries.filter { $0.kindRaw == kind.rawValue }
                if !items.isEmpty {
                    Section(kind.label) {
                        ForEach(items) { entry in
                            Button { editing = entry } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(entry.title).font(.subheadline.bold())
                                        if entry.isOngoing { Text("Ongoing").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2).background(Color.accentColor.opacity(0.15), in: Capsule()) }
                                    }
                                    if let date = entry.date { Text(date.shortDate).font(.caption).foregroundStyle(.secondary) }
                                    if !entry.details.isEmpty { Text(entry.details).font(.caption).lineLimit(3) }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            for i in offsets { context.delete(items[i]) }
                            try? context.save()
                        }
                    }
                }
            }
            if entries.isEmpty {
                Section {
                    Text("Add your health conditions, past surgeries, allergies and the other medicines you take. Your doctor will want to know about these when planning bone treatment.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Medical history")
        .sheet(isPresented: $adding) { EditHistoryView(entry: nil) }
        .sheet(item: $editing) { EditHistoryView(entry: $0) }
    }
}

private struct EditHistoryView: View {
    let entry: MedicalHistoryEntry?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var kind: HistoryKind = .condition
    @State private var title = ""
    @State private var hasDate = false
    @State private var date = Date()
    @State private var ongoing = false
    @State private var details = ""

    private var placeholder: String {
        switch kind {
        case .condition: return "e.g. Hypothyroidism"
        case .surgery: return "e.g. Right hip replacement"
        case .allergy: return "e.g. Penicillin — rash"
        case .medication: return "e.g. Levothyroxine 75 mcg daily"
        case .familyHistory: return "e.g. Mother — osteoporosis"
        case .other: return "Title"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $kind) {
                    ForEach(HistoryKind.allCases) { Label($0.label, systemImage: $0.symbol).tag($0) }
                }
                TextField(placeholder, text: $title)
                Toggle("Add a date", isOn: $hasDate)
                if hasDate { DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date) }
                if kind == .condition || kind == .medication { Toggle("Ongoing", isOn: $ongoing) }
                Section("Details") {
                    TextField("Doctor, dose, reaction, notes…", text: $details, axis: .vertical).lineLimit(3...8)
                }
            }
            .navigationTitle(entry == nil ? "Add" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.bold().disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard let entry else { return }
                kind = entry.kind
                title = entry.title
                hasDate = entry.date != nil
                date = entry.date ?? Date()
                ongoing = entry.isOngoing
                details = entry.details
            }
        }
    }

    private func save() {
        let target = entry ?? MedicalHistoryEntry(kind: kind, title: title)
        target.kind = kind
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.date = hasDate ? date : nil
        target.isOngoing = ongoing
        target.details = details
        if entry == nil { context.insert(target) }
        try? context.save()
        dismiss()
    }
}

// MARK: - Fractures

struct FractureListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FractureRecord.date, order: .reverse) private var fractures: [FractureRecord]
    @State private var adding = false
    @State private var editing: FractureRecord?

    var body: some View {
        List {
            Section {
                Button { adding = true } label: { Label("Add a broken bone", systemImage: "plus.circle.fill") }
            } footer: {
                Text("Include any bone you've broken as an adult. A break from a fall from standing height or less (a \"fragility fracture\") is one of the strongest signs of osteoporosis, and raises the chance of another.")
            }
            if fractures.contains(where: { $0.cause.isFragility }) {
                Section {
                    WarningRow(warning: SafetyWarning(id: "fragility", severity: .info,
                        message: "You've recorded a fragility fracture. Make sure your doctor knows about it — it's a key part of deciding on bone treatment."))
                }
            }
            Section {
                ForEach(fractures) { f in
                    Button { editing = f } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(f.site.label).font(.subheadline.bold())
                            Text(f.date.shortDate).font(.caption).foregroundStyle(.secondary)
                            Text(f.cause.label).font(.caption)
                            if !f.treatment.isEmpty { Text("Treatment: \(f.treatment)").font(.caption) }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(fractures[i]) }
                    try? context.save()
                }
            }
        }
        .navigationTitle("Broken bones")
        .sheet(isPresented: $adding) { EditFractureView(fracture: nil) }
        .sheet(item: $editing) { EditFractureView(fracture: $0) }
    }
}

struct EditFractureView: View {
    let fracture: FractureRecord?
    var initialDate: Date? = nil
    var initialSite: FractureSite? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var site: FractureSite = .wrist
    @State private var cause: FractureCause = .lowTrauma
    @State private var treatment = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Bone", selection: $site) {
                    ForEach(FractureSite.allCases) { Text($0.label).tag($0) }
                }
                DatePicker("Date (approximate is fine)", selection: $date, in: ...Date(), displayedComponents: .date)
                Section("How did it happen?") {
                    Picker("Cause", selection: $cause) {
                        ForEach(FractureCause.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section("Treatment and notes") {
                    TextField("e.g. Cast for 6 weeks, surgery with plate", text: $treatment, axis: .vertical)
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle(fracture == nil ? "Add broken bone" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
            .onAppear {
                if let fracture {
                    date = fracture.date; site = fracture.site; cause = fracture.cause
                    treatment = fracture.treatment; notes = fracture.notes
                } else {
                    if let initialDate { date = initialDate }
                    if let initialSite { site = initialSite }
                }
            }
        }
    }

    private func save() {
        let target = fracture ?? FractureRecord()
        target.date = date
        target.site = site
        target.cause = cause
        target.treatment = treatment
        target.notes = notes
        if fracture == nil { context.insert(target) }
        try? context.save()
        dismiss()
    }
}

// MARK: - Risk factors and FRAX

struct RiskFactorsView: View {
    @Bindable var profile: PatientProfile
    @Query private var fractures: [FractureRecord]

    var body: some View {
        Form {
            Section {
                Text("Tick anything that applies to you. Your doctor uses these, with your age, sex, weight, height, previous fractures and DEXA result, to estimate your fracture risk (for example with the FRAX tool).")
                    .font(.subheadline)
                if fractures.contains(where: { $0.cause.isFragility }) {
                    Label("Previous fragility fracture — from your broken bones list", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                }
            }
            ForEach(RiskFactor.Group.allCases, id: \.self) { group in
                Section(group.rawValue) {
                    ForEach(RiskFactor.allCases.filter { $0.group == group }) { factor in
                        Toggle(factor.label, isOn: Binding(
                            get: { profile.riskFactors.contains(factor) },
                            set: { on in
                                var set = profile.riskFactors
                                if on { set.insert(factor) } else { set.remove(factor) }
                                profile.riskFactors = set
                            }))
                    }
                }
            }
            Section {
                OptionalNumberField(title: "Major osteoporotic fracture", value: $profile.fraxMajorPercent, unit: "%")
                OptionalNumberField(title: "Hip fracture", value: $profile.fraxHipPercent, unit: "%")
                DatePicker("Date calculated", selection: Binding(get: { profile.fraxDate ?? Date() }, set: { profile.fraxDate = $0 }),
                           in: ...Date(), displayedComponents: .date)
                if profile.fraxMajorPercent != nil || profile.fraxHipPercent != nil {
                    Text(FRAX.meetsUSTreatmentThreshold(major: profile.fraxMajorPercent, hip: profile.fraxHipPercent)
                         ? "In US guidelines, for people with low bone mass, treatment is often recommended when the 10-year risk is 20% or more for a major fracture or 3% or more for a hip fracture. Discuss your result with your doctor."
                         : "These are below the levels at which US guidelines usually recommend medicine for people with low bone mass (20% major, 3% hip). Your doctor will consider your whole picture.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("My FRAX result (10-year risk)")
            } footer: {
                Text("FRAX is often printed on DEXA reports. Bone Health does not calculate it.")
            }
        }
        .navigationTitle("Risk factors")
    }
}
