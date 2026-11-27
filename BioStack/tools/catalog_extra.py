"""Nootropics and peptides content for build_catalog.py.

Nootropic supplements carry typical doses like the main supplement list.
Prescription/unapproved nootropics and all peptides are REFERENCE ONLY:
status, sport rules, evidence, mechanism, risks and labs. No doses,
administration or sourcing information is included by design.
"""

# Same row format as S in build_catalog.py:
# name | category | dose | timing | evidence | goals | notes
NOOTROPIC_SUPPLEMENTS = """
Phosphatidylserine | Nootropic | 100–300 mg | With meals | C | cognition,stress | Some evidence for memory in older adults and for blunting cortisol after hard exercise.
Ginkgo biloba (EGb 761) | Nootropic | 120–240 mg standardised extract | Split with meals | C | cognition | Large trials (GEM) did not prevent dementia. Increases bleeding risk with anticoagulants and antiplatelets.
Huperzine A | Nootropic | 50–200 mcg | Morning | D | cognition | Acetylcholinesterase inhibitor with a long half-life. Can cause nausea, slow heart rate and muscle cramps; avoid with dementia drugs or before anaesthesia.
Uridine monophosphate | Nootropic | 250–500 mg | Daily | D | cognition | Studied with omega-3 and choline (Souvenaid) in early Alzheimer's with modest effects.
Choline bitartrate | Nootropic | 250–500 mg | With food | D | cognition | Cheap choline source; less brain-targeted than alpha-GPC or citicoline. Fishy body odour at high doses.
Sulbutiamine | Nootropic | 200–600 mg | Morning | D | cognition,stress | Fat-soluble vitamin B1 derivative. Small studies on fatigue only.
Paraxanthine | Nootropic | 100–300 mg | Morning or before training | C | cognition,endurance | The main metabolite of caffeine; early trials suggest similar alertness with fewer jitters.
Theacrine | Nootropic | 100–200 mg | Morning | D | cognition,stress | Caffeine-like compound with less tolerance build-up in small studies. Can raise heart rate.
Gotu kola | Nootropic | 500–1,000 mg extract | With food | D | cognition,skin | Rare liver injury reported.
Nicotinamide (vitamin B3) | Nootropic | 500 mg | With food | C | skin,longevity | Reduced new skin cancers in high-risk people (ONTRAC). Doses above 3 g/day can harm the liver.
"""

# Supplement names (existing in S) that also belong in the nootropics section.
NOOTROPIC_TAGS = {
    "Caffeine", "L-theanine", "Creatine monohydrate", "Rhodiola rosea", "Panax ginseng", "Lion's mane",
    "Bacopa monnieri", "Alpha-GPC", "Citicoline (CDP-choline)", "L-tyrosine", "Acetyl-L-carnitine",
    "Magnesium L-threonate", "Omega-3 (EPA + DHA)", "Saffron", "Cocoa flavanols", "Ketone esters", "MCT oil",
}

# Clinical entries (in RX) that also belong to other sections.
CLINICAL_TAGS = {
    "Modafinil": ["nootropics"],
    "Semaglutide": ["peptides"], "Tirzepatide": ["peptides"], "Liraglutide": ["peptides"], "Retatrutide": ["peptides"],
}

