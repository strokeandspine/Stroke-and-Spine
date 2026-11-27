import Foundation

// DRAFT CONTENT — needs review by a physician and a physical therapist before release.
// Written for adults aged 60+. General guidance only; it never replaces personal medical advice.

struct GuideSection: Hashable {
    enum Style { case normal, tip, warning, stop }
    var title: String
    var body: String? = nil
    var bullets: [String] = []
    var style: Style = .normal
}

struct Guide: Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    let summary: String
    let sections: [GuideSection]
    var sources: [String] = []
}

struct WarmUpMove: Identifiable, Hashable {
    let name: String
    let seconds: Int
    let how: String
    var id: String { name }
}

struct Stretch: Identifiable, Hashable {
    let id: String
    let name: String
    let bodyParts: [BodyPart]
    let holdSeconds: Int
    let perSide: Bool
    let position: String
    let steps: [String]
    var caution: String? = nil

    var dose: String { "Hold \(holdSeconds) seconds\(perSide ? " each side" : ""), 2 times" }
}

enum GuideLibrary {
    static let version = "Draft 0.1 — not yet clinically reviewed"

    /// Shown before every workout and in the injury guide. These mean stop now.
    static let stopNow = [
        "Chest pain, pressure or tightness, or pain spreading to your arm, neck or jaw",
        "Unusual shortness of breath, or you can't speak a few words",
        "Dizziness, light-headedness or feeling faint",
        "A racing, pounding or irregular heartbeat",
        "Sudden, sharp pain in a joint or muscle",
        "Sudden severe headache, blurred vision, or weakness or numbness on one side",
    ]

    static let callEmergency = "If chest pain, trouble breathing, fainting or stroke signs don't settle within a few minutes of stopping, call 911."

    static let all: [Guide] = [warmUp, coolDown, stretching, sauna, coldPlunge, avoidingInjury, effort]

    static func guide(_ id: String) -> Guide? { all.first { $0.id == id } }

    // MARK: Warm-up

    static let warmUpMoves: [WarmUpMove] = [
        WarmUpMove(name: "March in place", seconds: 120, how: "March on the spot or walk around the house, swinging your arms. Hold a counter if you need to. Start slow and build up gently."),
        WarmUpMove(name: "Shoulder rolls", seconds: 30, how: "Roll your shoulders slowly backwards 5 times, then forwards 5 times."),
        WarmUpMove(name: "Arm circles", seconds: 30, how: "Arms out to the sides, make small circles, gradually getting bigger. Then reverse."),
        WarmUpMove(name: "Trunk turns", seconds: 30, how: "Sitting or standing tall, hands on your shoulders, turn gently left and right. Move only as far as is comfortable."),
        WarmUpMove(name: "Hip circles", seconds: 30, how: "Hands on your hips or a counter, slowly circle your hips one way, then the other."),
        WarmUpMove(name: "Leg swings", seconds: 40, how: "Holding a counter, gently swing one leg forward and back 10 times, then the other."),
        WarmUpMove(name: "Ankle circles", seconds: 30, how: "Sitting, lift one foot and circle the ankle 10 times each way. Switch."),
        WarmUpMove(name: "Practice set", seconds: 60, how: "Do your first exercise with no weight or a very light one, for 8–10 easy reps."),
    ]

    static let warmUp = Guide(
        id: "warm-up", title: "Warming up", symbol: "flame",
        summary: "5–10 minutes of gentle movement gets blood flowing to your muscles, loosens your joints and lets your heart rate rise slowly.",
        sections: [
            GuideSection(title: "Why it matters more as we get older", body: "Muscles, tendons and joints get stiffer with age. Cold muscles are more likely to strain, and a sudden jump in effort is harder on the heart. A gentle warm-up makes the main workout feel easier and safer."),
            GuideSection(title: "How to warm up", bullets: [
                "Start with 2–5 minutes of light movement such as marching in place or walking. You should be breathing a little faster but still able to talk easily.",
                "Move your joints through a comfortable range: shoulders, trunk, hips, knees and ankles.",
                "Finish with a practice set of your first exercise using no weight or a very light one.",
                "Take longer — 10 minutes or more — on cold mornings, or if you're stiff from arthritis.",
            ]),
            GuideSection(title: "Save long stretches for later", body: "Holding stretches for a long time before lifting can make muscles temporarily weaker. Keep the warm-up moving, and do your longer stretches in the cool-down.", style: .tip),
            GuideSection(title: "Don't skip it", body: "If you only have a few minutes, shorten the workout — not the warm-up.", style: .warning),
        ],
        sources: ["American College of Sports Medicine — exercise guidance for older adults", "CDC — physical activity for adults 65 and older"]
    )

