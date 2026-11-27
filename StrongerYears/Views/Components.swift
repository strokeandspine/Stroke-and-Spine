import SwiftUI

/// A large, high-contrast button — at least 60 points tall for easy tapping.
struct BigButtonStyle: ButtonStyle {
    var prominent = true
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(.horizontal)
            .foregroundStyle(prominent ? Color.white : tint)
            .background(prominent ? tint : tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(tint, lineWidth: prominent ? 0 : 2))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Large +/- control for reps, seconds and weight.
struct BigStepper: View {
    let title: String
    @Binding var value: Double
    var step: Double = 1
    var range: ClosedRange<Double> = 0...999
    var unit: String = ""

    var body: some View {
        VStack(spacing: 6) {
            Text(title).font(.headline).foregroundStyle(.secondary)
            HStack(spacing: 16) {
                circleButton("minus") { value = max(range.lowerBound, value - step) }
                    .accessibilityLabel("Decrease \(title)")
                Text("\(Progression.formatWeight(value))\(unit.isEmpty ? "" : " \(unit)")")
                    .font(.largeTitle.bold())
                    .monospacedDigit()
                    .frame(minWidth: 90)
                    .accessibilityLabel(title)
                    .accessibilityValue("\(Progression.formatWeight(value)) \(unit)")
                circleButton("plus") { value = min(range.upperBound, value + step) }
                    .accessibilityLabel("Increase \(title)")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func circleButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title2.bold())
                .frame(width: 60, height: 60)
                .background(Color.accentColor.opacity(0.15), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

/// Int-backed wrapper around BigStepper.
struct BigIntStepper: View {
    let title: String
    @Binding var value: Int
    var step = 1
    var range: ClosedRange<Int> = 0...999
    var unit = ""

    var body: some View {
        BigStepper(
            title: title,
            value: Binding(get: { Double(value) }, set: { value = Int($0) }),
            step: Double(step),
            range: Double(range.lowerBound)...Double(range.upperBound),
            unit: unit
        )
    }
}

/// 0–10 effort picker with words.
struct EffortPicker: View {
    @Binding var value: Int
    var target: ClosedRange<Int>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("How hard was it?").font(.headline)
                Spacer()
                Text("\(value) — \(EffortScale.words(value))")
                    .font(.headline)
                    .foregroundStyle(color)
            }
            Slider(value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }), in: 0...10, step: 1)
                .accessibilityLabel("Effort")
                .accessibilityValue("\(value) out of 10, \(EffortScale.words(value))")
            if let target {
                Text("Your target is \(target.lowerBound)–\(target.upperBound).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var color: Color {
        guard let target else { return .primary }
        if value > target.upperBound + 1 || value >= 9 { return .red }
        if value > target.upperBound { return .orange }
        return .green
    }
}

/// Multi-select chips.
struct ChipPicker<Item: Hashable & Identifiable>: View {
    let items: [Item]
    let label: (Item) -> String
    @Binding var selection: Set<Item>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(items) { item in
                let selected = selection.contains(item)
                Button {
                    if selected { selection.remove(item) } else { selection.insert(item) }
                } label: {
                    HStack {
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        Text(label(item)).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .font(.body.weight(.medium))
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    .background(selected ? Color.accentColor.opacity(0.18) : Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.accentColor : .clear, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }
}

/// A list of red "stop if" signs.
struct StopSignsCard: View {
    var body: some View {
        Card {
            Label("Stop straight away if you feel", systemImage: "exclamationmark.octagon.fill")
                .font(.headline)
                .foregroundStyle(.red)
            ForEach(GuideLibrary.stopNow, id: \.self) { item in
                Label(item, systemImage: "xmark.circle")
                    .font(.subheadline)
            }
            Text(GuideLibrary.callEmergency)
                .font(.subheadline.bold())
            Link(destination: URL(string: "tel://911")!) {
                Label("Call 911", systemImage: "phone.fill")
            }
            .buttonStyle(BigButtonStyle(prominent: false, tint: .red))
        }
    }
}

struct BodyPartBadges: View {
    let parts: [BodyPart]

    var body: some View {
        Text(parts.map(\.rawValue).joined(separator: " · "))
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

extension Date {
    var dayAndDate: String { formatted(.dateTime.weekday(.wide).month(.wide).day()) }
}
