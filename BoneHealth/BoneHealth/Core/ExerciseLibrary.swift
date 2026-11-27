import Foundation

enum ExerciseCategory: String, CaseIterable, Codable, Identifiable {
    case strength, balance, weightBearing, posture, flexibility

    var id: String { rawValue }

    var name: String {
        switch self {
        case .strength: return "Strength (resistance)"
        case .balance: return "Balance"
        case .weightBearing: return "Weight-bearing aerobic"
        case .posture: return "Posture and spine-sparing moves"
        case .flexibility: return "Gentle stretching"
        }
    }

    var symbol: String {
        switch self {
        case .strength: return "dumbbell"
        case .balance: return "figure.stand"
        case .weightBearing: return "figure.walk"
        case .posture: return "figure.cooldown"
        case .flexibility: return "figure.flexibility"
        }
    }

    var why: String {
        switch self {
        case .strength: return "Muscles pulling on bone signal it to stay strong. Strength training also makes everyday tasks and getting up from a fall easier."
        case .balance: return "Better balance means fewer falls — and most hip and wrist fractures happen in a fall."
        case .weightBearing: return "Activity on your feet loads your hips and spine. It also keeps your heart and lungs fit."
        case .posture: return "Strong back muscles support the spine and help prevent the stooped posture that strains vertebrae. Learning to bend at the hips protects your spine."
        case .flexibility: return "Gentle stretches keep joints moving. Avoid stretches that round your back or twist hard."
        }
    }

    var weeklyGoal: String {
        switch self {
        case .strength: return "At least 2 days a week, working all major muscle groups"
        case .balance: return "Every day if you can — at least 2 hours over the week, including tai chi or other balance work"
        case .weightBearing: return "150 minutes a week of moderate activity, such as 30 minutes on 5 days"
        case .posture: return "Every day — a few minutes is enough"
        case .flexibility: return "After activity, when muscles are warm"
        }
    }
}

struct BoneExercise: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let summary: String
    let steps: [String]
    let dose: String
    let tips: [String]
    let stopIf: [String]
    /// Shown prominently, e.g. "Skip if you've had a spine fracture unless your physical therapist says it's OK".
    var caution: String?
    var symbol: String { category.symbol }
}

enum ExerciseLibrary {
    static let contentVersion = "Draft 2026-11 — awaiting physical therapist review"

    static let generalStopSigns = [
        "Chest pain, pressure or tightness, or unusual shortness of breath — stop and call 911 if it doesn't settle with rest",
        "Feeling dizzy, faint or sick",
        "Sudden sharp pain, especially in your back, hip or ribs",
        "Pain that is worse the next day and doesn't settle",
    ]

    struct Avoid: Identifiable, Hashable { let title: String; let detail: String; var id: String { title } }

    static let movementsToAvoid: [Avoid] = [
        Avoid(title: "Bending forward with a rounded back", detail: "Toe touches, sit-ups, crunches and rounding to pick things up put heavy pressure on the front of the vertebrae, where spine fractures happen. Bend at your hips and knees instead (see the hip hinge)."),
        Avoid(title: "Twisting your spine to the limit", detail: "Forceful twists, such as a hard golf swing or twisting yoga poses, can strain the spine. Turn your whole body by moving your feet."),
        Avoid(title: "Lifting heavy things with a rounded back", detail: "Keep loads close to your body, bend your knees and keep your back straight. Ask for help with heavy items."),
        Avoid(title: "Combining bending and twisting", detail: "Such as reaching across your body to lift a laundry basket or vacuuming with a twisting motion."),
        Avoid(title: "High-impact jumping if you've had a spine fracture", detail: "Jumping and running can be fine for some people, but check with your doctor or physical therapist first if you have had a spine fracture or very low bone density."),
        Avoid(title: "Activities with a high risk of falling", detail: "Such as using a step ladder alone, or icy surfaces. If you love an activity, ask a physical therapist how to make it safer."),
    ]

