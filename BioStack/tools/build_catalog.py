"""Generates BioStack/Resources/catalog.json, the single source of content for the
iPhone app and the web app.

Usage: python3 BioStack/tools/build_catalog.py

Supplement rows: name | category | dose | timing | evidence | goals | notes
Evidence: A = strong (multiple RCTs/meta-analyses), B = moderate, C = limited/mixed,
D = weak or mostly preclinical.
"""
import json
import re
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "Resources" / "catalog.json"

GOALS = [
    ("longevity", "Longevity & healthy ageing", "hourglass"),
    ("strength", "Strength & power", "dumbbell"),
    ("hypertrophy", "Muscle growth", "figure.strengthtraining.traditional"),
    ("endurance", "Endurance", "figure.run"),
    ("recovery", "Recovery", "bandage"),
    ("bodycomp", "Fat loss & body composition", "scalemass"),
    ("sleep", "Sleep", "moon.zzz"),
    ("cognition", "Focus & cognition", "brain.head.profile"),
    ("stress", "Stress & mood", "leaf"),
    ("heart", "Heart & blood vessels", "heart"),
    ("metabolic", "Blood sugar & metabolism", "drop"),
    ("joints", "Joints, tendons & bone", "figure.walk"),
    ("immunity", "Immunity", "shield"),
    ("hormones", "Hormonal health", "waveform.path.ecg"),
    ("gut", "Gut health", "circle.grid.cross"),
    ("skin", "Skin, hair & eyes", "sparkles"),
]

