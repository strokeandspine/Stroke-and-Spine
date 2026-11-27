import SwiftUI
import SwiftData
import Charts

struct LogSupplementView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SupplementIntake.takenAt, order: .reverse) private var intakes: [SupplementIntake]
    @Query private var plans: [MedicationPlan]

    @State private var source: IntakeSource = .supplement
    @State private var productID = SupplementProduct.supplements[0].id
    @State private var custom = false
    @State private var customName = ""
    @State private var customCalcium: Double?
    @State private var customVitaminD: Double?
    @State private var customMagnesium: Double?
    @State private var servings = 1.0
    @State private var takenAt = Date()

    private var options: [SupplementProduct] { source == .supplement ? SupplementProduct.supplements : SupplementProduct.foods }
    private var product: SupplementProduct? { SupplementProduct.all.first { $0.id == productID } }

    private var perServing: [NutrientAmount] {
        if custom { return SupplementProduct.amounts(ca: customCalcium ?? 0, d: customVitaminD ?? 0, mg: customMagnesium ?? 0) }
        return product?.perServing ?? []
    }

    private var name: String {
        if custom { return customName.isEmpty ? (source == .supplement ? "Other supplement" : "Other food") : customName }
        return product?.name ?? ""
    }

    private var proposed: IntakeRecord {
        IntakeRecord(takenAt: takenAt, source: source,
                     amounts: perServing.map { NutrientAmount(nutrient: $0.nutrient, amount: $0.amount * servings) })
    }

    /// Recent oral bisphosphonate doses, for the "wait before calcium" check.
    private var windows: [EmptyStomachWindow] {
        plans.compactMap { plan -> EmptyStomachWindow? in
            guard let drug = plan.drug, let minutes = drug.emptyStomachMinutes, let last = plan.lastDose else { return nil }
            return EmptyStomachWindow(drugName: drug.genericName.lowercased(), takenAt: last, waitMinutes: minutes)
        }
    }

    private var warnings: [SafetyWarning] {
        profile.supplementChecker.warnings(records: intakes.map(\.record), proposed: proposed, emptyStomach: windows)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $source) {
                        ForEach(IntakeSource.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Not listed", isOn: $custom)
                    if custom {
                        TextField("Name", text: $customName)
                        OptionalNumberField(title: "Calcium", value: $customCalcium, unit: "mg")
                        OptionalNumberField(title: "Vitamin D", value: $customVitaminD, unit: "IU")
                        OptionalNumberField(title: "Magnesium", value: $customMagnesium, unit: "mg")
                    } else {
                        Picker(source == .supplement ? "Supplement" : "Food", selection: $productID) {
                            ForEach(options) { Text($0.name).tag($0.id) }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    Stepper("\(servings.formatted()) \(custom ? "serving" : (product?.servingName ?? "serving"))\(servings == 1 ? "" : "s")",
                            value: $servings, in: 0.5...10, step: 0.5)
                    DatePicker("When", selection: $takenAt, in: ...Date().addingTimeInterval(300))
                } header: {
                    Text("What did you have?")
                } footer: {
                    if custom {
                        Text("Use the elemental calcium and magnesium on the Supplement Facts label (not the weight of the compound). Vitamin D labels list mcg and IU: 1 mcg = 40 IU.")
                    } else if let note = product?.note, !note.isEmpty {
                        Text(note)
                    }
                }

                Section("This adds") {
                    if proposed.amounts.isEmpty { Text("Nothing yet").foregroundStyle(.secondary) }
                    ForEach(proposed.amounts, id: \.nutrient) { a in
                        LabeledContent(a.nutrient.name, value: a.nutrient.format(a.amount))
                    }
                }

                if !warnings.isEmpty {
                    Section("Check before you take it") {
                        ForEach(warnings) { WarningRow(warning: $0) }
                    }
                }
            }
            .navigationTitle("Log intake")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold().disabled(perServing.isEmpty) }
            }
            .onChange(of: source) { _, _ in productID = options[0].id }
        }
    }

    private func save() {
        context.insert(SupplementIntake(takenAt: takenAt, productName: name, source: source, servings: servings, perServing: perServing))
        try? context.save()
        dismiss()
    }
}

struct SupplementHistoryView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \SupplementIntake.takenAt, order: .reverse) private var intakes: [SupplementIntake]
    @State private var nutrient: Nutrient = .calcium

    private struct DayTotal: Identifiable {
        let day: Date
        let total: Double
        var id: Date { day }
    }

    private var lastFourteenDays: [DayTotal] {
        let calendar = Calendar.current
        let records = intakes.map(\.record)
        let checker = profile.supplementChecker
        return (0..<14).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) else { return nil }
            return DayTotal(day: day, total: checker.total(nutrient, records: records, on: day))
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Nutrient", selection: $nutrient) {
                    ForEach(Nutrient.allCases) { Text($0.name).tag($0) }
                }
                .pickerStyle(.segmented)
                let target = profile.nutrientTargets.daily[nutrient] ?? 0
                Chart {
                    ForEach(lastFourteenDays) { d in
                        BarMark(x: .value("Day", d.day, unit: .day), y: .value(nutrient.unit, d.total))
                    }
                    RuleMark(y: .value("Target", target))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(dash: [4]))
                        .annotation(position: .top, alignment: .leading) { Text("Target").font(.caption2).foregroundStyle(.green) }
                }
                .frame(height: 180)
                if nutrient == .vitaminD {
                    let avg = profile.supplementChecker.sevenDayAverage(.vitaminD, records: intakes.map(\.record), endingOn: Date())
                    Text("7-day average: \(Nutrient.vitaminD.format(avg)) a day").font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("Last 14 days")
            }

            Section {
                NavigationLink { SupplementTargetsView(profile: profile) } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My daily targets")
                        Text(Nutrient.allCases.map { "\($0.name) \($0.format(profile.nutrientTargets.daily[$0] ?? 0))" }.joined(separator: " · "))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Section("Log") {
                if intakes.isEmpty { Text("Nothing logged yet.").foregroundStyle(.secondary) }
                ForEach(intakes.prefix(100)) { intake in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(intake.productName).font(.subheadline.bold())
                        Text("\(intake.servings.formatted()) × · " + intake.totalAmounts.map { "\($0.nutrient.name) \($0.nutrient.format($0.amount))" }.joined(separator: ", "))
                            .font(.caption)
                        Text(intake.takenAt.shortDateTime).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    let shown = Array(intakes.prefix(100))
                    for i in offsets { context.delete(shown[i]) }
                    try? context.save()
                }
            }
        }
        .navigationTitle("Supplements")
    }
}