    // MARK: Cool-down

    static let coolDown = Guide(
        id: "cool-down", title: "Cooling down", symbol: "wind",
        summary: "5–10 minutes of easy movement and stretching lets your heart rate and blood pressure come down gradually.",
        sections: [
            GuideSection(title: "Why it matters", body: "Stopping suddenly after exercise can make blood pool in your legs, which can make you dizzy or light-headed. This is more common as we age and if you take blood pressure medicines."),
            GuideSection(title: "How to cool down", bullets: [
                "Walk slowly or march gently for 2–3 minutes, letting your breathing return to normal.",
                "Take a few slow, deep breaths: in through your nose for 4, out through your mouth for 6.",
                "Stretch the muscles you've worked — the app suggests stretches for each session.",
                "Drink some water.",
            ]),
            GuideSection(title: "Getting up safely", bullets: [
                "If you've been lying or sitting on the floor, roll onto your side, push up to sitting, and pause for a few seconds before standing.",
                "Stand up slowly from a chair and pause before walking off.",
            ], style: .tip),
            GuideSection(title: "Feeling dizzy?", body: "Sit or lie down straight away and raise your feet. If it doesn't pass within a few minutes, or comes with chest pain or shortness of breath, call 911.", style: .stop),
        ],
        sources: ["American Heart Association — warm up, cool down", "National Institute on Aging — exercise and physical activity"]
    )

    // MARK: Stretching

    static let stretches: [Stretch] = [
        Stretch(id: "calf-wall", name: "Calf stretch", bodyParts: [.legs, .balance], holdSeconds: 30, perSide: true, position: "Standing at a wall",
                steps: ["Stand facing a wall, hands on it at shoulder height.", "Step one foot back, keeping that leg straight and the heel on the floor.", "Bend your front knee until you feel a stretch in the back calf."]),
        Stretch(id: "seated-hamstring", name: "Seated hamstring stretch", bodyParts: [.legs, .hips], holdSeconds: 30, perSide: true, position: "Sitting in a chair",
                steps: ["Sit near the front of a chair.", "Straighten one leg out in front, heel on the floor, toes up.", "Sit tall and lean forward slightly from your hips until you feel a stretch in the back of your thigh."],
                caution: "Keep your back straight — don't round down toward your toes."),
        Stretch(id: "standing-quad", name: "Front of thigh stretch", bodyParts: [.legs], holdSeconds: 30, perSide: true, position: "Standing, holding a chair",
                steps: ["Hold a chair or counter with one hand.", "Bend one knee and hold your ankle, sock or pant leg behind you. A towel looped around the ankle helps.", "Keep your knees together and stand tall until you feel a stretch in the front of your thigh."],
                caution: "If you can't reach comfortably, rest your foot on a chair seat behind you instead."),
        Stretch(id: "hip-flexor", name: "Hip flexor stretch", bodyParts: [.hips], holdSeconds: 30, perSide: true, position: "Standing, holding a chair",
                steps: ["Hold a counter and take a step forward with one foot, like a small lunge.", "Keep your back leg fairly straight and tuck your tailbone under.", "Gently shift your weight forward until you feel a stretch at the front of the back hip."]),
        Stretch(id: "seated-figure-4", name: "Seated buttock stretch", bodyParts: [.hips], holdSeconds: 30, perSide: true, position: "Sitting in a chair",
                steps: ["Sit tall and cross one ankle over the opposite knee.", "Gently press the raised knee down and lean forward slightly from your hips."],
                caution: "Avoid this one if you've had a hip replacement unless your surgeon says it's OK — crossing the legs can be against your precautions."),
        Stretch(id: "doorway-chest", name: "Doorway chest stretch", bodyParts: [.chest, .shoulders], holdSeconds: 30, perSide: false, position: "Standing in a doorway",
                steps: ["Stand in a doorway with your forearms on the frame, elbows at shoulder height or a little lower.", "Step one foot through and lean forward gently until you feel a stretch across your chest."]),
        Stretch(id: "upper-back-hug", name: "Upper back stretch", bodyParts: [.back, .shoulders], holdSeconds: 30, perSide: false, position: "Sitting or standing",
                steps: ["Wrap your arms around yourself as if giving yourself a hug.", "Round your upper back gently and breathe into the space between your shoulder blades."]),
        Stretch(id: "cross-body-shoulder", name: "Shoulder stretch", bodyParts: [.shoulders, .back], holdSeconds: 30, perSide: true, position: "Sitting or standing",
                steps: ["Bring one arm across your chest.", "Use your other hand to gently press it closer above the elbow."]),
        Stretch(id: "overhead-triceps", name: "Back of arm stretch", bodyParts: [.arms], holdSeconds: 30, perSide: true, position: "Sitting or standing",
                steps: ["Raise one arm and bend the elbow so your hand reaches down your back.", "Use the other hand to gently press the elbow back."],
                caution: "Skip if raising your arm overhead hurts your shoulder."),
        Stretch(id: "wrist-forearm", name: "Wrist and forearm stretch", bodyParts: [.arms], holdSeconds: 30, perSide: true, position: "Sitting or standing",
                steps: ["Hold one arm out straight, palm up.", "With the other hand, gently bend the fingers down toward the floor."]),
        Stretch(id: "seated-twist", name: "Seated twist", bodyParts: [.core, .back], holdSeconds: 30, perSide: true, position: "Sitting in a chair",
                steps: ["Sit tall with both feet flat.", "Turn your upper body gently to one side, holding the chair back.", "Keep your hips facing forward and breathe slowly."],
                caution: "If you have osteoporosis of the spine, keep the twist small and gentle, or skip it."),
        Stretch(id: "knee-to-chest", name: "Knee to chest", bodyParts: [.core, .hips], holdSeconds: 30, perSide: true, position: "Lying on your back on a bed",
                steps: ["Lie on your back with knees bent.", "Bring one knee toward your chest, holding behind the thigh.", "Keep the other foot on the bed."]),
        Stretch(id: "neck-side", name: "Gentle neck stretch", bodyParts: [.shoulders, .back], holdSeconds: 20, perSide: true, position: "Sitting",
                steps: ["Sit tall and let one ear drop toward your shoulder.", "Keep your shoulders down and relaxed."],
                caution: "Never roll your head in full circles or pull on your head."),
    ]

