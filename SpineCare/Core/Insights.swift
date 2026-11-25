import Foundation

/// Simple, honest trend summaries. A 2-point change on a 0–10 pain scale is
/// the commonly used threshold for a change patients notice (MCID).
enum Insights {
    static let painMCID = 2.0

    struct DailyValue {
        var date: Date
        var value: Double
    }

    static func average(_ values: [DailyValue], from start: Date, to end: Date) -> Double? {
        let inRange = values.filter { $0.date >= start && $0.date < end }.map(\.value)
        guard !inRange.isEmpty else { return nil }
        return inRange.reduce(0, +) / Double(inRange.count)
    }

    /// Compares the last 7 days with the 7 days before.
    static func weeklyPainSummary(_ values: [DailyValue], now: Date = Date(), calendar: Calendar = .current) -> String? {
        let today = calendar.startOfDay(for: now)
        guard let end = calendar.date(byAdding: .day, value: 1, to: today),
              let weekAgo = calendar.date(byAdding: .day, value: -6, to: today),
              let twoWeeksAgo = calendar.date(byAdding: .day, value: -13, to: today),
              let thisWeek = average(values, from: weekAgo, to: end)
        else { return nil }

        let formatted = String(format: "%.1f", thisWeek)
        guard let lastWeek = average(values, from: twoWeeksAgo, to: weekAgo) else {
            return "Your average pain over the last 7 days is \(formatted) out of 10."
        }
        let delta = thisWeek - lastWeek
        if delta <= -painMCID {
            return "Your average pain this week is \(formatted), down \(String(format: "%.1f", -delta)) points from last week. That's a meaningful improvement."
        } else if delta >= painMCID {
            return "Your average pain this week is \(formatted), up \(String(format: "%.1f", delta)) points from last week. If this continues, consider checking in with your doctor or physical therapist."
        } else {
            return "Your average pain this week is \(formatted), about the same as last week (\(String(format: "%.1f", lastWeek)))."
        }
    }
}
