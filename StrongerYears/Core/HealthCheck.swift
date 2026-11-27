import Foundation

/// A short "before you start" checklist. This is the app's own wording, not a licensed
/// questionnaire. Any "yes" means: talk to your doctor before starting or changing your routine.
enum HealthCheck {
    struct Question: Identifiable, Hashable {
        let id: String
        let text: String
        let advice: String
    }

    static let questions: [Question] = [
        Question(id: "heart", text: "Has a doctor ever said you have a heart condition, or that you should only exercise under medical supervision?",
                 advice: "Ask your doctor what kind and amount of exercise is safe for you. Cardiac rehab programs are a great supervised option."),
        Question(id: "chest-pain", text: "Do you get chest pain, pressure or tightness when you're active, or have you had it in the past month at rest?",
                 advice: "Don't start until you've seen your doctor. Chest pain with activity needs checking first."),
        Question(id: "dizzy", text: "Do you lose your balance because of dizziness, or have you fainted in the past year?",
                 advice: "Ask your doctor about the cause, and do balance exercises next to a counter or with someone nearby."),
        Question(id: "blood-pressure", text: "Do you have high blood pressure that isn't well controlled (over 160/100), or take medicine for blood pressure or your heart?",
                 advice: "Check with your doctor. Some medicines change how your heart rate responds to exercise — use the effort scale instead."),
        Question(id: "bones-joints", text: "Do you have osteoporosis, a joint replacement, or a bone or joint problem that could be made worse by exercise?",
                 advice: "Ask your doctor or a physical therapist which movements to avoid. The app flags exercises that need extra care."),
        Question(id: "surgery", text: "Have you had surgery, a fall, a fracture or a hospital stay in the past 6 months?",
                 advice: "Get the OK from your doctor or surgeon, and start at the gentlest level."),
        Question(id: "diabetes", text: "Do you have diabetes, kidney disease or another long-term condition?",
                 advice: "Ask your doctor how to exercise safely with your condition. With diabetes, keep a snack handy and know the signs of low blood sugar."),
        Question(id: "other", text: "Do you know of any other reason you shouldn't do physical activity?",
                 advice: "Talk to your doctor before you start."),
    ]

    static func question(_ id: String) -> Question? { questions.first { $0.id == id } }

    static func needsDoctor(answers: Set<String>) -> Bool { !answers.isEmpty }

    static let allClearMessage = "Great — you can start gently. Start at the easiest level, build up slowly, and see your doctor if anything changes."
    static let seeDoctorMessage = "Please talk to your doctor before you start, and show them the plan the app gives you. You can still read the guides and explore the exercises."
}
