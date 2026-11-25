import Foundation

/// A validated patient-reported outcome measure (PROM).
///
/// LICENSING: PHQ-9 and GAD-7 are free to use without permission. The Oswestry
/// Disability Index (ODI) and Insomnia Severity Index (ISI) are copyrighted and
/// need a commercial licence (both are distributed through Mapi Research Trust /
/// ePROVIDE) before the app is released. See docs/LICENSING.md.
struct Questionnaire: Identifiable, Hashable {
    enum ID: String, CaseIterable, Codable {
        case odi, phq9, gad7, isi
    }

    struct Option: Hashable {
        let label: String
        let value: Int
    }

    struct Item: Hashable {
        let text: String
        let options: [Option]
        /// Optional items (e.g. ODI "sex life") may be skipped without invalidating the score.
        var isOptional: Bool = false
    }

    let id: ID
    let title: String
    let shortTitle: String
    let measures: String
    let instructions: String
    let items: [Item]
    /// How often the app suggests repeating this questionnaire.
    let recommendedIntervalDays: Int

    func score(_ answers: [Int?]) -> QuestionnaireScore? {
        Scoring.score(self, answers: answers)
    }
}

struct QuestionnaireScore: Equatable {
    let value: Double
    /// Highest possible value, for display ("12 of 27", "34%").
    let maximum: Double
    let isPercentage: Bool
    let severity: String
    /// True when an answer means the person should see crisis resources right away.
    let needsCrisisSupport: Bool

    var display: String {
        isPercentage ? "\(Int(value.rounded()))%" : "\(Int(value)) of \(Int(maximum))"
    }
}

enum Scoring {
    static func score(_ q: Questionnaire, answers: [Int?]) -> QuestionnaireScore? {
        guard answers.count == q.items.count else { return nil }
        // Every required item must be answered.
        for (item, answer) in zip(q.items, answers) where !item.isOptional && answer == nil {
            return nil
        }
        let answered = answers.compactMap { $0 }

        switch q.id {
        case .odi:
            // ODI: each section 0–5. Score = total / (5 × sections answered) × 100.
            guard !answered.isEmpty else { return nil }
            let pct = Double(answered.reduce(0, +)) / Double(5 * answered.count) * 100
            return QuestionnaireScore(value: pct, maximum: 100, isPercentage: true,
                                      severity: odiSeverity(pct), needsCrisisSupport: false)
        case .phq9:
            let total = answered.reduce(0, +)
            let item9 = answers[8] ?? 0
            return QuestionnaireScore(value: Double(total), maximum: 27, isPercentage: false,
                                      severity: phq9Severity(total), needsCrisisSupport: item9 > 0)
        case .gad7:
            let total = answered.reduce(0, +)
            return QuestionnaireScore(value: Double(total), maximum: 21, isPercentage: false,
                                      severity: gad7Severity(total), needsCrisisSupport: false)
        case .isi:
            let total = answered.reduce(0, +)
            return QuestionnaireScore(value: Double(total), maximum: 28, isPercentage: false,
                                      severity: isiSeverity(total), needsCrisisSupport: false)
        }
    }

    static func odiSeverity(_ pct: Double) -> String {
        switch pct {
        case ..<21: return "Minimal disability"
        case ..<41: return "Moderate disability"
        case ..<61: return "Severe disability"
        case ..<81: return "Very severe disability"
        default: return "Extreme disability"
        }
    }

    static func phq9Severity(_ s: Int) -> String {
        switch s {
        case ..<5: return "Minimal"
        case ..<10: return "Mild"
        case ..<15: return "Moderate"
        case ..<20: return "Moderately severe"
        default: return "Severe"
        }
    }

    static func gad7Severity(_ s: Int) -> String {
        switch s {
        case ..<5: return "Minimal"
        case ..<10: return "Mild"
        case ..<15: return "Moderate"
        default: return "Severe"
        }
    }

    static func isiSeverity(_ s: Int) -> String {
        switch s {
        case ..<8: return "No significant insomnia"
        case ..<15: return "Subthreshold insomnia"
        case ..<22: return "Moderate insomnia"
        default: return "Severe insomnia"
        }
    }

