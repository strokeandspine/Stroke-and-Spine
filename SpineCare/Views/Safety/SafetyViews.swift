import SwiftUI
import SwiftData

/// Warning-sign checklist. Any "yes" leads straight to how urgently to get care.
struct RedFlagCheckView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var positive: Set<String> = []
    @State private var result: Urgency?
    @State private var includeAfterSurgery = false

    var body: some View {
        NavigationStack {
            Group {
                if let result {
                    UrgencyResultView(urgency: result, flagged: RedFlagScreen.flags.filter { positive.contains($0.id) }) { dismiss() }
                } else {
                    checklist
                }
            }
            .navigationTitle("Warning signs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if result == nil {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                }
            }
        }
    }

    private var checklist: some View {
        Form {
            Section {
                Text("Turn on anything that is happening to you now.")
            }
            ForEach([RedFlag.Group.nerves, .general], id: \.self) { group in
                section(for: group)
            }
            Section {
                Toggle("I've had spine surgery or an injection in the last 6 weeks", isOn: $includeAfterSurgery)
            }
            if includeAfterSurgery {
                section(for: .afterSurgery)
            }
            Section {
                Button(positive.isEmpty ? "None of these apply" : "See what to do") { submit() }
                    .bold()
            }
        }
    }

    private func section(for group: RedFlag.Group) -> some View {
        Section(group.rawValue) {
            ForEach(RedFlagScreen.flags.filter { $0.group == group }) { flag in
                Toggle(flag.question, isOn: Binding(
                    get: { positive.contains(flag.id) },
                    set: { if $0 { positive.insert(flag.id) } else { positive.remove(flag.id) } }))
            }
        }
    }

    private func submit() {
        let check = RedFlagCheck(positiveIDs: positive)
        context.insert(check)
        try? context.save()
        result = check.urgency
    }
}

struct UrgencyResultView: View {
    let urgency: Urgency
    let flagged: [RedFlag]
    var onDone: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label(urgency.headline, systemImage: icon)
                        .font(.title2.bold())
                        .foregroundStyle(color)
                    Text(urgency.advice)
                }
                .padding(.vertical, 8)
            }
            if urgency == .emergency {
                Section {
                    Link(destination: URL(string: "tel:911")!) {
                        Label("Call 911", systemImage: "phone.fill").font(.headline)
                    }
                }
            }
            if !flagged.isEmpty {
                Section("You reported") {
                    ForEach(flagged) { Text($0.question) }
                }
            }
            Section {
                Button("Done", action: onDone)
            }
        }
    }

    private var icon: String {
        switch urgency {
        case .none: return "checkmark.shield.fill"
        case .prompt: return "stethoscope"
        case .urgent: return "exclamationmark.triangle.fill"
        case .emergency: return "light.beacon.max.fill"
        }
    }

    private var color: Color {
        switch urgency {
        case .none: return .green
        case .prompt: return .blue
        case .urgent: return .orange
        case .emergency: return .red
        }
    }
}

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                Text("If you're having thoughts of hurting yourself or that you'd be better off dead, please reach out now. You don't have to wait until things get worse.")
            }
            Section("Free, confidential, 24/7") {
                ForEach(CrisisResources.all) { resource in
                    Link(destination: resource.url) {
                        VStack(alignment: .leading) {
                            Text(resource.name).font(.headline)
                            Text(resource.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                Text("It can also help to tell your doctor, or someone you trust, how you've been feeling.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Support is available")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } }
        }
    }
}
