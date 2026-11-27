import SwiftUI
import Charts

// "Offered surgery? Explore your options" — every option for a spine condition, from conservative care
// to open surgery, with outcomes and side effects. Content: Core/TreatmentOptions*.swift.

private let shortlistKey = "treatmentOptionsShortlist"

extension ApproachTier {
    var color: Color {
        switch self {
        case .conservative: return .green
        case .interventional: return .teal
        case .minimallyInvasive: return .blue
        case .lessInvasive: return .purple
        case .traditional: return .orange
        }
    }
}

extension SideEffect.Severity {
    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .orange
        case .serious: return .red
        }
    }
}

// MARK: - Home

struct TreatmentOptionsHomeView: View {
    @AppStorage(shortlistKey) private var shortlistRaw = ""

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Been offered spine surgery?", systemImage: "signpost.right.and.left").font(.title3.bold())
                    Text("See every option for your condition — from non-operative care and injections to minimally invasive and open surgery — with how well each works and how often side effects happen.")
                        .font(.subheadline)
                    Text(TreatmentOptionsContent.disclaimer).font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Choose your condition") {
                ForEach(TreatmentGuides.all) { guide in
                    NavigationLink { ConditionGuideView(guide: guide) } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(guide.name).font(.body.weight(.medium))
                                Text("\(guide.options.count) options · \(guide.alsoCalled)").font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                        } icon: {
                            Image(systemName: guide.symbol)
                        }
                    }
                }
            }

            Section("Understanding your options") {
                NavigationLink { TierGuideView() } label: { Label("From conservative care to open surgery", systemImage: "chart.bar.doc.horizontal") }
                NavigationLink { BulletListView(title: "Reading the numbers", items: TreatmentGuides.readingTheNumbers, footer: frequencyKey) } label: { Label("How to read the numbers", systemImage: "percent") }
                NavigationLink { BulletListView(title: "Why wasn't I told?", items: TreatmentGuides.whyNotMentioned, footer: "If an option here wasn't mentioned, it's worth asking about. There is often a good reason it isn't right for you.") } label: { Label("Why an option may not have been mentioned", systemImage: "questionmark.bubble") }
                NavigationLink { BulletListView(title: "Second opinions", items: TreatmentGuides.secondOpinion, footer: nil) } label: { Label("Getting a second opinion", systemImage: "person.2") }
                NavigationLink { BulletListView(title: "Questions for your surgeon", items: TreatmentGuides.generalQuestions, footer: nil) } label: { Label("Questions to ask your surgeon", systemImage: "text.bubble") }
            }

            Section {
                NavigationLink { ShortlistView() } label: {
                    HStack {
                        Label("Options to discuss", systemImage: "bookmark")
                        Spacer()
                        Text("\(OptionShortlist(stored: shortlistRaw).items.count)").foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text("Save options as you read, then share the list with your surgeon.")
            }

            Section {
                Text("Treatment options content: \(TreatmentOptionsContent.version)").font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Treatment options")
    }

    private var frequencyKey: String {
        "How often: " + FrequencyBand.allCases.reversed().map { "\($0.label) = \($0.definition)" }.joined(separator: "; ") + "."
    }
}

struct BulletListView: View {
    let title: String
    let items: [String]
    let footer: String?

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { Text($0) }
            } footer: {
                if let footer { Text(footer) }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TierGuideView: View {
    var body: some View {
        List {
            ForEach(ApproachTier.allCases) { tier in
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(tier.label, systemImage: tier.symbol).font(.headline).foregroundStyle(tier.color)
                            Spacer()
                            InvasivenessDots(tier: tier)
                        }
                        Text(tier.explanation).font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            Section {
                Text("More invasive doesn't mean better or worse. For some conditions the simplest option works as well as surgery; for others — such as spinal cord compression — surgery is often the safest choice.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Types of approach")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InvasivenessDots: View {
    let tier: ApproachTier

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...ApproachTier.allCases.count, id: \.self) { i in
                Circle()
                    .fill(i <= tier.invasivenessScore ? tier.color : Color(.tertiarySystemFill))
                    .frame(width: 7, height: 7)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Invasiveness \(tier.invasivenessScore) of \(ApproachTier.allCases.count)")
    }
}

// MARK: - Condition

struct ConditionGuideView: View {
    let guide: SpineConditionGuide

    var body: some View {
        List {
            Section {
                Text(guide.summary)
                Text("Also called: \(guide.alsoCalled)").font(.caption).foregroundStyle(.secondary)
            }

            if !guide.urgentSigns.isEmpty {
                Section {
                    ForEach(guide.urgentSigns, id: \.self) { sign in
                        Label(sign, systemImage: "exclamationmark.octagon.fill")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Don't wait — get help if")
                }
            }

            Section("What usually happens without surgery") {
                ForEach(guide.naturalHistory, id: \.self) { Text($0).font(.subheadline) }
            }

            Section("When surgery is usually offered") {
                ForEach(guide.whenSurgeryIsOffered, id: \.self) { Text($0).font(.subheadline) }
            }

            Section {
                NavigationLink { ComparisonView(guide: guide) } label: {
                    Label("Compare outcomes and side effects", systemImage: "chart.bar.xaxis").bold()
                }
            }

            ForEach(guide.tiers) { tier in
                Section {
                    ForEach(guide.options(in: tier)) { option in
                        NavigationLink { OptionDetailView(guide: guide, option: option) } label: { OptionRow(option: option) }
                    }
                } header: {
                    Label(tier.label, systemImage: tier.symbol).foregroundStyle(tier.color)
                }
            }

            Section("Studies that compared options directly") {
                ForEach(guide.comparisons) { study in
                    StudyRow(study: study)
                }
            }

            Section("Questions to ask") {
                ForEach(guide.questionsToAsk + Array(TreatmentGuides.generalQuestions.prefix(3)), id: \.self) { q in
                    Label(q, systemImage: "questionmark.circle").font(.subheadline)
                }
                NavigationLink("All questions") { BulletListView(title: "Questions for your surgeon", items: guide.questionsToAsk + TreatmentGuides.generalQuestions, footer: nil) }
            }

            Section {
                Text(TreatmentOptionsContent.disclaimer).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(guide.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OptionRow: View {
    let option: TreatmentOption

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(option.name).font(.body.weight(.medium))
                Spacer()
                InvasivenessDots(tier: option.tier)
            }
            Text(option.summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            HStack(spacing: 12) {
                if let imp = option.outcomes.improvement {
                    Label(imp.percentText, systemImage: "arrow.up.heart").foregroundStyle(.green)
                }
                if let ser = option.outcomes.seriousComplications {
                    Label(ser.percentText, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                }
                Text("Evidence: \(option.evidence.label)").foregroundStyle(.secondary)
            }
            .font(.caption2)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

struct StudyRow: View {
    let study: ComparisonStudy

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(study.name).font(.subheadline.bold())
            Text(study.compared).font(.caption).foregroundStyle(.secondary)
            Text(study.finding).font(.subheadline)
            Text(study.citation).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Option detail

struct OptionDetailView: View {
    let guide: SpineConditionGuide
    let option: TreatmentOption
    @AppStorage(shortlistKey) private var shortlistRaw = ""

    private var saved: Bool { OptionShortlist(stored: shortlistRaw).contains(guide, option) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(option.tier.label, systemImage: option.tier.symbol)
                            .font(.caption.bold())
                            .foregroundStyle(option.tier.color)
                        Spacer()
                        InvasivenessDots(tier: option.tier)
                    }
                    Text(option.summary)
                }
                .padding(.vertical, 4)
                FactRow(title: "Anesthesia", value: option.anesthesia, symbol: "bed.double")
                FactRow(title: "Hospital stay", value: option.hospitalStay, symbol: "building.2")
                FactRow(title: "Recovery", value: option.recovery, symbol: "calendar")
                FactRow(title: "Strength of evidence", value: "\(option.evidence.label) — \(option.evidence.explanation)", symbol: "checkmark.seal")
            }

            Section {
                OutcomeBlock(title: "Meaningful improvement", range: option.outcomes.improvement, color: .green, note: guide.improvementDefinition)
                OutcomeBlock(title: "Serious complications", range: option.outcomes.seriousComplications, color: .red, note: nil)
                OutcomeBlock(title: "Further surgery or repeat procedure", range: option.outcomes.furtherTreatment, color: .orange, note: "Within a few years, including repeat injections or switching to surgery.")
            } header: {
                Text("Results — out of 100 people")
            } footer: {
                Text(TreatmentOptionsContent.differentStudiesCaveat)
            }

            Section("What the studies found") {
                ForEach(option.keyFindings, id: \.self) { Text($0).font(.subheadline) }
            }

            ForEach(SideEffect.Severity.allCases.reversed(), id: \.self) { severity in
                let effects = option.sideEffectsByRisk.filter { $0.severity == severity }
                if !effects.isEmpty {
                    Section {
                        ForEach(effects) { SideEffectRow(effect: $0) }
                    } header: {
                        Label("\(severity.label) side effects and risks", systemImage: "circle.fill").foregroundStyle(severity.color)
                    } footer: {
                        Text(severity.explanation)
                    }
                }
            }

            Section("What happens") {
                ForEach(Array(option.whatHappens.enumerated()), id: \.offset) { i, step in
                    Label(step, systemImage: "\(i + 1).circle").font(.subheadline)
                }
            }

            Section("May suit people with") {
                ForEach(option.bestFor, id: \.self) { Label($0, systemImage: "checkmark").font(.subheadline) }
            }
            if !option.lessSuitableIf.isEmpty {
                Section("May be less suitable if") {
                    ForEach(option.lessSuitableIf, id: \.self) { Label($0, systemImage: "xmark").font(.subheadline) }
                }
            }

            Section {
                Text(option.availability).font(.subheadline)
            } header: {
                Text("Availability and coverage")
            } footer: {
                Text("Coverage changes often. Check with your insurer or Medicare before booking.")
            }

            Section("Sources") {
                ForEach(option.sources, id: \.self) { Text($0).font(.caption).foregroundStyle(.secondary) }
            }

            Section {
                Text(TreatmentOptionsContent.disclaimer).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(option.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    var list = OptionShortlist(stored: shortlistRaw)
                    list.toggle(guide, option)
                    shortlistRaw = list.stored
                } label: {
                    Label(saved ? "Saved to discuss" : "Save to discuss", systemImage: saved ? "bookmark.fill" : "bookmark")
                }
            }
        }
    }
}

struct FactRow: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline)
            }
        } icon: {
            Image(systemName: symbol)
        }
    }
}

struct OutcomeBlock: View {
    let title: String
    let range: PercentRange?
    let color: Color
    let note: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline.bold())
                Spacer()
                Text(range?.percentText ?? "Not reported").font(.subheadline.monospacedDigit()).foregroundStyle(range == nil ? Color.secondary : color)
            }
            if let range {
                Text(range.naturalFrequency).font(.caption).foregroundStyle(.secondary)
                if range.high >= 1 {
                    IconArray(low: range.low, high: range.high, color: color)
                }
            }
            if let note { Text(note).font(.caption2).foregroundStyle(.secondary) }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// 100 people as a 20 × 5 grid. Solid = the low end of the range, faded = up to the high end.
struct IconArray: View {
    let low: Double
    let high: Double
    let color: Color

    var body: some View {
        let lo = Int(low.rounded()), hi = Int(high.rounded())
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 20), spacing: 3) {
            ForEach(0..<100, id: \.self) { i in
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(i < lo ? color : (i < hi ? color.opacity(0.35) : Color(.tertiarySystemFill)))
            }
        }
        .frame(maxWidth: 320)
        .accessibilityHidden(true)
    }
}

struct SideEffectRow: View {
    let effect: SideEffect

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(effect.name).font(.subheadline.weight(.medium))
                Spacer()
                Text(effect.chance.percentText).font(.subheadline.monospacedDigit()).foregroundStyle(effect.severity.color)
            }
            RiskBar(range: effect.chance, color: effect.severity.color)
            Text("\(effect.band.label): \(effect.chance.naturalFrequency.lowercasedFirst)").font(.caption).foregroundStyle(.secondary)
            if !effect.detail.isEmpty { Text(effect.detail).font(.caption) }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

/// Horizontal bar on a 0–100% scale, with a minimum visible width for rare risks.
struct RiskBar: View {
    let range: PercentRange
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.tertiarySystemFill))
                Capsule().fill(color.opacity(0.35)).frame(width: max(4, w * range.high / 100))
                Capsule().fill(color).frame(width: max(3, w * range.low / 100))
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}

