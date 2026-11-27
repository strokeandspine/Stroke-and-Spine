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
    let kind: String          // "supplement" | "clinical"
    let category: String
    let goals: [String]
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

    var isClinical: Bool { kind == "clinical" }
    var grade: Evidence? { evidence.flatMap(Evidence.init(rawValue:)) }
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
    let apps: [DataApp]

    var all: [Compound] { supplements + clinical }
    func goal(_ id: String) -> Goal? { goals.first { $0.id == id } }
    func compound(_ id: String) -> Compound? { all.first { $0.id == id } }
    func compounds(for goal: String) -> [Compound] { all.filter { $0.goals.contains(goal) } }

    private struct File: Codable {
        let goals: [Goal]; let supplements: [Compound]; let clinical: [Compound]; let apps: [DataApp]
    }

    init(goals: [Goal], supplements: [Compound], clinical: [Compound], apps: [DataApp]) {
        self.goals = goals; self.supplements = supplements; self.clinical = clinical; self.apps = apps
    }

    static func load(bundle: Bundle = .main) -> Catalog {
        guard let url = bundle.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data) else {
            assertionFailure("catalog.json missing or invalid")
            return Catalog(goals: [], supplements: [], clinical: [], apps: [])
        }
        return Catalog(goals: file.goals, supplements: file.supplements, clinical: file.clinical, apps: file.apps)
    }
}
