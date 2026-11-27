import Foundation
import HealthKit
import UserNotifications
import Observation

/// Reads recovery and body data that wearables (Oura, WHOOP, Garmin, Apple Watch…) write to Apple Health.
@Observable
final class HealthService {
    struct Metric: Identifiable { let id: String; let label: String; let value: String }
    private let store = HKHealthStore()
    var metrics: [Metric] = []
    var authorized = false

    private let types: [(HKQuantityTypeIdentifier, String, HKUnit, String)] = [
        (.heartRateVariabilitySDNN, "HRV", .secondUnit(with: .milli), "ms"),
        (.restingHeartRate, "Resting HR", .count().unitDivided(by: .minute()), "bpm"),
        (.vo2Max, "VO2 max", HKUnit(from: "ml/kg*min"), ""),
        (.bodyMass, "Weight", .gramUnit(with: .kilo), "kg"),
        (.bodyFatPercentage, "Body fat", .percent(), "%"),
        (.bloodGlucose, "Glucose", HKUnit(from: "mg/dL"), "mg/dL"),
    ]

    func connect() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        var read = Set<HKObjectType>(types.compactMap { HKQuantityType.quantityType(forIdentifier: $0.0) })
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { read.insert(sleep) }
        do {
            try await store.requestAuthorization(toShare: [], read: read)
            authorized = true
            await refresh()
        } catch { authorized = false }
    }

    func refresh() async {
        var out: [Metric] = []
        for (id, label, unit, suffix) in types {
            guard let type = HKQuantityType.quantityType(forIdentifier: id),
                  let sample = await latest(type) else { continue }
            var v = sample.quantity.doubleValue(for: unit)
            if id == .bodyFatPercentage { v *= 100 }
            out.append(Metric(id: label, label: label, value: String(format: v < 20 ? "%.1f" : "%.0f", v) + (suffix.isEmpty ? "" : " \(suffix)")))
        }
        if let hours = await sleepLastNight() { out.insert(Metric(id: "sleep", label: "Sleep", value: String(format: "%.1f h", hours)), at: 0) }
        await MainActor.run { metrics = out }
    }

    private func latest(_ type: HKQuantityType) async -> HKQuantitySample? {
        await withCheckedContinuation { cont in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, s, _ in
                cont.resume(returning: s?.first as? HKQuantitySample)
            }
            store.execute(q)
        }
    }

    private func sleepLastNight() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let start = Calendar.current.date(byAdding: .hour, value: -20, to: .now)!
        let pred = HKQuery.predicateForSamples(withStart: start, end: .now)
        let asleep: Set<Int> = [HKCategoryValueSleepAnalysis.asleepCore.rawValue, HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                                HKCategoryValueSleepAnalysis.asleepREM.rawValue, HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue]
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, s, _ in
                let secs = (s as? [HKCategorySample] ?? []).filter { asleep.contains($0.value) }
                    .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                cont.resume(returning: secs > 0 ? secs / 3600 : nil)
            }
            store.execute(q)
        }
    }
}

enum Reminders {
    static func schedule(_ item: StackItem) async {
        let center = UNUserNotificationCenter.current()
        let id = item.reminderID
        center.removePendingNotificationRequests(withIdentifiers: [id])
        guard item.remind, (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        let content = UNMutableNotificationContent()
        content.title = item.name
        content.body = "Time for \(item.dose)."
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: item.hour, minute: item.minute), repeats: true)
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func cancel(_ item: StackItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.reminderID])
    }
}
