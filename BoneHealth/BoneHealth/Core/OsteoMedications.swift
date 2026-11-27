import Foundation

enum DoseFrequency: String, Codable, CaseIterable, Identifiable {
    case daily, weekly, monthly, every3Months, every6Months, yearly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Once a week"
        case .monthly: return "Once a month"
        case .every3Months: return "Every 3 months"
        case .every6Months: return "Every 6 months"
        case .yearly: return "Once a year"
        }
    }

    func nextDue(after last: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: last)
        let next: Date?
        switch self {
        case .daily: next = calendar.date(byAdding: .day, value: 1, to: start)
        case .weekly: next = calendar.date(byAdding: .day, value: 7, to: start)
        case .monthly: next = calendar.date(byAdding: .month, value: 1, to: start)
        case .every3Months: next = calendar.date(byAdding: .month, value: 3, to: start)
        case .every6Months: next = calendar.date(byAdding: .month, value: 6, to: start)
        case .yearly: next = calendar.date(byAdding: .year, value: 1, to: start)
        }
        return next ?? start
    }
}

enum DrugClass: String, CaseIterable, Identifiable {
    case oralBisphosphonate, ivBisphosphonate, rankLigandInhibitor, parathyroidHormoneAnalog, sclerostinInhibitor, serm, hormoneTherapy, calcitonin

    var id: String { rawValue }

    var name: String {
        switch self {
        case .oralBisphosphonate: return "Bisphosphonates (tablets)"
        case .ivBisphosphonate: return "Bisphosphonates (infusion or injection)"
        case .rankLigandInhibitor: return "RANK ligand inhibitor"
        case .parathyroidHormoneAnalog: return "Bone-building (anabolic) injections"
        case .sclerostinInhibitor: return "Sclerostin inhibitor (bone-building)"
        case .serm: return "Selective estrogen receptor modulator (SERM)"
        case .hormoneTherapy: return "Menopausal hormone therapy"
        case .calcitonin: return "Calcitonin"
        }
    }

    var howItWorks: String {
        switch self {
        case .oralBisphosphonate, .ivBisphosphonate:
            return "Slow down the cells that break down bone (osteoclasts), so bone is lost more slowly and density holds steady or rises. They stay in bone for years, which is why a planned break can sometimes be considered."
        case .rankLigandInhibitor:
            return "An antibody that blocks RANK ligand, a signal osteoclasts need to form and work. Its effect wears off within months, so doses must not be late."
        case .parathyroidHormoneAnalog:
            return "Daily injections that act like parathyroid hormone given in small pulses, which stimulates new bone formation. Used for people at very high fracture risk, usually for up to 2 years, followed by a medicine that keeps the new bone."
        case .sclerostinInhibitor:
            return "Blocks sclerostin, a protein that stops bone formation. It builds bone and also reduces breakdown. Given for 12 months, then followed by another medicine."
        case .serm:
            return "Acts like estrogen on bone (slowing bone loss) but blocks estrogen in breast and uterus tissue. For postmenopausal women."
        case .hormoneTherapy:
            return "Estrogen (with a progestogen if you have a uterus) slows bone loss. Mainly used to treat menopausal symptoms; it also helps prevent osteoporosis."
        case .calcitonin:
            return "A hormone that slightly slows bone breakdown. It has weaker effects than other options and is rarely a first choice."
        }
    }
}

enum DrugRoute: String {
    case tablet, infusion, injection, nasalSpray, various

    var label: String {
        switch self {
        case .tablet: return "Tablet by mouth"
        case .infusion: return "Intravenous (IV) infusion or injection at a clinic"
        case .injection: return "Injection under the skin"
        case .nasalSpray: return "Nasal spray"
        case .various: return "Tablets, patches, gels or sprays"
        }
    }
}

