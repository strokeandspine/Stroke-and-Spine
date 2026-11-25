import Foundation

/// Warning-sign screening. Wording deliberately says how urgently to get care,
/// not what the condition might be (keeps the app out of "diagnosis").
enum Urgency: Int, Comparable, Codable {
    case none = 0
    /// Book an appointment with your doctor in the next few days.
    case prompt = 1
    /// Contact your doctor or an urgent care clinic today.
    case urgent = 2
    /// Call 911 or go to the emergency room now.
    case emergency = 3

    static func < (a: Urgency, b: Urgency) -> Bool { a.rawValue < b.rawValue }

    var headline: String {
        switch self {
        case .none: return "No warning signs reported"
        case .prompt: return "See your doctor soon"
        case .urgent: return "Contact a doctor today"
        case .emergency: return "Get emergency care now"
        }
    }

    var advice: String {
        switch self {
        case .none:
            return "None of the warning signs apply to you right now. If anything changes, run this check again."
        case .prompt:
            return "Some of what you reported should be checked by a doctor. Book an appointment within the next few days, and come back to this check if things get worse."
        case .urgent:
            return "Some of what you reported needs medical attention today. Call your doctor's office or visit an urgent care clinic. If you can't reach anyone, go to the emergency room."
        case .emergency:
            return "Some of what you reported can be a sign of a serious problem that needs treatment straight away. Call 911 or go to the nearest emergency room now. Do not wait to see if it gets better."
        }
    }
}

struct RedFlag: Identifiable, Hashable {
    enum Group: String, CaseIterable {
        case nerves = "Nerves, bladder and bowel"
        case general = "General health"
        case afterSurgery = "After a recent surgery or procedure"
    }

    let id: String
    let question: String
    let group: Group
    let urgency: Urgency
}

enum RedFlagScreen {
    static let flags: [RedFlag] = [
        // Nerves, bladder and bowel
        RedFlag(id: "bladder", question: "New trouble passing urine, or leaking urine without meaning to", group: .nerves, urgency: .emergency),
        RedFlag(id: "bowel", question: "New loss of control of your bowels", group: .nerves, urgency: .emergency),
        RedFlag(id: "saddle", question: "Numbness around your genitals, bottom or inner thighs (the area that would touch a saddle)", group: .nerves, urgency: .emergency),
        RedFlag(id: "bilateralWeakness", question: "New weakness or numbness in both legs", group: .nerves, urgency: .emergency),
        RedFlag(id: "progressiveWeakness", question: "Weakness in a leg or foot that is getting worse, or your foot slapping or dragging when you walk", group: .nerves, urgency: .urgent),

        // General health
        RedFlag(id: "fever", question: "Fever or chills along with your back pain", group: .general, urgency: .urgent),
        RedFlag(id: "trauma", question: "Back pain that started after a fall, car accident or other injury", group: .general, urgency: .urgent),
        RedFlag(id: "cancer", question: "A history of cancer, and this back pain is new or different", group: .general, urgency: .urgent),
        RedFlag(id: "immune", question: "A weakened immune system (for example long-term steroids, chemotherapy, transplant medicines or HIV) or injecting drug use", group: .general, urgency: .urgent),
        RedFlag(id: "weightLoss", question: "Losing weight without trying", group: .general, urgency: .prompt),
        RedFlag(id: "nightPain", question: "Severe pain at night that doesn't ease when you rest or change position", group: .general, urgency: .prompt),
        RedFlag(id: "osteoporosis", question: "Osteoporosis or long-term steroid use, and the pain started suddenly", group: .general, urgency: .prompt),

        // After surgery or a procedure
        RedFlag(id: "chestPain", question: "Chest pain or sudden shortness of breath", group: .afterSurgery, urgency: .emergency),
        RedFlag(id: "calfSwelling", question: "Pain, swelling or warmth in one calf", group: .afterSurgery, urgency: .urgent),
        RedFlag(id: "woundInfection", question: "Your wound is red, swollen, hot, leaking fluid or opening up", group: .afterSurgery, urgency: .urgent),
        RedFlag(id: "postOpFever", question: "A temperature of 101°F (38.3°C) or higher", group: .afterSurgery, urgency: .urgent),
        RedFlag(id: "headache", question: "A severe headache that gets worse when you sit or stand (after an injection or surgery)", group: .afterSurgery, urgency: .urgent),
    ]

    static func flag(id: String) -> RedFlag? { flags.first { $0.id == id } }

    /// The overall urgency is the most urgent flag the person ticked.
    static func evaluate(_ positiveIDs: Set<String>) -> Urgency {
        flags.filter { positiveIDs.contains($0.id) }.map(\.urgency).max() ?? .none
    }
}

enum CrisisResources {
    struct Resource: Identifiable {
        let id = UUID()
        let name: String
        let detail: String
        let url: URL
    }

    static let all: [Resource] = [
        Resource(name: "Call 988", detail: "Suicide & Crisis Lifeline — free, confidential, 24/7", url: URL(string: "tel:988")!),
        Resource(name: "Text 988", detail: "Text with a trained crisis counselor", url: URL(string: "sms:988")!),
        Resource(name: "Text HOME to 741741", detail: "Crisis Text Line", url: URL(string: "sms:741741&body=HOME")!),
        Resource(name: "Call 911", detail: "If you are in immediate danger", url: URL(string: "tel:911")!),
    ]
}