    /// Stretches matched to the body parts trained, with no duplicates.
    static func suggestedStretches(for parts: [BodyPart], limit: Int = 6) -> [Stretch] {
        var picked: [Stretch] = []
        for part in parts {
            if let s = stretches.first(where: { $0.bodyParts.contains(part) && !picked.contains($0) }) {
                picked.append(s)
            }
            if picked.count == limit { break }
        }
        return picked
    }

    static let stretching = Guide(
        id: "stretching", title: "Stretching", symbol: "figure.flexibility",
        summary: "Regular stretching keeps your joints moving freely, which makes everyday tasks like dressing, reaching and looking over your shoulder easier.",
        sections: [
            GuideSection(title: "How often and how long", bullets: [
                "Stretch at least 2–3 days a week — every day is even better.",
                "Hold each stretch for 30–60 seconds. Older muscles benefit from the longer end.",
                "Repeat each stretch 2–4 times.",
                "Stretch when you're warm: after a workout, a walk or a warm shower.",
            ]),
            GuideSection(title: "Doing it right", bullets: [
                "Move slowly into the stretch until you feel mild tension — never pain.",
                "Hold still. Don't bounce.",
                "Keep breathing slowly. Breathe out as you ease into the stretch.",
                "Use a chair or counter for support when standing.",
                "You should feel a little looser as you hold. If it gets more painful, ease off.",
            ]),
            GuideSection(title: "Take care if you have", bullets: [
                "A hip or knee replacement: follow your surgeon's precautions about how far to bend, cross or turn the leg.",
                "Osteoporosis: avoid bending forward from the waist with a rounded back (like touching your toes) and deep twists.",
                "Recent injury or surgery: ask your physical therapist which stretches are safe.",
            ], style: .warning),
        ],
        sources: ["American College of Sports Medicine — flexibility recommendations for older adults", "National Institute on Aging — flexibility exercises"]
    )

    // MARK: Sauna