# Reference-only nootropics. Same columns as RX:
# name, class, status, uses, mechanism, evidence, risks, labs, goals
NOOTROPIC_REFERENCE = [
    ("Armodafinil", "Wakefulness-promoting agent", "Prescription, controlled (US Schedule IV); banned in sport (WADA)",
     "Narcolepsy, shift-work disorder, residual sleepiness in sleep apnoea",
     "The longer-acting R-isomer of modafinil; increases dopamine signalling.",
     "Similar to modafinil: improves wakefulness in sleep-deprived people; small effects in rested healthy people.",
     "Insomnia, headache, anxiety, rare serious skin reactions; reduces hormonal contraceptive effectiveness.", "None routine", "cognition"),
    ("Adrafinil", "Modafinil prodrug", "Not approved in the US; withdrawn in France; banned in sport (WADA)",
     "None approved", "Converted to modafinil in the liver.",
     "Little direct human research.", "Raised liver enzymes with regular use; same risks as modafinil.", "Liver enzymes (ALT, AST)", "cognition"),
    ("Methylphenidate", "Stimulant", "Prescription, controlled (US Schedule II); banned in competition (WADA)",
     "ADHD, narcolepsy", "Blocks dopamine and noradrenaline reuptake.",
     "Clear benefit in ADHD. In healthy people, effects are small and people tend to overestimate them.",
     "Raised heart rate and blood pressure, insomnia, appetite loss, dependence and misuse; dangerous with heart conditions.",
     "Blood pressure, heart rate, weight", "cognition"),
    ("Amphetamine salts", "Stimulant", "Prescription, controlled (US Schedule II); banned in competition (WADA)",
     "ADHD, narcolepsy", "Releases dopamine and noradrenaline.",
     "Clear benefit in ADHD; limited and mixed benefit for healthy people.",
     "Raised heart rate and blood pressure, insomnia, anxiety, psychosis at high doses, dependence; cardiac risk.",
     "Blood pressure, heart rate, weight", "cognition"),
    ("Piracetam", "Racetam", "Not approved in the US and cannot be sold as a supplement; prescription in parts of Europe",
     "Myoclonus and some cognitive conditions (Europe)", "Thought to modulate AMPA receptors and membrane fluidity; not fully understood.",
     "No convincing benefit in healthy adults. Mixed results in older people with cognitive impairment.",
     "Agitation, insomnia, increased bleeding with anticoagulants.", "None routine", "cognition"),
    ("Aniracetam", "Racetam", "Not approved in the US; FDA has warned sellers",
     "None approved in the US", "AMPA receptor modulator.", "Very limited human evidence.",
     "Anxiety, headache, insomnia. Product quality is unregulated.", "None routine", "cognition,stress"),
    ("Phenylpiracetam", "Racetam (stimulant)", "Prescription in Russia; not approved in the US; banned in competition (WADA)",
     "Asthenia (Russia)", "Racetam with stimulant properties.", "Mostly Russian-language studies; little independent data.",
     "Insomnia, irritability, raised blood pressure, tolerance.", "Blood pressure", "cognition,endurance"),
    ("Noopept", "Racetam-like peptide derivative", "Prescription/OTC in Russia; not approved in the US; FDA has warned sellers",
     "Cognitive impairment (Russia)", "Proposed to raise BDNF and NGF; acts on AMPA receptors.",
     "Small, mostly Russian-language trials.", "Headache, irritability, sleep problems. Unregulated product quality.", "None routine", "cognition"),
    ("Memantine", "NMDA receptor antagonist", "Prescription (US)", "Moderate-to-severe Alzheimer's disease",
     "Blocks excessive glutamate signalling.", "Modest benefit in Alzheimer's; no shown benefit in healthy people.",
     "Dizziness, headache, confusion.", "Kidney function", "cognition"),
    ("Nicotine (replacement therapy)", "Nicotinic receptor agonist", "Gum, lozenges and patches are OTC (US) for smoking cessation; on WADA's monitoring programme, not banned",
     "Stopping smoking", "Activates nicotinic acetylcholine receptors.",
     "Improves attention and fine motor speed in small studies, including non-smokers.",
     "Highly addictive; raises heart rate and blood pressure; nausea. Avoid in pregnancy and heart disease.", "Blood pressure", "cognition"),
    ("Vinpocetine", "Periwinkle alkaloid derivative", "Sold as a supplement in the US; FDA warns against use in pregnancy; prescription in some countries",
     "Cerebrovascular disorders (outside the US)", "PDE1 inhibitor that may increase brain blood flow.",
     "Weak, older trials.", "Miscarriage and fetal harm risk; low blood pressure; bleeding with anticoagulants.", "None routine", "cognition"),
    ("Phenibut", "GABA-B agonist", "Not approved in the US; FDA has warned against it; controlled in several countries",
     "Anxiety and insomnia (Russia)", "Acts like baclofen at GABA-B receptors.",
     "Little quality evidence.", "Rapid tolerance, dependence and severe withdrawal (seizures, psychosis); dangerous with alcohol or sedatives. Poison-centre calls have risen sharply.",
     "None routine", "stress,sleep"),
    ("Tianeptine", "Atypical antidepressant", "Not approved in the US; FDA has issued repeated warnings; prescription in some countries",
     "Depression (outside the US)", "Opioid-receptor agonist at higher exposure.",
     "Effective antidepressant at prescribed doses where approved.", "Opioid-like dependence, withdrawal, overdose and death have been reported with US gas-station products.",
     "None routine", "stress"),
]

