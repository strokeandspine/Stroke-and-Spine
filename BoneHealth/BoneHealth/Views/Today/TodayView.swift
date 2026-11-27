import SwiftUI
import SwiftData

struct TodayView: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \MedicationPlan.startedOn) private var plans: [MedicationPlan]
    @Query(sort: \SupplementIntake.takenAt, order: .reverse) private var intakes: [SupplementIntake]
    @Query(sort: \ExerciseLog.date, order: .reverse) private var exercise: [ExerciseLog]
    @Query(sort: \FallRecord.date, order: .reverse) private var falls: [FallRecord]
    @Query(sort: \FallRiskScreen.date, order: .reverse) private var screens: [FallRiskScreen]
    @Query(sort: \VitalReading.date) private var vitals: [VitalReading]
    @Query(sort: \PainEntry.date, order: .reverse) private var pain: [PainEntry]
    @Query(sort: \RadiologyReport.date, order: .reverse) private var reports: [RadiologyReport]

    @State private var sheet: TodaySheet?

    enum TodaySheet: String, Identifiable {
        case supplement, pain, fall, exercise, vitals
        var id: String { rawValue }
    }

    private var activePlans: [MedicationPlan] { plans.filter(\.isActive) }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let part = hour < 12 ? "Good morning" : (hour < 18 ? "Good afternoon" : "Good evening")
        return profile.preferredName.isEmpty ? part : "\(part), \(profile.preferredName)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    alertsCard
                    medicinesCard
                    supplementsCard
                    exerciseCard
                    quickActions
                    dexaCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(greeting)
            .sheet(item: $sheet) { which in
                switch which {
                case .supplement: LogSupplementView(profile: profile)
                case .pain: LogPainView(profile: profile)
                case .fall: LogFallView()
                case .exercise: LogExerciseView()
                case .vitals: LogVitalsView(profile: profile)
                }
            }
        }
    }

    // MARK: Alerts drawn from every part of the app

    private var alerts: [SafetyWarning] {
        var result: [SafetyWarning] = []
        for plan in activePlans {
            guard let drug = plan.drug, let status = plan.status() else { continue }
            if status.state == .urgent {
                result.append(SafetyWarning(id: "med-\(plan.drugID)", severity: .stop, message: "\(drug.genericName): \(status.message)"))
            }
            result += MedicationSchedule.durationNotes(drug: drug, startedOn: plan.startedOn)
        }
        let heights = vitals.compactMap(\.heightCm)
        if let warning = BodyMeasures.heightLossWarning(latestCm: vitals.last(where: { $0.heightCm != nil })?.heightCm,
                                                        tallestMeasuredCm: heights.max(),
                                                        rememberedPeakCm: profile.tallestAdultHeightCm,
                                                        metric: profile.usesMetricUnits) {
            result.append(warning)
        }
        result += FallRisk.recommendations(falls: falls.map(\.summaryInput), latestChecklistScore: screens.first?.score)
            .filter { $0.severity >= .caution }
        return result.sortedBySeverity
    }

    @ViewBuilder private var alertsCard: some View {
        let current = alerts
        if !current.isEmpty {
            Card {
                Label("Worth knowing", systemImage: "bell.badge").font(.headline)
                ForEach(current) { WarningRow(warning: $0) }
            }
        }
    }

    // MARK: Medicines

    private var medicinesCard: some View {
        Card {
            HStack {
                Label("Bone medicines", systemImage: "pills").font(.headline)
                Spacer()
                NavigationLink("All") { MedicinesView(profile: profile, embedded: true) }.font(.subheadline)
            }
            if activePlans.isEmpty {
                Text("Add the osteoporosis medicine you take to see when each dose is due.").font(.subheadline).foregroundStyle(.secondary)
                NavigationLink { DrugLibraryView(profile: profile) } label: { Label("Browse medicines", systemImage: "books.vertical") }
            }
            ForEach(activePlans) { plan in
                if let drug = plan.drug, let status = plan.status() {
                    NavigationLink { MedicationPlanDetailView(plan: plan, profile: profile) } label: {
                        HStack {
                            Circle().fill(ScaleColor.color(for: status.state)).frame(width: 10, height: 10)
                            VStack(alignment: .leading) {
                                Text(drug.genericName).font(.subheadline.bold())
                                Text(status.message).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Supplements

    private var supplementsCard: some View {
        let statuses = profile.supplementChecker.status(records: intakes.map(\.record), on: Date())
        return Card {
            HStack {
                Label("Today's calcium, vitamin D and magnesium", systemImage: "chart.bar").font(.headline)
                Spacer()
            }
            ForEach(statuses) { status in
                ProgressRow(title: status.nutrient.name,
                            valueText: "\(status.nutrient.format(status.total)) of \(status.nutrient.format(status.target))",
                            fraction: status.fraction,
                            tint: status.level == .overLimit ? .red : (status.level == .onTarget ? .green : .accentColor))
            }
            Button { sheet = .supplement } label: { Label("Log a supplement or food", systemImage: "plus.circle.fill") }
        }
    }

    // MARK: Exercise

    private var exerciseCard: some View {
        let week = WeeklyExerciseProgress.compute(exercise.map(\.record))
        return Card {
            Label("This week's exercise", systemImage: "figure.walk").font(.headline)
            ProgressRow(title: "Weight-bearing", valueText: "\(week.aerobicMinutes) of \(WeeklyExerciseProgress.aerobicGoal) min",
                        fraction: Double(week.aerobicMinutes) / Double(WeeklyExerciseProgress.aerobicGoal))
            ProgressRow(title: "Strength", valueText: "\(week.strengthDays) of \(WeeklyExerciseProgress.strengthGoal) days",
                        fraction: Double(week.strengthDays) / Double(WeeklyExerciseProgress.strengthGoal))
            ProgressRow(title: "Balance", valueText: "\(week.balanceMinutes) of \(WeeklyExerciseProgress.balanceGoal) min",
                        fraction: Double(week.balanceMinutes) / Double(WeeklyExerciseProgress.balanceGoal))
        }
    }

    // MARK: Quick actions

    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            quickButton("Pain score", "bolt.heart", .pain)
            quickButton("Log exercise", "figure.strengthtraining.functional", .exercise)
            quickButton("Vitals", "heart.text.square", .vitals)
            quickButton("Record a fall", "figure.fall", .fall)
        }
    }

    private func quickButton(_ title: String, _ symbol: String, _ target: TodaySheet) -> some View {
        Button { sheet = target } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.title2)
                Text(title).font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: Latest DEXA

    @ViewBuilder private var dexaCard: some View {
        if let dexa = reports.first(where: { $0.kind == .dexa }) {
            let lowest = BoneDensity.lowest(dexa.dexaResults)
            NavigationLink { RadiologyDetailView(report: dexa, profile: profile) } label: {
                Card {
                    Label("Latest DEXA", systemImage: "figure.stand").font(.headline)
                    Text(dexa.date.shortDate).font(.subheadline).foregroundStyle(.secondary)
                    if let lowest, let t = lowest.tScore {
                        let category = BoneDensity.category(tScore: t)
                        Text("Lowest T-score \(t.scoreText) (\(lowest.site.shortName))").font(.subheadline.bold())
                        Text(category.title).font(.subheadline).foregroundStyle(ScaleColor.color(for: category))
                    }
                    let months = Calendar.current.monthsBetween(dexa.date, Date())
                    if months >= 24 {
                        Text("It's been \(months / 12) years since your last DEXA. Ask your doctor whether it's time for another.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
