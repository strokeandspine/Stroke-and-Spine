import Foundation
import Observation

struct Goal: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
}

enum Evidence: String, CaseIterable {
    case A, B, C, D
    var label: String {
        switch self {
        case .A: "Strong evidence"
        case .B: "Moderate evidence"
        case .C: "Limited or mixed evidence"
        case .D: "Weak or mostly preclinical"
        }
    }
}

/// A catalogue entry. Supplements carry dose and timing; clinical entries are reference-only.
struct Compound: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let kind: String          // "supplement" | "clinical" | "peptide"
    let category: String
    let goals: [String]
    let sections: [String]
    // Supplements
    let dose: String?
    let timing: String?
    let evidence: String?
    let notes: String?
    // Clinical
    let status: String?
    let uses: String?
    let mechanism: String?
    let evidence_text: String?
    let risks: String?
    let labs: String?
    // Peptides
    let tier: String?        // "approved" | "trial" | "unapproved"
    let sport: String?

    /// Reference-only entries (no doses): clinical compounds and peptides.
    var isClinical: Bool { kind != "supplement" }
    var isPeptide: Bool { kind == "peptide" }
    var isUnapprovedPeptide: Bool { isPeptide && tier != "approved" }
    var grade: Evidence? { evidence.flatMap(Evidence.init(rawValue:)) }
}

struct GuideNote: Codable, Hashable {
    let title: String
    let text: String
}

struct DataApp: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let category: String
    let description: String
    let url: URL
}

@Observable
final class Catalog {
    let goals: [Goal]
    let supplements: [Compound]
    let clinical: [Compound]
    let peptides: [Compound]
    let peptideGuide: [GuideNote]
    let apps: [DataApp]

    var all: [Compound] { supplements + clinical + peptides }
    func section(_ id: String) -> [Compound] { all.filter { $0.sections.contains(id) } }
    func goal(_ id: String) -> Goal? { goals.first { $0.id == id } }
    func compound(_ id: String) -> Compound? { all.first { $0.id == id } }
    func compounds(for goal: String) -> [Compound] { all.filter { $0.goals.contains(goal) } }

    private struct File: Codable {
        let goals: [Goal]; let supplements: [Compound]; let clinical: [Compound]
        let peptides: [Compound]; let peptide_guide: [GuideNote]; let apps: [DataApp]
    }

    init(goals: [Goal], supplements: [Compound], clinical: [Compound], peptides: [Compound], peptideGuide: [GuideNote], apps: [DataApp]) {
        self.goals = goals; self.supplements = supplements; self.clinical = clinical
        self.peptides = peptides; self.peptideGuide = peptideGuide; self.apps = apps
    }

    static func load(bundle: Bundle = .main) -> Catalog {
        guard let url = bundle.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data) else {
            assertionFailure("catalog.json missing or invalid")
            return Catalog(goals: [], supplements: [], clinical: [], peptides: [], peptideGuide: [], apps: [])
        }
        return Catalog(goals: file.goals, supplements: file.supplements, clinical: file.clinical,
                       peptides: file.peptides, peptideGuide: file.peptide_guide, apps: file.apps)
    }
}