S = """
Creatine monohydrate | Performance | 3–5 g daily | Any time; consistency matters more than timing | A | strength,hypertrophy,cognition,longevity | Optional loading of 20 g/day for 5–7 days saturates muscle faster. Can raise serum creatinine without harming the kidneys, so tell whoever reads your labs.
Whey protein | Protein | 20–40 g per serving, toward 1.6–2.2 g protein/kg/day in total | After training or with meals | A | hypertrophy,strength,recovery,bodycomp | Count it toward total daily protein rather than adding on top. Isolate suits lactose sensitivity.
Casein protein | Protein | 30–40 g | Before bed | B | hypertrophy,recovery | Slow digestion supports overnight muscle protein synthesis.
Plant protein blend | Protein | 25–40 g per serving | With meals | B | hypertrophy,bodycomp | Pea + rice blends match whey best; slightly higher servings make up for lower leucine.
Essential amino acids (EAAs) | Protein | 10–15 g | Around training | C | hypertrophy,recovery | Useful when whole-protein intake is low; redundant if daily protein is adequate.
Branched-chain amino acids (BCAAs) | Protein | 5–10 g | Around training | D | recovery | Little benefit when total protein intake is adequate; EAAs or whole protein are better.
Leucine | Protein | 2–3 g per meal | With lower-protein meals | C | hypertrophy | Most useful for older adults with low appetite.
HMB | Performance | 3 g daily, split | With meals | C | hypertrophy,recovery | Benefits mainly in untrained or older people and during calorie restriction.
Caffeine | Stimulant | 3–6 mg/kg | 30–60 minutes before exercise | A | endurance,strength,cognition,bodycomp | Keep to about 400 mg/day for healthy adults and stop 8+ hours before bed. Avoid with arrhythmias, uncontrolled blood pressure or pregnancy beyond 200 mg.
L-theanine | Nootropic | 100–200 mg | With caffeine, or in the evening | B | cognition,stress,sleep | Smooths caffeine jitters; 2:1 theanine to caffeine is common.
Beta-alanine | Performance | 3.2–6.4 g daily in 0.8–1.6 g doses | With meals, daily for 4+ weeks | A | endurance,strength | Helps efforts of 1–4 minutes. Tingling (paresthesia) is harmless; sustained-release forms reduce it.
Citrulline malate | Performance | 6–8 g | 60 minutes before training | B | endurance,strength,heart | Raises arginine and nitric oxide more reliably than arginine itself.
Sodium bicarbonate | Performance | 0.2–0.3 g/kg | 60–180 minutes before high-intensity events | A | endurance | Gut upset is common; split doses or enteric capsules help. High sodium load.
Dietary nitrate (beetroot juice) | Performance | 6–8 mmol nitrate (~400–500 mg) | 2–3 hours before exercise | A | endurance,heart | Antibacterial mouthwash blocks the effect. Harmless red urine (beeturia).
Betaine (TMG) | Performance | 2.5 g daily | With food | C | strength,metabolic | May slightly raise LDL in some people.
Taurine | Amino acid | 1–3 g daily | Any time | C | endurance,heart,longevity | Ageing research in animals is promising; human data are early.
Carbohydrate (drinks, gels) | Sports nutrition | 30–60 g/hour; up to 90 g/hour glucose+fructose for long events | During sessions over 60–90 minutes | A | endurance | Train the gut beforehand to avoid GI distress.
Electrolytes (sodium) | Sports nutrition | 300–600 mg sodium per hour of sweating | During long or hot sessions | B | endurance | Needs vary widely; a sweat test can personalise. Caution with high blood pressure or kidney disease.
Ketone esters | Sports nutrition | 10–25 g | 30–60 minutes before | D | endurance,cognition | Mixed performance results; GI upset and cost are common issues.
MCT oil | Fat | 5–15 g, building up slowly | With food | D | cognition,bodycomp | Start low to avoid GI upset.
L-carnitine L-tartrate | Performance | 1–2 g daily | With carbohydrate-containing meals | C | recovery | May reduce muscle damage markers. Raises TMAO, of uncertain significance.
Acetyl-L-carnitine | Nootropic | 500–2,000 mg | Morning | C | cognition,stress | Some evidence for mood and fatigue in older adults.
Tart cherry | Recovery | 480 mg extract or 30 ml concentrate twice daily | Around hard training blocks | C | recovery,sleep | Avoid constant use if you want maximal training adaptation from inflammation.
Collagen peptides | Recovery | 10–15 g with ~50 mg vitamin C | 30–60 minutes before tendon/joint loading | C | joints,skin,recovery | Not a complete protein; don't count toward muscle-building protein.
Glutamine | Amino acid | 5–10 g | Any time | D | gut,recovery | Little performance effect in healthy athletes.
Vitamin D3 | Vitamin | 1,000–4,000 IU daily, guided by 25(OH)D blood level | With a meal containing fat | A | immunity,joints,longevity,hormones | Stay at or under 4,000 IU/day unless a clinician prescribes more. Retest after 8–12 weeks.
Vitamin K2 (MK-7) | Vitamin | 90–200 mcg | With fat-containing food | C | joints,heart | Do not take with warfarin unless your clinician agrees.
Vitamin C | Vitamin | 200–1,000 mg | Split through the day | B | immunity,skin | Mega-doses around training may blunt adaptations; kidney stone risk above 1 g/day.
Vitamin B12 | Vitamin | 250–1,000 mcg | Daily | A | cognition,longevity | Important for vegans, people over 50 and metformin users. Treats deficiency only.
Folate (methylfolate) | Vitamin | 400 mcg DFE | Daily | A | heart,cognition | Essential before and during pregnancy. High doses can mask B12 deficiency.
B-complex | Vitamin | About 100% of daily values | Morning with food | C | cognition,stress | Bright yellow urine from riboflavin is normal. Biotin interferes with many lab tests: stop 2–3 days before blood work.
Vitamin E | Vitamin | 15 mg (22 IU) daily from food and supplements | With food | D | skin | Avoid high-dose supplements: linked to higher prostate cancer risk and bleeding.
Multivitamin | Vitamin | 1 serving daily | With breakfast | B | longevity,cognition,immunity | Large trials (COSMOS) found modest cognitive benefits in older adults.
Iron | Mineral | 18–65 mg elemental, only when ferritin or iron is low | Alternate days, with vitamin C, away from coffee, tea and calcium | A | endurance | Test before you take it. Excess iron is harmful, especially with hemochromatosis.
Magnesium glycinate | Mineral | 200–400 mg elemental | Evening | B | sleep,stress,recovery | Supplemental upper limit is 350 mg/day for most adults; above that diarrhoea is common. Caution with kidney disease.
Magnesium L-threonate | Mineral | 1.5–2 g compound (~144 mg magnesium) | Evening | C | cognition,sleep | Marketed for brain uptake; human trials are small.
Zinc | Mineral | 8–11 mg; 15–30 mg if low | With food | B | immunity,hormones,skin | Long-term intake above 40 mg/day causes copper deficiency.
Calcium | Mineral | Enough to reach 1,000–1,200 mg/day including diet | No more than 500 mg at a time | B | joints | Food sources preferred. Separate from iron and thyroid medication.
Potassium citrate | Mineral | Food first; supplements are limited to 99 mg per pill in the US | With meals | B | heart | Dangerous with kidney disease, ACE inhibitors, ARBs or potassium-sparing diuretics.
Iodine | Mineral | 150 mcg | Daily | B | hormones | Excess can trigger thyroid problems; avoid kelp mega-doses.
Selenium | Mineral | 55–100 mcg | Daily | B | immunity,hormones | Upper limit 400 mcg/day. Two Brazil nuts ≈ 100–200 mcg.
Boron | Mineral | 3–10 mg | With food | C | joints,hormones | Small studies only.
Chromium picolinate | Mineral | 200–1,000 mcg | With meals | D | metabolic | Small effects on glucose at best.
Omega-3 (EPA + DHA) | Fatty acid | 1–3 g combined EPA+DHA | With meals | A | heart,longevity,joints,cognition,stress | Above 3 g/day may raise atrial fibrillation and bleeding risk. Check with your clinician if you take blood thinners.
Plant sterols | Heart | 1.5–3 g daily | With meals | A | heart | Lowers LDL by 6–12%.
Psyllium husk | Fibre | 5–10 g with a full glass of water | Before meals | A | heart,metabolic,gut,bodycomp | Lowers LDL and blunts glucose spikes. Separate from medications by 2 hours.
Red yeast rice | Heart | 1.2–2.4 g, standardised products only | Evening | C | heart | Contains monacolin K, identical to lovastatin, with the same risks. Product quality varies; a 2024 Japanese outbreak of kidney injury was linked to contaminated products. Don't combine with statins.
Aged garlic extract | Heart | 600–1,200 mg | With food | B | heart,immunity | Modest blood pressure reduction. May increase bleeding with anticoagulants.
Cocoa flavanols | Heart | 500–900 mg flavanols | Daily | B | heart,cognition | The COSMOS trial suggested lower cardiovascular death. Chocolate is not an efficient source.
Coenzyme Q10 (ubiquinol) | Antioxidant | 100–300 mg | With a meal containing fat | C | heart,longevity,endurance | Often used with statins for muscle aches (mixed evidence). May reduce warfarin's effect.
Berberine | Metabolic | 500 mg 2–3 times daily | With meals | B | metabolic,heart,bodycomp | Lowers glucose and LDL. Interacts with many drugs via CYP enzymes; avoid in pregnancy. GI upset common.
Alpha-lipoic acid | Metabolic | 300–600 mg | On an empty stomach | C | metabolic | Can lower blood sugar; monitor if diabetic.
Myo-inositol | Metabolic | 2–4 g | Split doses | B | metabolic,hormones,stress | Best evidence is in PCOS.
Ceylon cinnamon | Metabolic | 1–3 g | With meals | D | metabolic | Choose Ceylon: cassia contains coumarin, which can harm the liver.
Green tea extract (EGCG) | Metabolic | 250–500 mg EGCG | With food, never fasted | C | bodycomp,metabolic | Liver injury reported, mostly with fasting doses above 800 mg/day.
Curcumin (enhanced absorption) | Anti-inflammatory | 500–1,000 mg | With food | C | joints,recovery,longevity | Rare liver injury, especially with piperine forms. Caution with anticoagulants and gallstones.
Ginger | Anti-inflammatory | 1–2 g | With food | C | recovery,gut | Helps nausea and mild muscle soreness.
Boswellia serrata | Anti-inflammatory | 100–250 mg AKBA-standardised extract | With food | C | joints | Small trials in knee osteoarthritis are positive.
Glucosamine sulfate | Joint | 1,500 mg | Daily | C | joints | Mixed results for knee osteoarthritis. Shellfish-derived versions exist.
Chondroitin | Joint | 800–1,200 mg | Daily | C | joints | Often paired with glucosamine. May raise bleeding with warfarin.
MSM | Joint | 1.5–3 g | Daily | C | joints,recovery | Small trials only.
Oral hyaluronic acid | Joint | 120–200 mg | Daily | C | joints,skin | Small trials only.
Astaxanthin | Antioxidant | 4–12 mg | With fat-containing food | C | skin,recovery | May reduce exercise-induced oxidative stress.
Lutein + zeaxanthin | Antioxidant | 10 mg lutein + 2 mg zeaxanthin | With food | B | skin,cognition | AREDS2 formula for macular degeneration.
N-acetylcysteine (NAC) | Antioxidant | 600–1,200 mg | Daily | C | longevity,immunity | Glutathione precursor. High doses around training may blunt adaptations.
Liposomal glutathione | Antioxidant | 250–1,000 mg | Daily | D | longevity | Oral absorption is debated.
Nicotinamide riboside (NR) | Longevity | 300–1,000 mg | Morning | C | longevity | Raises NAD+ in blood reliably; clinical benefits are not yet shown.
NMN | Longevity | 250–1,000 mg | Morning | C | longevity | Raises NAD+; human outcome data are limited. US regulatory status has changed over time.
Resveratrol | Longevity | 150–500 mg | With fat-containing food | D | longevity,heart | Human results are inconsistent.
Quercetin | Longevity | 500–1,000 mg | With food | C | longevity,immunity | Studied as a senolytic alongside other drugs. CYP interactions.
Fisetin | Longevity | 100–500 mg | With fat-containing food | D | longevity | Senolytic trials in humans are ongoing; results not yet established.
Spermidine | Longevity | 1–6 mg | Daily | C | longevity,skin | Autophagy-related research; human trials are small.
Urolithin A | Longevity | 500–1,000 mg | Daily | C | longevity,endurance | Small trials show better muscle endurance and mitochondrial markers.
Calcium alpha-ketoglutarate (Ca-AKG) | Longevity | 1 g | Daily | D | longevity | Mostly animal data; human trials ongoing.
Sulforaphane (broccoli sprout) | Longevity | 10–40 mg sulforaphane, or glucoraphanin with myrosinase | With food | C | longevity | Activates Nrf2 antioxidant pathways.
Pycnogenol (pine bark) | Antioxidant | 100–200 mg | Daily | C | heart,skin | Modest blood pressure and circulation effects.
Ashwagandha (root extract) | Adaptogen | 300–600 mg standardised extract | Daily or evening | B | stress,sleep,strength | Rare liver injury reported. Avoid in pregnancy; caution with thyroid disease.
Rhodiola rosea | Adaptogen | 200–600 mg (3% rosavins) | Morning | C | stress,endurance,cognition | Can feel stimulating; avoid late in the day.
Panax ginseng | Adaptogen | 200–400 mg extract | Morning | C | cognition,immunity,stress | May interact with warfarin and diabetes medication.
Tongkat ali | Adaptogen | 200–400 mg standardised extract | Morning | C | hormones,stress | Small trials; quality and contamination vary.
Fenugreek extract | Herbal | 500–600 mg | With food | C | hormones,metabolic | Can lower blood sugar. Maple-syrup body odour is harmless.
Maca | Herbal | 1.5–3 g | Daily | D | hormones,stress | Evidence mainly for libido.
Shilajit | Herbal | 250–500 mg purified | Daily | D | hormones,endurance | Unpurified products can contain heavy metals; buy third-party tested.
Saffron | Herbal | 30 mg | Daily | B | stress,sleep | Several trials show mood benefits.
Lion's mane | Mushroom | 500–3,000 mg | Daily | C | cognition | Small human trials.
Cordyceps | Mushroom | 1–3 g | Daily | D | endurance | Mixed results for VO2 max.
Reishi | Mushroom | 1–3 g | Evening | D | sleep,immunity | Rare liver toxicity; caution with anticoagulants.
Bacopa monnieri | Nootropic | 300 mg (50% bacosides) | With fat-containing food, for 8–12 weeks | B | cognition,stress | Effects build slowly; GI upset possible.
Alpha-GPC | Nootropic | 300–600 mg | Morning or before training | C | cognition,strength | Choline source; may slightly raise TMAO.
Citicoline (CDP-choline) | Nootropic | 250–500 mg | Morning | C | cognition | Attention benefits in small trials.
L-tyrosine | Nootropic | 500–2,000 mg | 60 minutes before demanding tasks | C | cognition,stress | Avoid with MAO inhibitors or hyperthyroidism.
5-HTP | Mood | 50–200 mg | Evening | D | stress,sleep | Risk of serotonin syndrome with SSRIs, SNRIs, triptans or MAOIs: do not combine.
Melatonin | Sleep | 0.3–3 mg | 30–60 minutes before bed | B | sleep | Low doses work as well as high ones. Useful for jet lag and shift work.
Glycine | Sleep | 3 g | Before bed | C | sleep | Small trials show improved sleep quality.
Apigenin | Sleep | 50 mg | Before bed | D | sleep | Chamomile compound; limited human data.
GABA | Sleep | 100–300 mg | Before bed | D | sleep,stress | Unclear whether it crosses into the brain.
Probiotics (strain-specific) | Gut | Per strain, typically 1–10 billion CFU | Daily | C | gut,immunity | Benefits depend on the exact strain and condition.
Bovine colostrum | Gut | 10–20 g | Daily | C | gut,immunity | May reduce gut permeability during heavy training.
Digestive enzymes | Gut | As labelled | With meals | D | gut | Lactase for lactose intolerance is the clearest use.
Elderberry | Immunity | As labelled | During colds | D | immunity | May shorten colds slightly. Never eat raw berries.
"""

