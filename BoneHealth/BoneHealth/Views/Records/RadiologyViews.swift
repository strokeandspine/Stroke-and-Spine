import SwiftUI
import SwiftData
import PhotosUI
import Charts

struct RadiologyListView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \RadiologyReport.date, order: .reverse) private var reports: [RadiologyReport]
    @State private var adding = false

    var body: some View {
        List {
            Section {
                Button { adding = true } label: { Label("Add a report or scan", systemImage: "plus.circle.fill") }
                NavigationLink { DexaExplainerView() } label: { Label("Understanding your DEXA results", systemImage: "questionmark.circle") }
            }
            Section("Reports") {
                if reports.isEmpty {
                    Text("Add your DEXA scans, spine X-rays, VFA, CT, MRI and other imaging reports. You can attach photos of the printed report.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                ForEach(reports) { report in
                    NavigationLink { RadiologyDetailView(report: report, profile: profile) } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(report.title).font(.subheadline.bold())
                                Text([report.date.shortDate, report.facility].filter { !$0.isEmpty }.joined(separator: " · "))
                                    .font(.caption).foregroundStyle(.secondary)
                                if report.kind == .dexa, let lowest = BoneDensity.lowest(report.dexaResults), let t = lowest.tScore {
                                    Text("Lowest T-score \(t.scoreText) at \(lowest.site.shortName.lowercased())").font(.caption)
                                } else if !report.impression.isEmpty {
                                    Text(report.impression).font(.caption).lineLimit(2)
                                }
                            }
                        } icon: {
                            Image(systemName: report.kind.symbol)
                        }
                    }
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(reports[i]) }
                    try? context.save()
                }
            }
        }
        .navigationTitle("Radiology")
        .sheet(isPresented: $adding) { EditRadiologyView(report: nil) }
    }
}

struct RadiologyDetailView: View {
    @Bindable var report: RadiologyReport
    @Bindable var profile: PatientProfile

    @Query(sort: \RadiologyReport.date) private var allReports: [RadiologyReport]
    @Query private var fractures: [FractureRecord]
    @State private var editing = false
    @State private var viewing: ReportAttachment?

    private var hasFragilityFracture: Bool { fractures.contains { $0.cause.isFragility && $0.date <= report.date } }

