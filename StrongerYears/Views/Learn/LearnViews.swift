import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(GuideLibrary.all) { guide in
                        NavigationLink { GuideDetailView(guide: guide) } label: { GuideRow(guide: guide) }
                            .buttonStyle(.plain)
                    }
                    NavigationLink { ExerciseLibraryView() } label: {
                        Label("All exercises by body part", systemImage: "books.vertical")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false))
                    .padding(.top, 8)
                    Text(GuideLibrary.version).font(.footnote).foregroundStyle(.secondary)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Learn")
        }
    }
}

struct GuideRow: View {
    let guide: Guide

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: guide.symbol)
                .font(.title)
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.accentColor)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title).font(.headline)
                Text(guide.summary).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

struct GuideDetailView: View {
    let guide: Guide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(guide.summary).font(.title3)

                ForEach(guide.sections, id: \.self) { section in
                    GuideSectionView(section: section)
                }

                if guide.id == "warm-up" {
                    Text("A simple warm-up routine").font(.title2.bold())
                    ForEach(GuideLibrary.warmUpMoves) { move in
                        Card {
                            HStack {
                                Text(move.name).font(.headline)
                                Spacer()
                                Text(move.seconds >= 60 ? "\(move.seconds / 60) min" : "\(move.seconds) sec")
                                    .foregroundStyle(.secondary)
                            }
                            Text(move.how)
                        }
                    }
                }

                if guide.id == "stretching" {
                    Text("Stretches by body part").font(.title2.bold())
                    ForEach(GuideLibrary.stretches) { s in
                        StretchCard(stretch: s)
                    }
                }

                if guide.id == "avoiding-injury" || guide.id == "cold-plunge" || guide.id == "sauna" {
                    Link(destination: URL(string: "tel://911")!) {
                        Label("Emergency: call 911", systemImage: "phone.fill")
                    }
                    .buttonStyle(BigButtonStyle(prominent: false, tint: .red))
                }

                if !guide.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Based on").font(.footnote.bold())
                        ForEach(guide.sources, id: \.self) { Text("• \($0)").font(.footnote) }
                        Text("General information only — not medical advice.").font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(guide.title)
    }
}

struct GuideSectionView: View {
    let section: GuideSection

    private var color: Color {
        switch section.style {
        case .normal: return .primary
        case .tip: return .accentColor
        case .warning: return .orange
        case .stop: return .red
        }
    }

    private var symbol: String? {
        switch section.style {
        case .normal: return nil
        case .tip: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .stop: return "exclamationmark.octagon.fill"
        }
    }

    var body: some View {
        Card {
            if let symbol {
                Label(section.title, systemImage: symbol).font(.headline).foregroundStyle(color)
            } else {
                Text(section.title).font(.headline)
            }
            if let text = section.body { Text(text) }
            ForEach(section.bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Text("•").bold()
                    Text(bullet)
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(section.style == .normal ? .clear : color.opacity(0.6), lineWidth: 2))
    }
}

struct StretchCard: View {
    let stretch: Stretch

    var body: some View {
        Card {
            Text(stretch.name).font(.headline)
            Text("\(stretch.position) · \(stretch.dose)").font(.subheadline).foregroundStyle(.secondary)
            Text(stretch.bodyParts.map(\.rawValue).joined(separator: ", ")).font(.footnote).foregroundStyle(.secondary)
            ForEach(Array(stretch.steps.enumerated()), id: \.offset) { i, step in
                Text("\(i + 1). \(step)")
            }
            if let caution = stretch.caution {
                Label(caution, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange).font(.subheadline)
            }
        }
    }
}
