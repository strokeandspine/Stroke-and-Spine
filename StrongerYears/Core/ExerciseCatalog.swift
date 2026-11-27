import Foundation

// DRAFT CONTENT — needs review by a licensed physical therapist or exercise physiologist
// before release. Steps are written so they can double as video scripts.

struct StrengthExercise: Identifiable, Hashable {
    let id: String
    let name: String
    let bodyPart: BodyPart
    let equipment: Equipment
    let difficulty: Difficulty
    let summary: String
    let steps: [String]
    let tips: [String]
    var cautions: [String] = []
    /// Timed holds (balance, planks) instead of reps.
    var holdSeconds: Int? = nil
    /// Done on each side (each leg or arm) in turn.
    var perSide = false
    var easierID: String? = nil
    var harderID: String? = nil
    var startingWeight: String? = nil

    var isTimed: Bool { holdSeconds != nil }

    var usesWeight: Bool {
        switch equipment {
        case .dumbbells, .ankleWeights, .machines: return true
        default: return false
        }
    }

    var usesBand: Bool { equipment == .bands }
}

enum ExerciseCatalog {
    static let version = "Draft 0.1 — not yet clinically reviewed"

    static func exercise(_ id: String) -> StrengthExercise? { byID[id] }

    static func exercises(for part: BodyPart) -> [StrengthExercise] { all.filter { $0.bodyPart == part } }

    private static let byID: [String: StrengthExercise] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static let all: [StrengthExercise] = legs + hips + back + chest + shoulders + arms + core + balance

    // MARK: Legs

    static let legs: [StrengthExercise] = [
        StrengthExercise(
            id: "sit-to-stand", name: "Sit to stand", bodyPart: .legs, equipment: .chair, difficulty: .easy,
            summary: "The most useful exercise there is: standing up from a chair without using your hands.",
            steps: [
                "Sit near the front of a sturdy chair that is against a wall, feet flat and hip-width apart.",
                "Lean your chest slightly forward, nose over toes.",
                "Breathe out and push through your heels to stand up tall.",
                "Breathe in and slowly lower yourself back down, taking 3 seconds, and sit down gently.",
            ],
            tips: ["Use your hands on the armrests at first if you need to, then try with arms crossed.", "A firm cushion on the seat makes it easier."],
            cautions: ["If you've had a hip replacement, keep to the chair height your surgeon recommends."],
            harderID: "goblet-squat"
        ),
        StrengthExercise(
            id: "goblet-squat", name: "Goblet squat to chair", bodyPart: .legs, equipment: .dumbbells, difficulty: .medium,
            summary: "Sit to stand while holding a weight at your chest.",
            steps: [
                "Stand in front of a chair, feet a little wider than hips.",
                "Hold one dumbbell upright against your chest with both hands.",
                "Push your hips back and bend your knees to lightly touch the chair — don't sit down fully.",
                "Breathe out and push through your heels to stand tall.",
            ],
            tips: ["Keep your knees pointing the same way as your toes.", "Keep your chest up and your back long."],
            easierID: "sit-to-stand", harderID: "step-up",
            startingWeight: "Start with 5–10 lb."
        ),
        StrengthExercise(
            id: "step-up", name: "Step-ups", bodyPart: .legs, equipment: .bodyweight, difficulty: .harder,
            summary: "Stepping up onto a stair builds the strength you use on stairs and curbs.",
            steps: [
                "Stand facing the bottom stair, holding the rail.",
                "Place one whole foot on the step.",
                "Breathe out and push through that heel to step up, bringing the other foot to join it.",
                "Step back down with the same leg you started with, slowly.",
                "Do all your reps on one leg, then switch.",
            ],
            tips: ["Always hold a rail or wall.", "Start with a low step, 4–6 inches."],
            cautions: ["Skip this if your balance is unsteady — stay with sit to stand."],
            perSide: true, easierID: "goblet-squat"
        ),
        StrengthExercise(
            id: "calf-raise", name: "Calf raises", bodyPart: .legs, equipment: .chair, difficulty: .easy,
            summary: "Strong calves help with walking, balance and pushing off.",
            steps: [
                "Stand behind a sturdy chair, holding the back with both hands.",
                "Breathe out and rise up onto your toes as high as is comfortable.",
                "Hold for one second at the top.",
                "Lower your heels slowly to the floor.",
            ],
            tips: ["Keep your body tall — don't lean on the chair.", "Harder: do one foot at a time."]
        ),
        StrengthExercise(
            id: "seated-knee-extension", name: "Seated knee extension", bodyPart: .legs, equipment: .ankleWeights, difficulty: .easy,
            summary: "Strengthens the front of the thigh, which supports the knee.",
            steps: [
                "Sit tall in a chair with ankle weights on, feet flat.",
                "Breathe out and straighten one knee until your leg is out in front of you.",
                "Hold for one second, pointing your toes up to the ceiling.",
                "Lower slowly. Do all reps on one leg, then switch.",
            ],
            tips: ["No ankle weights? Do it without, holding for 3 seconds at the top."],
            perSide: true,
            startingWeight: "Start with 1–2 lb per ankle."
        ),
        StrengthExercise(
            id: "leg-press", name: "Leg press machine", bodyPart: .legs, equipment: .machines, difficulty: .medium,
            summary: "A supported way to build leg strength at the gym.",
            steps: [
                "Adjust the seat so your knees are bent to about a right angle when your feet are on the plate.",
                "Place your feet hip-width apart in the middle of the plate.",
                "Breathe out and push the plate away until your legs are almost straight — don't lock your knees.",
                "Let the plate come back slowly over 3 seconds.",
            ],
            tips: ["Ask gym staff to show you how to set it up the first time."],
            cautions: ["Don't let your knees come right up to your chest — it can strain your lower back."],
            startingWeight: "Start light — the lightest setting or one plate."
        ),
    ]

