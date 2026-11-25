import SwiftUI

/// 0–10 slider used for pain, sleep and mood.
struct ScaleSlider: View {
    let title: String
    @Binding var value: Int
    var lowLabel = "No pain"
    var highLabel = "Worst imaginable"
    /// For sleep and mood, a high number is good.
    var higherIsBetter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text("\(value)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(ScaleColor.color(for: value, higherIsBetter: higherIsBetter))
            }
            Slider(value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }), in: 0...10, step: 1)
                .accessibilityLabel(title)
                .accessibilityValue("\(value) out of 10")
            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

enum ScaleColor {
    static func color(for value: Int, higherIsBetter: Bool = false) -> Color {
        let badness = higherIsBetter ? 10 - value : value
        switch badness {
        case ..<4: return .green
        case ..<7: return .orange
        default: return .red
        }
    }
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Multi-select chips laid out in a grid.
struct TagPicker: View {
    let options: [String]
    @Binding var selection: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ForEach(options, id: \.self) { tag in
                let selected = selection.contains(tag)
                Button {
                    if selected { selection.removeAll { $0 == tag } } else { selection.append(tag) }
                } label: {
                    Text(tag)
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected ? Color.accentColor.opacity(0.2) : Color(.tertiarySystemFill), in: Capsule())
                        .overlay(Capsule().stroke(selected ? Color.accentColor : .clear, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }
}

struct WarningRow: View {
    let warning: SafetyWarning

    var body: some View {
        Label {
            Text(warning.message).font(.subheadline)
        } icon: {
            Image(systemName: icon).foregroundStyle(color)
        }
    }

    private var icon: String {
        switch warning.severity {
        case .stop: return "exclamationmark.octagon.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var color: Color {
        switch warning.severity {
        case .stop: return .red
        case .caution: return .orange
        case .info: return .blue
        }
    }
}

struct LockView: View {
    var onUnlock: () -> Void
    @State private var failed = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill").font(.system(size: 48))
            Text("Stroke & Spine is locked").font(.title2.bold())
            if failed { Text("Couldn't unlock. Try again.").foregroundStyle(.secondary) }
            Button("Unlock") { Task { await unlock() } }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .task { await unlock() }
    }

    private func unlock() async {
        if await AppLock.authenticate() { onUnlock() } else { failed = true }
    }
}

extension Date {
    var shortDate: String { formatted(date: .abbreviated, time: .omitted) }
    var shortDateTime: String { formatted(date: .abbreviated, time: .shortened) }
}
