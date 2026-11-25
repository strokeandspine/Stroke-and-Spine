import SwiftUI
import SwiftData

/// Steps through a questionnaire one item at a time, then scores and saves it.
struct QuestionnaireView: View {
    let questionnaire: Questionnaire

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \QuestionnaireResponse.date, order: .reverse) private var allResponses: [QuestionnaireResponse]

    @State private var index = 0
    @State private var answers: [Int?]
    @State private var result: QuestionnaireScore?
    @State private var previous: QuestionnaireResponse?
    @State private var showingCrisis = false

    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
        _answers = State(initialValue: Array(repeating: nil, count: questionnaire.items.count))
    }

    var body: some View {
        Group {
            if let result {
                resultView(result)
            } else {
                questionView
            }
        }
        .navigationTitle(questionnaire.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCrisis) {
            NavigationStack { CrisisResourcesView() }
        }
    }

    private var questionView: some View {
        let item = questionnaire.items[index]
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: Double(index), total: Double(questionnaire.items.count))
                Text("Question \(index + 1) of \(questionnaire.items.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Text(questionnaire.instructions).font(.subheadline).foregroundStyle(.secondary)
                Text(item.text).font(.title3.bold())

                ForEach(item.options, id: \.value) { option in
                    Button { choose(option.value) } label: {
                        HStack {
                            Text(option.label).multilineTextAlignment(.leading)
                            Spacer()
                            if answers[index] == option.value {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    if index > 0 {
                        Button("Back") { index -= 1 }
                    }
                    Spacer()
                    if item.isOptional {
                        Button("Skip — doesn't apply") { answers[index] = nil; advance() }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func choose(_ value: Int) {
        answers[index] = value
        // PHQ-9 question 9: show crisis resources straight away, before anything else.
        if questionnaire.id == .phq9 && index == 8 && value > 0 {
            showingCrisis = true
        }
        advance()
    }

    private func advance() {
        if index < questionnaire.items.count - 1 {
            index += 1
        } else {
            finish()
        }
    }

    private func finish() {
        guard let score = questionnaire.score(answers) else { return }
        previous = allResponses.first { $0.instrumentRaw == questionnaire.id.rawValue }
        context.insert(QuestionnaireResponse(instrument: questionnaire.id, answers: answers, score: score))
        try? context.save()
        result = score
    }

    private func resultView(_ score: QuestionnaireScore) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(score.display).font(.system(size: 44, weight: .bold)).monospacedDigit()
                    Text(score.severity).font(.title3)
                    if let previous {
                        Text(Scoring.describeChange(from: previous.score, to: score.value, id: questionnaire.id))
                            .foregroundStyle(.secondary)
                        Text("Last time: \(previous.display) on \(previous.date.shortDate)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text("\(questionnaire.title) — \(questionnaire.measures.lowercased()). Lower scores are better. Share your results with your doctor; a score is not a diagnosis.")
            }

            if score.needsCrisisSupport {
                Section("You don't have to go through this alone") {
                    Text("You said you've had thoughts of being better off dead or hurting yourself. Please reach out now — talking to someone can help.")
                    ForEach(CrisisResources.all) { resource in
                        Link(destination: resource.url) {
                            Label(resource.name, systemImage: "phone.fill")
                        }
                    }
                }
            }

            if let advice = followUp(score) {
                Section("What next") { Text(advice) }
            }

            Section {
                Button("Done") { dismiss() }
            }
        }
    }

    private func followUp(_ score: QuestionnaireScore) -> String? {
        switch questionnaire.id {
        case .phq9 where score.value >= 10, .gad7 where score.value >= 10:
            return "Your score suggests these symptoms may be having a real effect on you. Mood and anxiety often get tangled up with long-lasting pain, and both are treatable. Consider talking to your doctor — treating them often helps the pain too."
        case .isi where score.value >= 15:
            return "Your sleep problems look significant. Talk to your doctor — cognitive behavioral therapy for insomnia (CBT-I) works well and doesn't rely on sleeping pills."
        case .odi where score.value >= 41:
            return "Your back pain is having a big effect on daily life. If you haven't recently, it's worth reviewing your plan with your doctor or physical therapist."
        default:
            return nil
        }
    }
}

struct QuestionnaireListView: View {
    @Query(sort: \QuestionnaireResponse.date, order: .reverse) private var responses: [QuestionnaireResponse]

    var body: some View {
        List {
            ForEach(Questionnaire.all) { q in
                let history = responses.filter { $0.instrumentRaw == q.id.rawValue }
                Section {
                    NavigationLink("Take \(q.shortTitle)") { QuestionnaireView(questionnaire: q) }
                    ForEach(history.prefix(5)) { r in
                        HStack {
                            Text(r.date.shortDate)
                            Spacer()
                            Text("\(r.display) · \(r.severity)").foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                } header: {
                    Text(q.measures)
                } footer: {
                    Text("Suggested every \(q.recommendedIntervalDays) days.")
                }
            }
        }
        .navigationTitle("Questionnaires")
    }
}
