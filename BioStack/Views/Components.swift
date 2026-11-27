import SwiftUI

struct EvidenceBadge: View {
    let compound: Compound
    var body: some View {
        let (text, color): (String, Color) = compound.isClinical ? ("Rx", .primary) : {
            switch compound.grade {
            case .A: ("A", .teal)
            case .B: ("B", .green)
            case .C: ("C", .orange)
            default: ("D", .gray)
            }
        }()
        Text(text)
            .font(.caption.monospaced().weight(.semibold))
            .foregroundStyle(compound.isClinical ? Color(.systemBackground) : .white)
            .frame(width: 26, height: 22)
            .background(color, in: RoundedRectangle(cornerRadius: 5))
            .accessibilityLabel(compound.isClinical ? "Clinical reference" : compound.grade?.label ?? "")
    }
}

struct CompoundRow: View {
    @Environment(Catalog.self) private var catalog
    let compound: Compound
    var body: some View {
        HStack(spacing: 12) {
            EvidenceBadge(compound: compound)
            VStack(alignment: .leading, spacing: 2) {
                Text(compound.name).font(.body.weight(.medium))
                Text(compound.isClinical ? (compound.status ?? "") : (compound.dose ?? ""))
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }
}