    // MARK: Hips and glutes

    static let hips: [StrengthExercise] = [
        StrengthExercise(
            id: "glute-bridge", name: "Bridge", bodyPart: .hips, equipment: .bodyweight, difficulty: .easy,
            summary: "Lifting your hips works the glutes, the body's biggest muscles.",
            steps: [
                "Lie on your back on a bed or mat with knees bent and feet flat.",
                "Tighten your stomach muscles gently.",
                "Breathe out and squeeze your buttocks to lift your hips until your body is in a line from shoulders to knees.",
                "Hold for 2 seconds, then lower slowly.",
            ],
            tips: ["Doing it on the bed avoids getting down to the floor.", "Don't arch your back — lift only as high as is comfortable."],
            harderID: "dumbbell-rdl"
        ),
        StrengthExercise(
            id: "standing-hip-abduction", name: "Standing side leg lift", bodyPart: .hips, equipment: .chair, difficulty: .easy,
            summary: "Strengthens the side of the hip, which keeps you steady when you walk.",
            steps: [
                "Stand behind a chair, holding the back.",
                "Keeping your body upright and toes pointing forward, lift one leg out to the side.",
                "Lift only as far as you can without leaning.",
                "Lower slowly. Do all reps on one side, then switch.",
            ],
            tips: ["Add a resistance band around your ankles or ankle weights to make it harder."],
            perSide: true, harderID: "band-side-steps"
        ),
        StrengthExercise(
            id: "standing-hip-extension", name: "Standing back leg lift", bodyPart: .hips, equipment: .chair, difficulty: .easy,
            summary: "Works the buttocks and helps you walk with a longer stride.",
            steps: [
                "Stand behind a chair, holding the back, and lean forward very slightly from the hips.",
                "Keeping your knee straight, move one leg backwards.",
                "Squeeze your buttock and hold for a second. Don't arch your back.",
                "Lower slowly. Do all reps on one side, then switch.",
            ],
            tips: ["It's a small movement — a few inches is plenty."],
            perSide: true
        ),
        StrengthExercise(
            id: "band-side-steps", name: "Band side steps", bodyPart: .hips, equipment: .bands, difficulty: .medium,
            summary: "Walking sideways against a band strengthens the hips for steadier walking.",
            steps: [
                "Place a loop band just above your knees or around your ankles.",
                "Stand with feet hip-width apart, knees slightly bent, beside a counter.",
                "Step sideways with one foot, then bring the other foot halfway in, keeping tension on the band.",
                "Take 10 steps one way, then 10 steps back.",
            ],
            tips: ["Keep your toes pointing forward.", "Stay near the counter so you can hold on."],
            easierID: "standing-hip-abduction"
        ),
        StrengthExercise(
            id: "dumbbell-rdl", name: "Hip hinge with dumbbells", bodyPart: .hips, equipment: .dumbbells, difficulty: .harder,
            summary: "Teaches safe lifting from the hips and strengthens the back of the legs.",
            steps: [
                "Stand tall holding a dumbbell in each hand in front of your thighs.",
                "With a soft bend in your knees, push your hips back and let the weights slide down your thighs.",
                "Keep your back flat. Go down only until you feel a stretch in the back of your thighs, around knee height.",
                "Breathe out and squeeze your buttocks to stand back up.",
            ],
            tips: ["Practice with a broomstick along your back first: it should touch your head, upper back and tailbone the whole time."],
            cautions: ["Not recommended if you have osteoporosis of the spine unless a physical therapist has taught you the movement."],
            easierID: "glute-bridge",
            startingWeight: "Start with 5–8 lb in each hand."
        ),
    ]

