import Foundation

/// Clinical risk factors for osteoporosis and fracture. Most are FRAX inputs; the rest are common secondary causes.
/// The app doesn't calculate FRAX — it helps the person collect what their doctor needs.
enum RiskFactor: String, CaseIterable, Codable, Identifiable {
    // FRAX inputs
    case parentHipFracture, currentSmoker, glucocorticoids, rheumatoidArthritis, alcohol, earlyMenopause
    // Conditions
    case type1Diabetes, type2Diabetes, hyperthyroidism, hyperparathyroidism, celiacOrIBD, chronicKidneyDisease, chronicLiverDisease,
         multipleMyeloma, eatingDisorder, lowTestosterone, immobility, weightLossSurgery
    // Medicines
    case aromataseInhibitor, androgenDeprivation, antiSeizure, protonPumpInhibitor, thyroidExcess, heparinLongTerm, thiazolidinedione, sedatives

    enum Group: String, CaseIterable {
        case frax = "Main risk factors (used in FRAX)"
        case conditions = "Health conditions"
        case medicines = "Medicines"
    }

    var id: String { rawValue }

    var group: Group {
        switch self {
        case .parentHipFracture, .currentSmoker, .glucocorticoids, .rheumatoidArthritis, .alcohol, .earlyMenopause: return .frax
        case .aromataseInhibitor, .androgenDeprivation, .antiSeizure, .protonPumpInhibitor, .thyroidExcess, .heparinLongTerm, .thiazolidinedione, .sedatives: return .medicines
        default: return .conditions
        }
    }

    var label: String {
        switch self {
        case .parentHipFracture: return "A parent broke their hip"
        case .currentSmoker: return "I currently smoke"
        case .glucocorticoids: return "Steroid tablets (such as prednisone) for 3 months or more"
        case .rheumatoidArthritis: return "Rheumatoid arthritis"
        case .alcohol: return "3 or more alcoholic drinks a day"
        case .earlyMenopause: return "Menopause before age 45 (or ovaries removed)"
        case .type1Diabetes: return "Type 1 diabetes"
        case .type2Diabetes: return "Type 2 diabetes"
        case .hyperthyroidism: return "Overactive thyroid"
        case .hyperparathyroidism: return "Overactive parathyroid glands"
        case .celiacOrIBD: return "Celiac disease, Crohn's or ulcerative colitis"
        case .chronicKidneyDisease: return "Chronic kidney disease"
        case .chronicLiverDisease: return "Chronic liver disease"
        case .multipleMyeloma: return "Multiple myeloma or MGUS"
        case .eatingDisorder: return "Anorexia or another eating disorder (now or in the past)"
        case .lowTestosterone: return "Low testosterone (men)"
        case .immobility: return "Unable to walk or bed-bound for long periods"
        case .weightLossSurgery: return "Weight-loss (bariatric) surgery"
        case .aromataseInhibitor: return "Aromatase inhibitor for breast cancer (anastrozole, letrozole, exemestane)"
        case .androgenDeprivation: return "Hormone therapy for prostate cancer"
        case .antiSeizure: return "Anti-seizure medicine (such as phenytoin or carbamazepine)"
        case .protonPumpInhibitor: return "Long-term acid reducer (such as omeprazole)"
        case .thyroidExcess: return "High-dose thyroid hormone"
        case .heparinLongTerm: return "Long-term heparin injections"
        case .thiazolidinedione: return "Pioglitazone for diabetes"
        case .sedatives: return "Sleeping pills, sedatives or some antidepressants (raise fall risk)"
        }
    }

    /// Counts as a FRAX "secondary osteoporosis" input.
    var isFraxSecondaryCause: Bool {
        [.type1Diabetes, .hyperthyroidism, .celiacOrIBD, .chronicLiverDisease, .earlyMenopause, .lowTestosterone, .eatingDisorder].contains(self)
    }
}

enum FractureSite: String, CaseIterable, Codable, Identifiable {
    case hip, spine, wrist, upperArm, pelvis, ribs, ankle, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hip: return "Hip"
        case .spine: return "Spine (vertebra)"
        case .wrist: return "Wrist or forearm"
        case .upperArm: return "Shoulder or upper arm"
        case .pelvis: return "Pelvis"
        case .ribs: return "Ribs"
        case .ankle: return "Ankle or leg"
        case .other: return "Other"
        }
    }
}

enum FractureCause: String, CaseIterable, Codable, Identifiable {
    case lowTrauma, noKnownInjury, highTrauma

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lowTrauma: return "Fall from standing height or less, or a minor bump"
        case .noKnownInjury: return "No injury I know of (found on an X-ray, or from coughing or lifting)"
        case .highTrauma: return "Major injury (car accident, fall from a height, sport)"
        }
    }

    /// A fragility fracture is one from a force that wouldn't normally break a healthy bone.
    var isFragility: Bool { self != .highTrauma }
}

enum HistoryKind: String, CaseIterable, Codable, Identifiable {
    case condition, surgery, allergy, medication, familyHistory, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .condition: return "Condition"
        case .surgery: return "Surgery or procedure"
        case .allergy: return "Allergy"
        case .medication: return "Other medicine"
        case .familyHistory: return "Family history"
        case .other: return "Other"
        }
    }

    var symbol: String {
        switch self {
        case .condition: return "stethoscope"
        case .surgery: return "cross.case"
        case .allergy: return "allergens"
        case .medication: return "pills"
        case .familyHistory: return "person.2"
        case .other: return "doc.text"
        }
    }
}

enum RadiologyKind: String, CaseIterable, Codable, Identifiable {
    case dexa, vfa, xray, ct, mri, boneScan, ultrasound, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dexa: return "DEXA (bone density) scan"
        case .vfa: return "Vertebral fracture assessment (VFA)"
        case .xray: return "X-ray"
        case .ct: return "CT scan"
        case .mri: return "MRI"
        case .boneScan: return "Nuclear bone scan"
        case .ultrasound: return "Ultrasound"
        case .other: return "Other imaging"
        }
    }

    var symbol: String {
        switch self {
        case .dexa: return "figure.stand"
        case .vfa: return "figure.walk"
        case .xray: return "xmark.rectangle"
        case .ct, .mri: return "circle.dashed.rectangle"
        case .boneScan: return "dot.radiowaves.left.and.right"
        case .ultrasound: return "waveform"
        case .other: return "photo"
        }
    }
}
