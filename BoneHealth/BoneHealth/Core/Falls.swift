import Foundation

/// CDC STEADI "Stay Independent" checklist (Rubenstein et al., 2011). Public domain.
enum FallRiskChecklist {
    struct Item: Identifiable, Hashable {
        let id: Int
        let text: String
        let points: Int
        let why: String
    }

    static let items: [Item] = [
        Item(id: 1, text: "I have fallen in the past year.", points: 2, why: "People who have fallen once are likely to fall again."),
        Item(id: 2, text: "I use or have been advised to use a cane or walker to get around safely.", points: 2, why: "People who have been advised to use a cane or walker may already be more likely to fall."),
        Item(id: 3, text: "Sometimes I feel unsteady when I am walking.", points: 1, why: "Unsteadiness or needing support while walking are signs of poor balance."),
        Item(id: 4, text: "I steady myself by holding onto furniture when walking at home.", points: 1, why: "This is also a sign of poor balance."),
        Item(id: 5, text: "I am worried about falling.", points: 1, why: "People who are worried about falling are more likely to fall."),
        Item(id: 6, text: "I need to push with my hands to stand up from a chair.", points: 1, why: "This is a sign of weak leg muscles, a major reason for falling."),
        Item(id: 7, text: "I have some trouble stepping up onto a curb.", points: 1, why: "This is also a sign of weak leg muscles."),
        Item(id: 8, text: "I often have to rush to the toilet.", points: 1, why: "Rushing to the bathroom, especially at night, increases your chance of falling."),
        Item(id: 9, text: "I have lost some feeling in my feet.", points: 1, why: "Numbness in your feet can cause stumbles and lead to falls."),
        Item(id: 10, text: "I take medicine that sometimes makes me feel light-headed or more tired than usual.", points: 1, why: "Side effects from medicines can sometimes increase your chance of falling."),
        Item(id: 11, text: "I take medicine to help me sleep or improve my mood.", points: 1, why: "These medicines can sometimes increase your chance of falling."),
        Item(id: 12, text: "I often feel sad or depressed.", points: 1, why: "Symptoms of depression, such as not feeling well or feeling slowed down, are linked to falls."),
    ]

    static let maximum = 14
    static let atRiskThreshold = 4

    static func score(_ answers: Set<Int>) -> Int {
        items.filter { answers.contains($0.id) }.reduce(0) { $0 + $1.points }
    }

    static func isAtRisk(score: Int) -> Bool { score >= atRiskThreshold }

    static func interpretation(score: Int) -> String {
        isAtRisk(score: score)
            ? "A score of 4 or more means you may be at risk of falling. Share this with your doctor and ask for a falls risk assessment — many causes of falls can be fixed."
            : "Your score is below 4, which suggests a lower risk of falling. Keep active and repeat the checklist each year, or sooner if anything changes."
    }
}

struct FallSummaryInput: Hashable {
    var date: Date
    var isNearMiss: Bool
    var injured: Bool
}

enum FallRisk {
    /// Recommendations based on falls logged in the last 12 months (AGS/BGS and STEADI guidance).
    static func recommendations(falls: [FallSummaryInput], latestChecklistScore: Int?, now: Date = Date(), calendar: Calendar = .current) -> [SafetyWarning] {
        guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return [] }
        let recent = falls.filter { $0.date >= yearAgo }
        let actualFalls = recent.filter { !$0.isNearMiss }
        let injurious = actualFalls.filter(\.injured)
        let nearMisses = recent.filter(\.isNearMiss)
        var result: [SafetyWarning] = []

        if actualFalls.count >= 2 || !injurious.isEmpty {
            result.append(SafetyWarning(id: "falls-assessment", severity: .caution,
                message: "You've had \(actualFalls.count) fall\(actualFalls.count == 1 ? "" : "s") in the past year\(injurious.isEmpty ? "" : ", including one with an injury"). Guidelines recommend a full falls risk assessment — ask your doctor. It usually looks at balance, strength, eyesight, blood pressure, feet and medicines."))
        } else if actualFalls.count == 1 {
            result.append(SafetyWarning(id: "falls-one", severity: .info,
                message: "You've had one fall in the past year. Tell your doctor, and ask them to check your balance and walking."))
        }
        if nearMisses.count >= 2 {
            result.append(SafetyWarning(id: "falls-near-miss", severity: .info,
                message: "You've logged \(nearMisses.count) near-misses in the past year. Trips and stumbles are worth mentioning to your doctor or physical therapist."))
        }
        if let score = latestChecklistScore, FallRiskChecklist.isAtRisk(score: score) {
            result.append(SafetyWarning(id: "falls-checklist", severity: .caution,
                message: "Your Stay Independent checklist score was \(score) of \(FallRiskChecklist.maximum). A score of 4 or more means you may be at risk of falling."))
        }
        return result
    }
}