RX = [
    # name, class, status, uses, mechanism, evidence, risks, labs, goals
    ("Metformin", "Biguanide", "Prescription (US)", "Type 2 diabetes, prediabetes, PCOS",
     "Lowers liver glucose output and improves insulin sensitivity.",
     "TAME trial is testing it as an ageing drug. May blunt muscle and VO2 max gains from training in healthy people.",
     "GI upset, B12 deficiency, rare lactic acidosis (mainly kidney disease).", "HbA1c, fasting glucose, B12, kidney function (eGFR)", "metabolic,longevity"),
    ("Semaglutide", "GLP-1 receptor agonist (biologic peptide)", "Prescription (US, FDA-approved)", "Type 2 diabetes, obesity, cardiovascular risk reduction",
     "Mimics GLP-1 to slow stomach emptying, cut appetite and improve insulin release.",
     "SELECT trial: 20% fewer major cardiovascular events. 15% average weight loss in obesity trials.",
     "Nausea, vomiting, muscle and lean-mass loss, gallbladder disease, pancreatitis; avoid with personal/family history of medullary thyroid cancer.", "HbA1c, lipids, body composition (DEXA), kidney function", "bodycomp,metabolic,heart,longevity"),
    ("Tirzepatide", "GIP/GLP-1 receptor agonist (biologic peptide)", "Prescription (US, FDA-approved)", "Type 2 diabetes, obesity, sleep apnoea",
     "Acts on both GIP and GLP-1 receptors to reduce appetite and improve glucose control.",
     "SURMOUNT trials: about 20% average weight loss.",
     "Similar to semaglutide: GI effects, lean-mass loss, gallbladder and pancreatitis risk.", "HbA1c, lipids, body composition", "bodycomp,metabolic,heart"),
    ("Liraglutide", "GLP-1 receptor agonist (biologic peptide)", "Prescription (US)", "Type 2 diabetes, obesity",
     "Daily GLP-1 agonist.", "Less weight loss than weekly agents; cardiovascular benefit shown (LEADER).",
     "GI effects, gallbladder and pancreatitis risk.", "HbA1c, weight", "bodycomp,metabolic"),
    ("Retatrutide", "GIP/GLP-1/glucagon triple agonist", "Investigational — not approved", "Obesity (phase 3 trials)",
     "Adds glucagon-receptor activity to raise energy expenditure.", "Phase 2: about 24% weight loss at 48 weeks.",
     "Long-term safety unknown. Not legally available outside trials.", "Trial-managed", "bodycomp,metabolic"),
    ("Empagliflozin", "SGLT2 inhibitor", "Prescription (US)", "Type 2 diabetes, heart failure, chronic kidney disease",
     "Makes the kidneys excrete glucose.", "Strong heart and kidney protection; extended lifespan in male mice (ITP, canagliflozin).",
     "Genital infections, dehydration, rare ketoacidosis.", "Kidney function, glucose, ketones if unwell", "metabolic,heart,longevity"),
    ("Acarbose", "Alpha-glucosidase inhibitor", "Prescription (US)", "Type 2 diabetes",
     "Slows carbohydrate digestion to blunt glucose spikes.", "Extended lifespan in mice (ITP).",
     "Gas, bloating, diarrhoea.", "Glucose, HbA1c, liver enzymes", "metabolic,longevity"),
    ("Rapamycin (sirolimus)", "mTOR inhibitor", "Prescription (US) for transplant; longevity use is off-label", "Organ transplant rejection, some rare diseases",
     "Inhibits mTOR, a central nutrient-sensing growth pathway.", "Most robust lifespan extension in mice. Human longevity trials (e.g. PEARL) are small and early.",
     "Immune suppression, mouth ulcers, raised lipids and glucose, impaired wound healing.", "Lipids, glucose, blood count, drug levels where applicable", "longevity"),
    ("Statins (e.g. rosuvastatin)", "HMG-CoA reductase inhibitor", "Prescription (US)", "High LDL and ApoB, cardiovascular prevention",
     "Blocks cholesterol production in the liver.", "Decades of outcome data for heart attack and stroke prevention.",
     "Muscle aches, small rise in diabetes risk, rare liver injury.", "Lipid panel, ApoB, liver enzymes, CK if symptoms, HbA1c", "heart,longevity"),
    ("Ezetimibe", "Cholesterol absorption inhibitor", "Prescription (US)", "High LDL",
     "Blocks cholesterol absorption in the gut.", "Adds to statins (IMPROVE-IT).", "Generally well tolerated.", "Lipid panel, ApoB", "heart"),
    ("PCSK9 inhibitors (evolocumab, alirocumab)", "Monoclonal antibody (biologic)", "Prescription (US)", "High LDL, cardiovascular disease",
     "Increases LDL receptor recycling in the liver.", "Lowers LDL 50–60%; fewer cardiovascular events.", "Injection-site reactions; cost.", "Lipid panel, ApoB", "heart,longevity"),
    ("Bempedoic acid", "ACL inhibitor", "Prescription (US)", "High LDL, statin intolerance",
     "Blocks cholesterol production upstream of statins without muscle effects.", "CLEAR Outcomes: fewer cardiovascular events.",
     "Raised uric acid, gout, tendon rupture (rare).", "Lipids, uric acid", "heart"),
    ("Low-dose aspirin", "Antiplatelet", "Over the counter; prevention use should be clinician-guided", "Secondary prevention of heart attack and stroke",
     "Irreversibly inhibits platelet COX-1.", "No longer advised for routine primary prevention in older adults (ASPREE).",
     "Gastrointestinal and brain bleeding.", "Blood count if bleeding", "heart"),
    ("Telmisartan", "Angiotensin receptor blocker", "Prescription (US)", "High blood pressure",
     "Blocks angiotensin II; partial PPAR-gamma activity.", "Strong blood pressure outcome data.",
     "High potassium, dizziness, kidney effects; not in pregnancy.", "Blood pressure, potassium, kidney function", "heart,metabolic"),
    ("Testosterone replacement therapy", "Androgen (hormone therapy)", "Prescription, controlled substance (US Schedule III)", "Diagnosed male hypogonadism",
     "Replaces testosterone when the body makes too little.", "Improves symptoms in confirmed deficiency. TRAVERSE trial: no increase in major cardiovascular events in men with hypogonadism.",
     "Raised haematocrit, infertility and testicular shrinkage, acne, sleep apnoea, prostate effects. Use without a diagnosis is illegal and unsafe.", "Total and free testosterone, haematocrit, PSA, estradiol, lipids", "hormones"),
    ("Menopausal hormone therapy", "Estrogen ± progestogen", "Prescription (US)", "Menopause symptoms, bone loss prevention",
     "Replaces estrogen (plus progestogen if you have a uterus).", "Best for symptoms when started within 10 years of menopause or before age 60.",
     "Blood clots and stroke (lower with skin patches), breast cancer risk with combined therapy.", "Mammography, blood pressure, bone density", "hormones,joints"),
    ("Levothyroxine", "Thyroid hormone", "Prescription (US)", "Hypothyroidism",
     "Replaces thyroxine (T4).", "Standard treatment for deficiency only.",
     "Over-treatment causes arrhythmia and bone loss.", "TSH, free T4", "hormones"),
    ("DHEA", "Adrenal hormone precursor", "Dietary supplement in the US; prescription or banned elsewhere; banned in sport (WADA)", "Adrenal insufficiency (specialist use)",
     "Converted into testosterone and estrogen.", "Benefits in healthy people are inconsistent.",
     "Acne, hair loss, hormone-sensitive cancer concerns.", "DHEA-S, sex hormones", "hormones"),
    ("Finasteride", "5-alpha-reductase inhibitor", "Prescription (US)", "Male pattern hair loss, enlarged prostate",
     "Lowers DHT.", "Effective for hair loss.", "Sexual side effects, mood changes; lowers PSA readings.", "PSA (interpret ×2)", "skin"),
    ("Minoxidil", "Vasodilator", "OTC topical; oral is prescription", "Hair loss; oral form for blood pressure",
     "Prolongs the hair growth phase.", "Effective for hair loss.", "Scalp irritation; oral form can cause fluid retention and fast heart rate.", "Blood pressure, heart rate (oral)", "skin"),
    ("Tadalafil", "PDE5 inhibitor", "Prescription (US)", "Erectile dysfunction, enlarged prostate, pulmonary hypertension",
     "Increases blood flow by boosting cGMP.", "Approved indications only; no proven performance benefit.",
     "Headache, flushing; dangerous with nitrates.", "Blood pressure", "heart,hormones"),
    ("Low-dose naltrexone", "Opioid antagonist (off-label low dose)", "Prescription (US), off-label", "Off-label for fibromyalgia, some autoimmune conditions",
     "Brief opioid-receptor blockade with possible anti-inflammatory effects.", "Small trials only.",
     "Vivid dreams, insomnia; blocks opioid painkillers.", "None routine", "stress,recovery"),
    ("Modafinil", "Wakefulness-promoting agent", "Prescription, controlled (US Schedule IV); banned in sport (WADA)", "Narcolepsy, shift-work disorder, sleep apnoea fatigue",
     "Increases dopamine and other wake-promoting signals.", "Modest cognitive effects in sleep-deprived people.",
     "Insomnia, headache, rare severe skin reactions; reduces hormonal contraceptive effect.", "None routine", "cognition"),
    ("Dasatinib + quercetin", "Senolytic combination (investigational)", "Dasatinib is a prescription cancer drug; senolytic use is experimental", "Chronic myeloid leukaemia (dasatinib)",
     "Clears senescent cells in animal models.", "Small human pilot studies only.",
     "Dasatinib: low blood counts, fluid around the lungs, bleeding.", "Trial-managed", "longevity"),
    ("Sildenafil", "PDE5 inhibitor", "Prescription (US)", "Erectile dysfunction, pulmonary hypertension",
     "Increases blood flow by boosting cGMP.", "Approved indications only.", "Headache, visual changes; dangerous with nitrates.", "Blood pressure", "heart,hormones"),
]

