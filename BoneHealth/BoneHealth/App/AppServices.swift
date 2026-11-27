import Foundation
import LocalAuthentication
import UserNotifications

enum AppText {
    static let appName = "Bone Health"

    static let disclaimer = """
    Bone Health helps you keep track of your bone health and understand your care. It does not diagnose conditions, calculate your fracture risk, or replace advice from your doctor, pharmacist or physical therapist.

    It is not for emergencies. If you think you have a medical emergency, call 911.

    Medicine information is a summary of US prescribing information. Always follow your prescriber's instructions and the leaflet that comes with your medicine.
    """

    static let privacy = """
    Your information is stored only on this iPhone. Bone Health has no account and no ads, and does not sell or share your data. You can export or delete everything at any time in More → Privacy and data.
    """
}

/// Public web pages. TODO: replace example.com before submitting to the App Store.
enum AppLinks {
    static let privacy = URL(string: "https://example.com/bone-health/privacy")!
    static let terms = URL(string: "https://example.com/bone-health/terms")!
    static let support = URL(string: "https://example.com/bone-health/support")!
}

/// Sources behind the app's health content (App Review Guideline 1.4.1).
enum Sources {
    static let all: [String] = [
        "LeBoff MS, Greenspan SL, Insogna KL, et al. The clinician's guide to prevention and treatment of osteoporosis. Osteoporos Int. 2022;33(10):2049–2102. (Bone Health & Osteoporosis Foundation)",
        "Camacho PM, Petak SM, Binkley N, et al. AACE/ACE clinical practice guidelines for the diagnosis and treatment of postmenopausal osteoporosis — 2020 update. Endocr Pract. 2020;26(Suppl 1):1–46.",
        "Shoback D, Rosen CJ, Black DM, et al. Pharmacological management of osteoporosis in postmenopausal women: an Endocrine Society guideline update. J Clin Endocrinol Metab. 2020;105(3):587–594.",
        "International Society for Clinical Densitometry (ISCD). 2023 Official Positions — Adult.",
        "World Health Organization. Assessment of fracture risk and its application to screening for postmenopausal osteoporosis. WHO Technical Report Series 843. 1994.",
        "Tsourdi E, et al. Discontinuation of denosumab therapy for osteoporosis: a systematic review and position statement by ECTS. Bone. 2017;105:11–17.",
        "US FDA prescribing information for alendronate, risedronate, ibandronate, zoledronic acid, denosumab (including the 2024 boxed warning on severe hypocalcemia in advanced CKD), teriparatide, abaloparatide, romosozumab, raloxifene, estrogens and calcitonin salmon.",
        "National Institutes of Health, Office of Dietary Supplements. Calcium, Vitamin D and Magnesium fact sheets for health professionals.",
        "Institute of Medicine. Dietary Reference Intakes for Calcium and Vitamin D. National Academies Press; 2011.",
        "Giangregorio LM, Papaioannou A, MacIntyre NJ, et al. Too Fit To Fracture: exercise recommendations for individuals with osteoporosis or osteoporotic vertebral fracture. Osteoporos Int. 2014;25(3):821–835.",
        "Sinaki M, et al. Stronger back muscles reduce the incidence of vertebral fractures: a prospective 10 year follow-up of postmenopausal women. Bone. 2002;30(6):836–841.",
        "Centers for Disease Control and Prevention. STEADI — Stopping Elderly Accidents, Deaths & Injuries: Stay Independent brochure and Check for Safety home checklist.",
        "Rubenstein LZ, Vivrette R, Harker JO, Stevens JA, Kramer BJ. Validating an evidence-based, self-rated fall risk questionnaire (FRQ) for older adults. J Safety Res. 2011;42(6):493–499.",
        "Montero-Odasso M, et al. World guidelines for falls prevention and management for older adults. Age Ageing. 2022;51(9):afac205.",
        "Krebs EE, Lorenz KA, Bair MJ, et al. Development and initial validation of the PEG, a three-item scale assessing pain intensity and interference. J Gen Intern Med. 2009;24(6):733–738.",
        "Whelton PK, Carey RM, et al. 2017 ACC/AHA guideline for the prevention, detection, evaluation, and management of high blood pressure in adults. Hypertension. 2018;71(6):e13–e115.",
    ]
}

// MARK: - App lock

enum AppLock {
    /// Face ID / Touch ID with passcode fallback. Returns true if the device has no passcode set.
    static func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return true }
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your health information")
        } catch {
            return false
        }
    }
}

// MARK: - Reminders

enum Reminders {
    static let supplementID = "daily-supplements"

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleSupplements(hour: Int) async -> Bool {
        guard await requestPermission() else { return false }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [supplementID])
        let content = UNMutableNotificationContent()
        content.title = "Calcium and vitamin D"
        content.body = "Time for your supplements. Log them so you can see how close you are to your daily target."
        var components = DateComponents()
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try? await center.add(UNNotificationRequest(identifier: supplementID, content: content, trigger: trigger))
        return true
    }

    static func cancelSupplements() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [supplementID])
    }

    static func medicationID(_ drugID: String) -> String { "medication-\(drugID)" }

    /// Daily medicines repeat at 8 am. Others get a one-off reminder at 9 am on the due date
    /// (and, for long intervals, a heads-up 2 weeks before so there's time to book an appointment).
    static func scheduleMedication(drug: OsteoDrug, frequency: DoseFrequency, nextDue: Date?) async -> Bool {
        guard await requestPermission() else { return false }
        let center = UNUserNotificationCenter.current()
        let base = medicationID(drug.id)
        center.removePendingNotificationRequests(withIdentifiers: [base, base + "-early"])
        let calendar = Calendar.current

        let content = UNMutableNotificationContent()
        content.title = "\(drug.genericName) is due"
        content.body = drug.emptyStomachMinutes != nil
            ? "Take it with a full glass of plain water and stay upright for \(drug.emptyStomachMinutes ?? 30) minutes."
            : "Log it in Bone Health when you've had it."

        if frequency == .daily {
            var components = DateComponents()
            components.hour = 8
            try? await center.add(UNNotificationRequest(identifier: base, content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)))
            return true
        }

        guard let nextDue else { return true }
        var components = calendar.dateComponents([.year, .month, .day], from: nextDue)
        components.hour = 9
        if let fire = calendar.date(from: components), fire > Date() {
            try? await center.add(UNNotificationRequest(identifier: base, content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)))
        }
        if [.every3Months, .every6Months, .yearly].contains(frequency),
           let early = calendar.date(byAdding: .day, value: -14, to: nextDue), early > Date() {
            let earlyContent = UNMutableNotificationContent()
            earlyContent.title = "Book your \(drug.genericName.lowercased()) appointment"
            earlyContent.body = "Your next dose is due on \(nextDue.formatted(date: .abbreviated, time: .omitted))."
            var earlyComponents = calendar.dateComponents([.year, .month, .day], from: early)
            earlyComponents.hour = 9
            try? await center.add(UNNotificationRequest(identifier: base + "-early", content: earlyContent,
                trigger: UNCalendarNotificationTrigger(dateMatching: earlyComponents, repeats: false)))
        }
        return true
    }

    static func cancelMedication(drugID: String) {
        let base = medicationID(drugID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [base, base + "-early"])
    }
}