    // MARK: Back

    static let back: [StrengthExercise] = [
        StrengthExercise(
            id: "band-row", name: "Seated band row", bodyPart: .back, equipment: .bands, difficulty: .easy,
            summary: "Pulling strengthens the upper back and helps posture.",
            steps: [
                "Sit tall on the floor or a firm bench with legs out, the middle of the band around your feet. Or sit in a chair with the band anchored in a closed door at chest height.",
                "Hold an end in each hand, arms straight in front.",
                "Breathe out and pull your elbows back past your sides, squeezing your shoulder blades together.",
                "Return slowly.",
            ],
            tips: ["Keep your shoulders down away from your ears.", "Move your hands further along the band to make it harder."],
            harderID: "one-arm-row"
        ),
        StrengthExercise(
            id: "wall-angel", name: "Wall slides", bodyPart: .back, equipment: .bodyweight, difficulty: .easy,
            summary: "Gently works the upper back muscles that keep you from stooping.",
            steps: [
                "Stand with your back against a wall, feet a few inches forward.",
                "Raise your arms into a 'goalpost' shape, backs of your hands toward the wall.",
                "Slowly slide your arms up the wall as far as is comfortable.",
                "Slide them back down, squeezing your shoulder blades down and together.",
            ],
            tips: ["Your hands don't need to touch the wall — go only as far as is comfortable."]
        ),
        StrengthExercise(
            id: "one-arm-row", name: "One-arm dumbbell row", bodyPart: .back, equipment: .dumbbells, difficulty: .medium,
            summary: "A classic back exercise, supported by a chair or bench.",
            steps: [
                "Place one hand on the seat of a sturdy chair or bench, feet apart, back flat.",
                "Hold a dumbbell in the other hand, arm hanging straight down.",
                "Breathe out and pull the weight up toward your hip, elbow close to your side.",
                "Lower slowly. Do all reps on one side, then switch.",
            ],
            tips: ["Think of starting a lawnmower, but slowly.", "Don't twist your body."],
            perSide: true, easierID: "band-row", harderID: "lat-pulldown",
            startingWeight: "Start with 5–8 lb."
        ),
        StrengthExercise(
            id: "lat-pulldown", name: "Lat pulldown machine", bodyPart: .back, equipment: .machines, difficulty: .medium,
            summary: "Builds the large back muscles that help you pull yourself up.",
            steps: [
                "Sit at the machine with your thighs under the pads.",
                "Hold the bar a little wider than your shoulders.",
                "Breathe out and pull the bar down to the top of your chest, leaning back very slightly.",
                "Let it rise slowly until your arms are straight.",
            ],
            tips: ["Never pull the bar behind your neck."],
            easierID: "band-row",
            startingWeight: "Start with the lightest setting."
        ),
        StrengthExercise(
            id: "band-pull-apart", name: "Band pull-apart", bodyPart: .back, equipment: .bands, difficulty: .easy,
            summary: "Opens the chest and strengthens the muscles between the shoulder blades.",
            steps: [
                "Sit or stand tall holding a light band in both hands, arms straight in front at shoulder height.",
                "Breathe out and pull the band apart by moving your hands out to the sides.",
                "Squeeze your shoulder blades together.",
                "Return slowly.",
            ],
            tips: ["Keep a slight bend in your elbows."]
        ),
    ]