APPS = [
    ("Apple Health", "Hub", "Central store for iPhone and Apple Watch data, plus most apps below.", "https://www.apple.com/health/"),
    ("Oura", "Sleep & recovery ring", "Sleep stages, HRV, resting heart rate, temperature, readiness.", "https://ouraring.com"),
    ("WHOOP", "Recovery wearable", "Strain, recovery, HRV, sleep, Healthspan / biological age estimates.", "https://www.whoop.com"),
    ("Ultrahuman Ring", "Sleep & recovery ring", "Sleep, HRV, movement and metabolic add-ons.", "https://www.ultrahuman.com"),
    ("Garmin Connect", "Training wearable", "GPS training, VO2 max estimate, training load, Body Battery, HRV status.", "https://connect.garmin.com"),
    ("Polar Flow", "Training wearable", "Heart rate training, recovery and sleep.", "https://flow.polar.com"),
    ("COROS", "Training wearable", "GPS training load and recovery for endurance athletes.", "https://coros.com"),
    ("Fitbit", "Wearable", "Steps, heart rate, sleep and SpO2.", "https://www.fitbit.com"),
    ("Withings", "Smart scales & BP", "Weight, body composition, blood pressure, ECG.", "https://www.withings.com"),
    ("Eight Sleep", "Smart mattress", "Sleep tracking and temperature control.", "https://www.eightsleep.com"),
    ("Strava", "Training log", "Runs, rides and swims with social features.", "https://www.strava.com"),
    ("TrainingPeaks", "Training planning", "Structured endurance plans, TSS and fitness/fatigue modelling.", "https://www.trainingpeaks.com"),
    ("Hevy", "Strength log", "Sets, reps, volume and progressive overload tracking.", "https://www.hevyapp.com"),
    ("Strong", "Strength log", "Simple lifting log with 1RM estimates.", "https://www.strong.app"),
    ("HRV4Training", "HRV", "Camera or sensor-based morning HRV and training guidance.", "https://www.hrv4training.com"),
    ("Elite HRV", "HRV", "HRV readiness with chest strap support.", "https://elitehrv.com"),
    ("Dexcom Stelo", "Glucose (CGM)", "Over-the-counter continuous glucose monitor.", "https://www.stelo.com"),
    ("Abbott Lingo", "Glucose (CGM)", "Over-the-counter CGM for wellness.", "https://www.hellolingo.com"),
    ("Levels", "Metabolic health", "CGM-based metabolic coaching and labs.", "https://www.levels.com"),
    ("Cronometer", "Nutrition", "Detailed micronutrient and macronutrient tracking.", "https://cronometer.com"),
    ("MyFitnessPal", "Nutrition", "Calorie and macro tracking with a large food database.", "https://www.myfitnesspal.com"),
    ("Function Health", "Lab testing", "100+ biomarker blood testing twice a year.", "https://www.functionhealth.com"),
    ("InsideTracker", "Lab testing", "Blood biomarkers, InnerAge and recommendations.", "https://www.insidetracker.com"),
    ("Superpower", "Lab testing", "Broad biomarker panels with clinician review.", "https://superpower.com"),
    ("Quest (questhealth.com)", "Lab testing", "Consumer-ordered blood tests.", "https://www.questhealth.com"),
    ("Labcorp OnDemand", "Lab testing", "Consumer-ordered blood tests.", "https://www.ondemand.labcorp.com"),
    ("TruDiagnostic", "Biological age", "Epigenetic (DNA methylation) age tests, including DunedinPACE.", "https://www.trudiagnostic.com"),
    ("Tally Health", "Biological age", "Cheek-swab epigenetic age test.", "https://tallyhealth.com"),
    ("Viome", "Gut & microbiome", "Gut microbiome and RNA testing.", "https://www.viome.com"),
    ("Health Records (Apple)", "Medical records", "Pull lab results from participating US health systems into Apple Health.", "https://support.apple.com/en-us/104998"),
]

