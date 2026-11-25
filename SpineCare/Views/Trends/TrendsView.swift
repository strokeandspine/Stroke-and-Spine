import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \DailyCheckIn.date) private var checkIns: [DailyCheckIn]
    @Query(sort: \QuestionnaireResponse.date) private var responses: [QuestionnaireResponse]
    @Environment(Store.self) private var store
    @State private var rangeDays = 30
    @State private var showingPaywall = false

    private var startDate: Date {
        Calendar.current.date(byAdding: .day, value: -rangeDays, to: Date()) ?? Date()
    }

    private var recent: [DailyCheckIn] { checkIns.filter { $0.date >= startDate } }

    var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Range", selection: $rangeDays) {
                        Text("30 days").tag(30)
                        Text(store.isPremium ? "90 days" : "90 days 🔒").tag(90)
                        Text(store.isPremium ? "1 year" : "1 year 🔒").tag(365)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: rangeDays) { _, days in
                        if days > 30 && !PremiumFeature.longTrends.isAvailable(isPremium: store.isPremium) {
                            rangeDays = 30
                            showingPaywall = true
                        }
                    }

                    if recent.isEmpty {
                        ContentUnavailableView("No check-ins yet", systemImage: "chart.xyaxis.line",
                                               description: Text("Your charts will appear after a few daily check-ins."))
                    } else {
                        painChart
                        sleepMoodChart
                        if store.isPremium, let note = correlationNote { Card { Label("Pattern", systemImage: "lightbulb").font(.headline); Text(note) } }
                    }
                    questionnaireCharts
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trends")
            .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private var painChart: some View {
        Card {
            Text("Pain (0–10)").font(.headline)
            Chart {
                ForEach(recent) { c in
                    LineMark(x: .value("Date", c.date, unit: .day), y: .value("Pain", c.backPain))
                        .foregroundStyle(by: .value("Where", "Back"))
                    LineMark(x: .value("Date", c.date, unit: .day), y: .value("Pain", c.legPain))
                        .foregroundStyle(by: .value("Where", "Leg"))
                    if c.isFlare {
                        PointMark(x: .value("Date", c.date, unit: .day), y: .value("Pain", c.worstPain))
                            .symbol(.diamond)
                            .foregroundStyle(.red)
                    }
                }
            }
            .chartYScale(domain: 0...10)
            .frame(height: 200)
            if recent.contains(where: \.isFlare) {
                Text("◆ = flare-up").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var sleepMoodChart: some View {
        Card {
            Text("Sleep and mood (higher is better)").font(.headline)
            Chart {
                ForEach(recent) { c in
                    LineMark(x: .value("Date", c.date, unit: .day), y: .value("Score", c.sleepQuality))
                        .foregroundStyle(by: .value("Measure", "Sleep"))
                    LineMark(x: .value("Date", c.date, unit: .day), y: .value("Score", c.mood))
                        .foregroundStyle(by: .value("Measure", "Mood"))
                }
            }
            .chartYScale(domain: 0...10)
            .frame(height: 180)
        }
    }

    /// Compares next-day pain after poor vs. good nights. Only shown with enough data.
    private var correlationNote: String? {
        let poor = recent.filter { $0.sleepQuality <= 4 }.map { Double($0.backPain) }
        let good = recent.filter { $0.sleepQuality >= 7 }.map { Double($0.backPain) }
        guard poor.count >= 5, good.count >= 5 else { return nil }
        let poorAvg = poor.reduce(0, +) / Double(poor.count)
        let goodAvg = good.reduce(0, +) / Double(good.count)
        let diff = poorAvg - goodAvg
        guard abs(diff) >= 1 else { return nil }
        return String(format: "On days after a poor night's sleep your back pain averages %.1f, compared with %.1f after a good night.", poorAvg, goodAvg)
    }

    private var questionnaireCharts: some View {
        ForEach(Questionnaire.all) { q in
            let points = responses.filter { $0.instrumentRaw == q.id.rawValue }
            if points.count >= 2 {
                Card {
                    Text(q.shortTitle).font(.headline)
                    Chart(points) { r in
                        LineMark(x: .value("Date", r.date), y: .value("Score", r.score))
                        PointMark(x: .value("Date", r.date), y: .value("Score", r.score))
                    }
                    .chartYScale(domain: 0...(points.first?.maximum ?? 100))
                    .frame(height: 150)
                    Text("Lower is better. Latest: \(points.last?.display ?? "") (\(points.last?.severity ?? ""))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}