    // MARK: Chest

    static let chest: [StrengthExercise] = [
        StrengthExercise(
            id: "wall-pushup", name: "Wall push-up", bodyPart: .chest, equipment: .bodyweight, difficulty: .easy,
            summary: "Works chest, shoulders and arms with no equipment.",
            steps: [
                "Stand at arm's length from a wall and place your hands on it at shoulder height and width.",
                "Keep your body straight from head to heels.",
                "Breathe in and bend your elbows to bring your chest toward the wall.",
                "Breathe out and push back to the start.",
            ],
            tips: ["Step further from the wall to make it harder."],
            harderID: "counter-pushup"
        ),
        StrengthExercise(
            id: "counter-pushup", name: "Counter push-up", bodyPart: .chest, equipment: .bodyweight, difficulty: .medium,
            summary: "A harder push-up using a kitchen counter or sturdy table.",
            steps: [
                "Place your hands on the edge of a sturdy counter, a little wider than your shoulders.",
                "Walk your feet back until your body is in a straight line.",
                "Bend your elbows to lower your chest toward the counter.",
                "Breathe out and push back up.",
            ],
            tips: ["Make sure the counter is fixed and won't slide."],
            easierID: "wall-pushup", harderID: "floor-press"
        ),
        StrengthExercise(
            id: "band-chest-press", name: "Seated band chest press", bodyPart: .chest, equipment: .bands, difficulty: .easy,
            summary: "A chest press you can do from a chair.",
            steps: [
                "Sit tall in a chair with the band around the chair back, an end in each hand at chest height.",
                "Breathe out and push both hands forward until your arms are straight.",
                "Return slowly.",
            ],
            tips: ["Keep your wrists straight."]
        ),
        StrengthExercise(
            id: "floor-press", name: "Dumbbell chest press", bodyPart: .chest, equipment: .dumbbells, difficulty: .harder,
            summary: "Lying on a bed or bench, press dumbbells upward.",
            steps: [
                "Lie on your back on a firm bed or bench, knees bent, a dumbbell in each hand at the sides of your chest.",
                "Breathe out and press the weights up until your arms are straight above your chest.",
                "Lower slowly until your upper arms touch the bed.",
            ],
            tips: ["Have someone pass you the weights once you're lying down if that's easier."],
            easierID: "counter-pushup",
            startingWeight: "Start with 3–8 lb in each hand."
        ),
        StrengthExercise(
            id: "chest-press-machine", name: "Chest press machine", bodyPart: .chest, equipment: .machines, difficulty: .medium,
            summary: "A supported chest press at the gym.",
            steps: [
                "Adjust the seat so the handles are level with the middle of your chest.",
                "Breathe out and push the handles forward until your arms are almost straight.",
                "Return slowly.",
            ],
            tips: ["Keep your back against the pad."],
            startingWeight: "Start with the lightest setting."
        ),
    ]

    // MARK: Shoulders