    private var previousDexa: RadiologyReport? {
        allReports.filter { $0.kind == .dexa && $0.date < report.date }.last
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: report.date.shortDate)
                if !report.bodyPart.isEmpty { LabeledContent("Body part", value: report.bodyPart) }
                if !report.facility.isEmpty { LabeledContent("Facility", value: report.facility) }
                if !report.orderedBy.isEmpty { LabeledContent("Ordered by", value: report.orderedBy) }
                if !report.machine.isEmpty { LabeledContent("Machine", value: report.machine) }
            }

            if report.kind == .dexa { dexaSections }

            if !report.impression.isEmpty {
                Section("Impression / findings") { Text(report.impression) }
            }
            if !report.notes.isEmpty {
                Section("My notes") { Text(report.notes) }
            }
            if !report.attachments.isEmpty {
                Section("Photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(report.attachments) { a in
                                if let image = UIImage(data: a.imageData) {
                                    Button { viewing = a } label: {
                                        Image(uiImage: image).resizable().scaledToFill()
                                            .frame(width: 110, height: 140).clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(report.kind.label)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { Button("Edit") { editing = true } }
        .sheet(isPresented: $editing) { EditRadiologyView(report: report) }
        .sheet(item: $viewing) { a in
            NavigationStack {
                ScrollView([.horizontal, .vertical]) {
                    if let image = UIImage(data: a.imageData) { Image(uiImage: image) }
                }
                .toolbar { Button("Done") { viewing = nil } }
            }
        }
    }

    @ViewBuilder private var dexaSections: some View {
        let results = report.dexaResults
        let useT = BoneDensity.usesTScore(age: profile.age, sex: profile.sex, isPostmenopausal: profile.isPostmenopausal)
        Section {
            ForEach(results) { r in
                VStack(alignment: .leading, spacing: 4) {
                    Text(r.label).font(.subheadline.bold())
                    HStack(spacing: 16) {
                        if let bmd = r.bmd { Text(String(format: "BMD %.3f g/cm²", bmd)) }
                        if let t = r.tScore { Text("T \(t.scoreText)") }
                        if let z = r.zScore { Text("Z \(z.scoreText)") }
                    }
                    .font(.subheadline).monospacedDigit()
                    if useT, let t = r.tScore {
                        let c = BoneDensity.category(tScore: t)
                        Text(c.title).font(.caption).foregroundStyle(ScaleColor.color(for: c))
                    } else if !useT, let z = r.zScore {
                        Text(BoneDensity.isZScoreBelowExpected(z) ? "Below the expected range for age" : "Within the expected range for age")
                            .font(.caption).foregroundStyle(BoneDensity.isZScoreBelowExpected(z) ? Color.orange : Color.green)
                    }
                }
            }
        } header: {
            Text("Results")
        } footer: {
            Text(useT ? "T-scores are used for postmenopausal women and men 50 and older." : "For premenopausal women and men under 50, the Z-score is used rather than the T-score.")
        }

        if useT, let overall = BoneDensity.overallCategory(results, hasFragilityFracture: hasFragilityFracture) {
            Section("What this means") {
                Text(overall.title).font(.headline).foregroundStyle(ScaleColor.color(for: overall))
                Text(overall.range).font(.subheadline)
                Text("Based on your lowest T-score. Your doctor will interpret it together with your risk factors and fracture history.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        if report.trabecularBoneScore != nil || report.fraxMajorPercent != nil || report.fraxHipPercent != nil {
            Section("Other results") {
                if let tbs = report.trabecularBoneScore { LabeledContent("Trabecular bone score", value: String(format: "%.3f", tbs)) }
                if let m = report.fraxMajorPercent { LabeledContent("FRAX major fracture (10-yr)", value: "\(m.formatted())%") }
                if let h = report.fraxHipPercent { LabeledContent("FRAX hip fracture (10-yr)", value: "\(h.formatted())%") }
            }
        }
        if let previous = previousDexa {
            let changes = results.compactMap { new -> BoneDensity.Change? in
                guard let old = previous.dexaResults.first(where: { $0.site == new.site && $0.side == new.side }) else { return nil }
                return BoneDensity.change(from: old, to: new)
            }
            if !changes.isEmpty {
                Section {
                    ForEach(changes, id: \.self) { c in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(c.site.name).font(.subheadline.bold())
                            Text(c.summary).font(.caption)
                        }
                    }
                    if !previous.machine.isEmpty && !report.machine.isEmpty && previous.machine.lowercased() != report.machine.lowercased()
                        || !previous.facility.isEmpty && !report.facility.isEmpty && previous.facility.lowercased() != report.facility.lowercased() {
                        WarningRow(warning: SafetyWarning(id: "different-machine", severity: .info,
                            message: "These scans were done at different centres or on different machines, so the comparison may not be reliable."))
                    }
                } header: {
                    Text("Change since \(previous.date.shortDate)")
                } footer: {
                    Text("Compares bone density (BMD) using typical least significant changes. Your DEXA centre can tell you its exact values.")
                }
            }
        }
    }
}

struct EditRadiologyView: View {
    let report: RadiologyReport?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var kind: RadiologyKind = .dexa
    @State private var date = Date()
    @State private var bodyPart = ""
    @State private var facility = ""
    @State private var orderedBy = ""
    @State private var machine = ""
    @State private var impression = ""
    @State private var notes = ""
    @State private var results: [DexaSiteResult] = DexaSite.allCases.filter { $0 != .forearm }.map { DexaSiteResult(site: $0) }
    @State private var tbs: Double?
    @State private var fraxMajor: Double?
    @State private var fraxHip: Double?
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var newImages: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(RadiologyKind.allCases) { Text($0.label).tag($0) }
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                    if kind != .dexa { TextField("Body part (e.g. thoracic spine)", text: $bodyPart) }
                    TextField("Facility", text: $facility)
                    TextField("Ordered by", text: $orderedBy)
                    if kind == .dexa || kind == .vfa {
                        Picker("Machine", selection: $machine) {
                            Text("Not sure").tag("")
                            Text("Hologic").tag("Hologic")
                            Text("GE Lunar").tag("GE Lunar")
                            Text("Other").tag("Other")
                        }
                    }
                }

                if kind == .dexa {
                    ForEach($results) { $r in
                        Section {
                            Picker("Site", selection: $r.site) {
                                ForEach(DexaSite.allCases) { Text($0.name).tag($0) }
                            }
                            if r.site != .lumbarSpine {
                                Picker("Side", selection: $r.side) {
                                    Text("Not stated").tag("")
                                    Text("Left").tag("Left")
                                    Text("Right").tag("Right")
                                }
                            }
                            OptionalNumberField(title: "BMD", value: $r.bmd, unit: "g/cm²")
                            OptionalNumberField(title: "T-score", value: $r.tScore, allowsNegative: true)
                            OptionalNumberField(title: "Z-score", value: $r.zScore, allowsNegative: true)
                        }
                    }
                    .onDelete { results.remove(atOffsets: $0) }
                    Section {
                        Button("Add another site") { results.append(DexaSiteResult(site: .forearm)) }
                    } footer: {
                        Text("Copy the numbers from the results table on your report. Leave blank anything that isn't there. T-scores are usually negative — type the minus sign.")
                    }
                    Section("Also on the report (optional)") {
                        OptionalNumberField(title: "Trabecular bone score", value: $tbs)
                        OptionalNumberField(title: "FRAX major fracture", value: $fraxMajor, unit: "%")
                        OptionalNumberField(title: "FRAX hip fracture", value: $fraxHip, unit: "%")
                    }
                }

                Section("Impression / findings") {
                    TextField("Copy the radiologist's impression", text: $impression, axis: .vertical).lineLimit(3...10)
                }
                Section("My notes") {
                    TextField("Questions for my doctor, what I was told…", text: $notes, axis: .vertical)
                }
                Section {
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                        Label("Attach photos of the report", systemImage: "doc.viewfinder")
                    }
                    if !newImages.isEmpty { Text("\(newImages.count) new photo\(newImages.count == 1 ? "" : "s") will be attached").font(.caption) }
                    if let report, !report.attachments.isEmpty {
                        Text("\(report.attachments.count) photo\(report.attachments.count == 1 ? "" : "s") already attached").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(report == nil ? "Add report" : "Edit report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
            .onAppear(perform: load)
            .onChange(of: pickerItems) { _, items in
                Task {
                    var loaded: [Data] = []
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self) { loaded.append(data) }
                    }
                    newImages = loaded
                }
            }
        }
    }

    private func load() {
        guard let report else { return }
        kind = report.kind
        date = report.date
        bodyPart = report.bodyPart
        facility = report.facility
        orderedBy = report.orderedBy
        machine = report.machine
        impression = report.impression
        notes = report.notes
        if !report.dexaResults.isEmpty { results = report.dexaResults }
        tbs = report.trabecularBoneScore
        fraxMajor = report.fraxMajorPercent
        fraxHip = report.fraxHipPercent
    }

    private func save() {
        let target = report ?? RadiologyReport(kind: kind, date: date)
        target.kind = kind
        target.date = date
        target.bodyPart = kind == .dexa ? "" : bodyPart
        target.facility = facility
        target.orderedBy = orderedBy
        target.machine = machine
        target.impression = impression
        target.notes = notes
        target.dexaResults = kind == .dexa ? results.filter { $0.bmd != nil || $0.tScore != nil || $0.zScore != nil } : []
        target.trabecularBoneScore = kind == .dexa ? tbs : nil
        target.fraxMajorPercent = kind == .dexa ? fraxMajor : nil
        target.fraxHipPercent = kind == .dexa ? fraxHip : nil
        if report == nil { context.insert(target) }
        for data in newImages {
            let attachment = ReportAttachment(imageData: data)
            context.insert(attachment)
            attachment.report = target
        }
        try? context.save()
        dismiss()
    }
}