    static let all: [BoneExercise] = [
        // Strength
        BoneExercise(id: "sit-to-stand", name: "Sit to stand", category: .strength,
            summary: "Strengthens thighs and hips — the muscles you use to get up from a chair or the floor.",
            steps: ["Sit near the front of a sturdy chair with your feet hip-width apart.", "Lean forward slightly from your hips, keeping your back straight and chest up.", "Push through your heels to stand up fully. Use your hands on the armrests if you need to.", "Slowly lower yourself back down, sitting back with control."],
            dose: "2 sets of 8–12, 2–3 days a week",
            tips: ["Make it harder by not using your hands, using a lower chair, or holding a weight at your chest."],
            stopIf: ["Knee or hip pain that is sharp or stays afterwards"]),
        BoneExercise(id: "wall-push-up", name: "Wall push-up", category: .strength,
            summary: "Strengthens chest, shoulders and arms, which helps protect your wrists if you fall.",
            steps: ["Stand an arm's length from a wall and place your palms on it at shoulder height.", "Keep your body straight from head to heels.", "Bend your elbows to bring your chest towards the wall.", "Push back to the start."],
            dose: "2 sets of 8–12, 2–3 days a week",
            tips: ["Step further from the wall, or progress to a kitchen counter, to make it harder."],
            stopIf: ["Shoulder or wrist pain"]),
        BoneExercise(id: "heel-raise", name: "Heel raises", category: .strength,
            summary: "Strengthens your calves and ankles for walking and balance.",
            steps: ["Stand tall holding the back of a chair or a counter.", "Rise up onto the balls of your feet.", "Hold for a second, then lower slowly."],
            dose: "2 sets of 10–15, 2–3 days a week",
            tips: ["Progress to holding on with one hand, then a fingertip."],
            stopIf: ["Cramping or sharp pain in the calf or Achilles"]),
        BoneExercise(id: "side-leg-raise", name: "Standing side leg raise", category: .strength,
            summary: "Strengthens the hip muscles that keep you steady when you walk.",
            steps: ["Stand tall holding a chair or counter.", "Keeping your toes pointing forward and your body upright, lift one leg out to the side.", "Lower slowly. Repeat, then switch legs."],
            dose: "2 sets of 8–12 each side, 2–3 days a week",
            tips: ["Don't lean your upper body to the side.", "Add an ankle weight or a band around your ankles to progress."],
            stopIf: ["Hip pain"]),
        BoneExercise(id: "band-row", name: "Seated band row", category: .strength,
            summary: "Strengthens your upper back to support good posture.",
            steps: ["Sit tall with a resistance band looped around a sturdy object in front of you, or around your feet.", "Hold the ends with your arms straight.", "Pull your elbows back, squeezing your shoulder blades together.", "Slowly return."],
            dose: "2 sets of 8–12, 2–3 days a week",
            tips: ["Keep your back upright — don't lean back or round forward."],
            stopIf: ["Neck or shoulder pain"]),
        BoneExercise(id: "step-up", name: "Step-ups", category: .strength,
            summary: "Builds leg strength for stairs and curbs, and loads the hip bones.",
            steps: ["Stand facing the bottom stair, holding the handrail.", "Step up with one foot, then bring the other up.", "Step down with the first foot, then the other.", "Repeat, leading with the other leg."],
            dose: "2 sets of 8–10 each leg, 2–3 days a week",
            tips: ["Start with a low step. Hold a weight in your free hand to progress."],
            stopIf: ["Knee pain or feeling unsteady"]),
        BoneExercise(id: "hip-bridge", name: "Bridge", category: .strength,
            summary: "Strengthens your buttocks and the back of your thighs.",
            steps: ["Lie on your back with knees bent and feet flat.", "Tighten your buttocks and lift your hips until your body is in a line from shoulders to knees.", "Hold for 2–3 seconds, then lower slowly."],
            dose: "2 sets of 8–12, 2–3 days a week",
            tips: ["Roll onto your side and push up with your arms to get up from the floor — don't sit straight up."],
            stopIf: ["Back pain"]),

        // Balance
        BoneExercise(id: "tandem-stand", name: "Heel-to-toe stand", category: .balance,
            summary: "A simple way to challenge your balance safely.",
            steps: ["Stand at a counter with one hand on it.", "Place one foot directly in front of the other, heel touching toes.", "Hold for up to 30 seconds, then switch feet."],
            dose: "3–4 times each side, daily",
            tips: ["Progress by holding on lightly, then hovering your hand, then looking side to side."],
            stopIf: ["You can't stay steady even with a hand on the counter"]),
        BoneExercise(id: "single-leg", name: "Single-leg stand", category: .balance,
            summary: "Improves the balance you need to step over things and climb stairs.",
            steps: ["Stand at a counter holding on with both hands.", "Lift one foot a little off the floor.", "Hold for up to 30 seconds, then switch."],
            dose: "3–4 times each side, daily",
            tips: ["Progress to holding on with one hand, then one finger.", "Try it while brushing your teeth (holding the sink)."],
            stopIf: ["Feeling dizzy"]),
        BoneExercise(id: "heel-toe-walk", name: "Heel-to-toe walk", category: .balance,
            summary: "Trains balance while moving.",
            steps: ["Stand next to a counter or wall you can touch.", "Walk forward placing the heel of one foot right in front of the toes of the other.", "Take 10–20 steps, looking ahead, not at your feet."],
            dose: "2–3 times, daily",
            tips: ["Have someone nearby the first few times."],
            stopIf: ["You start to lose your balance often"]),
        BoneExercise(id: "side-step", name: "Side stepping", category: .balance,
            summary: "Strengthens hips and trains balance for sideways movements, a common cause of hip fractures.",
            steps: ["Stand facing a counter, holding it lightly.", "Step sideways along it 10 steps, keeping your toes forward.", "Step back the other way."],
            dose: "2–3 times each way, daily",
            tips: ["Add a band around your thighs to make it harder."],
            stopIf: ["Hip pain"]),
        BoneExercise(id: "tai-chi", name: "Tai chi weight shifts", category: .balance,
            summary: "Tai chi has strong evidence for reducing falls.",
            steps: ["Stand with feet wider than your hips, knees slightly bent, near a counter.", "Slowly shift your weight onto your right foot, then back to the middle, then onto your left.", "Move slowly and breathe steadily. Then try shifting forward and back with one foot ahead."],
            dose: "5–10 minutes, daily. Consider a tai chi class for older adults.",
            tips: ["Look for programs such as Tai Ji Quan: Moving for Better Balance."],
            stopIf: ["Knee pain"]),

        // Weight-bearing
        BoneExercise(id: "brisk-walk", name: "Brisk walking", category: .weightBearing,
            summary: "The easiest bone-loading activity to fit into every day.",
            steps: ["Walk at a pace where you can talk but not sing.", "Start with 10 minutes and build up.", "Choose even, well-lit paths and wear supportive shoes."],
            dose: "30 minutes, 5 days a week (can be split into 10-minute walks)",
            tips: ["Walking poles can improve stability and posture."],
            stopIf: ["Chest pain or unusual breathlessness"]),
        BoneExercise(id: "stairs", name: "Stair climbing", category: .weightBearing,
            summary: "Loads the hips more than walking on the flat.",
            steps: ["Hold the handrail.", "Climb at a steady pace, placing your whole foot on each step.", "Rest at the top before coming down."],
            dose: "A few flights a day",
            tips: [],
            stopIf: ["Knee pain or feeling unsteady"]),
        BoneExercise(id: "heel-drops", name: "Heel drops", category: .weightBearing,
            summary: "A small impact that sends a strong signal to the hip bones.",
            steps: ["Stand holding a counter.", "Rise onto your toes, then drop your heels to the floor with a firm thump.", "Stand still for a moment between each one."],
            dose: "10–20 drops, once or twice a day",
            tips: ["Progress slowly over weeks."],
            stopIf: ["Back, hip or knee pain"],
            caution: "Skip this if you've had a spine fracture or have very low bone density, unless your doctor or physical therapist says it's OK."),
        BoneExercise(id: "dance", name: "Dancing", category: .weightBearing,
            summary: "Fun, social and good for balance too.",
            steps: ["Choose a style without big twists or deep forward bends.", "Start with 10–15 minutes."],
            dose: "Count it towards your 150 minutes a week",
            tips: ["Line dancing and ballroom are good choices."],
            stopIf: ["Dizziness or pain"]),

        // Posture and spine-sparing
        BoneExercise(id: "hip-hinge", name: "Hip hinge (safe bending)", category: .posture,
            summary: "The way to bend that protects your spine. Use it to pick things up, load the dishwasher and get into the car.",
            steps: ["Stand with feet hip-width apart, a chair in front of you.", "Place your hands on your hips.", "Keeping your back straight and chest proud, push your hips back and bend your knees slightly, as if closing a car door with your bottom.", "Return to standing by squeezing your buttocks."],
            dose: "10 times daily to practise, then use it all the time",
            tips: ["Hold a broomstick along your back touching your head, upper back and tailbone — it should stay in contact."],
            stopIf: ["Back pain"]),
        BoneExercise(id: "chin-tuck", name: "Chin tucks", category: .posture,
            summary: "Counteracts a forward head posture.",
            steps: ["Sit or stand tall, looking straight ahead.", "Gently draw your chin straight back, making a \"double chin\".", "Hold 3–5 seconds, then relax."],
            dose: "10 times, daily",
            tips: [],
            stopIf: ["Dizziness or neck pain"]),
        BoneExercise(id: "shoulder-squeeze", name: "Shoulder blade squeeze", category: .posture,
            summary: "Strengthens the muscles between your shoulder blades.",
            steps: ["Sit or stand tall with arms by your sides.", "Squeeze your shoulder blades back and down.", "Hold 5 seconds, then relax."],
            dose: "10 times, daily",
            tips: ["Don't shrug your shoulders up towards your ears."],
            stopIf: []),
        BoneExercise(id: "prone-extension", name: "Lying back extension", category: .posture,
            summary: "Strengthens the back extensor muscles; studies show this can reduce spine fractures.",
            steps: ["Lie face down with a pillow under your hips and arms by your sides.", "Squeeze your shoulder blades and lift your head and shoulders a few inches, looking at the floor.", "Hold 3 seconds, then lower slowly."],
            dose: "Start with 5, building to 10, 3 days a week",
            tips: ["If lying on your front is hard, try standing \"wall arches\": stand with your back to a wall and gently press your shoulders and head back towards it."],
            stopIf: ["Back pain"],
            caution: "If you've had a recent spine fracture, ask your physical therapist before starting."),
        BoneExercise(id: "wall-stand", name: "Wall posture check", category: .posture,
            summary: "Shows how upright you can stand and lets you practise.",
            steps: ["Stand with your heels, buttocks, shoulders and head against a wall.", "If your head doesn't touch, gently tuck your chin and bring it as close as is comfortable.", "Hold 30 seconds, breathing normally."],
            dose: "Once or twice a day",
            tips: ["If the gap between the back of your head and the wall is growing over time, tell your doctor."],
            stopIf: ["Neck pain"]),

        // Flexibility
        BoneExercise(id: "chest-stretch", name: "Doorway chest stretch", category: .flexibility,
            summary: "Opens up a tight chest that pulls you into a stoop.",
            steps: ["Stand in a doorway with forearms on the frame, elbows at shoulder height.", "Step one foot forward until you feel a gentle stretch across your chest.", "Hold 20–30 seconds."],
            dose: "2–3 times, daily",
            tips: [],
            stopIf: ["Shoulder pain"]),
        BoneExercise(id: "calf-stretch", name: "Calf stretch", category: .flexibility,
            summary: "Keeps ankles flexible for a steady walk.",
            steps: ["Stand facing a wall, hands on it.", "Step one foot back, keeping the heel down and knee straight.", "Lean forward until you feel the stretch in your calf. Hold 20–30 seconds."],
            dose: "2–3 times each side, daily",
            tips: [],
            stopIf: []),
        BoneExercise(id: "hamstring-stretch", name: "Seated hamstring stretch (straight back)", category: .flexibility,
            summary: "Stretches the back of the thigh without rounding the spine.",
            steps: ["Sit on the front of a chair with one leg straight out, heel on the floor.", "Keeping your back straight and chest up, lean forward from your hips until you feel a gentle stretch.", "Hold 20–30 seconds."],
            dose: "2 times each side, daily",
            tips: ["Don't reach for your toes or round your back."],
            stopIf: ["Back pain"]),
    ]

