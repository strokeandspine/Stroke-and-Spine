import Foundation

// DRAFT CONTENT — needs review by the product owner (and ideally a licensed physical therapist)
// before release. Each exercise is written to be filmed: the steps double as the video script.
// Content version is shown in the app so reviewed versions can be tracked.

enum ExerciseContent {
    static let version = "Draft 0.1 — not yet clinically reviewed"

    /// Shown before every session and on every exercise.
    static let generalStopIf = [
        "Pain spreads further down your leg, or you get new numbness, tingling or weakness",
        "Sharp, stabbing pain that doesn't ease as soon as you stop",
        "Pain is more than 2 points higher than when you started and still higher the next morning",
        "Dizziness, chest pain or shortness of breath",
    ]

    /// The "traffic light" pain guide used across the app.
    static let painGuide = [
        "Green — up to 2 points above your usual pain during exercise is OK, as long as it settles back within a day. Hurt doesn't mean harm.",
        "Amber — 3–4 points higher, or it takes longer than a day to settle: do fewer reps or try the easier version next time.",
        "Red — pain over 5 points higher, or any of the stop signs: stop, and check in with your doctor or physical therapist.",
    ]
}

struct Exercise: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case mobility = "Mobility"
        case core = "Core stability"
        case strength = "Strength"
        case stretch = "Stretching"
        case nerve = "Nerve glides"
        case activity = "Walking and activity"
        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .mobility: return "arrow.triangle.2.circlepath"
            case .core: return "circle.grid.cross"
            case .strength: return "dumbbell"
            case .stretch: return "figure.flexibility"
            case .nerve: return "bolt.horizontal"
            case .activity: return "figure.walk"
            }
        }
    }

    enum Position: String {
        case onBack = "Lying on your back"
        case onFront = "Lying on your front"
        case onSide = "Lying on your side"
        case handsKnees = "On hands and knees"
        case kneeling = "Kneeling"
        case sitting = "Sitting"
        case standing = "Standing"
    }

    struct Dosage: Hashable {
        var reps: Int? = nil
        var holdSeconds: Int? = nil
        var sets: Int = 1
        var perSide: Bool = false
        var minutes: Int? = nil

        var description: String {
            if let minutes { return "\(minutes) minutes" }
            var parts: [String] = []
            if let reps { parts.append("\(reps) reps" + (perSide ? " each side" : "")) }
            if let holdSeconds { parts.append("hold \(holdSeconds) seconds" + (reps == nil && perSide ? " each side" : "")) }
            if sets > 1 { parts.append("\(sets) sets") }
            return parts.joined(separator: ", ")
        }
    }

    let id: String
    let name: String
    let category: Category
    let position: Position
    let purpose: String
    let steps: [String]
    let cues: [String]
    let mistakes: [String]
    let dosage: Dosage
    var easierID: String? = nil
    var harderID: String? = nil
    /// Extra stop signs for this exercise, on top of `ExerciseContent.generalStopIf`.
    var stopIf: [String] = []
    /// Gentle enough for the first weeks after spine surgery (with the surgeon's OK).
    var earlyPostOpOK: Bool = false
    /// Not recommended in the first 3 months after a fusion unless the surgeon says otherwise.
    var avoidAfterRecentFusion: Bool = false
}

