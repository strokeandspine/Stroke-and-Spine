import SwiftUI

/// 0–10 slider used for pain, effort and the PEG items.
struct ScaleSlider: View {
    let title: String
    @Binding var value: Int
    var lowLabel = "No pain"
    var highLabel = "Worst imaginable"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text("\(value)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(ScaleColor.color(for: value))
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
    static func color(for value: Int) -> Color {
        switch value {
        case ..<4: return .green
        case ..<7: return .orange
        default: return .red
        }
    }

    static func color(for category: BoneDensityCategory) -> Color {
        switch category {
        case .normal: return .green
        case .lowBoneMass: return .orange
        case .osteoporosis, .severeOsteoporosis: return .red
        }
    }

    static func color(for state: ScheduleStatus.State) -> Color {
        switch state {
        case .completed, .upToDate: return .green
        case .dueSoon: return .blue
        case .dueToday: return .orange
        case .overdue, .urgent: return .red
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
    var labels: [String: String] = [:]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ForEach(options, id: \.self) { tag in
                let selected = selection.contains(tag)
                Button {
                    if selected { selection.removeAll { $0 == tag } } else { selection.append(tag) }
                } label: {
                    Text(labels[tag] ?? tag)
                        .font(.subheadline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
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

/// A bulleted list used throughout the education pages.
struct BulletList: View {
    let items: [String]
    var symbol = "circle.fill"
    var tint: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: symbol).font(.system(size: 6)).foregroundStyle(tint)
                    Text(item).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .font(.subheadline)
    }
}

struct ProgressRow: View {
    let title: String
    let valueText: String
    let fraction: Double
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline.bold())
                Spacer()
                Text(valueText).font(.subheadline).monospacedDigit().foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(fraction, 0), 1)).tint(tint)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Number entry that writes nil when the field is cleared.
struct OptionalNumberField: View {
    let title: String
    @Binding var value: Double?
    var unit: String = ""
    var allowsNegative = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("—", value: $value, format: .number)
                .keyboardType(allowsNegative ? .numbersAndPunctuation : .decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
            if !unit.isEmpty { Text(unit).foregroundStyle(.secondary) }
        }
    }
}

struct OptionalIntField: View {
    let title: String
    @Binding var value: Int?
    var unit: String = ""

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("—", value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
            if !unit.isEmpty { Text(unit).foregroundStyle(.secondary) }
        }
    }
}

struct LockView: View {
    var onUnlock: () -> Void
    @State private var failed = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill").font(.system(size: 48))
            Text("\(AppText.appName) is locked").font(.title2.bold())
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

extension Double {
    /// "-2.4" style, one decimal, with a real minus sign.
    var scoreText: String { String(format: "%.1f", self).replacingOccurrences(of: "-", with: "−") }
}