    static func exercise(_ id: String) -> BoneExercise? { all.first { $0.id == id } }
    static func exercises(in category: ExerciseCategory) -> [BoneExercise] { all.filter { $0.category == category } }
}

/// One logged session, as plain values for progress calculations.
struct ExerciseRecord: Hashable {
    var date: Date
    var category: ExerciseCategory
    var minutes: Int
}

struct WeeklyExerciseProgress: Hashable {
    var aerobicMinutes: Int
    var strengthDays: Int
    var balanceMinutes: Int
    var postureDays: Int

    static let aerobicGoal = 150
    static let strengthGoal = 2
    static let balanceGoal = 120
    static let postureGoal = 5

    /// Counts the 7 days ending on `day`.
    static func compute(_ records: [ExerciseRecord], endingOn day: Date = Date(), calendar: Calendar = .current) -> WeeklyExerciseProgress {
        let end = calendar.startOfDay(for: day)
        guard let start = calendar.date(byAdding: .day, value: -6, to: end),
              let endExclusive = calendar.date(byAdding: .day, value: 1, to: end) else {
            return WeeklyExerciseProgress(aerobicMinutes: 0, strengthDays: 0, balanceMinutes: 0, postureDays: 0)
        }
        let week = records.filter { $0.date >= start && $0.date < endExclusive }
        func days(_ c: ExerciseCategory) -> Int { Set(week.filter { $0.category == c }.map { calendar.startOfDay(for: $0.date) }).count }
        func minutes(_ c: ExerciseCategory) -> Int { week.filter { $0.category == c }.reduce(0) { $0 + $1.minutes } }
        return WeeklyExerciseProgress(aerobicMinutes: minutes(.weightBearing), strengthDays: days(.strength),
                                      balanceMinutes: minutes(.balance), postureDays: days(.posture))
    }
}