struct OsteoDrug: Identifiable, Hashable {
    let id: String
    let genericName: String
    let brandNames: [String]
    let drugClass: DrugClass
    let route: DrugRoute
    let frequencies: [DoseFrequency]
    let usualDose: String
    let howToTake: [String]
    let missedDose: String
    let commonSideEffects: [String]
    let callDoctorIf: [String]
    let notFor: [String]
    let boxedWarning: String?
    let howLong: String
    let afterStopping: String?
    /// Oral bisphosphonates: minutes to stay upright and take nothing but plain water.
    var emptyStomachMinutes: Int?
    /// Whole course is a fixed number of doses (romosozumab: 12).
    var maxDoses: Int?
    /// Cumulative months after which the label limits or asks for review (PTH analogs: 24).
    var reviewAfterMonths: Int?
    /// Days past due after which a late dose becomes urgent (denosumab).
    var urgentAfterDaysLate: Int?

    var defaultFrequency: DoseFrequency { frequencies[0] }
    var displayName: String { brandNames.isEmpty ? genericName : "\(genericName) (\(brandNames.joined(separator: ", ")))" }
    var isAntiresorptive: Bool { [.oralBisphosphonate, .ivBisphosphonate, .rankLigandInhibitor].contains(drugClass) }
}

/// Drafted from US prescribing information and the BHOF 2022 clinician's guide; needs clinical review before release.
enum OsteoDrugLibrary {
    static let contentVersion = "Draft 2026-11 — awaiting clinical review"

    private static let oralBisphosphonateRules = [
        "Take it first thing in the morning, before any food, drink or other medicines.",
        "Swallow the tablet whole with a full glass (6–8 oz) of plain water — not coffee, juice, mineral water or milk.",
        "Stay sitting upright or standing (don't lie down) for at least 30 minutes, and until you've eaten.",
        "Wait at least 30 minutes before eating, drinking anything other than water, or taking calcium, antacids, vitamins or other medicines.",
    ]

    private static let jawAndThigh = [
        "New or unusual pain in your thigh, hip or groin — rarely a sign of an unusual thigh bone fracture",
        "Jaw pain, swelling, a loose tooth, or exposed bone in your mouth — rarely osteonecrosis of the jaw. Tell your dentist you take this medicine.",
    ]