enum ExerciseLibrary {
    static let all: [Exercise] = [
        // MARK: Early / gentle
        Exercise(id: "ankle-pumps", name: "Ankle pumps", category: .mobility, position: .onBack,
            purpose: "Keeps blood moving in your legs and gently moves the nerves. Useful in the first days after surgery.",
            steps: ["Lie on your back with your legs straight.", "Point your toes away from you.", "Then pull them back toward you.", "Keep a steady rhythm."],
            cues: ["Move only at the ankles", "Breathe normally"],
            mistakes: ["Holding your breath"],
            dosage: .init(reps: 20, sets: 1), earlyPostOpOK: true),

        Exercise(id: "heel-slides", name: "Heel slides", category: .mobility, position: .onBack,
            purpose: "Gentle leg movement without moving your back.",
            steps: ["Lie on your back with both legs straight.", "Slowly slide one heel toward your bottom, bending the knee.", "Go only as far as is comfortable.", "Slide it back down and switch legs."],
            cues: ["Keep your back relaxed and still", "Slide, don't lift"],
            mistakes: ["Arching your back as the leg straightens"],
            dosage: .init(reps: 10, perSide: true), earlyPostOpOK: true),

        Exercise(id: "abdominal-brace", name: "Abdominal bracing", category: .core, position: .onBack,
            purpose: "Wakes up the deep tummy muscles that support your spine. The foundation for all the core exercises.",
            steps: ["Lie on your back with knees bent and feet flat.", "Place your fingertips just inside your hip bones.", "Breathe in. As you breathe out, gently tighten your lower tummy as if zipping up tight trousers. You should feel the muscle firm under your fingers.", "Hold while breathing normally, then relax."],
            cues: ["About 30% effort — gentle, not a full squeeze", "Keep breathing", "Your back shouldn't move"],
            mistakes: ["Holding your breath", "Pushing your back hard into the floor", "Sucking your stomach in hard"],
            dosage: .init(reps: 10, holdSeconds: 10), harderID: "dead-bug", earlyPostOpOK: true),

        // MARK: Mobility
        Exercise(id: "pelvic-tilt", name: "Pelvic tilts", category: .mobility, position: .onBack,
            purpose: "Gently moves your lower back and helps ease stiffness.",
            steps: ["Lie on your back with knees bent and feet flat.", "Gently flatten your lower back into the floor by tilting your pelvis back.", "Then let it arch slightly away from the floor.", "Rock slowly between the two, staying in a comfortable range."],
            cues: ["Small, slow movements", "Let your breathing stay relaxed"],
            mistakes: ["Lifting your bottom off the floor", "Pushing into pain"],
            dosage: .init(reps: 10, sets: 2), earlyPostOpOK: true),

        Exercise(id: "knee-to-chest", name: "Single knee to chest", category: .stretch, position: .onBack,
            purpose: "Eases tension in the lower back and buttock.",
            steps: ["Lie on your back with knees bent.", "Hold behind one thigh and gently draw the knee toward your chest.", "Hold, then lower slowly and switch legs."],
            cues: ["Hold behind the thigh, not on the kneecap", "Keep the other foot on the floor"],
            mistakes: ["Pulling hard or bouncing", "Lifting your head and shoulders"],
            dosage: .init(reps: 3, holdSeconds: 20, perSide: true),
            avoidAfterRecentFusion: true),

        Exercise(id: "knee-rolls", name: "Knee rolls (lower trunk rotation)", category: .mobility, position: .onBack,
            purpose: "Gentle twisting movement to ease stiffness.",
            steps: ["Lie on your back with knees bent and together, feet flat.", "Slowly let both knees fall to one side as far as is comfortable.", "Bring them back to the middle, then to the other side."],
            cues: ["Keep both shoulders on the floor", "Move slowly and smoothly"],
            mistakes: ["Letting the knees drop quickly", "Going further than is comfortable"],
            dosage: .init(reps: 10, perSide: true),
            avoidAfterRecentFusion: true),

        Exercise(id: "cat-cow", name: "Cat–cow", category: .mobility, position: .handsKnees,
            purpose: "Moves the whole spine through a comfortable range.",
            steps: ["Start on hands and knees: hands under shoulders, knees under hips.", "Slowly round your back up toward the ceiling, letting your head drop.", "Then slowly let your back dip down and lift your head to look forward.", "Move between the two in a comfortable range."],
            cues: ["Move with your breath", "Slow and smooth"],
            mistakes: ["Forcing the end of the movement", "Locking your elbows"],
            dosage: .init(reps: 10),
            avoidAfterRecentFusion: true),

        Exercise(id: "childs-pose", name: "Child's pose", category: .stretch, position: .kneeling,
            purpose: "A resting stretch for the lower back and hips.",
            steps: ["Start on hands and knees.", "Slowly sit your hips back toward your heels, sliding your hands forward.", "Rest your forehead down if comfortable and breathe slowly.", "Walk your hands back to come up."],
            cues: ["Widen your knees if that's more comfortable", "Relax into it"],
            mistakes: ["Forcing your hips down to your heels"],
            dosage: .init(reps: 3, holdSeconds: 20),
            stopIf: ["Knee pain — place a pillow behind your knees or skip this one"],
            avoidAfterRecentFusion: true),

        Exercise(id: "prone-lying", name: "Lying on your front (prone on elbows)", category: .mobility, position: .onFront,
            purpose: "Gently extends the lower back. A starting point if bending backward eases your pain.",
            steps: ["Lie on your front for a minute to relax.", "Prop yourself up on your elbows, keeping your hips on the floor.", "Let your lower back relax and sag.", "Hold, then lower down."],
            cues: ["Keep your bottom relaxed"],
            mistakes: ["Shrugging your shoulders up to your ears"],
            dosage: .init(reps: 3, holdSeconds: 30), harderID: "press-up",
            stopIf: ["Leg pain increases or spreads further down the leg"]),

        Exercise(id: "press-up", name: "Prone press-up (back extension)", category: .mobility, position: .onFront,
            purpose: "For people whose pain eases when bending backward. Helpful leg pain often moves up toward the back (\"centralizes\") — that is a good sign.",
            steps: ["Lie on your front with your hands under your shoulders, as if starting a push-up.", "Keeping your hips on the floor, slowly straighten your arms to lift your chest.", "Go only as far as is comfortable and let your lower back sag.", "Pause, then lower slowly."],
            cues: ["Hips stay down", "Let your back muscles relax — your arms do the work"],
            mistakes: ["Lifting your hips", "Tensing your bottom"],
            dosage: .init(reps: 10), easierID: "prone-lying",
            stopIf: ["Leg pain increases or spreads further down the leg — stop and use the easier version"],
            avoidAfterRecentFusion: true),

        Exercise(id: "standing-extension", name: "Standing back bend", category: .mobility, position: .standing,
            purpose: "A quick reset after sitting for a long time.",
            steps: ["Stand with feet hip-width apart.", "Place your hands on your lower back, fingers pointing down.", "Gently lean backward, using your hands for support.", "Return to upright."],
            cues: ["Small movement", "Look forward, not up at the ceiling"],
            mistakes: ["Bending your knees", "Going too far"],
            dosage: .init(reps: 5),
            stopIf: ["Leg pain increases or spreads further down the leg"],
            avoidAfterRecentFusion: true),

        // MARK: Core stability
        Exercise(id: "bridge", name: "Glute bridge", category: .strength, position: .onBack,
            purpose: "Strengthens your buttock muscles, which help support your lower back.",
            steps: ["Lie on your back with knees bent and feet flat, hip-width apart.", "Gently brace your tummy.", "Squeeze your buttocks and lift your hips until your body makes a straight line from shoulders to knees.", "Hold briefly, then lower slowly."],
            cues: ["Push through your heels", "Squeeze your buttocks, not your back"],
            mistakes: ["Arching your back at the top", "Letting your knees fall in or out"],
            dosage: .init(reps: 10, holdSeconds: 3, sets: 2), harderID: "single-leg-bridge"),

        Exercise(id: "single-leg-bridge", name: "Single-leg bridge", category: .strength, position: .onBack,
            purpose: "A harder bridge that also challenges hip control.",
            steps: ["Start in the bridge position.", "Straighten one knee so that leg is held out in line with your thigh.", "Lift your hips using the other leg, keeping your pelvis level.", "Lower slowly. Switch sides."],
            cues: ["Keep both hips level, like a tray"],
            mistakes: ["Letting one hip drop"],
            dosage: .init(reps: 8, perSide: true), easierID: "bridge"),

        Exercise(id: "bird-dog", name: "Bird dog", category: .core, position: .handsKnees,
            purpose: "Trains your back and tummy muscles to keep your spine steady while your arms and legs move.",
            steps: ["Start on hands and knees with a flat back.", "Gently brace your tummy.", "Slide one leg back and lift it to hip height.", "If that's easy, also lift the opposite arm forward.", "Hold, return, then switch sides."],
            cues: ["Imagine a cup of tea balanced on your lower back", "Reach long rather than high"],
            mistakes: ["Twisting your hips", "Lifting the leg too high and arching"],
            dosage: .init(reps: 8, holdSeconds: 5, perSide: true), easierID: "abdominal-brace"),

        Exercise(id: "dead-bug", name: "Dead bug", category: .core, position: .onBack,
            purpose: "Builds deep core control without loading your back.",
            steps: ["Lie on your back and lift your knees so your hips and knees are bent at 90°, arms reaching to the ceiling.", "Gently brace your tummy so your lower back stays still.", "Slowly lower one heel to tap the floor.", "Return and switch legs. When that's easy, lower the opposite arm overhead at the same time."],
            cues: ["Keep your lower back still", "Move slowly, breathe out as you lower"],
            mistakes: ["Your back arching off the floor", "Rushing"],
            dosage: .init(reps: 8, perSide: true), easierID: "abdominal-brace"),

        Exercise(id: "side-plank-knees", name: "Side plank from the knees", category: .core, position: .onSide,
            purpose: "Strengthens the muscles along the side of your trunk.",
            steps: ["Lie on your side propped on your forearm, elbow under your shoulder, knees bent behind you.", "Lift your hips so your body is in a line from head to knees.", "Hold, then lower. Switch sides."],
            cues: ["Push the floor away with your forearm", "Hips forward, not sagging back"],
            mistakes: ["Letting your hips drop", "Shrugging the shoulder"],
            dosage: .init(reps: 3, holdSeconds: 15, perSide: true), harderID: "side-plank"),

        Exercise(id: "side-plank", name: "Side plank", category: .core, position: .onSide,
            purpose: "A harder side plank for building endurance.",
            steps: ["Start as for the side plank from the knees, but with legs straight and feet stacked.", "Lift your hips into a straight line from head to feet.", "Hold, then lower. Switch sides."],
            cues: ["Keep breathing"],
            mistakes: ["Hips sagging"],
            dosage: .init(reps: 3, holdSeconds: 20, perSide: true), easierID: "side-plank-knees",
            avoidAfterRecentFusion: true),

        Exercise(id: "plank-modified", name: "Front plank from the knees", category: .core, position: .kneeling,
            purpose: "Builds endurance in the muscles that support your spine.",
            steps: ["Lie on your front propped on your forearms, elbows under shoulders.", "Brace gently and lift your body so you're supported on forearms and knees.", "Keep a straight line from head to knees. Hold, then lower."],
            cues: ["Look at the floor just ahead of your hands"],
            mistakes: ["Bottom high in the air", "Back sagging"],
            dosage: .init(reps: 3, holdSeconds: 15),
            avoidAfterRecentFusion: true),

        // MARK: Strength
        Exercise(id: "clamshell", name: "Clamshells", category: .strength, position: .onSide,
            purpose: "Strengthens the hip muscles that help keep your pelvis steady when you walk.",
            steps: ["Lie on your side with hips and knees bent, feet together.", "Keeping your feet touching, lift your top knee.", "Lower slowly. Switch sides after the set."],
            cues: ["Don't let your top hip roll backward", "Slow on the way down"],
            mistakes: ["Rolling your hips back to lift higher"],
            dosage: .init(reps: 12, perSide: true), earlyPostOpOK: true),

        Exercise(id: "sit-to-stand", name: "Sit to stand", category: .strength, position: .sitting,
            purpose: "Builds leg strength for everyday tasks and teaches you to bend at the hips, not the back.",
            steps: ["Sit near the front of a sturdy chair with feet hip-width apart.", "Lean forward from your hips with a straight back.", "Push through your feet to stand up tall.", "Sit back down slowly, reaching your bottom back."],
            cues: ["Nose over toes as you stand", "Use your arms on the chair if you need to"],
            mistakes: ["Dropping into the chair", "Rounding your back"],
            dosage: .init(reps: 10, sets: 2), earlyPostOpOK: true),

        // MARK: Stretching
        Exercise(id: "hip-flexor-stretch", name: "Kneeling hip flexor stretch", category: .stretch, position: .kneeling,
            purpose: "Stretches the front of the hip, which gets tight from sitting.",
            steps: ["Kneel on one knee with the other foot flat in front (a cushion under the knee helps).", "Tuck your tailbone under slightly.", "Gently shift your weight forward until you feel a stretch at the front of the kneeling hip.", "Hold, then switch sides."],
            cues: ["Stay tall", "Tuck the tailbone — don't arch your back"],
            mistakes: ["Leaning forward or arching your back"],
            dosage: .init(reps: 2, holdSeconds: 30, perSide: true)),

        Exercise(id: "hamstring-stretch", name: "Hamstring stretch with a strap", category: .stretch, position: .onBack,
            purpose: "Stretches the back of the thigh without bending your back.",
            steps: ["Lie on your back with one knee bent and that foot flat.", "Loop a towel or strap around the other foot.", "Lift that leg, keeping the knee as straight as is comfortable, until you feel a stretch behind the thigh.", "Hold, then switch sides."],
            cues: ["Keep your head and back relaxed on the floor"],
            mistakes: ["Pulling until it hurts"],
            dosage: .init(reps: 2, holdSeconds: 30, perSide: true),
            stopIf: ["Shooting pain or tingling down the leg — try the nerve glide instead and check with your physical therapist"]),

        Exercise(id: "figure-four", name: "Figure-4 buttock stretch", category: .stretch, position: .onBack,
            purpose: "Stretches the deep buttock muscles.",
            steps: ["Lie on your back with knees bent.", "Cross one ankle over the other knee.", "Hold behind the bottom thigh and gently draw both legs toward you until you feel a stretch in the buttock.", "Hold, then switch sides."],
            cues: ["Keep your head down and shoulders relaxed"],
            mistakes: ["Forcing the knee down"],
            dosage: .init(reps: 2, holdSeconds: 30, perSide: true),
            avoidAfterRecentFusion: true),

        // MARK: Nerve
        Exercise(id: "sciatic-slider", name: "Sciatic nerve glide (seated)", category: .nerve, position: .sitting,
            purpose: "Gently moves the sciatic nerve to help with leg pain. It should feel like a mild stretch, never sharp.",
            steps: ["Sit upright on a chair.", "Slowly straighten one knee while tipping your head back to look up.", "Then bend the knee back down while bringing your chin toward your chest.", "Keep moving smoothly between the two. Switch legs."],
            cues: ["Smooth, rhythmic movement — don't hold the end position", "Mild tension is fine, pain is not"],
            mistakes: ["Holding the stretch", "Going into sharp or tingling pain"],
            dosage: .init(reps: 10, perSide: true),
            stopIf: ["Tingling or pain that lasts after you stop"]),

        // MARK: Activity
        Exercise(id: "walking", name: "Walking", category: .activity, position: .standing,
            purpose: "One of the best-proven activities for back pain. Short, frequent walks beat one long one at first.",
            steps: ["Walk at a comfortable pace on a flat surface.", "Start with what you can do comfortably — even 5 minutes counts.", "Add about 10% each week, or 1–2 minutes per walk."],
            cues: ["Stand tall and let your arms swing", "Several short walks a day are fine"],
            mistakes: ["Doing too much on a good day, then paying for it (\"boom and bust\")"],
            dosage: .init(minutes: 10), earlyPostOpOK: true),
    ]