/// T-scores over time for each site.
struct DexaTrendView: View {
    @Bindable var profile: PatientProfile
    @Query(sort: \RadiologyReport.date) private var reports: [RadiologyReport]

    private struct Point: Identifiable {
        let id = UUID()
        let date: Date
        let site: DexaSite
        let tScore: Double
    }

    private var points: [Point] {
        reports.filter { $0.kind == .dexa }.flatMap { r in
            r.dexaResults.compactMap { res in res.tScore.map { Point(date: r.date, site: res.site, tScore: $0) } }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if points.isEmpty {
                    ContentUnavailableView("No DEXA results yet", systemImage: "chart.line.uptrend.xyaxis",
                                           description: Text("Add a DEXA scan in Radiology reports to see your T-scores over time."))
                } else {
                    Card {
                        Text("T-scores").font(.headline)
                        Chart {
                            RuleMark(y: .value("Osteopenia", -1.0)).foregroundStyle(.orange.opacity(0.5)).lineStyle(StrokeStyle(dash: [4]))
                            RuleMark(y: .value("Osteoporosis", -2.5)).foregroundStyle(.red.opacity(0.5)).lineStyle(StrokeStyle(dash: [4]))
                            ForEach(points) { p in
                                LineMark(x: .value("Date", p.date), y: .value("T-score", p.tScore))
                                    .foregroundStyle(by: .value("Site", p.site.shortName))
                                PointMark(x: .value("Date", p.date), y: .value("T-score", p.tScore))
                                    .foregroundStyle(by: .value("Site", p.site.shortName))
                            }
                        }
                        .chartYScale(domain: .automatic(includesZero: true))
                        .frame(height: 240)
                        Text("Dashed lines: −1.0 (low bone mass) and −2.5 (osteoporosis). For tracking real change over time, your doctor compares BMD values rather than T-scores.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Bone density")
    }
}

struct DexaExplainerView: View {
    var body: some View {
        List {
            Section("How DEXA works") { Text(BoneDensity.explanation) }
            Section("T-score categories (WHO)") {
                ForEach(BoneDensityCategory.allCases, id: \.self) { c in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(c.title).font(.subheadline.bold()).foregroundStyle(ScaleColor.color(for: c))
                        Text(c.range).font(.caption)
                    }
                }
            }
            Section("Other terms on your report") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("BMD").font(.subheadline.bold())
                    Text("Bone mineral density in grams per square centimetre. The number used to measure change over time.").font(.caption)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Trabecular bone score (TBS)").font(.subheadline.bold())
                    Text("A measure of the bone's inner structure from the spine image. Above 1.31 is normal, 1.23–1.31 partly degraded, below 1.23 degraded. It can be added to FRAX.").font(.caption)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("FRAX").font(.subheadline.bold())
                    Text("Your estimated chance of a major osteoporotic fracture (hip, spine, wrist or shoulder) or a hip fracture in the next 10 years.").font(.caption)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("VFA").font(.subheadline.bold())
                    Text("Vertebral fracture assessment: a low-dose side view of the spine taken on the DEXA machine to look for spine fractures you may not know about.").font(.caption)
                }
            }
        }
        .navigationTitle("Understanding DEXA")
    }
}