    static let all: [OsteoDrug] = [
        OsteoDrug(
            id: "alendronate", genericName: "Alendronate", brandNames: ["Fosamax", "Binosto"],
            drugClass: .oralBisphosphonate, route: .tablet, frequencies: [.weekly, .daily],
            usualDose: "70 mg once a week (or 10 mg daily). 35 mg weekly is used for prevention.",
            howToTake: oralBisphosphonateRules + ["Binosto is an effervescent tablet: dissolve it in 4 oz of plain room-temperature water, wait 5 minutes, stir, then drink and follow with another 2 oz of water."],
            missedDose: "Weekly: take it the morning after you remember, then go back to your usual day. Never take two tablets on the same day.",
            commonSideEffects: ["Heartburn or indigestion", "Stomach pain, nausea, constipation or diarrhea", "Bone, joint or muscle aches"],
            callDoctorIf: ["Trouble or pain when swallowing, chest pain, or new or worse heartburn — stop taking it and call your doctor", "Severe bone, joint or muscle pain"] + jawAndThigh,
            notFor: ["Problems with the esophagus that slow swallowing", "Being unable to sit or stand upright for 30 minutes", "Low blood calcium (correct it first)", "Severe kidney disease (creatinine clearance below 35 mL/min)"],
            boxedWarning: nil,
            howLong: "Often reviewed after 5 years. If your fracture risk is lower, your doctor may suggest a break (a \"drug holiday\"); if it's still high, you may continue or switch.",
            afterStopping: "Bisphosphonates stay in bone, so protection fades slowly over 1–2 years. Your doctor will usually re-check your risk and DEXA during a break.",
            emptyStomachMinutes: 30),
        OsteoDrug(
            id: "risedronate", genericName: "Risedronate", brandNames: ["Actonel", "Atelvia"],
            drugClass: .oralBisphosphonate, route: .tablet, frequencies: [.weekly, .monthly, .daily],
            usualDose: "35 mg once a week, 150 mg once a month, or 5 mg daily.",
            howToTake: oralBisphosphonateRules + ["Atelvia (delayed-release) is different: take it right after breakfast with at least 4 oz of plain water, and stay upright for 30 minutes."],
            missedDose: "Weekly: take it the morning after you remember. Monthly: if your next dose is more than 7 days away, take it the morning after you remember; if it's within 7 days, skip it and wait. Never take two in the same week.",
            commonSideEffects: ["Heartburn, indigestion or stomach pain", "Diarrhea or constipation", "Back, joint or muscle pain"],
            callDoctorIf: ["Trouble or pain when swallowing, chest pain, or new or worse heartburn", "Severe bone, joint or muscle pain"] + jawAndThigh,
            notFor: ["Problems with the esophagus that slow swallowing", "Being unable to sit or stand upright for 30 minutes", "Low blood calcium", "Severe kidney disease (creatinine clearance below 30 mL/min)"],
            boxedWarning: nil,
            howLong: "Often reviewed after 5 years, when your doctor may consider a break if your risk has fallen.",
            afterStopping: "Protection fades slowly over 1–2 years after stopping.",
            emptyStomachMinutes: 30),
        OsteoDrug(
            id: "ibandronate-oral", genericName: "Ibandronate tablets", brandNames: ["Boniva"],
            drugClass: .oralBisphosphonate, route: .tablet, frequencies: [.monthly],
            usualDose: "150 mg once a month, on the same date each month.",
            howToTake: [
                "Take it first thing in the morning with a full glass (6–8 oz) of plain water.",
                "Stay sitting upright or standing for at least 60 minutes.",
                "Wait at least 60 minutes before eating, drinking anything other than water, or taking calcium, antacids, vitamins or other medicines.",
            ],
            missedDose: "If your next dose is more than 7 days away, take it the morning after you remember. If it's 1–7 days away, skip it and take the next one as planned.",
            commonSideEffects: ["Heartburn, indigestion or diarrhea", "Back pain or pain in arms and legs", "Flu-like symptoms after a dose"],
            callDoctorIf: ["Trouble or pain when swallowing, chest pain, or new or worse heartburn", "Severe bone, joint or muscle pain"] + jawAndThigh,
            notFor: ["Problems with the esophagus", "Being unable to sit or stand upright for 60 minutes", "Low blood calcium", "Severe kidney disease (creatinine clearance below 30 mL/min)"],
            boxedWarning: nil,
            howLong: "Often reviewed after 5 years.",
            afterStopping: "Protection fades slowly after stopping.",
            emptyStomachMinutes: 60),
        OsteoDrug(
            id: "ibandronate-iv", genericName: "Ibandronate injection", brandNames: ["Boniva injection"],
            drugClass: .ivBisphosphonate, route: .infusion, frequencies: [.every3Months],
            usualDose: "3 mg given into a vein by a health professional every 3 months.",
            howToTake: ["Given at a clinic over 15–30 seconds.", "Your kidney function is checked before each dose.", "Keep taking calcium and vitamin D as advised."],
            missedDose: "Have it as soon as you can, then every 3 months from that date.",
            commonSideEffects: ["Flu-like symptoms for a few days after the dose", "Muscle, joint or back pain", "Pain at the injection site"],
            callDoctorIf: ["Severe bone, joint or muscle pain"] + jawAndThigh,
            notFor: ["Low blood calcium", "Severe kidney disease (creatinine above 2.3 mg/dL)"],
            boxedWarning: nil,
            howLong: "Usually reviewed after several years of treatment.",
            afterStopping: "Protection fades slowly after stopping."),
        OsteoDrug(
            id: "zoledronic-acid", genericName: "Zoledronic acid", brandNames: ["Reclast"],
            drugClass: .ivBisphosphonate, route: .infusion, frequencies: [.yearly],
            usualDose: "5 mg infusion into a vein over at least 15 minutes, once a year (every 2 years is used for prevention).",
            howToTake: [
                "Drink at least 2 glasses of fluid (such as water) in the few hours before the infusion.",
                "Your kidney function is checked before each dose, and low calcium or vitamin D must be corrected first.",
                "Eating beforehand is fine.",
                "Flu-like symptoms (fever, aches, tiredness) are common for 1–3 days after the first dose. Acetaminophen can help — ask your care team.",
            ],
            missedDose: "Book the infusion as soon as you can, then yearly from that date.",
            commonSideEffects: ["Flu-like symptoms, fever, headache, muscle or joint pain for 1–3 days after the infusion (mainly the first)", "Nausea or tiredness"],
            callDoctorIf: ["Little or no urine, or swelling — possible kidney problems", "Muscle spasms, twitching, or numbness or tingling around the mouth or in fingers — possible low calcium", "Severe bone, joint or muscle pain", "Eye pain, redness or vision changes"] + jawAndThigh,
            notFor: ["Low blood calcium", "Severe kidney disease (creatinine clearance below 35 mL/min)", "Pregnancy or breastfeeding"],
            boxedWarning: nil,
            howLong: "Often reviewed after 3 yearly infusions (6 if your risk is still high).",
            afterStopping: "Zoledronic acid stays in bone for years, so protection fades slowly."),
        OsteoDrug(
            id: "denosumab", genericName: "Denosumab", brandNames: ["Prolia", "biosimilars such as Jubbonti"],
            drugClass: .rankLigandInhibitor, route: .injection, frequencies: [.every6Months],
            usualDose: "60 mg injection under the skin every 6 months.",
            howToTake: [
                "Given by a health professional (or at home if trained) in the upper arm, thigh or belly every 6 months.",
                "Don't be late: book your next injection for 6 months after your last one.",
                "Take calcium and vitamin D every day as your doctor advises — denosumab can lower blood calcium.",
                "Tell your dentist you take denosumab and keep up regular dental care.",
            ],
            missedDose: "Have it as soon as you can, then every 6 months from that date. Delays of more than a month raise the risk of spine fractures.",
            commonSideEffects: ["Back pain, pain in arms and legs, muscle or joint pain", "High cholesterol", "Bladder infections"],
            callDoctorIf: [
                "Muscle spasms, twitching or cramps, or numbness or tingling in fingers, toes or around the mouth — possible low calcium",
                "Red, swollen, hot or tender skin, fever, or a skin infection",
                "Severe rash, itching or skin peeling",
            ] + jawAndThigh,
            notFor: ["Low blood calcium (correct it first)", "Pregnancy"],
            boxedWarning: "Severe low blood calcium in people with advanced chronic kidney disease, including those on dialysis. Your doctor should check your kidney function and calcium before starting and monitor closely if you have advanced kidney disease.",
            howLong: "Can be continued long term. Unlike bisphosphonates, denosumab should not be stopped without a plan.",
            afterStopping: "Stopping or delaying denosumab causes rapid bone loss and a higher risk of several spine fractures at once. If you stop, your doctor will usually start a bisphosphonate (often zoledronic acid) to protect your bones.",
            urgentAfterDaysLate: 30),
        OsteoDrug(
            id: "teriparatide", genericName: "Teriparatide", brandNames: ["Forteo", "Bonsity", "generic"],
            drugClass: .parathyroidHormoneAnalog, route: .injection, frequencies: [.daily],
            usualDose: "20 mcg injected under the skin of the thigh or belly once a day.",
            howToTake: [
                "Inject at about the same time each day. Rotate between the thigh and belly.",
                "Sit or lie down for your first few doses in case you feel dizzy or light-headed.",
                "Keep the pen in the fridge (not the freezer). Each pen lasts 28 days once started — write the date on it.",
                "Don't share pens or needles.",
            ],
            missedDose: "Take it later that day if you remember. Don't take more than one injection in a day.",
            commonSideEffects: ["Dizziness or a fast heartbeat soon after the injection", "Leg cramps", "Nausea, joint pain", "Redness or swelling at the injection site"],
            callDoctorIf: ["Nausea, vomiting, constipation, low energy or muscle weakness — possible high calcium", "Bone pain that is new or unusual", "Fainting"],
            notFor: ["Paget's disease of bone or unexplained high alkaline phosphatase", "Children or young adults whose bones are still growing", "Previous radiation therapy to the bones", "Bone cancer or cancer that has spread to bone", "High blood calcium"],
            boxedWarning: nil,
            howLong: "Usually up to 2 years in a lifetime. Longer use is only for people who stay at or return to high fracture risk, as decided with your doctor.",
            afterStopping: "Start a bisphosphonate or denosumab right after finishing, or most of the new bone is lost.",
            reviewAfterMonths: 24),
        OsteoDrug(
            id: "abaloparatide", genericName: "Abaloparatide", brandNames: ["Tymlos"],
            drugClass: .parathyroidHormoneAnalog, route: .injection, frequencies: [.daily],
            usualDose: "80 mcg injected under the skin of the lower belly once a day.",
            howToTake: [
                "Inject at about the same time each day, rotating sites around the belly.",
                "Sit or lie down for your first few doses in case you feel dizzy.",
                "Before first use, keep the pen in the fridge. After first use, keep it at room temperature for up to 30 days.",
            ],
            missedDose: "Take it later that day if you remember. Don't take two doses in a day.",
            commonSideEffects: ["Dizziness or fast heartbeat after the injection", "Nausea, headache, tiredness", "Redness or swelling at the injection site"],
            callDoctorIf: ["Nausea, vomiting, constipation, low energy or muscle weakness — possible high calcium", "Kidney stone symptoms: severe side or lower back pain, blood in urine", "Fainting"],
            notFor: ["Paget's disease of bone", "Bones still growing", "Previous radiation therapy to the bones", "Bone cancer or cancer that has spread to bone", "High blood calcium"],
            boxedWarning: nil,
            howLong: "Use for more than 2 years in a lifetime is not recommended.",
            afterStopping: "Start a bisphosphonate or denosumab right after finishing, or most of the new bone is lost.",
            reviewAfterMonths: 24),
        OsteoDrug(
            id: "romosozumab", genericName: "Romosozumab", brandNames: ["Evenity"],
            drugClass: .sclerostinInhibitor, route: .injection, frequencies: [.monthly],
            usualDose: "210 mg (two injections, one after the other) under the skin once a month for 12 months.",
            howToTake: ["Given by a health professional once a month for 12 doses.", "Take calcium and vitamin D as advised."],
            missedDose: "Have it as soon as you can, then monthly from that date.",
            commonSideEffects: ["Joint pain", "Headache", "Injection site reactions"],
            callDoctorIf: [
                "Chest pain or pressure, shortness of breath, sudden numbness or weakness, trouble speaking, or a severe headache — call 911",
                "Muscle cramps or tingling — possible low calcium",
            ] + jawAndThigh,
            notFor: ["A heart attack or stroke in the past year", "Low blood calcium"],
            boxedWarning: "May increase the risk of heart attack, stroke and death from heart disease. It should not be started in people who had a heart attack or stroke in the past year, and is stopped if one happens.",
            howLong: "12 monthly doses only.",
            afterStopping: "Start a bisphosphonate or denosumab afterwards to keep the bone gained.",
            maxDoses: 12),
        OsteoDrug(
            id: "raloxifene", genericName: "Raloxifene", brandNames: ["Evista"],
            drugClass: .serm, route: .tablet, frequencies: [.daily],
            usualDose: "60 mg tablet once a day, any time, with or without food.",
            howToTake: [
                "Take it at the same time each day, with or without food.",
                "Stop it at least 3 days before surgery or a long period of being immobile (such as a long flight or bed rest) — ask your doctor.",
                "Move around regularly on long trips.",
            ],
            missedDose: "Take it when you remember that day. Don't take two in one day.",
            commonSideEffects: ["Hot flashes", "Leg cramps", "Swelling of hands, ankles or feet", "Flu-like symptoms, joint pain, sweating"],
            callDoctorIf: [
                "Pain, swelling or warmth in a leg — possible blood clot",
                "Sudden chest pain, shortness of breath or coughing up blood — call 911",
                "Sudden numbness, weakness, confusion or trouble speaking — call 911",
            ],
            notFor: ["A history of blood clots in the legs, lungs or eyes", "Pregnancy or anyone who could become pregnant", "Premenopausal women"],
            boxedWarning: "Increased risk of blood clots in the legs and lungs, and of death from stroke in postmenopausal women with heart disease or at high risk of it.",
            howLong: "Can be taken long term. It also lowers the risk of invasive breast cancer, but doesn't reduce hip fractures.",
            afterStopping: "Its bone benefit wears off within about a year of stopping."),
        OsteoDrug(
            id: "hormone-therapy", genericName: "Estrogen hormone therapy", brandNames: ["many brands"],
            drugClass: .hormoneTherapy, route: .various, frequencies: [.daily, .weekly],
            usualDose: "Varies by product — tablets daily, or patches changed once or twice a week.",
            howToTake: ["Use it exactly as prescribed.", "If you have a uterus, you'll need a progestogen too, to protect the womb lining.", "Have regular check-ups and breast screening."],
            missedDose: "Follow the instructions for your product.",
            commonSideEffects: ["Breast tenderness", "Spotting or bleeding", "Headache, nausea, bloating"],
            callDoctorIf: ["Unusual vaginal bleeding", "A breast lump", "Leg pain or swelling, chest pain or shortness of breath", "Sudden severe headache, vision changes, or weakness — call 911"],
            notFor: ["Unexplained vaginal bleeding", "Breast cancer or some other cancers", "Previous blood clots, stroke or heart attack", "Liver disease"],
            boxedWarning: "Estrogen alone raises the risk of endometrial cancer in women with a uterus. Estrogen, with or without a progestin, has been linked to higher risks of stroke, blood clots, dementia and, with a progestin, breast cancer and heart attack. Use the lowest effective dose for the shortest time that meets your goals.",
            howLong: "Mainly used for menopausal symptoms; your doctor will review it regularly.",
            afterStopping: "Bone loss resumes after stopping, so your doctor may suggest another bone medicine."),
        OsteoDrug(
            id: "calcitonin", genericName: "Calcitonin salmon", brandNames: ["Miacalcin"],
            drugClass: .calcitonin, route: .nasalSpray, frequencies: [.daily],
            usualDose: "One spray (200 units) in one nostril daily, alternating nostrils each day.",
            howToTake: ["Prime a new bottle before first use.", "Alternate nostrils each day.", "Keep unopened bottles in the fridge; the open bottle can stay at room temperature for up to 35 days."],
            missedDose: "Use it when you remember that day. Don't use two sprays in one day.",
            commonSideEffects: ["Runny nose, nosebleeds, nasal irritation", "Back pain, headache"],
            callDoctorIf: ["Signs of an allergic reaction: swelling of the face or throat, trouble breathing — call 911", "Muscle cramps or tingling — possible low calcium"],
            notFor: ["Allergy to calcitonin salmon"],
            boxedWarning: nil,
            howLong: "A small increase in cancer risk was seen with long-term use, so it is used for the shortest time needed.",
            afterStopping: nil),
    ]

