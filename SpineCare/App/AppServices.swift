import Foundation
import HealthKit
import LocalAuthentication
import UserNotifications
import Observation

enum AppText {
    static let disclaimer = """
    Stroke & Spine helps you track your back pain and understand your care. It does not diagnose conditions or replace advice from your doctor, physical therapist or pharmacist.

    It is not for emergencies. If you think you have a medical emergency, call 911.

    Medicine limits shown in the app come from standard US over-the-counter labels or the limits you enter. Always follow your product label and your doctor's advice.
    """

    static let privacy = """
    Your information is stored only on this iPhone. Stroke & Spine has no account, no ads, and does not sell or share your data. You can export or delete everything at any time in More → Your data.
    """
}

/// Public web pages. Upload docs/site/*.html to your website, then set these URLs.
enum AppLinks {
    // TODO: replace example.com with your website before submitting to the App Store.
    static let privacy = URL(string: "https://example.com/privacy")!
    static let terms = URL(string: "https://example.com/terms")!
    static let support = URL(string: "https://example.com/support")!
    static let appleEULA = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}

/// Sources behind the app's health content (App Review Guideline 1.4.1).
enum Sources {
    static let all: [String] = [
        "Qaseem A, Wilt TJ, McLean RM, Forciea MA. Noninvasive treatments for acute, subacute, and chronic low back pain: a clinical practice guideline from the American College of Physicians. Ann Intern Med. 2017;166(7):514–530.",
        "National Institute for Health and Care Excellence (NICE). Low back pain and sciatica in over 16s: assessment and management (NG59). 2016, updated 2020.",
        "Finucane LM, et al. International framework for red flags for potential serious spinal pathologies. J Orthop Sports Phys Ther. 2020;50(7):350–372.",
        "Fairbank JC, Pynsent PB. The Oswestry Disability Index. Spine. 2000;25(22):2940–2952.",
        "Kroenke K, Spitzer RL, Williams JB. The PHQ-9: validity of a brief depression severity measure. J Gen Intern Med. 2001;16(9):606–613.",
        "Spitzer RL, Kroenke K, Williams JBW, Löwe B. A brief measure for assessing generalized anxiety disorder: the GAD-7. Arch Intern Med. 2006;166(10):1092–1097.",
        "Bastien CH, Vallières A, Morin CM. Validation of the Insomnia Severity Index as an outcome measure for insomnia research. Sleep Med. 2001;2(4):297–307.",
        "Ostelo RW, et al. Interpreting change scores for pain and functional status in low back pain: towards international consensus regarding minimal important change. Spine. 2008;33(1):90–94.",
        "Brinjikji W, et al. Systematic literature review of imaging features of spinal degeneration in asymptomatic populations. AJNR Am J Neuroradiol. 2015;36(4):811–816.",
        "French SD, et al. Superficial heat or cold for low back pain. Cochrane Database Syst Rev. 2006;(1):CD004750.",
        "US Food and Drug Administration. Over-the-counter Drug Facts labels for acetaminophen, ibuprofen, naproxen sodium and aspirin; and FDA Drug Safety Communication on NSAID use at 20 weeks of pregnancy or later (2020).",
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
            return try await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                    localizedReason: "Unlock your health information")
        } catch {
            return false
        }
    }
}

// MARK: - Reminders

enum Reminders {
    static let checkInID = "daily-check-in"

    static func schedule(hour: Int) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        guard granted else { return false }
        center.removePendingNotificationRequests(withIdentifiers: [checkInID])

        let content = UNMutableNotificationContent()
        content.title = "Daily check-in"
        content.body = "How's your back today? It takes less than 30 seconds."
        var components = DateComponents()
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try? await center.add(UNNotificationRequest(identifier: checkInID, content: content, trigger: trigger))
        return true
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkInID])
    }
}

// MARK: - HealthKit (read-only: steps and sleep)

@Observable
final class HealthData {
    static let shared = HealthData()

    var stepsToday: Double?
    var sleepLastNightHours: Double?
    var hasRequested = UserDefaults.standard.bool(forKey: "healthkit.requested")

    @ObservationIgnored private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    @MainActor
    func requestAccess() async {
        guard isAvailable else { return }
        let types: Set<HKObjectType> = [HKQuantityType(.stepCount), HKCategoryType(.sleepAnalysis)]
        try? await store.requestAuthorization(toShare: [], read: types)
        hasRequested = true
        UserDefaults.standard.set(true, forKey: "healthkit.requested")
        await refresh()
    }

    @MainActor
    func refresh() async {
        guard isAvailable, hasRequested else { return }
        stepsToday = await steps(on: Date())
        sleepLastNightHours = await sleepHours(endingOn: Date())
    }

    func steps(on day: Date) async -> Double? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: predicate),
            options: .cumulativeSum)
        let result = try? await descriptor.result(for: store)
        return result?.sumQuantity()?.doubleValue(for: .count())
    }

    /// Time asleep between 6 pm the previous evening and noon on `day`.
    /// Overlapping samples (e.g. iPhone + Apple Watch) are merged so time isn't counted twice.
    func sleepHours(endingOn day: Date) async -> Double? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        guard let windowStart = calendar.date(byAdding: .hour, value: -6, to: startOfDay),
              let windowEnd = calendar.date(byAdding: .hour, value: 12, to: startOfDay) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: windowStart, end: windowEnd)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis), predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)])
        guard let samples = try? await descriptor.result(for: store) else { return nil }

        let asleepValues = HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue)
        let intervals = samples
            .filter { asleepValues.contains($0.value) }
            .map { (start: max($0.startDate, windowStart), end: min($0.endDate, windowEnd)) }
            .sorted { $0.start < $1.start }
        guard !intervals.isEmpty else { return nil }

        var total: TimeInterval = 0
        var current = intervals[0]
        for next in intervals.dropFirst() {
            if next.start <= current.end {
                current.end = max(current.end, next.end)
            } else {
                total += current.end.timeIntervalSince(current.start)
                current = next
            }
        }
        total += current.end.timeIntervalSince(current.start)
        return total / 3600
    }
}