    static func exercise(_ id: String) -> Exercise? { all.first { $0.id == id } }
}

// MARK: - Programs

struct RehabProgram: Identifiable, Hashable {
    struct Stage: Hashable {
        let name: String
        let goal: String
        let exerciseIDs: [String]
        /// Sessions to complete comfortably before the app suggests moving on.
        let minimumSessions: Int
    }

    let id: String
    let name: String
    let summary: String
    let whoItsFor: String
    let sessionsPerWeek: Int
    let stages: [Stage]
    let isFree: Bool
    /// Requires the person to confirm their surgeon has cleared them for exercise.
    var requiresSurgeonClearance: Bool = false

    var exercises: [Exercise] {
        Array(Set(stages.flatMap(\.exerciseIDs))).compactMap(ExerciseLibrary.exercise).sorted { $0.name < $1.name }
    }
}

enum RehabPrograms {
    static let all: [RehabProgram] = [
        RehabProgram(id: "getting-started", name: "Getting started",
            summary: "Gentle movement and walking to ease stiffness and build confidence.",
            whoItsFor: "Anyone with back pain who is new to exercise or in a flare-up.",
            sessionsPerWeek: 5,
            stages: [
                .init(name: "Stage 1", goal: "Move gently every day", exerciseIDs: ["pelvic-tilt", "knee-rolls", "knee-to-chest", "abdominal-brace", "walking"], minimumSessions: 5),
                .init(name: "Stage 2", goal: "Add strength", exerciseIDs: ["pelvic-tilt", "knee-rolls", "bridge", "abdominal-brace", "sit-to-stand", "walking"], minimumSessions: 6),
            ],
            isFree: true),

        RehabProgram(id: "after-surgery-early", name: "After surgery: early recovery",
            summary: "Very gentle exercises and walking for the first weeks after spine surgery.",
            whoItsFor: "People in the first 6 weeks after back surgery whose surgeon has said it's OK to start gentle exercise. Always follow your surgeon's own instructions first.",
            sessionsPerWeek: 7,
            stages: [
                .init(name: "Weeks 0–2", goal: "Walk often and keep your legs moving", exerciseIDs: ["ankle-pumps", "heel-slides", "abdominal-brace", "walking"], minimumSessions: 10),
                .init(name: "Weeks 2–6", goal: "Build everyday strength", exerciseIDs: ["heel-slides", "abdominal-brace", "clamshell", "sit-to-stand", "walking"], minimumSessions: 12),
            ],
            isFree: true, requiresSurgeonClearance: true),

        RehabProgram(id: "core-strength", name: "Core and strength",
            summary: "A progressive program to build the muscles that support your back.",
            whoItsFor: "People who can do the Getting started program comfortably.",
            sessionsPerWeek: 3,
            stages: [
                .init(name: "Foundation", goal: "Learn to control your core", exerciseIDs: ["abdominal-brace", "bridge", "bird-dog", "clamshell", "cat-cow"], minimumSessions: 6),
                .init(name: "Build", goal: "Increase strength and endurance", exerciseIDs: ["dead-bug", "bridge", "bird-dog", "side-plank-knees", "sit-to-stand", "hip-flexor-stretch"], minimumSessions: 6),
                .init(name: "Challenge", goal: "Strength for work, sport and lifting", exerciseIDs: ["dead-bug", "single-leg-bridge", "bird-dog", "side-plank", "plank-modified", "sit-to-stand"], minimumSessions: 8),
            ],
            isFree: false),

        RehabProgram(id: "leg-pain", name: "Leg pain (sciatica)",
            summary: "Gentle positions, nerve glides and walking for pain that travels down the leg.",
            whoItsFor: "People with leg pain from the back. If your leg pain spreads further down or you get weakness, stop and run the warning-sign check.",
            sessionsPerWeek: 5,
            stages: [
                .init(name: "Settle", goal: "Find comfortable positions", exerciseIDs: ["prone-lying", "abdominal-brace", "sciatic-slider", "walking"], minimumSessions: 6),
                .init(name: "Move", goal: "Restore movement and strength", exerciseIDs: ["press-up", "sciatic-slider", "bridge", "bird-dog", "walking"], minimumSessions: 8),
            ],
            isFree: false),

        RehabProgram(id: "desk-reset", name: "Desk worker reset",
            summary: "Short routines to break up sitting and undo stiffness.",
            whoItsFor: "People whose back pain is worse with long sitting.",
            sessionsPerWeek: 5,
            stages: [
                .init(name: "Daily reset", goal: "Move every 30–45 minutes", exerciseIDs: ["standing-extension", "sit-to-stand", "hip-flexor-stretch", "cat-cow", "walking"], minimumSessions: 10),
            ],
            isFree: false),
    ]

