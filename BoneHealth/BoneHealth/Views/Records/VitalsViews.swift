import SwiftUI
import SwiftData
import Charts

struct VitalsListView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \VitalReading.date, order: .reverse) private var readings: [VitalReading]
    @State private var showingAdd = false

    private var metric: Bool { profile.usesMetricUnits }

    var body: some View {
        List {
            let heights = readings.compactMap(\.heightCm)
            let latestHeight = readings.first(where: { $0.heightCm != nil })?.heightCm
            if let warning = BodyMeasures.heightLossWarning(latestCm: latestHeight, tallestMeasuredCm: heights.max(),
                                                            rememberedPeakCm: profile.tallestAdultHeightCm, metric: metric) {
                Section { WarningRow(warning: warning) }
            }

            let bp = readings.filter { $0.systolic != nil && $0.diastolic != nil }.prefix(60)
            if bp.count >= 2 {
                Section("Blood pressure") {
                    Chart {
                        ForEach(Array(bp)) { r in
                            LineMark(x: .value("Date", r.date), y: .value("mmHg", r.systolic ?? 0))
                                .foregroundStyle(by: .value("Reading", "Systolic"))
                            LineMark(x: .value("Date", r.date), y: .value("mmHg", r.diastolic ?? 0))
                                .foregroundStyle(by: .value("Reading", "Diastolic"))
                        }
                    }
                    .frame(height: 180)
                }
            }

            let weights = readings.filter { $0.weightKg != nil }.prefix(60)
            if weights.count >= 2 {
                Section("Weight") {
                    Chart(Array(weights)) { r in
                        LineMark(x: .value("Date", r.date), y: .value("Weight", displayWeight(r)))
                        PointMark(x: .value("Date", r.date), y: .value("Weight", displayWeight(r)))
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 160)
                }
            }

            Section {
                Button { showingAdd = true } label: { Label("Add a reading", systemImage: "plus.circle.fill") }
                if readings.isEmpty { Text("No readings yet.").foregroundStyle(.secondary) }
                ForEach(readings) { r in
                    VitalRow(reading: r, metric: metric, latestHeightCm: latestHeight)
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(readings[i]) }
                    try? context.save()
                }
            } header: {
                Text("Readings")
            } footer: {
                Text("Measure your height every year, standing straight against a wall without shoes. Losing height can be a sign of a spine fracture.")
            }
        }
        .navigationTitle("Vitals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink { HeightSettingsView(profile: profile) } label: { Image(systemName: "ruler") }
                    .accessibilityLabel("Tallest adult height")
            }
        }
        .sheet(isPresented: $showingAdd) { LogVitalsView(profile: profile) }
    }

    private func displayWeight(_ r: VitalReading) -> Double {
        let kg = r.weightKg ?? 0
        return metric ? kg : kg / BodyMeasures.kgPerPound
    }
}

private struct VitalRow: View {
    let reading: VitalReading
    let metric: Bool
    let latestHeightCm: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reading.date.shortDateTime).font(.caption).foregroundStyle(.secondary)
            if let s = reading.systolic, let d = reading.diastolic, let category = reading.bloodPressureCategory {
                HStack {
                    Text("BP \(s)/\(d)").font(.subheadline.bold())
                    Text(category.label).font(.caption).foregroundStyle(category >= .stage2 || category == .low ? Color.red : Color.secondary)
                }
            }
            HStack(spacing: 12) {
                if let hr = reading.heartRate { Text("Pulse \(hr)") }
                if let w = reading.weightKg { Text(BodyMeasures.formatWeight(w, metric: metric)) }
                if let h = reading.heightCm { Text(BodyMeasures.formatHeight(h, metric: metric)) }
            }
            .font(.subheadline)
            if let w = reading.weightKg, let h = reading.heightCm ?? latestHeightCm, let bmi = BodyMeasures.bmi(weightKg: w, heightCm: h) {
                Text(String(format: "BMI %.1f — %@", bmi, BodyMeasures.bmiLabel(bmi))).font(.caption).foregroundStyle(.secondary)
            }
            if !reading.note.isEmpty { Text(reading.note).font(.caption) }
        }
    }
}