    /// Minimal clinically important difference: the smallest change that patients notice as meaningful.
    static func mcid(for id: Questionnaire.ID) -> Double {
        switch id {
        case .odi: return 10   // percentage points
        case .phq9: return 5
        case .gad7: return 4
        case .isi: return 6
        }
    }

    /// Lower scores are better for every instrument used here.
    static func describeChange(from old: Double, to new: Double, id: Questionnaire.ID) -> String {
        let delta = new - old
        let threshold = mcid(for: id)
        if abs(delta) < threshold { return "About the same as last time" }
        return delta < 0 ? "Meaningfully better than last time" : "Meaningfully worse than last time"
    }
}

extension Questionnaire {
    static let all: [Questionnaire] = [.odi, .phq9, .gad7, .isi]

    static func with(id: ID) -> Questionnaire {
        all.first { $0.id == id }!
    }

    private static func options(_ labels: [String]) -> [Option] {
        labels.enumerated().map { Option(label: $1, value: $0) }
    }

    private static let frequency = Questionnaire.options(["Not at all", "Several days", "More than half the days", "Nearly every day"])

    // MARK: PHQ-9 (public domain, Pfizer)
    static let phq9 = Questionnaire(
        id: .phq9,
        title: "Patient Health Questionnaire (PHQ-9)",
        shortTitle: "Mood (PHQ-9)",
        measures: "Depression symptoms",
        instructions: "Over the last 2 weeks, how often have you been bothered by any of the following problems?",
        items: [
            "Little interest or pleasure in doing things",
            "Feeling down, depressed, or hopeless",
            "Trouble falling or staying asleep, or sleeping too much",
            "Feeling tired or having little energy",
            "Poor appetite or overeating",
            "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
            "Trouble concentrating on things, such as reading the newspaper or watching television",
            "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
            "Thoughts that you would be better off dead or of hurting yourself in some way",
        ].map { Item(text: $0, options: Questionnaire.frequency) },
        recommendedIntervalDays: 28
    )

    // MARK: GAD-7 (public domain, Pfizer)
    static let gad7 = Questionnaire(
        id: .gad7,
        title: "Generalized Anxiety Disorder scale (GAD-7)",
        shortTitle: "Anxiety (GAD-7)",
        measures: "Anxiety symptoms",
        instructions: "Over the last 2 weeks, how often have you been bothered by the following problems?",
        items: [
            "Feeling nervous, anxious, or on edge",
            "Not being able to stop or control worrying",
            "Worrying too much about different things",
            "Trouble relaxing",
            "Being so restless that it is hard to sit still",
            "Becoming easily annoyed or irritable",
            "Feeling afraid as if something awful might happen",
        ].map { Item(text: $0, options: Questionnaire.frequency) },
        recommendedIntervalDays: 28
    )

    // MARK: Insomnia Severity Index (© C. Morin — licence required for commercial use)
    static let isi: Questionnaire = {
        let severity = Questionnaire.options(["None", "Mild", "Moderate", "Severe", "Very severe"])
        return Questionnaire(
            id: .isi,
            title: "Insomnia Severity Index (ISI)",
            shortTitle: "Sleep (ISI)",
            measures: "Insomnia severity",
            instructions: "Please rate the current (i.e., last 2 weeks) severity of your sleep problems.",
            items: [
                Item(text: "Difficulty falling asleep", options: severity),
                Item(text: "Difficulty staying asleep", options: severity),
                Item(text: "Problems waking up too early", options: severity),
                Item(text: "How satisfied or dissatisfied are you with your current sleep pattern?",
                     options: Questionnaire.options(["Very satisfied", "Satisfied", "Moderately satisfied", "Dissatisfied", "Very dissatisfied"])),
                Item(text: "How noticeable to others do you think your sleep problem is in terms of impairing the quality of your life?",
                     options: Questionnaire.options(["Not at all noticeable", "A little", "Somewhat", "Much", "Very much noticeable"])),
                Item(text: "How worried or distressed are you about your current sleep problem?",
                     options: Questionnaire.options(["Not at all worried", "A little", "Somewhat", "Much", "Very much worried"])),
                Item(text: "To what extent do you consider your sleep problem to interfere with your daily functioning (e.g. daytime fatigue, mood, ability to function at work or daily chores, concentration, memory) currently?",
                     options: Questionnaire.options(["Not at all interfering", "A little", "Somewhat", "Much", "Very much interfering"])),
            ],
            recommendedIntervalDays: 28
        )
    }()

