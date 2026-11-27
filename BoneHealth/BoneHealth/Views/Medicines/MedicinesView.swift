import SwiftUI
import SwiftData

struct MedicinesView: View {
    @Bindable var profile: PatientProfile
    /// True when pushed from another screen, so it doesn't add its own navigation stack.
    var embedded = false

    var body: some View {
        if embedded {
            content
        } else {
            NavigationStack { content }
        }
    }

    private var content: some View { MedicinesContent(profile: profile).navigationTitle("Medicines") }
}

private struct MedicinesContent: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \MedicationPlan.startedOn, order: .reverse) private var plans: [MedicationPlan]
    @Query(sort: \SupplementIntake.takenAt, order: .reverse) private var intakes: [SupplementIntake]
    @State private var adding = false
    @State private var loggingSupplement = false

    private var active: [MedicationPlan] { plans.filter(\.isActive) }
    private var past: [MedicationPlan] { plans.filter { !$0.isActive } }

    var body: some View {
        List {
            Section {
                if active.isEmpty {
                    Text("No osteoporosis medicines added yet.").foregroundStyle(.secondary)
                }
                ForEach(active) { plan in
                    NavigationLink { MedicationPlanDetailView(plan: plan, profile: profile) } label: { PlanRow(plan: plan) }
                }
                Button { adding = true } label: { Label("Add a medicine I take", systemImage: "plus.circle.fill") }
            } header: {
                Text("My osteoporosis medicines")
            }

            Section {
                let statuses = profile.supplementChecker.status(records: intakes.map(\.record), on: Date())
                ForEach(statuses) { status in
                    ProgressRow(title: status.nutrient.name,
                                valueText: "\(status.nutrient.format(status.total)) of \(status.nutrient.format(status.target))",
                                fraction: status.fraction,
                                tint: status.level == .overLimit ? .red : (status.level == .onTarget ? .green : .accentColor))
                }
                Button { loggingSupplement = true } label: { Label("Log a supplement or food", systemImage: "plus.circle.fill") }
                NavigationLink { SupplementHistoryView(profile: profile) } label: { Label("Supplement history and targets", systemImage: "chart.bar") }
            } header: {
                Text("Calcium, vitamin D and magnesium today")
            }

            Section("Learn") {
                NavigationLink { DrugLibraryView(profile: profile) } label: { Label("All osteoporosis medicines", systemImage: "books.vertical") }
                NavigationLink { SupplementGuideView(profile: profile) } label: { Label("Calcium, vitamin D and magnesium guide", systemImage: "leaf") }
            }

            if !past.isEmpty {
                Section("Past medicines") {
                    ForEach(past) { plan in
                        NavigationLink { MedicationPlanDetailView(plan: plan, profile: profile) } label: {
                            VStack(alignment: .leading) {
                                Text(plan.drug?.genericName ?? plan.drugID).font(.subheadline.bold())
                                Text("\(plan.startedOn.shortDate) – \(plan.stoppedOn?.shortDate ?? "")").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $adding) { AddPlanView(drug: nil) }
        .sheet(isPresented: $loggingSupplement) { LogSupplementView(profile: profile) }
    }
}

private struct PlanRow: View {
    let plan: MedicationPlan

    var body: some View {
        HStack(alignment: .top) {
            if let status = plan.status() {
                Circle().fill(ScaleColor.color(for: status.state)).frame(width: 10, height: 10).padding(.top, 6)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.drug?.genericName ?? plan.drugID).font(.subheadline.bold())
                Text(plan.frequency.label).font(.caption).foregroundStyle(.secondary)
                if let status = plan.status() { Text(status.message).font(.caption).lineLimit(3) }
            }
        }
    }
}

// MARK: - Plan detail and dose logging

struct MedicationPlanDetailView: View {
    @Bindable var plan: MedicationPlan
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @State private var logging = false
    @State private var confirmingStop = false

    private var sortedDoses: [MedicationDoseLog] { plan.doses.sorted { $0.takenAt > $1.takenAt } }

    var body: some View {
        List {
            if let drug = plan.drug {
                if let status = plan.status() {
                    Section {
                        Label {
                            Text(status.message)
                        } icon: {
                            Circle().fill(ScaleColor.color(for: status.state)).frame(width: 12, height: 12)
                        }
                        if status.state != .completed {
                            Button { logging = true } label: { Label("Log a dose", systemImage: "checkmark.circle.fill") }.bold()
                        }
                    }
                }
                let notes = MedicationSchedule.durationNotes(drug: drug, startedOn: plan.startedOn)
                if !notes.isEmpty {
                    Section { ForEach(notes) { WarningRow(warning: $0) } }
                }
                if let boxed = drug.boxedWarning {
                    Section("Boxed warning") { WarningRow(warning: SafetyWarning(id: "boxed", severity: .caution, message: boxed)) }
                }

                Section("My plan") {
                    LabeledContent("Medicine", value: drug.genericName)
                    if plan.isActive {
                        Picker("How often", selection: Binding(get: { plan.frequency }, set: { plan.frequency = $0; reschedule() })) {
                            ForEach(drug.frequencies) { Text($0.label).tag($0) }
                        }
                    } else {
                        LabeledContent("How often", value: plan.frequency.label)
                    }
                    DatePicker("Started", selection: $plan.startedOn, in: ...Date(), displayedComponents: .date)
                    TextField("Prescribed by", text: $plan.prescriber)
                    TextField("Notes", text: $plan.notes, axis: .vertical)
                    if plan.isActive {
                        Toggle("Remind me when it's due", isOn: Binding(get: { plan.remindersEnabled }, set: { on in
                            plan.remindersEnabled = on
                            if on { reschedule() } else { Reminders.cancelMedication(drugID: drug.id) }
                        }))
                    }
                    if let max = drug.maxDoses {
                        LabeledContent("Doses so far", value: "\(plan.doses.count) of \(max)")
                    }
                }

                Section {
                    if sortedDoses.isEmpty { Text("No doses logged yet.").foregroundStyle(.secondary) }
                    ForEach(sortedDoses) { dose in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dose.takenAt.shortDateTime).font(.subheadline)
                            if !dose.sideEffects.isEmpty { Text("Side effects: \(dose.sideEffects.joined(separator: ", "))").font(.caption) }
                            if !dose.note.isEmpty { Text(dose.note).font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                    .onDelete { offsets in
                        let shown = sortedDoses
                        for i in offsets { context.delete(shown[i]) }
                        try? context.save()
                        reschedule()
                    }
                } header: {
                    Text("Dose history")
                }

                Section {
                    NavigationLink { DrugDetailView(drug: drug, profile: profile) } label: { Label("About \(drug.genericName.lowercased())", systemImage: "info.circle") }
                }

                Section {
                    if plan.isActive {
                        Button("I've stopped this medicine", role: .destructive) { confirmingStop = true }
                    } else {
                        Button("Restart this medicine") { plan.stoppedOn = nil }
                    }
                } footer: {
                    if let after = drug.afterStopping { Text(after) }
                }
            }
        }
        .navigationTitle(plan.drug?.genericName ?? "Medicine")
        .sheet(isPresented: $logging, onDismiss: reschedule) {
            if let drug = plan.drug { LogOsteoDoseView(plan: plan, drug: drug) }
        }
        .confirmationDialog("Stop this medicine?", isPresented: $confirmingStop, titleVisibility: .visible) {
            Button("Mark as stopped today", role: .destructive) {
                plan.stoppedOn = Date()
                plan.remindersEnabled = false
                Reminders.cancelMedication(drugID: plan.drugID)
            }
        } message: {
            Text(plan.drug?.afterStopping ?? "Only stop a bone medicine after talking to your doctor.")
        }
    }

    private func reschedule() {
        guard plan.remindersEnabled, plan.isActive, let drug = plan.drug else { return }
        let next = plan.status()?.nextDue
        Task {
            let ok = await Reminders.scheduleMedication(drug: drug, frequency: plan.frequency, nextDue: next)
            if !ok { plan.remindersEnabled = false }
        }
    }
}

struct AddPlanView: View {
    let drug: OsteoDrug?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var plans: [MedicationPlan]
    @State private var drugID = OsteoDrugLibrary.all[0].id
    @State private var frequency: DoseFrequency = .weekly
    @State private var startedOn = Date()
    @State private var hadLastDose = false
    @State private var lastDose = Date()
    @State private var prescriber = ""

    private var selected: OsteoDrug { OsteoDrugLibrary.drug(drugID) ?? OsteoDrugLibrary.all[0] }
    private var alreadyActive: Bool { plans.contains { $0.drugID == drugID && $0.isActive } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Medicine", selection: $drugID) {
                        ForEach(OsteoDrugLibrary.byClass) { group in
                            Section(group.drugClass.name) {
                                ForEach(group.drugs) { Text($0.displayName).tag($0.id) }
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Picker("How often", selection: $frequency) {
                        ForEach(selected.frequencies) { Text($0.label).tag($0) }
                    }
                    DatePicker("Started on", selection: $startedOn, in: ...Date(), displayedComponents: .date)
                    TextField("Prescribed by (optional)", text: $prescriber)
                } footer: {
                    Text(selected.usualDose)
                }
                Section {
                    Toggle("I've already had a dose", isOn: $hadLastDose)
                    if hadLastDose {
                        DatePicker("Most recent dose", selection: $lastDose, in: startedOn...Date(), displayedComponents: .date)
                    }
                } footer: {
                    Text("Adding your most recent dose lets the app work out when the next one is due.")
                }
                if alreadyActive {
                    Section { Text("You already have this medicine in your list.").foregroundStyle(.orange) }
                }
            }
            .navigationTitle("Add a medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Add") { save() }.bold().disabled(alreadyActive) }
            }
            .onAppear {
                if let drug { drugID = drug.id }
                frequency = selected.defaultFrequency
            }
            .onChange(of: drugID) { _, _ in frequency = selected.defaultFrequency }
        }
    }

    private func save() {
        let plan = MedicationPlan(drug: selected, frequency: frequency, startedOn: startedOn)
        plan.prescriber = prescriber
        context.insert(plan)
        if hadLastDose {
            let dose = MedicationDoseLog(takenAt: lastDose)
            context.insert(dose)
            dose.plan = plan
        }
        try? context.save()
        dismiss()
    }
}

struct LogOsteoDoseView: View {
    let plan: MedicationPlan
    let drug: OsteoDrug

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var takenAt = Date()
    @State private var checked: Set<Int> = []
    @State private var sideEffects: [String] = []
    @State private var note = ""
    @State private var saved = false

    private var needsChecklist: Bool { drug.emptyStomachMinutes != nil }

    var body: some View {
        NavigationStack {
            Form {
                if saved, let minutes = drug.emptyStomachMinutes {
                    Section {
                        let until = takenAt.addingTimeInterval(TimeInterval(minutes * 60))
                        Label("Logged", systemImage: "checkmark.circle.fill").foregroundStyle(.green).font(.headline)
                        Text("Stay upright, and have nothing but plain water until \(until.formatted(date: .omitted, time: .shortened)). After that you can eat, drink, and take calcium and other medicines.")
                    }
                } else {
                    Section {
                        DatePicker("When", selection: $takenAt, in: ...Date())
                    }
                    if needsChecklist {
                        Section {
                            ForEach(drug.howToTake.indices, id: \.self) { i in
                                Toggle(isOn: Binding(get: { checked.contains(i) }, set: { on in
                                    if on { checked.insert(i) } else { checked.remove(i) }
                                })) { Text(drug.howToTake[i]).font(.subheadline) }
                            }
                        } header: {
                            Text("Taking it the right way")
                        } footer: {
                            Text("Oral bisphosphonates are poorly absorbed, and can irritate the esophagus if not taken this way.")
                        }
                    }
                    Section("Any side effects? (optional)") {
                        TagPicker(options: drug.commonSideEffects, selection: $sideEffects)
                        TextField("Notes", text: $note, axis: .vertical)
                    }
                }
            }
            .navigationTitle("Log \(drug.genericName.lowercased())")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if saved {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.bold() }
                } else {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
                }
            }
        }
    }

    private func save() {
        let dose = MedicationDoseLog(takenAt: takenAt, sideEffects: sideEffects, note: note)
        context.insert(dose)
        dose.plan = plan
        try? context.save()
        if drug.emptyStomachMinutes != nil && takenAt.addingTimeInterval(TimeInterval((drug.emptyStomachMinutes ?? 0) * 60)) > Date() {
            saved = true
        } else {
            dismiss()
        }
    }
}
