import Foundation

/// ACC/AHA blood pressure categories.
enum BloodPressureCategory: Int, Comparable {
    case low, normal, elevated, stage1, stage2, severe

    static func < (a: BloodPressureCategory, b: BloodPressureCategory) -> Bool { a.rawValue < b.rawValue }

    static func classify(systolic: Int, diastolic: Int) -> BloodPressureCategory {
        if systolic >= 180 || diastolic >= 120 { return .severe }
        if systolic >= 140 || diastolic >= 90 { return .stage2 }
        if systolic >= 130 || diastolic >= 80 { return .stage1 }
        if systolic < 90 || diastolic < 60 { return .low }
        if systolic >= 120 { return .elevated }
        return .normal
    }

    var label: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .elevated: return "Elevated"
        case .stage1: return "High (stage 1)"
        case .stage2: return "High (stage 2)"
        case .severe: return "Very high"
        }
    }

    var advice: SafetyWarning? {
        switch self {
        case .severe:
            return SafetyWarning(id: "bp-severe", severity: .stop, message: "Blood pressure of 180/120 or higher is very high. Wait 5 minutes and measure again. If it's still this high, contact your doctor now. If you also have chest pain, shortness of breath, back pain, numbness or weakness, vision changes or trouble speaking, call 911.")
        case .low:
            return SafetyWarning(id: "bp-low", severity: .info, message: "Low blood pressure can make you dizzy or light-headed, especially when you stand up, which raises the risk of falling. Stand up slowly and tell your doctor if you feel faint.")
        case .stage2:
            return SafetyWarning(id: "bp-high", severity: .info, message: "This reading is in the high range. If most of your readings are like this, talk to your doctor.")
        default: return nil
        }
    }
}

enum BodyMeasures {
    static let cmPerInch = 2.54
    static let kgPerPound = 0.45359237

    static func bmi(weightKg: Double, heightCm: Double) -> Double? {
        guard weightKg > 0, heightCm > 0 else { return nil }
        let m = heightCm / 100
        return weightKg / (m * m)
    }

    static func bmiLabel(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case ..<25: return "Healthy weight"
        case ..<30: return "Overweight"
        default: return "Obesity"
        }
    }

    /// Height loss can be a sign of spine (vertebral) fractures, which often cause no pain.
    /// BHOF: vertebral imaging is advised for measured height loss of 2 cm (0.8 in) or more,
    /// or 4 cm (1.5 in) or more compared with the tallest height the person remembers as a young adult.
    static func heightLossWarning(latestCm: Double?, tallestMeasuredCm: Double?, rememberedPeakCm: Double?, metric: Bool) -> SafetyWarning? {
        guard let latest = latestCm else { return nil }
        if let tallest = tallestMeasuredCm, tallest - latest >= 2.0 {
            return SafetyWarning(id: "height-loss-measured", severity: .caution,
                message: "You've lost \(formatLength(tallest - latest, metric: metric)) of height since your tallest measurement in the app. Height loss of 2 cm (0.8 in) or more can be a sign of a spine fracture, even without pain. Ask your doctor whether you need a spine X-ray or VFA scan.")
        }
        if let peak = rememberedPeakCm, peak - latest >= 4.0 {
            return SafetyWarning(id: "height-loss-peak", severity: .caution,
                message: "You're \(formatLength(peak - latest, metric: metric)) shorter than your tallest adult height. Height loss of 4 cm (1.5 in) or more can be a sign of spine fractures. Ask your doctor whether you need a spine X-ray or VFA scan.")
        }
        return nil
    }

    static func formatLength(_ cm: Double, metric: Bool) -> String {
        metric ? String(format: "%.1f cm", cm) : String(format: "%.1f in", cm / cmPerInch)
    }

    static func formatHeight(_ cm: Double, metric: Bool) -> String {
        if metric { return String(format: "%.1f cm", cm) }
        let totalInches = cm / cmPerInch
        let feet = Int(totalInches / 12)
        return String(format: "%d ft %.1f in", feet, totalInches - Double(feet * 12))
    }

    static func formatWeight(_ kg: Double, metric: Bool) -> String {
        metric ? String(format: "%.1f kg", kg) : String(format: "%.1f lb", kg / kgPerPound)
    }

    static func heartRateNote(_ bpm: Int) -> SafetyWarning? {
        if bpm < 50 { return SafetyWarning(id: "hr-low", severity: .info, message: "A resting heart rate under 50 can be normal for very fit people, but tell your doctor if you feel dizzy, faint or short of breath.") }
        if bpm > 100 { return SafetyWarning(id: "hr-high", severity: .info, message: "A resting heart rate over 100 is higher than usual. Rest and re-check. If it stays high, or you have chest pain or feel faint, contact your doctor.") }
        return nil
    }
}

/// Bone-related blood tests worth keeping alongside scans.
enum LabTest: String, CaseIterable, Codable, Identifiable {
    case vitaminD, calcium, egfr, creatinine, pth, alkalinePhosphatase, magnesium, phosphate, tsh, ctx, p1np

    var id: String { rawValue }

    var name: String {
        switch self {
        case .vitaminD: return "Vitamin D (25-hydroxy)"
        case .calcium: return "Calcium"
        case .egfr: return "eGFR (kidney function)"
        case .creatinine: return "Creatinine"
        case .pth: return "Parathyroid hormone (PTH)"
        case .alkalinePhosphatase: return "Alkaline phosphatase"
        case .magnesium: return "Magnesium"
        case .phosphate: return "Phosphate"
        case .tsh: return "TSH (thyroid)"
        case .ctx: return "CTX (bone breakdown marker)"
        case .p1np: return "P1NP (bone formation marker)"
        }
    }

    var unit: String {
        switch self {
        case .vitaminD: return "ng/mL"
        case .calcium, .creatinine, .magnesium, .phosphate: return "mg/dL"
        case .egfr: return "mL/min/1.73m²"
        case .pth: return "pg/mL"
        case .alkalinePhosphatase: return "U/L"
        case .tsh: return "mIU/L"
        case .ctx: return "pg/mL"
        case .p1np: return "mcg/L"
        }
    }

    /// Brief, cautious context. Reference ranges vary by laboratory, so most tests only show the lab's own range.
    func note(for value: Double) -> String? {
        switch self {
        case .vitaminD:
            if value < 12 { return "Deficient. Your doctor will usually recommend treatment." }
            if value < 20 { return "Low for bone health." }
            if value < 30 { return "Adequate for most people; many bone specialists aim for 30 or higher if you have osteoporosis." }
            if value <= 50 { return "In the range most guidelines consider good for bone health." }
            return "Higher than needed. Ask your doctor whether to lower your vitamin D dose."
        case .egfr:
            if value < 30 { return "Severely reduced kidney function. Several osteoporosis medicines (alendronate, risedronate, ibandronate, zoledronic acid) are usually avoided, and denosumab needs close calcium monitoring." }
            if value < 35 { return "Reduced kidney function. Alendronate and zoledronic acid are usually avoided below about 35." }
            if value < 60 { return "Mildly to moderately reduced kidney function. Your doctor will take this into account when choosing medicines." }
            return nil
        case .calcium:
            if value < 8.5 { return "Below the usual range (about 8.5–10.2; it varies by lab). Low calcium must be corrected before some bone medicines." }
            if value > 10.2 { return "Above the usual range (about 8.5–10.2; it varies by lab). Your doctor may check for causes such as a parathyroid problem." }
            return nil
        default:
            return nil
        }
    }
}