    static let sauna = Guide(
        id: "sauna", title: "Using a sauna", symbol: "thermometer.sun",
        summary: "Saunas can help you relax and may ease muscle soreness. Heat puts extra demand on your heart, so start carefully.",
        sections: [
            GuideSection(title: "Check with your doctor first if you have", bullets: [
                "Heart disease, a recent heart attack, chest pain (angina), heart failure, or a heart valve problem such as aortic stenosis",
                "Low or uncontrolled high blood pressure, or you get dizzy when you stand up",
                "A history of fainting, stroke or seizures",
                "Kidney disease, diabetes with nerve damage in the feet, or you're pregnant",
                "Medicines that affect blood pressure, heart rate or fluid balance — such as diuretics (water pills), beta-blockers or other blood pressure tablets",
            ], style: .warning),
            GuideSection(title: "Your first sessions", bullets: [
                "Start with 5–10 minutes. Build up slowly to no more than 15–20 minutes.",
                "Sit on a lower bench — it's cooler near the floor.",
                "Drink a glass of water before and after.",
                "Have a light snack beforehand rather than going in hungry or straight after a large meal.",
                "Go with someone, or make sure staff know you're in there.",
            ]),
            GuideSection(title: "Getting out safely", bullets: [
                "Sit up for a minute before you stand, and stand up slowly — blood pressure can drop when you leave the heat.",
                "Hold the rail on the way out: floors and steps are often wet.",
                "Cool off gradually with a lukewarm shower and sit for a few minutes before getting dressed.",
            ], style: .tip),
            GuideSection(title: "Never", bullets: [
                "Drink alcohol before or during a sauna.",
                "Use a sauna when you feel unwell, have a fever, or straight after very hard exercise when you're already light-headed.",
                "Stay in if you feel dizzy, sick, have a headache or your heart is pounding. Leave straight away.",
            ], style: .stop),
            GuideSection(title: "After a workout", body: "A sauna after strength training is fine for most healthy people, but finish your cool-down and drink some water first. Your body is already warm and slightly dehydrated, so keep the session short."),
        ],
        sources: ["American Heart Association — heat and the heart", "Laukkanen et al., Mayo Clinic Proceedings 2018 — cardiovascular and other health benefits of sauna bathing"]
    )

    // MARK: Cold plunge

    static let coldPlunge = Guide(
        id: "cold-plunge", title: "Cold plunge", symbol: "snowflake",
        summary: "Cold water immersion has become popular for recovery. For older adults it carries real risks — the sudden cold causes a sharp rise in heart rate and blood pressure. Talk to your doctor before you try it.",
        sections: [
            GuideSection(title: "Don't cold plunge if you have", bullets: [
                "Heart disease, an irregular heartbeat (such as atrial fibrillation), a pacemaker, or a history of heart attack or stroke",
                "High blood pressure that isn't well controlled",
                "Raynaud's, poor circulation, or nerve damage in your hands or feet (you may not feel the cold damaging your skin)",
                "Cold allergy (cold urticaria)",
                "Any condition your doctor hasn't cleared you for",
            ], style: .stop),
            GuideSection(title: "What happens in cold water", body: "The first 30–60 seconds bring the 'cold shock response': you gasp, breathe fast, and your heart rate and blood pressure jump. This is the riskiest moment. It eases as you control your breathing."),
            GuideSection(title: "Start gently", bullets: [
                "Begin with a cool shower: finish your normal shower with 15–30 seconds of cool water. Build up over a few weeks.",
                "If you move on to a plunge, choose water around 55–60°F (13–15°C) — not ice cold.",
                "Start with 30 seconds. Most of the reported benefit comes within 1–3 minutes; there's no need to stay longer.",
                "Get in slowly, feet first, keeping your head and neck out of the water.",
                "Breathe slowly and steadily: long breaths out help settle the gasp reflex.",
            ]),
            GuideSection(title: "Stay safe", bullets: [
                "Never plunge alone. Have someone with you who can help you out.",
                "Have a step or rail to get in and out — cold legs are clumsy legs.",
                "Get out straight away if you feel chest pain, dizziness, numbness or can't control your breathing.",
                "Warm up afterwards with dry clothes, a warm drink and gentle movement. Avoid a hot shower straight away if you feel light-headed.",
                "Don't go straight from a hot sauna into a cold plunge if you have any heart or blood pressure condition — the swing is hard on the heart.",
            ], style: .warning),
            GuideSection(title: "Timing with strength training", body: "Cold water straight after strength training may reduce the muscle and strength gains you're working for. If building strength is your goal, wait at least 4–6 hours after lifting, or plunge on rest days.", style: .tip),
        ],
        sources: ["Tipton et al., Journal of Physiology 2017 — the cold shock response", "Roberts et al., Journal of Physiology 2015 — post-exercise cold water immersion and strength gains"]
    )

    // MARK: Avoiding injury