# Peptides — REFERENCE ONLY. Columns:
# name, class, tier, status, sport, uses, mechanism, evidence, risks, labs, goals
# tier: "approved" (approved medicine somewhere) or "trial" (in clinical trials)
P = "Not approved for human use in the US. FDA has listed it among bulk substances that raise significant safety concerns for compounding (2023); check current FDA status."
S0 = "Prohibited at all times (WADA S0, non-approved substances)"
S2 = "Prohibited at all times (WADA S2, peptide hormones and growth factors)"
PEPTIDES = [
    ("Tesamorelin", "Growth hormone–releasing hormone (GHRH) analogue", "approved",
     "Prescription (US, FDA-approved as Egrifta)", S2, "Reducing excess abdominal fat in HIV-associated lipodystrophy",
     "Stimulates the pituitary to release growth hormone, raising IGF-1.",
     "Randomised trials show less visceral fat and liver fat in HIV. Not studied as a performance or anti-ageing drug.",
     "Joint pain, fluid retention, raised blood sugar, injection-site reactions; avoid with active cancer.", "IGF-1, glucose, HbA1c", "bodycomp,metabolic"),
    ("Sermorelin", "GHRH analogue (first 29 amino acids)", "approved",
     "Previously FDA-approved; brand discontinued in the US in 2008; sometimes compounded", S2, "Growth hormone deficiency in children (historical)",
     "Stimulates natural growth hormone release.", "Older paediatric data; little adult outcome data.",
     "Flushing, headache, injection-site reactions; long-term adult safety not established.", "IGF-1, glucose", "bodycomp,sleep"),
    ("Bremelanotide (PT-141)", "Melanocortin receptor agonist", "approved",
     "Prescription (US, FDA-approved as Vyleesi)", S0 + " outside approved medical use", "Low sexual desire in premenopausal women",
     "Activates melanocortin-4 receptors in the brain.", "Modest improvement in desire in phase 3 trials.",
     "Nausea (common), flushing, temporary rise in blood pressure, skin darkening.", "Blood pressure", "hormones"),
    ("Afamelanotide", "Alpha-MSH analogue", "approved",
     "Prescription implant (US/EU, approved as Scenesse)", S0 + " outside approved medical use", "Erythropoietic protoporphyria (light sensitivity)",
     "Activates melanocortin-1 receptors to increase skin melanin.", "Increased pain-free sun exposure in trials.",
     "Nausea, headache, darkening of moles; needs skin checks.", "Skin examinations", "skin"),
    ("Setmelanotide", "Melanocortin-4 receptor agonist", "approved",
     "Prescription (US, approved as Imcivree)", S0 + " outside approved medical use", "Obesity from specific rare genetic conditions",
     "Restores appetite signalling in MC4R pathway defects.", "Significant weight loss in those genetic conditions only.",
     "Skin darkening, nausea, depression and suicidal thoughts.", "Mood monitoring", "bodycomp"),
    ("Teriparatide / abaloparatide", "Parathyroid hormone analogues", "approved",
     "Prescription (US, Forteo / Tymlos)", S2, "Osteoporosis with high fracture risk",
     "Intermittent PTH signalling builds new bone.", "Large reductions in spine fractures.",
     "Dizziness, leg cramps, raised calcium. Usually limited to two years.", "Calcium, bone density", "joints"),
    ("Oxytocin", "Neuropeptide hormone", "approved",
     "Prescription (US) for labour induction; nasal use is off-label/experimental", S2, "Inducing labour, postpartum bleeding",
     "Acts on oxytocin receptors in the uterus and brain.", "Social-behaviour effects of nasal oxytocin are inconsistent and many early findings did not replicate.",
     "Low sodium, blood pressure changes.", "Sodium", "stress"),
    ("Thymosin alpha-1", "Thymic peptide", "approved",
     "Approved in some countries (Zadaxin) for hepatitis B and as an immune adjuvant; not approved in the US", S0, "Hepatitis B, immune support (outside the US)",
     "Enhances T-cell function.", "Mixed results; some trials in sepsis and hepatitis.",
     "Injection-site reactions; generally well tolerated in trials.", "Blood count, liver enzymes", "immunity"),
    ("Elamipretide (SS-31)", "Mitochondria-targeted peptide", "approved",
     "FDA accelerated approval (2025) for Barth syndrome only; otherwise investigational", S0 + " outside approved medical use", "Barth syndrome",
     "Binds cardiolipin in the inner mitochondrial membrane to stabilise energy production.",
     "Benefit in Barth syndrome; trials in mitochondrial myopathy and heart failure missed main endpoints.",
     "Injection-site reactions.", "Trial or specialist-managed", "longevity,endurance"),
    ("Cerebrolysin", "Porcine brain-derived peptide mixture", "approved",
     "Approved in parts of Europe and Asia; not approved in the US", S0, "Stroke and dementia (outside the US)",
     "Mixture of neurotrophic peptide fragments.", "Systematic reviews show little or no benefit after stroke.",
     "Dizziness, agitation, allergic reactions.", "Specialist-managed", "cognition"),
    ("Cagrilintide (with semaglutide: CagriSema)", "Amylin analogue", "trial",
     "Investigational — phase 3 trials", S0, "Obesity and type 2 diabetes (trials)",
     "Mimics amylin to increase fullness; combined with semaglutide.", "Phase 3 (REDEFINE): about 20–23% average weight loss.",
     "GI side effects similar to GLP-1 drugs; long-term safety still being studied.", "Trial-managed", "bodycomp,metabolic"),
    ("Kisspeptin", "Reproductive neuropeptide", "trial", "Research use in fertility trials; not approved", S2,
     "Fertility research; claimed for testosterone",
     "Stimulates GnRH, LH and FSH release.",
     "Human research studies in reproductive medicine show reliable LH release.",
     "Research-setting only; effects on long-term fertility unknown.", "LH, FSH, testosterone, estradiol", "hormones"),
]

PEPTIDE_GUIDE = [
    ("What counts as a peptide", "Chains of 2–50 amino acids. Insulin, GLP-1 drugs, oxytocin and parathyroid hormone analogues are peptides."),
    ("What's included", "Peptides approved as medicines somewhere, and peptides in registered clinical trials. Unapproved 'research peptides' are not included."),
    ("Research peptides", "Products labelled 'not for human consumption' have no approval, usually no controlled human data, and testing regularly finds wrong amounts, other substances and contamination. Almost all are banned in sport."),
    ("Talking to a clinician", "Approved peptides are prescribed, dosed and monitored by a clinician. Bring this page to an appointment to discuss options and which labs to track."),
]