    static let shoulders: [StrengthExercise] = [
        StrengthExercise(
            id: "seated-overhead-press", name: "Seated shoulder press", bodyPart: .shoulders, equipment: .dumbbells, difficulty: .medium,
            summary: "Builds the strength to lift things onto high shelves.",
            steps: [
                "Sit tall in a chair with back support, a dumbbell in each hand at shoulder height, palms forward.",
                "Breathe out and press the weights up until your arms are almost straight.",
                "Lower slowly back to shoulder height.",
            ],
            tips: ["Don't arch your back — keep your ribs down."],
            cautions: ["Skip if lifting your arms overhead hurts your shoulder. Do the front raise to shoulder height instead."],
            easierID: "front-raise",
            startingWeight: "Start with 2–5 lb in each hand."
        ),
        StrengthExercise(
            id: "front-raise", name: "Front raise", bodyPart: .shoulders, equipment: .bodyweight, difficulty: .easy,
            summary: "Strengthens the front of the shoulder for reaching.",
            steps: [
                "Sit or stand tall, arms by your sides, thumbs pointing forward.",
                "Breathe out and raise both arms in front of you to shoulder height.",
                "Lower slowly.",
            ],
            tips: ["Hold a water bottle or light dumbbells to make it harder."],
            harderID: "seated-overhead-press"
        ),
        StrengthExercise(
            id: "lateral-raise", name: "Side raise", bodyPart: .shoulders, equipment: .dumbbells, difficulty: .medium,
            summary: "Strengthens the side of the shoulder.",
            steps: [
                "Sit or stand tall with a light dumbbell in each hand at your sides.",
                "With a slight bend in your elbows, raise your arms out to the sides up to shoulder height — no higher.",
                "Lower slowly.",
            ],
            tips: ["Lead with your elbows.", "Use very light weights — this muscle is small."],
            easierID: "front-raise",
            startingWeight: "Start with 1–3 lb in each hand."
        ),
        StrengthExercise(
            id: "band-external-rotation", name: "Band outward rotation", bodyPart: .shoulders, equipment: .bands, difficulty: .easy,
            summary: "Protects the rotator cuff, the small muscles that hold the shoulder in place.",
            steps: [
                "Sit or stand holding a light band in both hands, elbows bent to a right angle and tucked against your sides.",
                "Breathe out and rotate your forearms outward, keeping your elbows at your sides.",
                "Return slowly.",
            ],
            tips: ["A rolled towel between your elbow and side helps."]
        ),
    ]

    // MARK: Arms and grip