    static let avoidingInjury = Guide(
        id: "avoiding-injury", title: "Avoiding injury", symbol: "cross.case",
        summary: "Strength training is one of the safest kinds of exercise for older adults when you start light, learn good form and build up gradually.",
        sections: [
            GuideSection(title: "Stop straight away if you have", bullets: stopNow + [callEmergency], style: .stop),
            GuideSection(title: "Before you start", bullets: [
                "Talk to your doctor if you have a heart condition, high blood pressure, diabetes, osteoporosis, joint replacements, recent surgery, or you're not sure.",
                "If you take beta-blockers, your heart rate won't rise as much — use the effort scale instead of heart rate.",
                "If you have diabetes and take insulin or tablets that can cause lows, check your blood sugar before and after, and keep a snack handy.",
            ]),
            GuideSection(title: "Breathe — never hold your breath", body: "Breathe out as you lift or push, and in as you lower. Holding your breath while straining makes your blood pressure spike. Counting out loud keeps you breathing."),
            GuideSection(title: "Form first, weight second", bullets: [
                "Learn each exercise with no weight or a very light one.",
                "Move slowly and with control: about 2 seconds up and 3 seconds down. No swinging or jerking.",
                "Stay within a comfortable range of movement.",
                "If you can't keep good form, the weight is too heavy.",
            ]),
            GuideSection(title: "Build up gradually", bullets: [
                "Change only one thing at a time: weight, reps, sets, or session length.",
                "Use the '2-for-2' rule: when you can do 2 more reps than your target on your last set, in 2 sessions in a row, it's time for a small increase.",
                "Increase weights by the smallest step: 1–2 lb for arms, 2–5 lb for legs.",
                "Leave at least one day of rest between working the same muscles.",
                "After illness or time away, drop back to an easier level and build up again.",
            ]),
            GuideSection(title: "Normal soreness or pain?", bullets: [
                "Normal: a dull ache or stiffness in the muscles 1–2 days after a workout, which eases with gentle movement. Go lighter next time.",
                "Not normal: sharp or stabbing pain, pain in a joint, swelling, pain that makes you limp, or pain that lasts more than a few days. Stop that exercise and get it checked.",
            ]),
            GuideSection(title: "Set up a safe space", bullets: [
                "Clear the floor of rugs, cords and clutter.",
                "Wear supportive shoes with a good grip — not slippers or socks.",
                "Keep a sturdy chair or counter within reach for balance exercises.",
                "Keep water nearby and the room at a comfortable temperature.",
                "Keep your phone close by in case you need help.",
            ], style: .tip),
            GuideSection(title: "Special care", bullets: [
                "Osteoporosis: avoid sit-ups, toe-touches and lifting with a rounded back. Weight-bearing and strength exercises are still good for your bones — ask about a bone-safe plan.",
                "Joint replacement: follow your surgeon's movement precautions, especially in the first few months.",
                "Hernia, glaucoma or a recent eye procedure: avoid heavy straining and ask your doctor about limits.",
                "Arthritis flare: do gentle range-of-motion work and skip loaded exercises for that joint until it settles.",
            ], style: .warning),
        ],
        sources: ["National Institute on Aging — exercise safety", "CDC — physical activity guidelines for older adults", "American College of Sports Medicine — resistance training for older adults"]
    )

    // MARK: Effort scale

    static let effort = Guide(
        id: "effort", title: "How hard should it feel?", symbol: "gauge.with.dots.needle.50percent",
        summary: "The app uses a 0–10 effort scale so you can judge intensity without needing to know your heart rate.",
        sections: [
            GuideSection(title: "The scale", bullets: [
                "0 — Resting.",
                "1–2 — Very easy. You could do this all day.",
                "3–4 — Easy to somewhat hard. You could easily do 5 or more extra reps. Talking is easy.",
                "5–6 — Somewhat hard. You feel the muscles working. You could do 3–4 more reps with good form.",
                "7–8 — Hard. The last couple of reps take real effort, but your form is still good.",
                "9–10 — Very hard to maximum. Older adults shouldn't train here.",
            ]),
            GuideSection(title: "The talk test", body: "You should be able to speak in short sentences throughout your workout. If you can't, slow down and rest longer.", style: .tip),
            GuideSection(title: "Your settings", bullets: [
                "Gentle intensity: aim for 3–4.",
                "Moderate intensity: aim for 5–6.",
                "Challenging intensity: aim for 7–8.",
            ]),
        ],
        sources: ["American College of Sports Medicine — rating of perceived exertion"]
    )
}