    // MARK: Oswestry Disability Index v2.1a (© J. Fairbank — licence required for commercial use)
    static let odi = Questionnaire(
        id: .odi,
        title: "Oswestry Disability Index (ODI)",
        shortTitle: "Back function (ODI)",
        measures: "How much your back pain affects everyday activities",
        instructions: "In each section, choose the one statement that best describes your situation today.",
        items: [
            Item(text: "Pain intensity", options: Questionnaire.options([
                "I have no pain at the moment",
                "The pain is very mild at the moment",
                "The pain is moderate at the moment",
                "The pain is fairly severe at the moment",
                "The pain is very severe at the moment",
                "The pain is the worst imaginable at the moment"])),
            Item(text: "Personal care (washing, dressing, etc.)", options: Questionnaire.options([
                "I can look after myself normally without causing extra pain",
                "I can look after myself normally but it causes extra pain",
                "It is painful to look after myself and I am slow and careful",
                "I need some help but manage most of my personal care",
                "I need help every day in most aspects of self-care",
                "I do not get dressed, I wash with difficulty and stay in bed"])),
            Item(text: "Lifting", options: Questionnaire.options([
                "I can lift heavy weights without extra pain",
                "I can lift heavy weights but it gives extra pain",
                "Pain prevents me from lifting heavy weights off the floor, but I can manage if they are conveniently placed, e.g. on a table",
                "Pain prevents me from lifting heavy weights, but I can manage light to medium weights if they are conveniently positioned",
                "I can lift very light weights",
                "I cannot lift or carry anything at all"])),
            Item(text: "Walking", options: Questionnaire.options([
                "Pain does not prevent me walking any distance",
                "Pain prevents me from walking more than 1 mile",
                "Pain prevents me from walking more than 1/2 mile",
                "Pain prevents me from walking more than 100 yards",
                "I can only walk using a stick or crutches",
                "I am in bed most of the time"])),
            Item(text: "Sitting", options: Questionnaire.options([
                "I can sit in any chair as long as I like",
                "I can only sit in my favorite chair as long as I like",
                "Pain prevents me sitting more than 1 hour",
                "Pain prevents me from sitting more than 30 minutes",
                "Pain prevents me from sitting more than 10 minutes",
                "Pain prevents me from sitting at all"])),
            Item(text: "Standing", options: Questionnaire.options([
                "I can stand as long as I want without extra pain",
                "I can stand as long as I want but it gives me extra pain",
                "Pain prevents me from standing for more than 1 hour",
                "Pain prevents me from standing for more than 30 minutes",
                "Pain prevents me from standing for more than 10 minutes",
                "Pain prevents me from standing at all"])),
            Item(text: "Sleeping", options: Questionnaire.options([
                "My sleep is never disturbed by pain",
                "My sleep is occasionally disturbed by pain",
                "Because of pain I have less than 6 hours sleep",
                "Because of pain I have less than 4 hours sleep",
                "Because of pain I have less than 2 hours sleep",
                "Pain prevents me from sleeping at all"])),
            Item(text: "Sex life (if applicable)", options: Questionnaire.options([
                "My sex life is normal and causes no extra pain",
                "My sex life is normal but causes some extra pain",
                "My sex life is nearly normal but is very painful",
                "My sex life is severely restricted by pain",
                "My sex life is nearly absent because of pain",
                "Pain prevents any sex life at all"]), isOptional: true),
            Item(text: "Social life", options: Questionnaire.options([
                "My social life is normal and gives me no extra pain",
                "My social life is normal but increases the degree of pain",
                "Pain has no significant effect on my social life apart from limiting my more energetic interests, e.g. sport",
                "Pain has restricted my social life and I do not go out as often",
                "Pain has restricted my social life to my home",
                "I have no social life because of pain"])),
            Item(text: "Travelling", options: Questionnaire.options([
                "I can travel anywhere without pain",
                "I can travel anywhere but it gives me extra pain",
                "Pain is bad but I manage journeys over two hours",
                "Pain restricts me to journeys of less than one hour",
                "Pain restricts me to short necessary journeys under 30 minutes",
                "Pain prevents me from travelling except to receive treatment"])),
        ],
        recommendedIntervalDays: 14
    )
}