struct SupplementTargetsView: View {
    @Bindable var profile: PatientProfile

    private var standard: NutrientTargets { NutrientTargets.forPerson(age: profile.age, sex: profile.sex) }

    var body: some View {
        Form {
            Section {
                Text("Standard targets for your age and sex come from the US National Institutes of Health. If your doctor gave you different targets, enter them here.")
                    .font(.subheadline)
            }
            targetSection(.calcium, binding: $profile.calciumTargetOverride)
            targetSection(.vitaminD, binding: $profile.vitaminDTargetOverride)
            targetSection(.magnesium, binding: $profile.magnesiumTargetOverride)
            Section {
                Toggle("Doctor prescribed high-dose vitamin D", isOn: $profile.prescribedHighDoseVitaminD)
            } footer: {
                Text("Turn this on if your doctor prescribed more than 4,000 IU a day (or a large weekly dose), so the app doesn't warn you about the usual upper limit.")
            }
        }
        .navigationTitle("Daily targets")
    }

    private func targetSection(_ nutrient: Nutrient, binding: Binding<Double?>) -> some View {
        Section {
            OptionalNumberField(title: "My target", value: binding, unit: nutrient.unit)
            LabeledContent("Standard for you", value: nutrient.format(standard.daily[nutrient] ?? 0))
            if let ul = standard.upperLimit[nutrient] {
                LabeledContent(nutrient == .magnesium ? "Upper limit (supplements)" : "Upper limit", value: nutrient.format(ul))
            }
        } header: {
            Text(nutrient.name)
        } footer: {
            Text("Leave \"My target\" blank to use the standard.")
        }
    }
}

struct SupplementGuideView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        let t = profile.nutrientTargets
        List {
            Section("Calcium") {
                Text("Your target: \(Nutrient.calcium.format(t.daily[.calcium] ?? 0)) a day from food and supplements combined.").bold()
                BulletList(items: [
                    "Food first: dairy, calcium-set tofu, fortified plant milks and juice, and canned fish with bones. Most people get 600–800 mg from food, so a supplement may only need to cover the rest.",
                    "Take no more than 500 mg of supplemental calcium at a time — split larger amounts between meals.",
                    "Calcium carbonate is absorbed best with food. Calcium citrate can be taken any time and is better if you take an acid reducer.",
                    "More isn't better: above \(Nutrient.calcium.format(t.upperLimit[.calcium] ?? 2000)) a day raises the risk of kidney stones, and supplements may cause constipation.",
                    "Keep calcium at least 4 hours apart from levothyroxine, and separate from iron and some antibiotics — ask your pharmacist.",
                    "Never take calcium within 30 minutes (60 for ibandronate) after an oral bisphosphonate.",
                ])
            }
            Section("Vitamin D") {
                Text("Your target: \(Nutrient.vitaminD.format(t.daily[.vitaminD] ?? 0)) a day.").bold()
                BulletList(items: [
                    "Vitamin D helps you absorb calcium. Few foods contain much, so many people need a supplement.",
                    "The Bone Health & Osteoporosis Foundation advises 800–1,000 IU a day for adults 50 and older. Your doctor may advise more if your blood level is low.",
                    "Don't take more than 4,000 IU a day unless your doctor prescribed it. Weekly or monthly high doses should be taken exactly as prescribed.",
                    "A blood test (25-hydroxy vitamin D) shows your level. Add results in Records → Lab results.",
                ])
            }
            Section("Magnesium") {
                Text("Your target: \(Nutrient.magnesium.format(t.daily[.magnesium] ?? 0)) a day, mostly from food.").bold()
                BulletList(items: [
                    "Magnesium is part of bone and helps vitamin D work. Nuts, seeds, beans, whole grains and leafy greens are good sources.",
                    "Supplements aren't needed by everyone. If you take one, keep supplemental magnesium to \(Nutrient.magnesium.format(t.upperLimit[.magnesium] ?? 350)) a day or less unless your doctor advises otherwise — more can cause diarrhea.",
                    "If you have kidney disease, only take magnesium if your doctor says so.",
                ])
            }
            Section {
                Text("Sources: NIH Office of Dietary Supplements fact sheets; Bone Health & Osteoporosis Foundation clinician's guide (2022).")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Supplement guide")
    }
}