    static let arms: [StrengthExercise] = [
        StrengthExercise(
            id: "biceps-curl", name: "Biceps curl", bodyPart: .arms, equipment: .dumbbells, difficulty: .easy,
            summary: "For carrying groceries and lifting.",
            steps: [
                "Sit or stand tall with a dumbbell in each hand, palms facing forward.",
                "Breathe out and bend your elbows to bring the weights toward your shoulders.",
                "Lower slowly over 3 seconds.",
            ],
            tips: ["Keep your elbows by your sides.", "No dumbbells? Use cans or water bottles, or a band under your feet."],
            harderID: "hammer-curl",
            startingWeight: "Start with 3–5 lb."
        ),
        StrengthExercise(
            id: "hammer-curl", name: "Hammer curl", bodyPart: .arms, equipment: .dumbbells, difficulty: .medium,
            summary: "A curl with thumbs up that also builds the forearms and grip.",
            steps: [
                "Hold a dumbbell in each hand at your sides with palms facing in, like holding a hammer.",
                "Breathe out and bend your elbows to lift the weights.",
                "Lower slowly.",
            ],
            tips: ["Keep your wrists straight."],
            easierID: "biceps-curl",
            startingWeight: "Start with 5–8 lb."
        ),
        StrengthExercise(
            id: "triceps-extension", name: "Seated triceps extension", bodyPart: .arms, equipment: .dumbbells, difficulty: .medium,
            summary: "Strengthens the back of the arm, used to push up from a chair.",
            steps: [
                "Sit tall holding one dumbbell with both hands above your head.",
                "Keeping your elbows pointing forward, slowly bend them to lower the weight behind your head.",
                "Breathe out and straighten your arms.",
            ],
            tips: ["Use a light weight and move slowly."],
            cautions: ["Skip if lifting your arms overhead hurts your shoulder — do chair push-ups instead."],
            easierID: "chair-dip",
            startingWeight: "Start with 3–5 lb."
        ),
        StrengthExercise(
            id: "chair-dip", name: "Chair push-up", bodyPart: .arms, equipment: .chair, difficulty: .easy,
            summary: "Pushing yourself up using a chair's armrests.",
            steps: [
                "Sit in a sturdy chair with armrests, hands on the armrests, feet flat.",
                "Breathe out and press down through your hands to lift your bottom slightly off the seat.",
                "Use your legs as little as you can.",
                "Lower yourself slowly back to the seat.",
            ],
            tips: ["Even an inch off the seat counts."],
            harderID: "triceps-extension"
        ),
        StrengthExercise(
            id: "grip-squeeze", name: "Grip squeeze", bodyPart: .arms, equipment: .bodyweight, difficulty: .easy,
            summary: "Grip strength is linked to healthy ageing and helps with jars and rails.",
            steps: [
                "Hold a soft ball, rolled-up towel or grip trainer in one hand.",
                "Squeeze as hard as is comfortable for 3–5 seconds.",
                "Relax. Do all reps on one hand, then switch.",
            ],
            tips: ["Good if you have arthritis in your hands — use a soft ball and squeeze gently."],
            perSide: true
        ),
        StrengthExercise(
            id: "farmers-carry", name: "Farmer's carry", bodyPart: .arms, equipment: .dumbbells, difficulty: .harder,
            summary: "Walking while holding weights — just like carrying groceries.",
            steps: [
                "Hold a dumbbell in each hand at your sides, standing tall.",
                "Walk slowly for the set time, shoulders back and down.",
                "Put the weights down carefully by bending your knees.",
            ],
            tips: ["Walk in a clear hallway with nothing to trip on."],
            cautions: ["Not if your balance is unsteady."],
            holdSeconds: 30, easierID: "grip-squeeze",
            startingWeight: "Start with 5–10 lb in each hand."
        ),
    ]

    // MARK: Core

    static let core: [StrengthExercise] = [
        StrengthExercise(
            id: "seated-march", name: "Seated march", bodyPart: .core, equipment: .chair, difficulty: .easy,
            summary: "Gently works the deep stomach muscles while sitting.",
            steps: [
                "Sit tall near the front of a chair, hands lightly on the sides of the seat.",
                "Gently tighten your stomach as if bracing for a light poke.",
                "Lift one knee a few inches, lower it, then lift the other.",
                "Keep breathing normally throughout.",
            ],
            tips: ["Don't lean back — stay tall."],
            harderID: "dead-bug"
        ),
        StrengthExercise(
            id: "dead-bug", name: "Dead bug", bodyPart: .core, equipment: .bodyweight, difficulty: .medium,
            summary: "Builds core control while protecting your back.",
            steps: [
                "Lie on your back on a bed or mat with knees bent and arms pointing to the ceiling.",
                "Gently press your lower back toward the bed.",
                "Slowly lower one arm behind your head while sliding the opposite heel along the bed.",
                "Return and switch sides.",
            ],
            tips: ["Easier: move only the legs, or only the arms."],
            easierID: "seated-march", harderID: "bird-dog"
        ),
        StrengthExercise(
            id: "bird-dog", name: "Bird dog", bodyPart: .core, equipment: .bodyweight, difficulty: .harder,
            summary: "Builds back and core strength together.",
            steps: [
                "Kneel on all fours on a mat, hands under shoulders, knees under hips.",
                "Slowly reach one arm forward and the opposite leg back, keeping your back flat.",
                "Hold for 3 seconds, then return. Switch sides.",
            ],
            tips: ["Start by lifting just an arm or just a leg."],
            cautions: ["Needs comfortable knees and the ability to get down to and up from the floor."],
            easierID: "dead-bug"
        ),
        StrengthExercise(
            id: "counter-plank", name: "Counter plank", bodyPart: .core, equipment: .bodyweight, difficulty: .medium,
            summary: "A plank against a counter, holding your body straight.",
            steps: [
                "Place your forearms on a sturdy counter and walk your feet back until your body is straight.",
                "Gently tighten your stomach and buttocks.",
                "Hold the position, breathing normally.",
            ],
            tips: ["Don't hold your breath — count out loud."],
            holdSeconds: 20
        ),
        StrengthExercise(
            id: "pallof-press", name: "Band anti-twist press", bodyPart: .core, equipment: .bands, difficulty: .medium,
            summary: "Trains your core to keep you steady against twisting forces.",
            steps: [
                "Anchor a band at chest height in a closed door and stand side-on to it.",
                "Hold the band at your chest with both hands, feet hip-width apart.",
                "Breathe out and press your hands straight out in front, resisting the pull to twist.",
                "Hold for 2 seconds and bring them back. Do all reps, then face the other way.",
            ],
            tips: ["Step further away to make it harder."],
            perSide: true
        ),
    ]

