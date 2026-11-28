/* CoreCut content: foods, meals, exercises, programs, cardio and tips. */
(function (root) {
  'use strict';

  // Per 100 g (cooked weight where it says cooked). role: P = protein source, C = carbs/fats, V = vegetables (portion kept fixed).
  var FOODS = {
    chicken: { name: 'Chicken breast, cooked', kcal: 165, p: 31, c: 0, f: 3.6, role: 'P' },
    salmon: { name: 'Salmon, cooked', kcal: 208, p: 20, c: 0, f: 13, role: 'P' },
    beef: { name: 'Lean ground beef (93%), cooked', kcal: 182, p: 25, c: 0, f: 8.5, role: 'P' },
    turkey: { name: 'Ground turkey (93%), cooked', kcal: 176, p: 24, c: 0, f: 9, role: 'P' },
    tuna: { name: 'Tuna in water, drained', kcal: 116, p: 26, c: 0, f: 0.8, role: 'P' },
    shrimp: { name: 'Shrimp, cooked', kcal: 99, p: 24, c: 0.2, f: 0.3, role: 'P' },
    cod: { name: 'Cod or white fish, cooked', kcal: 105, p: 23, c: 0, f: 0.9, role: 'P' },
    eggs: { name: 'Whole eggs (1 large ≈ 50 g)', kcal: 143, p: 12.6, c: 0.7, f: 9.5, role: 'P' },
    whites: { name: 'Liquid egg whites', kcal: 52, p: 11, c: 0.7, f: 0.2, role: 'P' },
    yogurt: { name: 'Nonfat Greek yogurt', kcal: 59, p: 10, c: 3.6, f: 0.4, role: 'P' },
    cottage: { name: 'Low-fat cottage cheese', kcal: 72, p: 12, c: 2.7, f: 1, role: 'P' },
    whey: { name: 'Whey protein powder (1 scoop ≈ 30 g)', kcal: 400, p: 80, c: 8, f: 6, role: 'P' },
    pea: { name: 'Pea or plant protein powder (1 scoop ≈ 30 g)', kcal: 380, p: 78, c: 5, f: 7, role: 'P' },
    tofu: { name: 'Extra-firm tofu', kcal: 144, p: 17, c: 3, f: 8.7, role: 'P' },
    tempeh: { name: 'Tempeh', kcal: 192, p: 20, c: 8, f: 11, role: 'P' },
    edamame: { name: 'Edamame, shelled', kcal: 121, p: 12, c: 9, f: 5, role: 'P' },
    lentils: { name: 'Lentils, cooked', kcal: 116, p: 9, c: 20, f: 0.4, role: 'C' },
    blackbeans: { name: 'Black beans, cooked', kcal: 132, p: 8.9, c: 24, f: 0.5, role: 'C' },
    chickpeas: { name: 'Chickpeas, cooked', kcal: 164, p: 8.9, c: 27, f: 2.6, role: 'C' },
    oats: { name: 'Rolled oats, dry', kcal: 389, p: 17, c: 66, f: 7, role: 'C' },
    rice: { name: 'Rice, cooked', kcal: 130, p: 2.7, c: 28, f: 0.3, role: 'C' },
    potato: { name: 'Potato, cooked', kcal: 87, p: 1.9, c: 20, f: 0.1, role: 'C' },
    sweetpotato: { name: 'Sweet potato, cooked', kcal: 90, p: 2, c: 21, f: 0.2, role: 'C' },
    quinoa: { name: 'Quinoa, cooked', kcal: 120, p: 4.4, c: 21, f: 1.9, role: 'C' },
    bread: { name: 'Whole-grain bread (1 slice ≈ 40 g)', kcal: 247, p: 13, c: 41, f: 3.4, role: 'C' },
    tortilla: { name: 'Whole-wheat tortilla (1 large ≈ 70 g)', kcal: 300, p: 8, c: 50, f: 7, role: 'C' },
    pasta: { name: 'Whole-wheat pasta, cooked', kcal: 149, p: 6, c: 30, f: 1.7, role: 'C' },
    berries: { name: 'Berries', kcal: 57, p: 0.7, c: 14, f: 0.3, role: 'C' },
    banana: { name: 'Banana', kcal: 89, p: 1.1, c: 23, f: 0.3, role: 'C' },
    apple: { name: 'Apple', kcal: 52, p: 0.3, c: 14, f: 0.2, role: 'C' },
    soymilk: { name: 'Unsweetened soy milk', kcal: 33, p: 2.9, c: 1.8, f: 1.6, role: 'C' },
    almonds: { name: 'Almonds', kcal: 579, p: 21, c: 22, f: 50, role: 'C' },
    pb: { name: 'Peanut butter', kcal: 588, p: 25, c: 20, f: 50, role: 'C' },
    avocado: { name: 'Avocado', kcal: 160, p: 2, c: 9, f: 15, role: 'C' },
    oil: { name: 'Olive oil', kcal: 884, p: 0, c: 0, f: 100, role: 'C' },
    hummus: { name: 'Hummus', kcal: 166, p: 7.9, c: 14, f: 9.6, role: 'C' },
    broccoli: { name: 'Broccoli', kcal: 35, p: 2.4, c: 7, f: 0.4, role: 'V' },
    greens: { name: 'Salad greens', kcal: 20, p: 1.5, c: 3.5, f: 0.2, role: 'V' },
    veg: { name: 'Mixed vegetables (peppers, onion, zucchini…)', kcal: 40, p: 1.8, c: 8, f: 0.3, role: 'V' },
    salsa: { name: 'Salsa', kcal: 36, p: 1.5, c: 7, f: 0.2, role: 'V' }
  };

  function m(name, how, items) { return { name: name, how: how, items: items.map(function (x) { return { food: x[0], g: x[1] }; }) }; }

  // Four slots, two or three options each, per diet style. Base portions are for roughly a 2,000 kcal day.
  var MEALS = {
    omnivore: {
      breakfast: [
        m('Protein oats', 'Cook oats in water, stir in protein powder off the heat, top with berries and almonds.', [['oats', 70], ['whey', 30], ['berries', 100], ['almonds', 15]]),
        m('Egg scramble and toast', 'Scramble eggs and whites with vegetables in a non-stick pan. Toast on the side.', [['eggs', 150], ['whites', 150], ['veg', 100], ['bread', 80]]),
        m('Greek yogurt parfait', 'Layer yogurt, oats and berries. Drizzle peanut butter.', [['yogurt', 300], ['oats', 40], ['berries', 120], ['pb', 15]])
      ],
      lunch: [
        m('Chicken rice bowl', 'Batch-cook chicken and rice on Sunday. Steam broccoli, finish with olive oil, lemon and salt.', [['chicken', 150], ['rice', 180], ['broccoli', 150], ['oil', 8]]),
        m('Tuna avocado wrap', 'Mash tuna with Greek yogurt, mustard and pepper. Wrap with greens and avocado. Apple on the side.', [['tuna', 140], ['yogurt', 40], ['tortilla', 70], ['greens', 50], ['avocado', 50], ['apple', 150]]),
        m('Turkey taco salad', 'Brown turkey with taco spices. Serve over greens with black beans, salsa and avocado.', [['turkey', 140], ['blackbeans', 120], ['greens', 100], ['salsa', 60], ['avocado', 40]])
      ],
      snack: [
        m('Yogurt and berries', 'Mix and eat. Add cinnamon if you like.', [['yogurt', 250], ['berries', 100], ['almonds', 10]]),
        m('Cottage cheese and apple', 'Slice the apple and dip it, with a spoon of peanut butter.', [['cottage', 200], ['apple', 150], ['pb', 10]]),
        m('Shake and banana', 'Whey shaken with water or milk. Eat the banana before or after training.', [['whey', 35], ['banana', 120]])
      ],
      dinner: [
        m('Salmon, potatoes and salad', 'Roast salmon at 200 °C / 400 °F for 12–15 min. Boil or roast potatoes. Dress greens with olive oil.', [['salmon', 150], ['potato', 250], ['greens', 100], ['oil', 5]]),
        m('Beef and vegetable stir-fry', 'Brown beef in a hot pan, add vegetables, soy sauce, garlic and ginger. Serve over rice.', [['beef', 140], ['veg', 200], ['rice', 150], ['oil', 5]]),
        m('Shrimp pasta', 'Sauté shrimp with garlic and chili. Toss with pasta, vegetables and a little olive oil.', [['shrimp', 170], ['pasta', 180], ['veg', 150], ['oil', 8]])
      ]
    },
    vegetarian: {
      breakfast: [
        m('Greek yogurt bowl', 'Top yogurt with oats, berries and peanut butter.', [['yogurt', 300], ['oats', 50], ['berries', 100], ['pb', 15]]),
        m('Eggs and avocado toast', 'Fry or poach eggs. Add egg whites to bump protein. Avocado on toast.', [['eggs', 150], ['whites', 100], ['bread', 80], ['avocado', 40]]),
        m('Protein oats', 'Cook oats, stir in whey off the heat, top with berries.', [['oats', 70], ['whey', 30], ['berries', 100], ['almonds', 15]])
      ],
      lunch: [
        m('Lentil quinoa bowl', 'Combine warm lentils and quinoa with roasted vegetables and a spoon of hummus.', [['lentils', 200], ['quinoa', 150], ['veg', 150], ['hummus', 40], ['cottage', 100]]),
        m('Egg and bean burrito', 'Scramble eggs, add black beans and salsa, wrap with yogurt as sour cream.', [['tortilla', 70], ['eggs', 100], ['whites', 100], ['blackbeans', 120], ['salsa', 60], ['yogurt', 50]])
      ],
      snack: [
        m('Cottage cheese and berries', 'Mix and eat.', [['cottage', 200], ['berries', 120]]),
        m('Protein shake', 'Blend whey, soy milk and banana with ice.', [['whey', 30], ['soymilk', 300], ['banana', 100]])
      ],
      dinner: [
        m('Tofu stir-fry', 'Press tofu, cube and pan-fry until golden. Add vegetables and sauce. Serve over rice.', [['tofu', 200], ['veg', 200], ['rice', 180], ['oil', 5]]),
        m('Chickpea curry', 'Simmer chickpeas and vegetables in spices and tomato. Stir in yogurt off the heat. Serve with rice.', [['chickpeas', 200], ['yogurt', 120], ['veg', 150], ['rice', 150]])
      ]
    },
    vegan: {
      breakfast: [
        m('Plant protein oats', 'Cook oats in soy milk, stir in protein powder, top with berries.', [['oats', 70], ['pea', 30], ['soymilk', 250], ['berries', 100]]),
        m('Tofu scramble', 'Crumble tofu into a pan with turmeric, garlic and vegetables. Toast on the side.', [['tofu', 200], ['veg', 100], ['bread', 80], ['avocado', 40]])
      ],
      lunch: [
        m('Tempeh power bowl', 'Pan-fry sliced tempeh with soy sauce. Serve with quinoa and broccoli.', [['tempeh', 150], ['quinoa', 150], ['broccoli', 150], ['edamame', 60]]),
        m('Lentil hummus wrap', 'Fill a tortilla with lentils, hummus and greens.', [['lentils', 180], ['tortilla', 70], ['hummus', 40], ['greens', 50], ['pea', 15]])
      ],
      snack: [
        m('Edamame and apple', 'Steam edamame with sea salt.', [['edamame', 200], ['apple', 150]]),
        m('Plant shake', 'Blend protein powder, soy milk, banana and peanut butter.', [['pea', 30], ['soymilk', 300], ['banana', 100], ['pb', 10]])
      ],
      dinner: [
        m('Black bean and tofu chili', 'Simmer beans, crumbled tofu, vegetables, tomato and chili spices for 20 min. Serve over rice.', [['blackbeans', 200], ['tofu', 150], ['veg', 200], ['rice', 100]]),
        m('Tofu, sweet potato and greens', 'Roast tofu and sweet potato together at 220 °C / 425 °F for 25 min. Serve with broccoli.', [['tofu', 200], ['sweetpotato', 250], ['broccoli', 150], ['oil', 5]])
      ]
    }
  };

  var NUTRITION_RULES = [
    { title: 'Protein at every meal', body: 'Spread your protein over 3–5 meals of 25–50 g. It keeps you full and protects muscle while you are in a deficit.' },
    { title: 'Half the plate is vegetables', body: 'Vegetables add volume and fiber for very few calories. They are the easiest way to feel full on less.' },
    { title: 'Weigh food for 2 weeks', body: 'Use a kitchen scale for two weeks to learn what portions look like. After that, eyeballing gets much more accurate.' },
    { title: 'Watch the hidden calories', body: 'Cooking oil, dressings, sauces, coffee drinks and alcohol are where most plans go wrong. Measure oil with a spoon.' },
    { title: 'Carbs around training', body: 'Eat most of your starches in the meal before and after lifting. You will train harder and recover better.' },
    { title: 'Plan for the weekend', body: 'Two loose days can erase five good ones. Keep protein high and save calories for one planned meal out.' },
    { title: 'Alcohol', body: 'Each drink is roughly 100–200 kcal and slows fat burning for hours. Limit to a few a week, and choose spirits with zero-calorie mixers.' },
    { title: 'Salt and water', body: 'A salty meal can add 1–2 kg of water overnight. That is not fat. Judge progress by the weekly trend, not one day.' }
  ];

  // Exercise library. group: strength | core | cardio. pattern helps pick swaps.
  var EXERCISES = {
    squat: { name: 'Back squat', group: 'strength', area: 'Legs', steps: ['Bar on upper back, feet shoulder-width, toes slightly out.', 'Brace your abs like you are about to be punched.', 'Sit down between your heels until thighs are at least parallel.', 'Drive up through the whole foot, keeping chest up.'], cue: 'Brace hard before every rep; a squat is an ab exercise too.', swap: 'Goblet squat or leg press' },
    goblet: { name: 'Goblet squat', group: 'strength', area: 'Legs', steps: ['Hold a dumbbell at your chest, elbows down.', 'Squat between your knees, keeping your torso tall.', 'Pause at the bottom, then stand.'], cue: 'Elbows brush the insides of your knees.', swap: 'Bodyweight squat' },
    rdl: { name: 'Romanian deadlift', group: 'strength', area: 'Hamstrings and glutes', steps: ['Hold a bar or dumbbells at the hips, knees soft.', 'Push your hips back, sliding the weight down your thighs.', 'Stop when you feel a strong hamstring stretch, back flat.', 'Squeeze glutes to stand.'], cue: 'Hips go back, not down.', swap: 'Dumbbell RDL or hip hinge with a band' },
    deadlift: { name: 'Deadlift', group: 'strength', area: 'Full body', steps: ['Bar over mid-foot, grip just outside the legs.', 'Pull the slack out of the bar, chest up, back flat.', 'Push the floor away and stand tall.', 'Lower under control.'], cue: 'Ribs down, lats tight, bar stays touching your legs.', swap: 'Trap-bar deadlift' },
    lunge: { name: 'Walking lunge', group: 'strength', area: 'Legs', steps: ['Step forward long enough that both knees reach about 90°.', 'Lower the back knee toward the floor.', 'Push through the front heel into the next step.'], cue: 'Torso tall, front knee tracks over toes.', swap: 'Split squat' },
    hipthrust: { name: 'Hip thrust', group: 'strength', area: 'Glutes', steps: ['Upper back on a bench, bar over your hips.', 'Feet flat, shins vertical at the top.', 'Drive hips up, squeeze glutes, ribs down.', 'Lower with control.'], cue: 'Chin tucked, look forward not up.', swap: 'Glute bridge' },
    legpress: { name: 'Leg press', group: 'strength', area: 'Legs', steps: ['Feet shoulder-width in the middle of the platform.', 'Lower until knees reach about 90° without your lower back lifting.', 'Press up without locking the knees.'], cue: 'Keep your lower back on the pad.', swap: 'Goblet squat' },
    bench: { name: 'Bench press', group: 'strength', area: 'Chest and triceps', steps: ['Eyes under the bar, shoulder blades pinched back.', 'Grip a little wider than shoulders.', 'Lower to the mid-chest, elbows about 45° from the body.', 'Press up and slightly back.'], cue: 'Feet planted, keep a small arch, butt on the bench.', swap: 'Dumbbell press or push-up' },
    dbpress: { name: 'Incline dumbbell press', group: 'strength', area: 'Upper chest', steps: ['Bench at 30°.', 'Press dumbbells up over the upper chest.', 'Lower until a stretch in the chest.'], cue: 'Wrists stacked over elbows.', swap: 'Incline push-up' },
    pushup: { name: 'Push-up', group: 'strength', area: 'Chest, shoulders, core', steps: ['Hands under shoulders, body in one straight line.', 'Lower chest to just above the floor.', 'Push up while squeezing glutes and abs.'], cue: 'It is a moving plank. Do not let the hips sag.', swap: 'Incline push-up on a bench' },
    ohp: { name: 'Overhead press', group: 'strength', area: 'Shoulders', steps: ['Bar at the collarbone, grip just outside shoulders.', 'Squeeze glutes and abs.', 'Press straight up, moving your head back then through.', 'Lock out overhead.'], cue: 'No leaning back; your abs keep the ribs down.', swap: 'Seated dumbbell press' },
    row: { name: 'Barbell or cable row', group: 'strength', area: 'Back', steps: ['Hinge to about 45° (barbell) or sit tall (cable).', 'Pull toward the lower ribs.', 'Squeeze shoulder blades together, then lower slowly.'], cue: 'Lead with the elbows.', swap: 'One-arm dumbbell row' },
    dbrow: { name: 'One-arm dumbbell row', group: 'strength', area: 'Back', steps: ['Hand and knee on a bench, back flat.', 'Row the dumbbell toward your hip.', 'Lower to a full stretch.'], cue: 'Keep shoulders square to the floor.', swap: 'Cable row' },
    pullup: { name: 'Pull-up or lat pulldown', group: 'strength', area: 'Back and biceps', steps: ['Grip a little wider than shoulders.', 'Pull your chest toward the bar.', 'Lower all the way with control.'], cue: 'Think elbows to your back pockets.', swap: 'Assisted pull-up or band pulldown' },
    lateral: { name: 'Lateral raise', group: 'strength', area: 'Side shoulders', steps: ['Light dumbbells at your sides.', 'Raise out to shoulder height, slight bend in the elbow.', 'Lower slowly.'], cue: 'Lead with the elbows, not the hands. Wider shoulders make the waist look smaller.', swap: 'Cable lateral raise' },
    curl: { name: 'Dumbbell curl', group: 'strength', area: 'Biceps', steps: ['Elbows pinned at your sides.', 'Curl up, turning palms up.', 'Lower for 2–3 seconds.'], cue: 'No swinging.', swap: 'Cable curl' },
    triceps: { name: 'Cable triceps pushdown', group: 'strength', area: 'Triceps', steps: ['Elbows at your sides.', 'Push the handle down until arms are straight.', 'Return slowly.'], cue: 'Only the forearms move.', swap: 'Bench dip' },
    calf: { name: 'Standing calf raise', group: 'strength', area: 'Calves', steps: ['Balls of feet on a step.', 'Rise as high as you can, pause.', 'Lower to a full stretch.'], cue: 'Pause at the top and bottom.', swap: 'Seated calf raise' },
    facepull: { name: 'Face pull', group: 'strength', area: 'Rear shoulders', steps: ['Rope at face height.', 'Pull toward your forehead, hands apart.', 'Squeeze the upper back.'], cue: 'Good for posture after lots of pressing.', swap: 'Band pull-apart' },

    deadbug: { name: 'Dead bug', group: 'core', area: 'Deep abs (anti-extension)', steps: ['Lie on your back, arms up, knees over hips.', 'Press your lower back into the floor.', 'Slowly lower opposite arm and leg toward the floor.', 'Return and switch sides.'], cue: 'If your lower back lifts, shorten the reach.', swap: 'Heel taps' },
    plank: { name: 'Front plank', group: 'core', area: 'Deep abs (anti-extension)', steps: ['Forearms under shoulders, body straight.', 'Squeeze glutes and pull elbows toward toes.', 'Breathe and hold.'], cue: 'A hard 20 seconds beats a sloppy 2 minutes.', swap: 'Plank from knees' },
    sideplank: { name: 'Side plank', group: 'core', area: 'Obliques', steps: ['Elbow under shoulder, feet stacked.', 'Lift hips so the body is straight.', 'Hold, then switch.'], cue: 'Push the floor away with your elbow.', swap: 'Side plank from knees' },
    revcrunch: { name: 'Reverse crunch', group: 'core', area: 'Lower abs (flexion)', steps: ['Lie on your back, knees bent at 90°.', 'Curl your hips off the floor toward your ribs.', 'Lower slowly.'], cue: 'Curl the pelvis; do not just swing the legs.', swap: 'Knee tuck' },
    crunch: { name: 'Crunch', group: 'core', area: 'Upper abs (flexion)', steps: ['Knees bent, hands lightly by your ears.', 'Curl your ribs toward your hips.', 'Pause, lower slowly.'], cue: 'Exhale hard at the top.', swap: 'Stability-ball crunch' },
    cablecrunch: { name: 'Kneeling cable crunch', group: 'core', area: 'Rectus abdominis (weighted flexion)', steps: ['Kneel facing the cable with a rope behind your head.', 'Keep hips still and curl your ribs toward your hips.', 'Return slowly to a stretch.'], cue: 'Load the abs like any muscle: 8–15 hard reps.', swap: 'Weighted crunch' },
    hkr: { name: 'Hanging knee raise', group: 'core', area: 'Lower abs and hip flexors', steps: ['Hang from a bar, shoulders engaged.', 'Raise knees toward your chest while curling the pelvis.', 'Lower without swinging.'], cue: 'The curl of the pelvis at the top is the ab part.', swap: 'Captain\'s chair knee raise' },
    hlr: { name: 'Hanging leg raise', group: 'core', area: 'Lower abs', steps: ['Hang from a bar.', 'Keep legs nearly straight and raise them to hip height or higher.', 'Lower slowly.'], cue: 'No momentum. Pause at the top.', swap: 'Hanging knee raise' },
    wheel: { name: 'Ab wheel rollout', group: 'core', area: 'Whole abs (anti-extension)', steps: ['Kneel holding the wheel under your shoulders.', 'Roll forward as far as you can without your lower back sagging.', 'Pull back using your abs.'], cue: 'Ribs down, butt tucked the whole time.', swap: 'Plank walkout' },
    bodysaw: { name: 'Body saw', group: 'core', area: 'Deep abs (anti-extension)', steps: ['Forearm plank with feet on sliders or a towel.', 'Push your body back a few inches, then pull forward.'], cue: 'Smaller range, perfect position.', swap: 'Front plank' },
    pallof: { name: 'Pallof press', group: 'core', area: 'Obliques (anti-rotation)', steps: ['Stand side-on to a cable or band at chest height.', 'Press it straight out from your chest.', 'Hold 2 seconds without twisting; bring back.'], cue: 'The cable tries to turn you. Do not let it.', swap: 'Band Pallof press' },
    woodchop: { name: 'Cable woodchop', group: 'core', area: 'Obliques (rotation)', steps: ['Cable high, stand side-on.', 'Pull diagonally down across your body, rotating through the trunk.', 'Return slowly.'], cue: 'Power comes from the hips and trunk, not the arms.', swap: 'Band chop' },
    carry: { name: 'Suitcase carry', group: 'core', area: 'Obliques and grip', steps: ['Hold a heavy dumbbell in one hand.', 'Walk tall without leaning.', 'Switch hands.'], cue: 'Stand like there is a weight on both sides.', swap: 'Farmer carry' },
    hollow: { name: 'Hollow hold', group: 'core', area: 'Whole abs', steps: ['Lie on your back, lower back pressed down.', 'Lift shoulders and legs a few inches, arms overhead.', 'Hold.'], cue: 'Bend the knees to make it easier.', swap: 'Dead bug' },
    dragon: { name: 'Dragon flag negative', group: 'core', area: 'Whole abs (advanced)', steps: ['Lie on a bench holding behind your head.', 'Lift your body up onto the shoulders.', 'Lower as one straight line, as slowly as you can.'], cue: 'Advanced. Skip if you feel it in your lower back.', swap: 'Ab wheel rollout' },
    vacuum: { name: 'Stomach vacuum', group: 'core', area: 'Transverse abdominis', steps: ['Exhale fully.', 'Pull your belly button toward your spine and hold without breathing in.', 'Rest and repeat.'], cue: 'Trains the deep muscle that flattens the waist.', swap: 'Dead bug' }
  };

  // Ab circuits per phase. Two circuits that alternate. reps can say "30s".
  var AB_CIRCUITS = {
    1: [
      [['deadbug', 3, '8 per side'], ['plank', 3, '30 s'], ['revcrunch', 3, '10'], ['sideplank', 2, '20 s per side']],
      [['crunch', 3, '15'], ['pallof', 3, '10 per side'], ['hollow', 3, '20 s'], ['vacuum', 3, '15 s']]
    ],
    2: [
      [['hkr', 3, '10'], ['wheel', 3, '8 (from knees)'], ['pallof', 3, '12 per side'], ['sideplank', 3, '30 s per side']],
      [['cablecrunch', 3, '12'], ['bodysaw', 3, '10'], ['woodchop', 3, '10 per side'], ['revcrunch', 3, '12']]
    ],
    3: [
      [['hlr', 4, '8'], ['wheel', 3, '10'], ['carry', 3, '30 m per side'], ['hollow', 3, '30 s']],
      [['cablecrunch', 4, '10 (heavier)'], ['bodysaw', 3, '12'], ['woodchop', 3, '12 per side'], ['sideplank', 3, '40 s per side']]
    ],
    4: [
      [['hlr', 4, '10'], ['dragon', 3, '5'], ['pallof', 3, '12 per side'], ['vacuum', 3, '20 s']],
      [['cablecrunch', 4, '12'], ['wheel', 4, '10 (standing if able)'], ['carry', 3, '40 m per side'], ['hollow', 3, '40 s']]
    ]
  };

  // Rep schemes per phase: main lifts and accessories.
  var SCHEMES = {
    1: { main: [3, '10–12'], acc: [2, '12–15'], rest: '90 s', effort: 'Stop 3 reps short of failure. Learn the movements.' },
    2: { main: [4, '8–10'], acc: [3, '10–12'], rest: '2 min', effort: 'Stop 2 reps short of failure. Add a little weight each week.' },
    3: { main: [4, '6–8'], acc: [3, '8–12'], rest: '2–3 min', effort: 'Stop 1–2 reps short of failure on main lifts. Heavier is the goal.' },
    4: { main: [3, '5–8'], acc: [2, '10–12'], rest: '2–3 min', effort: 'Keep the weight on the bar. Less volume, same intensity, to recover in a deeper deficit.' }
  };

  // Workout templates: main = compounds, acc = accessories.
  var WORKOUTS = {
    fullA: { name: 'Full body A', main: ['squat', 'bench', 'row'], acc: ['lateral', 'curl'] },
    fullB: { name: 'Full body B', main: ['rdl', 'ohp', 'pullup'], acc: ['lunge', 'triceps'] },
    fullC: { name: 'Full body C', main: ['goblet', 'dbpress', 'dbrow'], acc: ['hipthrust', 'facepull'] },
    upperA: { name: 'Upper A (strength)', main: ['bench', 'row', 'ohp'], acc: ['pullup', 'lateral', 'triceps'] },
    lowerA: { name: 'Lower A (strength)', main: ['squat', 'rdl'], acc: ['lunge', 'calf'] },
    upperB: { name: 'Upper B (volume)', main: ['dbpress', 'pullup'], acc: ['dbrow', 'lateral', 'curl', 'facepull'] },
    lowerB: { name: 'Lower B (volume)', main: ['deadlift', 'legpress'], acc: ['hipthrust', 'calf'] },
    push: { name: 'Push', main: ['bench', 'ohp'], acc: ['dbpress', 'lateral', 'triceps'] },
    pull: { name: 'Pull', main: ['deadlift', 'pullup'], acc: ['row', 'facepull', 'curl'] },
    legs: { name: 'Legs', main: ['squat', 'rdl'], acc: ['lunge', 'legpress', 'calf'] }
  };

  var SPLITS = {
    3: { name: 'Full body, 3 days', days: [0, 2, 4], seq: ['fullA', 'fullB', 'fullC'], abs: [0, 2, 4] },
    4: { name: 'Upper / lower, 4 days', days: [0, 1, 3, 4], seq: ['upperA', 'lowerA', 'upperB', 'lowerB'], abs: [0, 3, 4] },
    5: { name: 'Upper / lower + push / pull / legs, 5 days', days: [0, 1, 2, 3, 4], seq: ['upperA', 'lowerA', 'push', 'pull', 'legs'], abs: [0, 2, 4] },
    6: { name: 'Push / pull / legs, 6 days', days: [0, 1, 2, 3, 4, 5], seq: ['push', 'pull', 'legs', 'push', 'pull', 'legs'], abs: [0, 2, 4] }
  };

  var CARDIO = {
    1: { steps: 7000, liss: [2, 30], hiit: { beginner: 0, intermediate: 1, advanced: 1 } },
    2: { steps: 8500, liss: [3, 30], hiit: { beginner: 1, intermediate: 1, advanced: 2 } },
    3: { steps: 10000, liss: [3, 40], hiit: { beginner: 1, intermediate: 2, advanced: 2 } },
    4: { steps: 11000, liss: [4, 40], hiit: { beginner: 1, intermediate: 2, advanced: 2 } }
  };
  var HIIT = {
    beginner: { name: 'Bike intervals', detail: 'Warm up 5 min. Then 6 rounds: 20 s hard (8/10 effort), 100 s easy. Cool down 5 min. About 20 min total.' },
    intermediate: { name: 'Bike or rower intervals', detail: 'Warm up 5 min. Then 8 rounds: 30 s hard (9/10), 90 s easy. Cool down 5 min. About 25 min total.' },
    advanced: { name: 'Sprint intervals', detail: 'Warm up 8 min. Then 10 rounds: 30 s all-out on bike, rower or hill, 60–90 s easy. Cool down 5 min.' }
  };
  var LISS_INFO = 'Zone 2: brisk walk, incline treadmill, easy bike or swim at a pace where you can talk in full sentences but would rather not. Burns fat without hurting recovery from lifting.';

  var TIPS = [
    { cat: 'Truth', text: 'You cannot spot-reduce belly fat. Crunches build the muscle; a calorie deficit uncovers it.' },
    { cat: 'Truth', text: 'Everyone has abs. Whether you see them depends mostly on body fat, then on how developed the muscle is.' },
    { cat: 'Truth', text: 'Lower-belly fat is usually the last to go. If the top abs are showing, you are close. Keep going.' },
    { cat: 'Truth', text: 'Genetics decide the shape of your abs: four, six or eight, even or staggered. Training decides how thick they are.' },
    { cat: 'Truth', text: 'Fat-burner pills and waist trainers do not burn belly fat. Save the money for good food.' },
    { cat: 'Nutrition', text: 'Protein first. Build every meal around a palm-to-two-palms portion of protein, then add the rest.' },
    { cat: 'Nutrition', text: 'Liquid calories do not fill you up. Water, black coffee, tea and diet drinks are your friends in a cut.' },
    { cat: 'Nutrition', text: 'Fiber keeps you full. Aim for vegetables or fruit at every meal.' },
    { cat: 'Nutrition', text: 'Plan tomorrow\'s food tonight. The meals you plan are the meals you eat.' },
    { cat: 'Nutrition', text: 'You do not need to cut carbs to get lean. Total calories and protein matter far more.' },
    { cat: 'Nutrition', text: 'Hungry between meals? Drink a big glass of water and wait 15 minutes. Then have a protein snack if you still need it.' },
    { cat: 'Nutrition', text: 'Eat slowly. It takes about 20 minutes for fullness signals to reach your brain.' },
    { cat: 'Nutrition', text: 'Keep two or three go-to meals you can make without thinking. Decision fatigue ruins diets.' },
    { cat: 'Training', text: 'Train abs like any other muscle: load them, aim for 8–15 hard reps, and add weight or difficulty over time.' },
    { cat: 'Training', text: 'Heavy squats, deadlifts and overhead presses work your core hard. Brace every rep.' },
    { cat: 'Training', text: 'Keep lifting heavy while you diet. It tells your body to keep the muscle.' },
    { cat: 'Training', text: 'Write down your weights. If they are going up or holding during a cut, you are keeping your muscle.' },
    { cat: 'Training', text: 'Slow the lowering phase of ab exercises to 3 seconds. Most people rush it and miss half the benefit.' },
    { cat: 'Training', text: 'Exhale hard at the top of a crunch. It forces the abs to contract fully.' },
    { cat: 'Training', text: 'Wider shoulders make your waist look smaller. Lateral raises are an ab exercise for your photos.' },
    { cat: 'Cardio', text: 'Steps are the most underrated fat-loss tool. 10,000 steps burns roughly 300–500 kcal and barely touches recovery.' },
    { cat: 'Cardio', text: 'A 10-minute walk after meals helps blood sugar and adds up to over an hour a week.' },
    { cat: 'Cardio', text: 'Keep HIIT to two sessions a week. More than that eats into your lifting recovery.' },
    { cat: 'Cardio', text: 'Do cardio after lifting or on separate days, not right before a heavy leg session.' },
    { cat: 'Recovery', text: 'Sleep 7–9 hours. Short sleep raises hunger hormones and makes you lose more muscle and less fat.' },
    { cat: 'Recovery', text: 'Stress raises cortisol, which drives cravings and water retention. A 10-minute walk outside helps.' },
    { cat: 'Recovery', text: 'Feeling flat and weak for over a week? You may need a few days at maintenance calories.' },
    { cat: 'Recovery', text: 'Feeling bloated? Check salt, fiber changes and sleep before you worry about fat gain.' },
    { cat: 'Mindset', text: 'Aim for 80% of perfect, 100% of the time. That beats perfect for two weeks then quitting.' },
    { cat: 'Mindset', text: 'The scale measures everything: water, food, muscle, fat. Trust the 2-week trend and your waist tape.' },
    { cat: 'Mindset', text: 'A bad meal is just one meal. The next one is a fresh start. Do not wait until Monday.' },
    { cat: 'Mindset', text: 'Compare photos two weeks apart, never day to day. Change is too slow to see in the mirror.' },
    { cat: 'Mindset', text: 'Motivation gets you started; habits get you abs. Make the plan so easy you cannot say no.' },
    { cat: 'Mindset', text: 'Tell one person about your goal. People who share their goals stick with them longer.' },
    { cat: 'Mindset', text: 'Lean is a skill. Every week you practice it, maintenance gets easier.' },
    { cat: 'Mindset', text: 'Visible abs in the morning, softer at night after food and water: that is normal for everyone.' },
    { cat: 'Mindset', text: 'If tracking food starts to feel obsessive or stressful, step back. Health comes first, abs second.' }
  ];

  var PHOTO_GUIDE = [
    'Same spot, same light, same time of day. Morning before eating is best.',
    'Phone at belly-button height, about 2 m (6 ft) away. Use the timer.',
    'Take front, side and back. Arms relaxed at your sides, then one flexed front shot.',
    'Wear the same shorts or underwear each time.',
    'Retake every 2 weeks. Photos stay on this device only.'
  ];

  var TAPE_GUIDE = {
    neck: 'Just below the Adam\'s apple (or the same level for women), tape sloping slightly down to the front. Do not flare your neck.',
    waist_male: 'Around the belly button, after a normal breath out. Do not suck in. Tape level all the way around.',
    waist_female: 'At the narrowest part of the waist, usually just above the belly button, after a normal breath out.',
    hip: 'Around the widest part of your buttocks, feet together.',
    tips: 'Use a soft tape measure snug on the skin but not pressing in. Measure twice and use the average. Measure at the same time of day each week.'
  };

  var api = {
    FOODS: FOODS, MEALS: MEALS, NUTRITION_RULES: NUTRITION_RULES, EXERCISES: EXERCISES, AB_CIRCUITS: AB_CIRCUITS,
    SCHEMES: SCHEMES, WORKOUTS: WORKOUTS, SPLITS: SPLITS, CARDIO: CARDIO, HIIT: HIIT, LISS_INFO: LISS_INFO,
    TIPS: TIPS, PHOTO_GUIDE: PHOTO_GUIDE, TAPE_GUIDE: TAPE_GUIDE
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.Content = api;
})(this);
