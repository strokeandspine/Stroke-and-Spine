import Foundation
import SwiftData

/// Something the user takes on a schedule.
@Model final class StackItem {
    var compoundID: String?      // nil for custom items
    var name: String
    var dose: String
    var hour: Int
    var minute: Int
    var remind: Bool
    var createdAt: Date
    var reminderID: String = UUID().uuidString

    init(compoundID: String?, name: String, dose: String, hour: Int, minute: Int, remind: Bool = false) {
        self.compoundID = compoundID; self.name = name; self.dose = dose
        self.hour = hour; self.minute = minute; self.remind = remind; self.createdAt = .now
    }
    var timeText: String { String(format: "%02d:%02d", hour, minute) }
}

/// One dose actually taken.
@Model final class DoseLog {
    var stackItemID: PersistentIdentifier?
    var name: String
    var dose: String
    var takenAt: Date
    var note: String

    init(stackItemID: PersistentIdentifier?, name: String, dose: String, takenAt: Date = .now, note: String = "") {
        self.stackItemID = stackItemID; self.name = name; self.dose = dose; self.takenAt = takenAt; self.note = note
    }
}

@Model final class LabResult {
    var marker: String
    var value: Double
    var unit: String
    var date: Date

    init(marker: String, value: Double, unit: String, date: Date) {
        self.marker = marker; self.value = value; self.unit = unit; self.date = date
    }
}

@Model final class EffectNote {
    var text: String
    var severity: String
    var date: Date

    init(text: String, severity: String, date: Date = .now) {
        self.text = text; self.severity = severity; self.date = date
    }
}

enum LabMarkers {
    static let common = ["25(OH) Vitamin D", "ApoB", "LDL-C", "HDL-C", "Triglycerides", "Lp(a)", "HbA1c",
        "Fasting glucose", "Fasting insulin", "hs-CRP", "Ferritin", "Vitamin B12", "Homocysteine", "TSH", "Free T4",
        "Total testosterone", "Estradiol", "Haematocrit", "Hemoglobin", "ALT", "AST", "eGFR", "Creatinine",
        "Cystatin C", "Uric acid", "Omega-3 index", "VO2 max", "Body fat %", "Lean mass", "Weight",
        "Blood pressure (systolic)", "Grip strength", "Biological age (epigenetic)"]
}
