import SwiftUI
import SwiftData

/// A summary to bring to an appointment, shareable as a PDF.
struct ReportView: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \RadiologyReport.date, order: .reverse) private var reports: [RadiologyReport]
    @Query(sort: \VitalReading.date, order: .reverse) private var vitals: [VitalReading]
    @Query(sort: \FractureRecord.date, order: .reverse) private var fractures: [FractureRecord]
    @Query(sort: \MedicalHistoryEntry.title) private var history: [MedicalHistoryEntry]
    @Query(sort: \LabResult.date, order: .reverse) private var labs: [LabResult]
    @Query(sort: \MedicationPlan.startedOn) private var plans: [MedicationPlan]
    @Query(sort: \SupplementIntake.takenAt) private var intakes: [SupplementIntake]
    @Query(sort: \ExerciseLog.date) private var exercise: [ExerciseLog]
    @Query(sort: \FallRecord.date, order: .reverse) private var falls: [FallRecord]
    @Query(sort: \FallRiskScreen.date, order: .reverse) private var screens: [FallRiskScreen]
    @Query(sort: \PainEntry.date, order: .reverse) private var pain: [PainEntry]

    @State private var pdfURL: URL?

    private var data: ReportData {
        ReportData(profile: profile, reports: reports, vitals: vitals, fractures: fractures, history: history, labs: labs,
                   plans: plans, intakes: intakes, exercise: exercise, falls: falls, screens: screens, pain: pain)
    }

    var body: some View {
        ScrollView {
            ReportContent(data: data)
                .padding()
                .background(Color.white)
                .environment(\.colorScheme, .light)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Bone health summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let pdfURL {
                    ShareLink(item: pdfURL) { Label("Share PDF", systemImage: "square.and.arrow.up") }
                } else {
                    Button("Create PDF") { pdfURL = renderPDF() }
                }
            }
        }
    }

    /// Renders the summary as one long page, then slices it into US Letter pages.
    @MainActor
    private func renderPDF() -> URL? {
        let pageWidth: CGFloat = 612, pageHeight: CGFloat = 792
        let content = ReportContent(data: data)
            .padding(36)
            .frame(width: pageWidth)
            .background(Color.white)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: content)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("bone-health-summary.pdf")
        var succeeded = false
        renderer.render { size, draw in
            var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            let pages = max(1, Int((size.height / pageHeight).rounded(.up)))
            for page in 0..<pages {
                pdf.beginPDFPage(nil)
                pdf.saveGState()
                // Core Graphics' origin is bottom-left: shift the tall image so this page's slice is visible.
                pdf.translateBy(x: 0, y: pageHeight - size.height + CGFloat(page) * pageHeight)
                draw(pdf)
                pdf.restoreGState()
                pdf.endPDFPage()
            }
            pdf.closePDF()
            succeeded = true
        }
        return succeeded ? url : nil
    }
}

/// Plain values gathered for the report.
struct ReportData {
    let profile: PatientProfile
    let reports: [RadiologyReport]
    let vitals: [VitalReading]
    let fractures: [FractureRecord]
    let history: [MedicalHistoryEntry]
    let labs: [LabResult]
    let plans: [MedicationPlan]
    let intakes: [SupplementIntake]
    let exercise: [ExerciseLog]
    let falls: [FallRecord]
    let screens: [FallRiskScreen]
    let pain: [PainEntry]