    static func drug(_ id: String) -> OsteoDrug? { all.first { $0.id == id } }

    struct Group: Identifiable {
        let drugClass: DrugClass
        let drugs: [OsteoDrug]
        var id: String { drugClass.rawValue }
    }

    static var byClass: [Group] {
        DrugClass.allCases.compactMap { c in
            let drugs = all.filter { $0.drugClass == c }
            return drugs.isEmpty ? nil : Group(drugClass: c, drugs: drugs)
        }
    }
}

struct ScheduleStatus: Hashable {
    enum State: Int, Comparable {
        case completed, upToDate, dueSoon, dueToday, overdue, urgent
        static func < (a: State, b: State) -> Bool { a.rawValue < b.rawValue }
    }

    let state: State
    let nextDue: Date?
    let message: String
}

enum MedicationSchedule {
    static func status(drug: OsteoDrug, frequency: DoseFrequency, startedOn: Date, doses: [Date],
                       now: Date = Date(), calendar: Calendar = .current) -> ScheduleStatus {
        if let max = drug.maxDoses, doses.count >= max {
            return ScheduleStatus(state: .completed, nextDue: nil,
                message: "You've had all \(max) doses. Ask your doctor about the medicine to start next, to keep the bone you've gained.")
        }
        let last = doses.max()
        let due = last.map { frequency.nextDue(after: $0, calendar: calendar) } ?? calendar.startOfDay(for: startedOn)
        let days = calendar.daysBetween(now, due)
        let dueText = due.formatted(date: .abbreviated, time: .omitted)

        if days > 0 {
            let soon = frequency == .daily ? false : days <= 7
            let when = days == 1 ? "tomorrow" : "on \(dueText)"
            return ScheduleStatus(state: soon ? .dueSoon : .upToDate, nextDue: due, message: "Next dose \(when).")
        }
        if days == 0 {
            return ScheduleStatus(state: .dueToday, nextDue: due, message: "Due today.")
        }
        let late = -days
        if let urgent = drug.urgentAfterDaysLate, late > urgent {
            return ScheduleStatus(state: .urgent, nextDue: due,
                message: "\(late) days late (due \(dueText)). Call your doctor's office now to book it — a late \(drug.genericName.lowercased()) dose raises the risk of spine fractures.")
        }
        if frequency == .daily {
            return ScheduleStatus(state: .overdue, nextDue: calendar.startOfDay(for: now),
                message: "\(late) day\(late == 1 ? "" : "s") missed. Take today's dose as usual — don't double up.")
        }
        return ScheduleStatus(state: .overdue, nextDue: due, message: "Overdue since \(dueText). \(drug.missedDose)")
    }

