import SwiftUI
import SwiftData

struct TodayView: View {
    @Bindable var profile: PatientProfile

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query(sort: \QuestionnaireResponse.date, order: .reverse) private var responses: [QuestionnaireResponse]
    @Query(sort: \RedFlagCheck.date, order: .reverse) private var redFlagChecks: [RedFlagCheck]

    @State private var health = HealthData.shared
    @State private var showingCheckIn = false
    @State private var showingRedFlags = false
    @State private var showingDose = false

    private var todaysCheckIn: DailyCheckIn? {
        checkIns.first { Calendar.current.isDateInToday($0.date) }
    }

    private var dueQuestionnaires: [Questionnaire] {
        Questionnaire.all.filter { q in
            guard let last = responses.first(where: { $0.instrumentRaw == q.id.rawValue }) else { return true }
            let days = Calendar.current.dateComponents([.day], from: last.date, to: Date()).day ?? 0
            return days >= q.recommendedIntervalDays
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if redFlagChecks.isEmpty {
                        firstSafetyCheckCard
                    }
                    checkInCard
                    if let summary = Insights.weeklyPainSummary(checkIns.map { Insights.DailyValue(date: $0.date, value: Double($0.backPain)) }) {
                        Card {
                            Label("This week", systemImage: "chart.line.uptrend.xyaxis").font(.headline)
                            Text(summary)
                        }
                    }
                    NavigationLink { TrendsView() } label: {
                        Card {
                            HStack {
                                Label("See your trends", systemImage: "chart.xyaxis.line").font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    healthCard
                    if !dueQuestionnaires.isEmpty { questionnairesCard }
                    quickActions
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(greeting)
            .sheet(isPresented: $showingCheckIn) { CheckInView(existing: todaysCheckIn) }
            .sheet(isPresented: $showingRedFlags) { RedFlagCheckView() }
            .sheet(isPresented: $showingDose) { LogDoseView(profile: profile) }
            .task { await health.refresh() }
            .refreshable { await health.refresh() }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let part = hour < 12 ? "Good morning" : hour < 18 ? "Good afternoon" : "Good evening"
        return profile.preferredName.isEmpty ? part : "\(part), \(profile.preferredName)"
    }

    private var firstSafetyCheckCard: some View {
        Card {
            Label("Start with a quick safety check", systemImage: "exclamationmark.shield").font(.headline)
            Text("A few yes/no questions about warning signs that need a doctor's attention. It takes about a minute.")
            Button("Check warning signs") { showingRedFlags = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var checkInCard: some View {
        Card {
            if let today = todaysCheckIn {
                HStack {
                    Label("Today's check-in", systemImage: "checkmark.circle.fill")
                        .font(.headline).foregroundStyle(.green)
                    Spacer()
                    Button("Edit") { showingCheckIn = true }
                }
                HStack(spacing: 0) {
                    metric("Back", today.backPain)
                    metric("Leg", today.legPain)
                    metric("Sleep", today.sleepQuality, higherIsBetter: true)
                    metric("Mood", today.mood, higherIsBetter: true)
                }
                if today.isFlare {
                    Label("Flare logged", systemImage: "flame").foregroundStyle(.orange).font(.subheadline)
                }
            } else {
                Label("Daily check-in", systemImage: "square.and.pencil").font(.headline)
                Text("How are your back, sleep and mood today?").foregroundStyle(.secondary)
                Button { showingCheckIn = true } label: {
                    Text("Check in").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    private func metric(_ title: String, _ value: Int, higherIsBetter: Bool = false) -> some View {
        VStack {
            Text("\(value)").font(.title.bold()).monospacedDigit()
                .foregroundStyle(ScaleColor.color(for: value, higherIsBetter: higherIsBetter))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var healthCard: some View {
        if health.isAvailable {
            Card {
                Label("From Apple Health", systemImage: "heart.text.square").font(.headline)
                if health.hasRequested {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(health.stepsToday.map { "\(Int($0))" } ?? "—").font(.title2.bold())
                            Text("steps today").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(health.sleepLastNightHours.map { String(format: "%.1f h", $0) } ?? "—").font(.title2.bold())
                            Text("asleep last night").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                } else {
                    Text("See how your steps and sleep relate to your pain.").foregroundStyle(.secondary)
                    Button("Connect Apple Health") { Task { await health.requestAccess() } }
                }
            }
        }
    }

    private var questionnairesCard: some View {
        Card {
            Label("Due questionnaires", systemImage: "list.clipboard").font(.headline)
            ForEach(dueQuestionnaires) { q in
                NavigationLink {
                    QuestionnaireView(questionnaire: q)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(q.shortTitle)
                            Text("\(q.items.count) questions").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            Button { showingDose = true } label: {
                Label("Log a medicine", systemImage: "pills").frame(maxWidth: .infinity)
            }
            Button { showingRedFlags = true } label: {
                Label("New symptoms?", systemImage: "exclamationmark.shield").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}

struct CheckInView: View {
    var existing: DailyCheckIn?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var backPain = 0
    @State private var legPain = 0
    @State private var worstPain = 0
    @State private var sleepQuality = 5
    @State private var painWokeMe = false
    @State private var mood = 5
    @State private var tags: [String] = []
    @State private var isFlare = false
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ScaleSlider(title: "Back pain", value: $backPain)
                    ScaleSlider(title: "Leg pain", value: $legPain)
                    ScaleSlider(title: "Worst pain", value: $worstPain)
                } header: {
                    Text("Pain over the last 24 hours")
                }
                Section("Last night") {
                    ScaleSlider(title: "Sleep quality", value: $sleepQuality, lowLabel: "Very poor", highLabel: "Very good", higherIsBetter: true)
                    Toggle("Pain woke me up", isOn: $painWokeMe)
                }
                Section("Mood") {
                    ScaleSlider(title: "Overall mood", value: $mood, lowLabel: "Very low", highLabel: "Very good", higherIsBetter: true)
                }
                Section("What affected your back today? (optional)") {
                    TagPicker(options: DailyCheckIn.suggestedTags, selection: $tags)
                    Toggle(isOn: $isFlare) { Label("I'm having a flare-up", systemImage: "flame") }
                    TextField("Notes", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
            }
            .onAppear(perform: load)
            .onChange(of: backPain) { _, new in worstPain = max(worstPain, new) }
            .onChange(of: legPain) { _, new in worstPain = max(worstPain, new) }
        }
    }

    private func load() {
        guard let e = existing else { return }
        backPain = e.backPain; legPain = e.legPain; worstPain = e.worstPain
        sleepQuality = e.sleepQuality; painWokeMe = e.painWokeMe; mood = e.mood
        tags = e.tags; isFlare = e.isFlare; note = e.note
    }

    private func save() {
        let entry = existing ?? DailyCheckIn()
        entry.backPain = backPain
        entry.legPain = legPain
        entry.worstPain = max(worstPain, backPain, legPain)
        entry.sleepQuality = sleepQuality
        entry.painWokeMe = painWokeMe
        entry.mood = mood
        entry.tags = tags
        entry.isFlare = isFlare
        entry.note = note
        if existing == nil { context.insert(entry) }
        try? context.save()
        dismiss()
    }
}