    var metric: Bool { profile.usesMetricUnits }
    var latestDexa: RadiologyReport? { reports.first { $0.kind == .dexa } }
    var otherImaging: [RadiologyReport] { reports.filter { $0.kind != .dexa }.prefix(6).map { $0 } }
    var since30: Date { Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
    var since365: Date { Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date() }

    var latestBP: VitalReading? { vitals.first { $0.systolic != nil && $0.diastolic != nil } }
    var latestWeight: VitalReading? { vitals.first { $0.weightKg != nil } }
    var latestHeight: VitalReading? { vitals.first { $0.heightCm != nil } }

    var heightWarning: SafetyWarning? {
        BodyMeasures.heightLossWarning(latestCm: latestHeight?.heightCm, tallestMeasuredCm: vitals.compactMap(\.heightCm).max(),
                                       rememberedPeakCm: profile.tallestAdultHeightCm, metric: metric)
    }

    /// Average daily intake over the last 30 days that had any entry.
    func averageIntake(_ nutrient: Nutrient) -> Double? {
        let recent = intakes.filter { $0.takenAt >= since30 }
        let days = Set(recent.map { Calendar.current.startOfDay(for: $0.takenAt) })
        guard !days.isEmpty else { return nil }
        return recent.reduce(0) { $0 + $1.record.amount(of: nutrient) } / Double(days.count)
    }

    var recentPain: [PainEntry] { pain.filter { $0.date >= since30 } }
    var fallsThisYear: [FallRecord] { falls.filter { $0.date >= since365 && !$0.isNearMiss } }

    var weeklyExerciseMinutes: Int {
        let recent = exercise.filter { $0.date >= since30 }
        return Int((Double(recent.reduce(0) { $0 + $1.minutes }) / 30 * 7).rounded())
    }
}

struct ReportContent: View {
    let data: ReportData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bone health summary").font(.title2.bold())
                Text(headerLine).font(.subheadline)
                Text("Prepared \(Date().shortDate) by the patient using \(AppText.appName). Patient-entered information — please verify.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            section("Bone density") {
                if let dexa = data.latestDexa {
                    Text("DEXA \(dexa.date.shortDate)\(dexa.facility.isEmpty ? "" : " · \(dexa.facility)")\(dexa.machine.isEmpty ? "" : " · \(dexa.machine)")").font(.caption.bold())
                    ForEach(dexa.dexaResults) { r in
                        Text("\(r.label): " + [r.bmd.map { String(format: "BMD %.3f", $0) }, r.tScore.map { "T \($0.scoreText)" }, r.zScore.map { "Z \($0.scoreText)" }]
                            .compactMap { $0 }.joined(separator: ", "))
                            .font(.caption)
                    }
                    if let tbs = dexa.trabecularBoneScore { Text(String(format: "TBS %.3f", tbs)).font(.caption) }
                } else {
                    Text("No DEXA recorded.").font(.caption)
                }
                if data.profile.fraxMajorPercent != nil || data.profile.fraxHipPercent != nil {
                    Text("FRAX 10-year risk: major \(data.profile.fraxMajorPercent.map { "\($0.formatted())%" } ?? "—"), hip \(data.profile.fraxHipPercent.map { "\($0.formatted())%" } ?? "—")").font(.caption)
                }
            }

            section("Fractures") {
                if data.fractures.isEmpty { Text("None recorded.").font(.caption) }
                ForEach(data.fractures) { f in
                    Text("\(f.date.shortDate): \(f.site.label) — \(f.cause.isFragility ? "fragility" : "high-trauma")\(f.treatment.isEmpty ? "" : "; \(f.treatment)")").font(.caption)
                }
            }

            section("Risk factors") {
                let factors = data.profile.riskFactors.sorted { $0.rawValue < $1.rawValue }
                Text(factors.isEmpty ? "None selected." : factors.map(\.label).joined(separator: "; ")).font(.caption)
            }

            section("Osteoporosis medicines") {
                if data.plans.isEmpty { Text("None recorded.").font(.caption) }
                ForEach(data.plans) { plan in
                    let name = plan.drug?.genericName ?? plan.drugID
                    let range = "\(plan.startedOn.shortDate) – \(plan.stoppedOn?.shortDate ?? "current")"
                    let last = plan.lastDose.map { "; last dose \($0.shortDate)" } ?? ""
                    let next = plan.status()?.nextDue.map { "; next due \($0.shortDate)" } ?? ""
                    Text("\(name), \(plan.frequency.label.lowercased()) (\(range)\(last)\(next))").font(.caption)
                }
            }

            section("Supplements (average per logged day, last 30 days)") {
                let targets = data.profile.nutrientTargets
                ForEach(Nutrient.allCases) { n in
                    Text("\(n.name): \(data.averageIntake(n).map { n.format($0) } ?? "not logged") (target \(n.format(targets.daily[n] ?? 0)))").font(.caption)
                }
            }