    // MARK: Balance

    static let balance: [StrengthExercise] = [
        StrengthExercise(
            id: "tandem-stand", name: "Heel-to-toe stand", bodyPart: .balance, equipment: .chair, difficulty: .easy,
            summary: "Standing with one foot in front of the other trains balance.",
            steps: [
                "Stand beside a counter or sturdy chair, holding on.",
                "Place one foot directly in front of the other, heel touching toes.",
                "Let go if you feel steady, keeping your hand close to the counter.",
                "Hold, then switch which foot is in front.",
            ],
            tips: ["Look at a fixed point ahead of you.", "Harder: close your eyes — only with the counter right there."],
            holdSeconds: 20, perSide: true, harderID: "single-leg-stand"
        ),
        StrengthExercise(
            id: "single-leg-stand", name: "Stand on one leg", bodyPart: .balance, equipment: .chair, difficulty: .medium,
            summary: "A simple test and trainer of balance.",
            steps: [
                "Stand beside a counter, holding on with one hand.",
                "Lift one foot off the floor.",
                "Let go if you can, keeping your hand just above the counter.",
                "Hold, then switch legs.",
            ],
            tips: ["Practice while waiting for the kettle."],
            holdSeconds: 20, perSide: true, easierID: "tandem-stand", harderID: "heel-toe-walk"
        ),
        StrengthExercise(
            id: "heel-toe-walk", name: "Heel-to-toe walk", bodyPart: .balance, equipment: .bodyweight, difficulty: .harder,
            summary: "Walking in a straight line, like on a tightrope.",
            steps: [
                "Stand at one end of a counter or hallway wall, close enough to touch it.",
                "Step forward, placing your heel directly in front of the toes of the other foot.",
                "Take 10–15 steps, then turn carefully and come back.",
            ],
            tips: ["Keep your eyes ahead, not on your feet."],
            cautions: ["Always next to a wall or counter, or with someone beside you."],
            holdSeconds: 30, easierID: "single-leg-stand"
        ),
        StrengthExercise(
            id: "clock-reach", name: "Clock reach", bodyPart: .balance, equipment: .chair, difficulty: .medium,
            summary: "Reaching in different directions while balancing.",
            steps: [
                "Stand beside a chair, holding it with one hand.",
                "Imagine you're standing at the center of a clock face.",
                "Lift the leg farthest from the chair and reach that arm to 12 o'clock, then 3, then 6.",
                "Return to standing on both feet, then switch sides.",
            ],
            tips: ["Keep your standing knee soft."],
            perSide: true
        ),
        StrengthExercise(
            id: "side-step-walk", name: "Side stepping", bodyPart: .balance, equipment: .bodyweight, difficulty: .easy,
            summary: "Walking sideways along a counter helps stability in all directions.",
            steps: [
                "Stand facing a kitchen counter, hands resting on it.",
                "Step sideways, keeping your toes facing forward.",
                "Take 10 steps one way, then 10 back.",
            ],
            tips: ["Keep your knees slightly bent."],
            holdSeconds: 30
        ),
    ]
}