    /// Reminders about how long the person has been on the medicine.
    static func durationNotes(drug: OsteoDrug, startedOn: Date, now: Date = Date(), calendar: Calendar = .current) -> [SafetyWarning] {
        let months = calendar.monthsBetween(startedOn, now)
        var result: [SafetyWarning] = []
        switch drug.drugClass {
        case .oralBisphosphonate where months >= 60:
            result.append(SafetyWarning(id: "\(drug.id)-review", severity: .info,
                message: "You've been on \(drug.genericName.lowercased()) for \(months / 12) years. Ask your doctor whether to continue, switch, or take a planned break."))
        case .ivBisphosphonate where months >= 36:
            result.append(SafetyWarning(id: "\(drug.id)-review", severity: .info,
                message: "You've had about \(months / 12) years of \(drug.genericName.lowercased()). Ask your doctor whether to continue or take a planned break."))
        default: break
        }
        if let limit = drug.reviewAfterMonths {
            if months >= limit {
                result.append(SafetyWarning(id: "\(drug.id)-limit", severity: .caution,
                    message: "You've used \(drug.genericName.lowercased()) for about \(months) months. Use beyond \(limit / 12) years needs your doctor's review. Plan the medicine you'll take next so you don't lose the new bone."))
            } else if months >= limit - 3 {
                result.append(SafetyWarning(id: "\(drug.id)-limit-soon", severity: .info,
                    message: "You're close to \(limit / 12) years of \(drug.genericName.lowercased()). Ask your doctor about the plan for what comes next."))
            }
        }
        return result
    }
}
