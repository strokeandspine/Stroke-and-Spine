import Foundation

/// One training day in the weekly schedule.
struct ScheduledDay: Codable, Hashable, Identifiable {
    /// Calendar weekday: 1 = Sunday … 7 = Saturday.
    var weekday: Int
    var name: String
    var bodyParts: [BodyPart]

    var id: Int { weekday }

    var weekdayName: String { Weekdays.name(weekday) }
}

struct SessionTemplate: Hashable {
    let name: String
    let bodyParts: [BodyPart]
}

enum Weekdays {
    /// Monday-first order, as most people think of their week.
    static let mondayFirst = [2, 3, 4, 5, 6, 7, 1]

    static func name(_ weekday: Int) -> String {
        let symbols = Calendar(identifier: .gregorian).weekdaySymbols // Sunday first
        guard (1...7).contains(weekday) else { return "" }
        return symbols[weekday - 1]
    }

    static func shortName(_ weekday: Int) -> String {
        let symbols = Calendar(identifier: .gregorian).shortWeekdaySymbols
        guard (1...7).contains(weekday) else { return "" }
        return symbols[weekday - 1]
    }

    /// Suggested days, spread out through the week.
    static func suggested(daysPerWeek: Int) -> [Int] {
        switch daysPerWeek {
        case ...1: return [3]                // Tuesday
        case 2: return [2, 5]                // Monday, Thursday
        case 3: return [2, 4, 6]             // Monday, Wednesday, Friday
        default: return [2, 3, 5, 6]         // Mon, Tue, Thu, Fri
        }
    }
}

enum ScheduleTemplates {
    static let fullBody: [BodyPart] = [.legs, .hips, .back, .chest, .shoulders, .arms, .core, .balance]

    /// Splits that give each body part at least 48 hours to recover.
    static func templates(daysPerWeek: Int) -> [SessionTemplate] {
        switch daysPerWeek {
        case ...1:
            return [SessionTemplate(name: "Full body", bodyParts: fullBody)]
        case 2:
            return [
                SessionTemplate(name: "Full body A", bodyParts: [.legs, .back, .chest, .core, .balance]),
                SessionTemplate(name: "Full body B", bodyParts: [.hips, .shoulders, .arms, .back, .balance]),
            ]
        case 3:
            return [
                SessionTemplate(name: "Legs, hips and core", bodyParts: [.legs, .hips, .core, .balance]),
                SessionTemplate(name: "Upper body", bodyParts: [.back, .chest, .shoulders, .arms]),
                SessionTemplate(name: "Full body and balance", bodyParts: [.legs, .back, .chest, .core, .balance]),
            ]
        default:
            return [
                SessionTemplate(name: "Lower body and balance", bodyParts: [.legs, .hips, .balance]),
                SessionTemplate(name: "Upper body: push", bodyParts: [.chest, .shoulders, .arms]),
                SessionTemplate(name: "Lower body and core", bodyParts: [.legs, .hips, .core]),
                SessionTemplate(name: "Upper body: pull", bodyParts: [.back, .arms, .core, .balance]),
            ]
        }
    }

    /// Assigns templates to the chosen weekdays in Monday-first order.
    static func schedule(weekdays: [Int]) -> [ScheduledDay] {
        let ordered = Weekdays.mondayFirst.filter { weekdays.contains($0) }
        let templates = templates(daysPerWeek: ordered.count)
        return ordered.enumerated().map { index, weekday in
            let t = templates[index % templates.count]
            return ScheduledDay(weekday: weekday, name: t.name, bodyParts: t.bodyParts)
        }
    }

    /// Warnings when the same muscles are trained on back-to-back days, or too often.
    static func restWarnings(_ days: [ScheduledDay]) -> [String] {
        var warnings: [String] = []
        let byWeekday = Dictionary(uniqueKeysWithValues: days.map { ($0.weekday, $0) })
        for day in days.sorted(by: { Weekdays.mondayFirst.firstIndex(of: $0.weekday)! < Weekdays.mondayFirst.firstIndex(of: $1.weekday)! }) {
            let nextWeekday = day.weekday == 7 ? 1 : day.weekday + 1
            guard let next = byWeekday[nextWeekday] else { continue }
            // Balance and core can be practiced daily; muscles need recovery.
            let overlap = Set(day.bodyParts).intersection(next.bodyParts).subtracting([.balance, .core])
            if !overlap.isEmpty {
                let names = BodyPart.allCases.filter { overlap.contains($0) }.map { $0.rawValue.lowercased() }
                warnings.append("\(day.weekdayName) and \(next.weekdayName) both work your \(ListFormatter.localizedString(byJoining: names)). Muscles need about 48 hours to recover — try a rest day in between or change one of the days.")
            }
        }
        if days.count > 5 {
            warnings.append("Strength training more than 5 days a week doesn't leave enough time to recover. 2–3 days is plenty for most people.")
        }
        return warnings
    }

    /// Body parts not trained at all in the week.
    static func missingBodyParts(_ days: [ScheduledDay]) -> [BodyPart] {
        let covered = Set(days.flatMap(\.bodyParts))
        return BodyPart.allCases.filter { !covered.contains($0) }
    }
}