struct LogVitalsView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \VitalReading.date, order: .reverse) private var readings: [VitalReading]

    @State private var date = Date()
    @State private var systolic: Int?
    @State private var diastolic: Int?
    @State private var heartRate: Int?
    @State private var weight: Double?
    @State private var heightFeet: Int?
    @State private var heightInches: Double?
    @State private var heightCm: Double?
    @State private var note = ""

    private var metric: Bool { profile.usesMetricUnits }

    private var resolvedHeightCm: Double? {
        if metric { return heightCm }
        guard heightFeet != nil || heightInches != nil else { return nil }
        let inches = Double(heightFeet ?? 0) * 12 + (heightInches ?? 0)
        return inches > 0 ? inches * BodyMeasures.cmPerInch : nil
    }

    private var resolvedWeightKg: Double? {
        guard let weight, weight > 0 else { return nil }
        return metric ? weight : weight * BodyMeasures.kgPerPound
    }

    private var warnings: [SafetyWarning] {
        var result: [SafetyWarning] = []
        if let s = systolic, let d = diastolic, let advice = BloodPressureCategory.classify(systolic: s, diastolic: d).advice {
            result.append(advice)
        }
        if let hr = heartRate, let note = BodyMeasures.heartRateNote(hr) { result.append(note) }
        if let h = resolvedHeightCm,
           let w = BodyMeasures.heightLossWarning(latestCm: h, tallestMeasuredCm: readings.compactMap(\.heightCm).max(),
                                                  rememberedPeakCm: profile.tallestAdultHeightCm, metric: metric) {
            result.append(w)
        }
        if let w = resolvedWeightKg, let h = resolvedHeightCm ?? readings.compactMap(\.heightCm).first,
           let bmi = BodyMeasures.bmi(weightKg: w, heightCm: h), bmi < 18.5 {
            result.append(SafetyWarning(id: "bmi-low", severity: .info, message: "A BMI under 18.5 is a risk factor for bone loss and fractures. Talk to your doctor if you've lost weight without trying."))
        }
        return result.sortedBySeverity
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("When", selection: $date, in: ...Date())
                }
                Section("Blood pressure and pulse") {
                    OptionalIntField(title: "Systolic (top)", value: $systolic, unit: "mmHg")
                    OptionalIntField(title: "Diastolic (bottom)", value: $diastolic, unit: "mmHg")
                    OptionalIntField(title: "Pulse", value: $heartRate, unit: "bpm")
                }
                Section("Weight and height") {
                    OptionalNumberField(title: "Weight", value: $weight, unit: metric ? "kg" : "lb")
                    if metric {
                        OptionalNumberField(title: "Height", value: $heightCm, unit: "cm")
                    } else {
                        OptionalIntField(title: "Height", value: $heightFeet, unit: "ft")
                        OptionalNumberField(title: "", value: $heightInches, unit: "in")
                    }
                }
                Section("Notes") {
                    TextField("For example: felt dizzy on standing", text: $note, axis: .vertical)
                }
                if !warnings.isEmpty {
                    Section { ForEach(warnings) { WarningRow(warning: $0) } }
                }
            }
            .navigationTitle("Add vitals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold().disabled(isEmpty) }
            }
        }
    }

    private var isEmpty: Bool {
        systolic == nil && diastolic == nil && heartRate == nil && resolvedWeightKg == nil && resolvedHeightCm == nil
    }

    private func save() {
        let reading = VitalReading(date: date)
        reading.systolic = systolic
        reading.diastolic = diastolic
        reading.heartRate = heartRate
        reading.weightKg = resolvedWeightKg
        reading.heightCm = resolvedHeightCm
        reading.note = note
        context.insert(reading)
        try? context.save()
        dismiss()
    }
}

struct HeightSettingsView: View {
    @Bindable var profile: PatientProfile
    @State private var value: Double?

    var body: some View {
        Form {
            Section {
                OptionalNumberField(title: "Tallest adult height", value: $value, unit: profile.usesMetricUnits ? "cm" : "in")
            } footer: {
                Text("The tallest you remember being as a young adult (for example, on your driver's license at 20). Losing 4 cm (1.5 in) or more from this height can be a sign of spine fractures.")
            }
        }
        .navigationTitle("Tallest height")
        .onAppear {
            if let cm = profile.tallestAdultHeightCm {
                value = profile.usesMetricUnits ? cm : (cm / BodyMeasures.cmPerInch * 10).rounded() / 10
            }
        }
        .onChange(of: value) { _, v in
            guard let v, v > 0 else { profile.tallestAdultHeightCm = nil; return }
            profile.tallestAdultHeightCm = profile.usesMetricUnits ? v : v * BodyMeasures.cmPerInch
        }
    }
}

// MARK: - Labs

struct LabListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LabResult.date, order: .reverse) private var labs: [LabResult]
    @State private var showingAdd = false

    var body: some View {
        List {
            Section {
                Button { showingAdd = true } label: { Label("Add a lab result", systemImage: "plus.circle.fill") }
            } footer: {
                Text("Copy results from your patient portal or lab report. Reference ranges vary between laboratories — use the range printed on your report.")
            }
            ForEach(LabTest.allCases) { test in
                let results = labs.filter { $0.testRaw == test.rawValue }
                if !results.isEmpty {
                    Section(test.name) {
                        ForEach(results) { r in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("\(r.value.formatted()) \(test.unit)").font(.subheadline.bold())
                                    Spacer()
                                    Text(r.date.shortDate).font(.caption).foregroundStyle(.secondary)
                                }
                                if let note = test.note(for: r.value) { Text(note).font(.caption).foregroundStyle(.secondary) }
                                if !r.note.isEmpty { Text(r.note).font(.caption) }
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets { context.delete(results[i]) }
                            try? context.save()
                        }
                    }
                }
            }
        }
        .navigationTitle("Lab results")
        .sheet(isPresented: $showingAdd) { AddLabView() }
    }
}

private struct AddLabView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var test: LabTest = .vitaminD
    @State private var value: Double?
    @State private var date = Date()
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Test", selection: $test) {
                    ForEach(LabTest.allCases) { Text($0.name).tag($0) }
                }
                OptionalNumberField(title: "Result", value: $value, unit: test.unit)
                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                TextField("Notes (e.g. lab's reference range)", text: $note, axis: .vertical)
                if let value, let text = test.note(for: value) {
                    Section { Text(text).font(.subheadline) }
                }
            }
            .navigationTitle("Add lab result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let value else { return }
                        let lab = LabResult(date: date, test: test, value: value)
                        lab.note = note
                        context.insert(lab)
                        try? context.save()
                        dismiss()
                    }
                    .bold().disabled(value == nil)
                }
            }
        }
    }
}