enum FallCause: String, CaseIterable, Codable, Identifiable {
    case trip, slip, lostBalance, dizzy, legsGaveWay, blackout, reaching, stairs, gettingUp, unknown

    var id: String { rawValue }

    var label: String {
        switch self {
        case .trip: return "Tripped"
        case .slip: return "Slipped"
        case .lostBalance: return "Lost my balance"
        case .dizzy: return "Felt dizzy or light-headed"
        case .legsGaveWay: return "Legs gave way"
        case .blackout: return "Blacked out or fainted"
        case .reaching: return "Reaching or bending"
        case .stairs: return "On stairs or a step"
        case .gettingUp: return "Getting up from a bed, chair or toilet"
        case .unknown: return "Don't know"
        }
    }
}

enum FallInjury: String, CaseIterable, Codable, Identifiable {
    case none, bruise, cut, sprain, headInjury, fracture, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "No injury"
        case .bruise: return "Bruise"
        case .cut: return "Cut or scrape"
        case .sprain: return "Sprain or strain"
        case .headInjury: return "Hit my head"
        case .fracture: return "Broken bone"
        case .other: return "Other injury"
        }
    }
}

enum FallLocation: String, CaseIterable, Codable, Identifiable {
    case homeInside, homeOutside, bathroom, bedroom, stairs, street, store, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .homeInside: return "At home, indoors"
        case .homeOutside: return "At home, outdoors (yard, driveway)"
        case .bathroom: return "Bathroom"
        case .bedroom: return "Bedroom"
        case .stairs: return "Stairs"
        case .street: return "Sidewalk or street"
        case .store: return "Store or public building"
        case .other: return "Somewhere else"
        }
    }
}

enum CareSought: String, CaseIterable, Codable, Identifiable {
    case none, doctor, urgentCare, emergency, admitted

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "No medical care"
        case .doctor: return "Saw my doctor"
        case .urgentCare: return "Urgent care"
        case .emergency: return "Emergency room"
        case .admitted: return "Admitted to hospital"
        }
    }
}

enum AfterFallAdvice {
    static let call911 = [
        "Hit your head and take a blood thinner (such as warfarin, apixaban, rivaroxaban or clopidogrel)",
        "Lost consciousness, or are confused, drowsy or vomiting after hitting your head",
        "Can't get up, can't move a limb, or can't put weight on a leg",
        "Severe pain, or a limb that looks bent or out of shape",
        "Chest pain, trouble breathing, or new weakness or numbness",
    ]

    static let seeDoctorToday = [
        "New pain in your hip, groin, back, wrist or shoulder after the fall — even a small fall can break a bone when you have osteoporosis",
        "You fell because you felt dizzy, faint or blacked out",
        "Pain that is getting worse instead of better",
    ]

    static let gettingUp = [
        "Stay still for a moment and take a few breaths. Check yourself for pain.",
        "If you're hurt or can't get up, call for help: use a medical alert button, phone or smart watch. Keep warm and change position gently while you wait.",
        "If you feel able to, roll onto your side, then onto your hands and knees.",
        "Crawl to a sturdy chair. Put your hands on the seat.",
        "Bring one foot forward so it's flat on the floor, then push up slowly and turn to sit in the chair.",
        "Rest before you try to stand, and tell someone you fell.",
    ]

    struct SafetyItem: Identifiable, Hashable { let id: String; let text: String }

    static let homeSafety: [SafetyItem] = [
        SafetyItem(id: "floors-clear", text: "Floors and stairs are clear of clutter, cords and loose rugs (or rugs have non-slip backing)"),
        SafetyItem(id: "stair-rails", text: "Stairs have sturdy handrails on both sides and good lighting, with switches at the top and bottom"),
        SafetyItem(id: "night-lights", text: "Night lights light the way from the bedroom to the bathroom"),
        SafetyItem(id: "bed-lamp", text: "A lamp or light switch is within reach of the bed"),
        SafetyItem(id: "grab-bars", text: "Grab bars are installed in the shower or tub and next to the toilet"),
        SafetyItem(id: "non-slip-mat", text: "There's a non-slip mat or strips in the tub or shower"),
        SafetyItem(id: "kitchen-reach", text: "Things you use often are within reach without a step stool"),
        SafetyItem(id: "shoes", text: "You wear supportive shoes with thin non-slip soles, indoors and out"),
        SafetyItem(id: "eyes", text: "You've had your eyes checked in the past year"),
        SafetyItem(id: "meds-review", text: "A doctor or pharmacist has reviewed your medicines in the past year"),
        SafetyItem(id: "alert", text: "You have a way to call for help if you fall (phone, medical alert button or watch with fall detection)"),
    ]
}