// MARK: - Comparison

struct ComparisonView: View {
    let guide: SpineConditionGuide
    @State private var measure: OutcomeMeasure = .improvement

    private struct Row: Identifiable {
        let option: TreatmentOption
        let range: PercentRange
        var id: String { option.id }
    }

    private var rows: [Row] {
        guide.options.compactMap { o in measure.value(in: o.outcomes).map { Row(option: o, range: $0) } }
    }

    private var missing: [TreatmentOption] { guide.options.filter { measure.value(in: $0.outcomes) == nil } }

    private var xMax: Double {
        let top = rows.map(\.range.high).max() ?? 100
        if measure == .improvement { return 100 }
        return min(100, max(5, (top * 1.15).rounded(.up)))
    }

    var body: some View {
        List {
            Section {
                Picker("Measure", selection: $measure) {
                    Text("Improve").tag(OutcomeMeasure.improvement)
                    Text("Serious risks").tag(OutcomeMeasure.seriousComplications)
                    Text("More treatment").tag(OutcomeMeasure.furtherTreatment)
                }
                .pickerStyle(.segmented)

                Text(description).font(.caption).foregroundStyle(.secondary)

                Chart(rows) { row in
                    BarMark(xStart: .value("Low", row.range.low), xEnd: .value("High", max(row.range.high, row.range.low + xMax * 0.01)),
                            y: .value("Option", row.option.name))
                        .foregroundStyle(by: .value("Approach", row.option.tier.shortLabel))
                        .annotation(position: .trailing) {
                            Text(row.range.percentText).font(.caption2).foregroundStyle(.secondary)
                        }
                }
                .chartXScale(domain: 0...xMax)
                .chartXAxisLabel("% of people")
                .chartForegroundStyleScale(domain: ApproachTier.allCases.map(\.shortLabel), range: ApproachTier.allCases.map(\.color))
                .chartLegend(position: .bottom)
                .frame(height: CGFloat(max(rows.count, 1)) * 44 + 60)
                .padding(.vertical, 8)

                if !missing.isEmpty {
                    Text("Not reported for: " + missing.map(\.name).joined(separator: ", ")).font(.caption2).foregroundStyle(.secondary)
                }
            } footer: {
                Text(TreatmentOptionsContent.differentStudiesCaveat)
            }

            Section("At a glance") {
                ForEach(guide.options) { o in
                    NavigationLink { OptionDetailView(guide: guide, option: o) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(o.name).font(.subheadline.bold())
                                Spacer()
                                InvasivenessDots(tier: o.tier)
                            }
                            Text("Stay: \(o.hospitalStay)").font(.caption)
                            Text("Recovery: \(o.recovery)").font(.caption)
                            Text("Side effects listed: \(o.sideEffects.count) · serious: \(o.seriousSideEffects.count) · evidence: \(o.evidence.label.lowercased())")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                NavigationLink { SideBySideView(guide: guide) } label: { Label("Compare two options side by side", systemImage: "rectangle.split.2x1") }
            }

            Section("Studies that compared options directly") {
                ForEach(guide.comparisons) { StudyRow(study: $0) }
            }
        }
        .navigationTitle("Compare options")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var description: String {
        switch measure {
        case .improvement: return guide.improvementDefinition + " Longer bars are better."
        case .seriousComplications: return "Share of people with a serious or major complication. Shorter bars are better. The scale is zoomed in so small risks are visible."
        case .furtherTreatment: return "Share who go on to have more surgery or a repeat procedure within a few years (for non-surgical options, this includes deciding to have surgery)."
        }
    }
}

struct SideBySideView: View {
    let guide: SpineConditionGuide
    @State private var leftID: String
    @State private var rightID: String

    init(guide: SpineConditionGuide) {
        self.guide = guide
        _leftID = State(initialValue: guide.options.first?.id ?? "")
        _rightID = State(initialValue: guide.options.last?.id ?? "")
    }

    var body: some View {
        let left = guide.option(leftID), right = guide.option(rightID)
        List {
            Section {
                Picker("First option", selection: $leftID) {
                    ForEach(guide.options) { Text($0.name).tag($0.id) }
                }
                Picker("Second option", selection: $rightID) {
                    ForEach(guide.options) { Text($0.name).tag($0.id) }
                }
            }
            if let left, let right {
                Section("Approach") { pair(left.tier.label, right.tier.label) }
                Section("Anesthesia") { pair(left.anesthesia, right.anesthesia) }
                Section("Hospital stay") { pair(left.hospitalStay, right.hospitalStay) }
                Section("Recovery") { pair(left.recovery, right.recovery) }
                ForEach(OutcomeMeasure.allCases) { m in
                    Section(m.rawValue) {
                        pair(measureText(m, left), measureText(m, right))
                    }
                }
                Section("Evidence") { pair(left.evidence.label, right.evidence.label) }
                Section("Serious risks") {
                    pair(left.seriousSideEffects.map { "\($0.name) (\($0.chance.percentText))" }.joined(separator: "\n").ifEmpty("None listed"),
                         right.seriousSideEffects.map { "\($0.name) (\($0.chance.percentText))" }.joined(separator: "\n").ifEmpty("None listed"))
                }
                Section {
                    Text(TreatmentOptionsContent.differentStudiesCaveat).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Side by side")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func measureText(_ m: OutcomeMeasure, _ o: TreatmentOption) -> String {
        m.value(in: o.outcomes)?.percentText ?? "Not reported"
    }

    private func pair(_ a: String, _ b: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(a).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Text(b).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}

// MARK: - Shortlist

struct ShortlistView: View {
    @AppStorage(shortlistKey) private var shortlistRaw = ""

    var body: some View {
        let list = OptionShortlist(stored: shortlistRaw)
        List {
            if list.items.isEmpty {
                Section {
                    Text("Tap the bookmark on any option to save it here.").foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(list.items) { item in
                        NavigationLink { OptionDetailView(guide: item.guide, option: item.option) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.option.name).font(.body.weight(.medium))
                                Text(item.guide.name).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        var updated = list
                        for i in offsets {
                            let item = list.items[i]
                            updated.toggle(item.guide, item.option)
                        }
                        shortlistRaw = updated.stored
                    }
                }
            }
        }
        .navigationTitle("Options to discuss")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: DiscussionSheet.text(for: list)) { Label("Share", systemImage: "square.and.arrow.up") }
            }
        }
    }
}