    static func program(_ id: String) -> RehabProgram? { all.first { $0.id == id } }

    /// Exercises a free user can open: everything used in a free program.
    static let freeExerciseIDs: Set<String> = Set(RehabPrograms.all.filter(\.isFree).flatMap { $0.stages.flatMap(\.exerciseIDs) })
}

// MARK: - Progression

enum Difficulty: Int, Codable, CaseIterable {
    case tooEasy = 0, aboutRight = 1, tooHard = 2
    var label: String {
        switch self {
        case .tooEasy: return "Too easy"
        case .aboutRight: return "About right"
        case .tooHard: return "Too hard"
        }
    }
}

struct SessionSummary {
    var date: Date
    var stageIndex: Int
    var painBefore: Int
    var painAfter: Int
    var difficulty: Difficulty
    var hurtExerciseIDs: [String]
}

enum ProgressionAdvice: Equatable {
    case keepGoing
    case stepBack(reason: String, easierOptions: [String: String])  // hurt exercise ID → easier exercise ID
    case readyToProgress(nextStage: Int)
    case programComplete

    var message: String {
        switch self {
        case .keepGoing: return "Keep going with this stage."
        case .stepBack(let reason, _): return reason
        case .readyToProgress: return "You've been doing well. You're ready to move on to the next stage."
        case .programComplete: return "You've completed this program. Keep it up, or try a more challenging one."
        }
    }
}

