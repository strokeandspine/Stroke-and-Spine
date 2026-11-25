import SwiftUI
import SwiftData
import Charts

/// One-page summary to bring to an appointment, shareable as a PDF.
struct ReportView: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \DailyCheckIn.date) private var checkIns: [DailyCheckIn]
    @Query(sort: \QuestionnaireResponse.date) private var responses: [QuestionnaireResponse]
    @Query(sort: \MedicationDose.takenAt) private var doses: [MedicationDose]
    @Query(sort: \SpineHistoryEntry.date, order: .reverse) private var history: [SpineHistoryEntry]

    @State private var pdfURL: URL?

    private var data: ReportData {
        ReportData(name: profile.preferredName, painStarted: profile.painStartedOn, goals: profile.goals,
                   checkIns: checkIns, responses: responses, doses: doses, history: history)
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
        .navigationTitle("Appointment report")
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
        .onChange(of: checkIns.count) { _, _ in pdfURL = nil }
    }

    @MainActor
    private func renderPDF() -> URL? {
        let page = ReportContent(data: data)
            .padding(36)
            .frame(width: 612) // US Letter width in points
            .background(Color.white)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: page)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("stroke-and-spine-report.pdf")
        var succeeded = false
        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil)
            draw(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            succeeded = true
        }
        return succeeded ? url : nil
    }
}

/// Plain values so the report can render outside the SwiftData environment.
struct ReportData {
    var name: String
    var painStarted: Date?
    var goals: String
    var checkIns: [DailyCheckIn]
    var responses: [QuestionnaireResponse]
    var doses: [MedicationDose]
    var history: [SpineHistoryEntry]

    var since: Date { Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
    var recentCheckIns: [DailyCheckIn] { checkIns.filter { $0.date >= since } }

    func average(_ key: KeyPath<DailyCheckIn, Int>) -> String {
        let values = recentCheckIns.map { Double($0[keyPath: key]) }
        guard !values.isEmpty else { return "—" }
        return String(format: "%.1f", values.reduce(0, +) / Double(values.count))
    }

    struct MedicineUse: Identifiable { let ingredient: Ingredient; let days: Int; var id: Ingredient { ingredient } }
    struct ScoreHistory: Identifiable { let questionnaire: Questionnaire; let responses: [QuestionnaireResponse]; var id: Questionnaire.ID { questionnaire.id } }

    var scoreHistories: [ScoreHistory] {
        Questionnaire.all.compactMap { q in
            let r = responses.filter { $0.instrumentRaw == q.id.rawValue }
            return r.isEmpty ? nil : ScoreHistory(questionnaire: q, responses: r)
        }
    }

    static func details(for e: SpineHistoryEntry) -> [String] {
        var parts: [String] = [e.spinalLevels.joined(separator: ", "), e.side, e.provider, e.facility]
        if !e.implants.isEmpty { parts.append("Implants: \(e.implants)") }
        if let relief = e.reliefPercent {
            var text = "Relief: \(relief)%"
            if let weeks = e.reliefWeeks { text += " for ~\(weeks) wk" }
            parts.append(text)
        }
        if !e.complications.isEmpty { parts.append("Complications: \(e.complications)") }
        return parts.filter { !$0.isEmpty }
    }

    /// Days in the last 30 on which each ingredient was taken.
    var medicineDays: [MedicineUse] {
        let calendar = Calendar.current
        let recent = doses.filter { $0.takenAt >= since }
        return Ingredient.allCases.compactMap { ingredient in
            let days = Set(recent.filter { $0.totalAmounts.contains { $0.ingredient == ingredient } }
                .map { calendar.startOfDay(for: $0.takenAt) })
            return days.isEmpty ? nil : MedicineUse(ingredient: ingredient, days: days.count)
        }
    }
}

struct ReportContent: View {
    let data: ReportData

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Back pain summary").font(.title.bold())
                Text([data.name.isEmpty ? nil : data.name, "Prepared \(Date().shortDate)"].compactMap { $0 }.joined(separator: " · "))
                    .foregroundStyle(.secondary)
                if let started = data.painStarted {
                    Text("Pain started around \(started.shortDate)").font(.subheadline)
                }
                if !data.goals.isEmpty { Text("Goal: \(data.goals)").font(.subheadline) }
            }

            section("Last 30 days (\(data.recentCheckIns.count) check-ins)") {
                Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 4) {
                    GridRow { Text("Average back pain"); Text("\(data.average(\.backPain)) / 10").bold() }
                    GridRow { Text("Average leg pain"); Text("\(data.average(\.legPain)) / 10").bold() }
                    GridRow { Text("Average worst pain"); Text("\(data.average(\.worstPain)) / 10").bold() }
                    GridRow { Text("Average sleep quality"); Text("\(data.average(\.sleepQuality)) / 10").bold() }
                    GridRow { Text("Nights woken by pain"); Text("\(data.recentCheckIns.filter(\.painWokeMe).count)").bold() }
                    GridRow { Text("Flare-ups"); Text("\(data.recentCheckIns.filter(\.isFlare).count)").bold() }
                }
                .font(.subheadline)
                if data.recentCheckIns.count >= 2 {
                    Chart(data.recentCheckIns) { c in
                        LineMark(x: .value("Date", c.date, unit: .day), y: .value("Pain", c.backPain))
                            .foregroundStyle(by: .value("Where", "Back"))
                        LineMark(x: .value("Date", c.date, unit: .day), y: .value("Pain", c.legPain))
                            .foregroundStyle(by: .value("Where", "Leg"))
                    }
                    .chartYScale(domain: 0...10)
                    .frame(height: 140)
                }
            }

            section("Questionnaire scores") {
                if data.scoreHistories.isEmpty { Text("None completed yet").foregroundStyle(.secondary) }
                ForEach(data.scoreHistories) { row in
                    let q = row.questionnaire
                    let r = row.responses
                    let latest = r[r.count - 1]
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(q.title): \(latest.display), \(latest.severity.lowercased()) (\(latest.date.shortDate))").bold()
                        if r.count >= 2 {
                            let first = r[0]
                            Text("First recorded: \(first.display) on \(first.date.shortDate)").foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
            }

            section("Over-the-counter pain relievers (last 30 days)") {
                if data.medicineDays.isEmpty { Text("None logged").foregroundStyle(.secondary) }
                ForEach(data.medicineDays) { use in
                    Text("\(use.ingredient.name): taken on \(use.days) of 30 days").font(.subheadline)
                }
            }

            section("Spine history") {
                if data.history.isEmpty { Text("None recorded").foregroundStyle(.secondary) }
                ForEach(data.history) { e in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(e.date.shortDate) — \(e.typeName)").bold()
                        let details = ReportData.details(for: e)
                        if !details.isEmpty { Text(details.joined(separator: " · ")).foregroundStyle(.secondary) }
                    }
                    .font(.subheadline)
                }
            }

            Text("Patient-reported information recorded in the Stroke & Spine app. Not a medical record.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Divider()
            content()
        }
    }
}