def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")

def main():
    supplements = []
    for line in S.strip().splitlines():
        name, cat, dose, timing, ev, goals, notes = [p.strip() for p in line.split("|")]
        supplements.append({"id": slug(name), "name": name, "kind": "supplement", "category": cat,
                            "dose": dose, "timing": timing, "evidence": ev,
                            "goals": goals.split(","), "notes": notes})
    rx = []
    for name, cls, status, uses, mech, evid, risks, labs, goals in RX:
        rx.append({"id": slug(name), "name": name, "kind": "clinical", "category": cls, "status": status,
                   "uses": uses, "mechanism": mech, "evidence_text": evid, "risks": risks,
                   "labs": labs, "goals": goals.split(",")})
    goal_ids = {g[0] for g in GOALS}
    for item in supplements + rx:
        bad = set(item["goals"]) - goal_ids
        assert not bad, (item["name"], bad)
    catalog = {
        "version": 1,
        "goals": [{"id": i, "name": n, "symbol": s} for i, n, s in GOALS],
        "supplements": supplements,
        "clinical": rx,
        "apps": [{"name": n, "category": c, "description": d, "url": u} for n, c, d, u in APPS],
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=1))
    print(f"{len(supplements)} supplements, {len(rx)} clinical, {len(APPS)} apps -> {OUT}")

if __name__ == "__main__":
    main()