            section("Vitals") {
                if let bp = data.latestBP, let s = bp.systolic, let d = bp.diastolic {
                    Text("Blood pressure \(s)/\(d) on \(bp.date.shortDate)").font(.caption)
                }
                if let w = data.latestWeight?.weightKg { Text("Weight \(BodyMeasures.formatWeight(w, metric: data.metric))").font(.caption) }
                if let h = data.latestHeight?.heightCm { Text("Height \(BodyMeasures.formatHeight(h, metric: data.metric))").font(.caption) }
                if let peak = data.profile.tallestAdultHeightCm { Text("Tallest adult height (self-reported) \(BodyMeasures.formatHeight(peak, metric: data.metric))").font(.caption) }
                if let warning = data.heightWarning { Text("⚠︎ \(warning.message)").font(.caption) }
            }

            if !data.labs.isEmpty {
                section("Latest labs") {
                    ForEach(LabTest.allCases) { test in
                        if let r = data.labs.first(where: { $0.testRaw == test.rawValue }) {
                            Text("\(test.name): \(r.value.formatted()) \(test.unit) (\(r.date.shortDate))").font(.caption)
                        }
                    }
                }
            }

            section("Falls and balance") {
                Text("Falls in the past 12 months: \(data.fallsThisYear.count) (\(data.fallsThisYear.filter(\.wasInjured).count) with injury)").font(.caption)
                if let s = data.screens.first {
                    Text("Stay Independent checklist: \(s.score)/\(FallRiskChecklist.maximum) on \(s.date.shortDate)\(FallRiskChecklist.isAtRisk(score: s.score) ? " — at risk" : "")").font(.caption)
                }
                ForEach(data.fallsThisYear.prefix(5)) { f in
                    Text("\(f.date.shortDate): \(f.location.label); \(f.causes.map(\.label).joined(separator: ", ")); \(f.injuries.map(\.label).joined(separator: ", "))").font(.caption)
                }
            }

            section("Pain (last 30 days)") {
                if data.recentPain.isEmpty {
                    Text("Not logged.").font(.caption)
                } else {
                    let avg = Double(data.recentPain.map(\.score).reduce(0, +)) / Double(data.recentPain.count)
                    Text(String(format: "Average %.1f/10, worst %d/10, %d entries", avg, data.recentPain.map(\.score).max() ?? 0, data.recentPain.count)).font(.caption)
                    if let peg = data.pain.first(where: { $0.pegScore != nil }), let score = peg.pegScore {
                        Text(String(format: "Latest PEG %.1f/10 (%@)", score, peg.date.shortDate)).font(.caption)
                    }
                    let sudden = data.recentPain.filter(\.isNewAndSudden)
                    if !sudden.isEmpty { Text("New sudden pain reported \(sudden.count) time\(sudden.count == 1 ? "" : "s")").font(.caption) }
                }
            }

            section("Exercise") {
                Text("About \(data.weeklyExerciseMinutes) minutes a week over the last 30 days").font(.caption)
            }

            if !data.otherImaging.isEmpty {
                section("Other imaging") {
                    ForEach(data.otherImaging) { r in
                        Text("\(r.date.shortDate): \(r.title)\(r.impression.isEmpty ? "" : " — \(r.impression)")").font(.caption).lineLimit(3)
                    }
                }
            }

            let conditions = data.history.filter { $0.kind == .condition || $0.kind == .surgery || $0.kind == .allergy || $0.kind == .medication }
            if !conditions.isEmpty {
                section("Medical history") {
                    ForEach(conditions) { e in
                        Text("\(e.kind.label): \(e.title)\(e.date.map { " (\($0.shortDate))" } ?? "")").font(.caption)
                    }
                }
            }
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headerLine: String {
        var parts: [String] = []
        if !data.profile.preferredName.isEmpty { parts.append(data.profile.preferredName) }
        if let age = data.profile.age { parts.append("age \(age)") }
        parts.append(data.profile.sex.label.lowercased())
        if data.profile.sex == .female { parts.append(data.profile.isPostmenopausal ? "postmenopausal" : "premenopausal") }
        parts.append(data.profile.boneStatus.label)
        return parts.joined(separator: " · ")
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.subheadline.bold())
            content()
        }
    }
}