enum RehabProgression {
    /// Uses the "traffic light" rules in `ExerciseContent.painGuide`.
    static func advice(program: RehabProgram, stageIndex: Int, sessions: [SessionSummary]) -> ProgressionAdvice {
        let stageSessions = sessions.filter { $0.stageIndex == stageIndex }.sorted { $0.date < $1.date }
        guard let last = stageSessions.last else { return .keepGoing }

        let painJump = last.painAfter - last.painBefore
        if !last.hurtExerciseIDs.isEmpty || painJump >= 3 || last.difficulty == .tooHard {
            var easier: [String: String] = [:]
            for id in last.hurtExerciseIDs {
                if let e = ExerciseLibrary.exercise(id)?.easierID { easier[id] = e }
            }
            let reason: String
            if painJump >= 3 {
                reason = "Your pain went up \(painJump) points last session. Next time do fewer reps, move in a smaller range, or use the easier versions. If pain stays higher the next day, check in with your doctor or physical therapist."
            } else if !last.hurtExerciseIDs.isEmpty {
                reason = "Some exercises bothered you last session. Try the easier versions or fewer reps for those."
            } else {
                reason = "Last session felt too hard. Do fewer reps or sets until it feels about right."
            }
            return .stepBack(reason: reason, easierOptions: easier)
        }

        let stage = program.stages[min(stageIndex, program.stages.count - 1)]
        let recent = stageSessions.suffix(3)
        let comfortable = recent.count == 3 && recent.allSatisfy {
            $0.difficulty != .tooHard && $0.painAfter - $0.painBefore <= 2 && $0.hurtExerciseIDs.isEmpty
        }
        if stageSessions.count >= stage.minimumSessions && comfortable {
            return stageIndex + 1 < program.stages.count ? .readyToProgress(nextStage: stageIndex + 1) : .programComplete
        }
        return .keepGoing
    }
}
