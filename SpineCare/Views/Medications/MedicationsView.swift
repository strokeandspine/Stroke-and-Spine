import SwiftUI
import SwiftData

struct MedicationsView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \MedicationDose.takenAt, order: .reverse) private var doses: [MedicationDose]
    @State private var showingLog = false

    private var checker: MedicationSafetyChecker { profile.safetyChecker }
    private var records: [DoseRecord] { doses.map(\.record) }

    var body: some View {
        NavigationStack {
            List {
                let statuses = checker.status(doses: records)
                Section {
                    if statuses.isEmpty {
                        Text("No pain relievers logged in the last 24 hours.").foregroundStyle(.secondary)
                    }
                    ForEach(statuses) { status in
                        IngredientStatusRow(status: status)
                    }
                    Button { showingLog = true } label: {
                        Label("Log a medicine", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Last 24 hours")
                } footer: {
                    Text("Limits come from typical US over-the-counter labels or the limits you set. Always follow your product label and your doctor's advice.")
                }

                let warnings = checker.warnings(doses: records)
                if !warnings.isEmpty {
                    Section("Safety notes") {
                        ForEach(warnings) { WarningRow(warning: $0) }
                    }
                }

                let streak = checker.consecutiveDaysUsed(doses: records)
                if streak >= 10 {
                    Section {
                        WarningRow(warning: SafetyWarning(id: "ten-days", severity: .caution,
                            message: "You've used pain relievers \(streak) days in a row. Over-the-counter labels say to stop and ask a doctor if pain lasts more than 10 days."))
                    }
                }

                Section("History") {
                    if doses.isEmpty {
                        Text("Nothing logged yet.").foregroundStyle(.secondary)
                    }
                    ForEach(doses.prefix(50)) { dose in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dose.productName).font(.subheadline.bold())
                            Text("\(dose.units.formatted()) × · \(dose.totalAmounts.map { "\($0.ingredient.name) \(Int($0.milligrams)) mg" }.joined(separator: ", "))")
                                .font(.caption)
                            Text(dose.takenAt.shortDateTime).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        let shown = Array(doses.prefix(50))
                        for i in offsets { context.delete(shown[i]) }
                        try? context.save()
                    }
                }

                Section("Other things that can help") {
                    Text("• Heat wraps or a heating pad (heat has good evidence for new back pain)")
                    Text("• Gentle movement and short walks rather than bed rest")
                    Text("• Topical gels or patches such as diclofenac gel, lidocaine or menthol — ask your pharmacist")
                }
                .font(.subheadline)
            }
            .navigationTitle("Medicines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink { DoseLimitsView(profile: profile) } label: { Image(systemName: "slider.horizontal.3") }
                        .accessibilityLabel("My label limits")
                }
            }
            .sheet(isPresented: $showingLog) { LogDoseView(profile: profile) }
        }
    }
}

struct IngredientStatusRow: View {
    let status: IngredientStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(status.ingredient.name).font(.headline)
                Spacer()
                Text("\(Int(status.totalMg)) of \(Int(status.limitMg)) mg")
                    .monospacedDigit()
                    .foregroundStyle(color)
            }
            ProgressView(value: min(status.fraction, 1))
                .tint(color)
            if let last = status.lastDose {
                Text("Last taken \(last.formatted(.relative(presentation: .named)))")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        switch status.level {
        case .ok: return .green
        case .approaching: return .orange
        case .reached, .over: return .red
        }
    }
}

struct LogDoseView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MedicationDose.takenAt, order: .reverse) private var doses: [MedicationDose]

    @State private var productIndex = 0
    @State private var useCustom = false
    @State private var customName = ""
    @State private var customIngredient: Ingredient = .acetaminophen
    @State private var customMg = 500.0
    @State private var units = 1.0
    @State private var takenAt = Date()
    @State private var recordPain = false
    @State private var painBefore = 5

    private var product: OTCProduct {
        if useCustom {
            return OTCProduct(name: customName.isEmpty ? "Other \(customIngredient.name.lowercased())" : customName,
                              perUnit: [IngredientAmount(ingredient: customIngredient, milligrams: customMg)])
        }
        return OTCProduct.presets[productIndex]
    }

    private var proposed: DoseRecord {
        DoseRecord(takenAt: takenAt, amounts: product.perUnit.map {
            IngredientAmount(ingredient: $0.ingredient, milligrams: $0.milligrams * units)
        })
    }

    private var warnings: [SafetyWarning] {
        profile.safetyChecker.warnings(doses: doses.map(\.record), proposed: proposed, now: max(Date(), takenAt))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What did you take?") {
                    Toggle("Product not listed", isOn: $useCustom)
                    if useCustom {
                        TextField("Product name", text: $customName)
                        Picker("Active ingredient", selection: $customIngredient) {
                            ForEach(Ingredient.allCases) { Text($0.name).tag($0) }
                        }
                        HStack {
                            Text("Amount per tablet")
                            Spacer()
                            TextField("mg", value: $customMg, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("mg")
                        }
                    } else {
                        Picker("Product", selection: $productIndex) {
                            ForEach(OTCProduct.presets.indices, id: \.self) { i in
                                Text(OTCProduct.presets[i].name).tag(i)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    Stepper("\(units.formatted()) \(product.unitName)\(units == 1 ? "" : "s")", value: $units, in: 0.5...6, step: 0.5)
                    DatePicker("When", selection: $takenAt, in: ...Date().addingTimeInterval(300))
                }

                Section {
                    Toggle("Record my pain now", isOn: $recordPain)
                    if recordPain { ScaleSlider(title: "Pain before taking it", value: $painBefore) }
                } footer: {
                    Text("Recording pain before a dose lets the app show you how well each medicine works for you.")
                }

                if !warnings.isEmpty {
                    Section("Check before you take it") {
                        ForEach(warnings) { WarningRow(warning: $0) }
                    }
                }
            }
            .navigationTitle("Log a medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.bold().disabled(useCustom && customMg <= 0)
                }
            }
        }
    }

    private func save() {
        context.insert(MedicationDose(takenAt: takenAt, product: product, units: units, painBefore: recordPain ? painBefore : nil))
        try? context.save()
        dismiss()
    }
}

struct DoseLimitsView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        Form {
            Section {
                Text("Set the 24-hour limit printed on your product's Drug Facts label, or a lower limit your doctor gave you. The app never allows a limit above the standard US label maximum.")
                    .font(.subheadline)
            }
            ForEach(Ingredient.allCases) { ingredient in
                Section(ingredient.name) {
                    let binding = Binding<Double>(
                        get: { profile.dailyLimitsMg[ingredient.rawValue] ?? ingredient.defaultDailyLimitMg },
                        set: { profile.dailyLimitsMg[ingredient.rawValue] = min($0, ingredient.labelCeilingMg) })
                    Stepper("\(Int(binding.wrappedValue)) mg per 24 hours", value: binding,
                            in: 0...ingredient.labelCeilingMg, step: ingredient == .naproxen ? 220 : 100)
                    if ingredient == .acetaminophen {
                        Text("Many Extra Strength labels say 3,000 mg; some say 4,000 mg. If you have liver disease or drink alcohol regularly, ask your doctor for your limit.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Section {
                Button("Reset to standard label limits") { profile.dailyLimitsMg = [:] }
            }
        }
        .navigationTitle("My label limits")
    }
}
