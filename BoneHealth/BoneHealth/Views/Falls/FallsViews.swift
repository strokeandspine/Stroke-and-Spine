import SwiftUI
import SwiftData

struct FallsHomeView: View {
    @Bindable var profile: PatientProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \FallRecord.date, order: .reverse) private var falls: [FallRecord]
    @Query(sort: \FallRiskScreen.date, order: .reverse) private var screens: [FallRiskScreen]
    @State private var logging = false
    @State private var checking = false

    private var pastYear: [FallRecord] {
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return falls.filter { $0.date >= yearAgo }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    stat("\(pastYear.filter { !$0.isNearMiss }.count)", "falls in the past year")
                    Divider()
                    stat("\(pastYear.filter(\.isNearMiss).count)", "near-misses")
                    Divider()
                    stat(screens.first.map { "\($0.score)" } ?? "—", "checklist score")
                }
                .frame(maxWidth: .infinity)
                Button { logging = true } label: { Label("Record a fall or near-miss", systemImage: "plus.circle.fill") }.bold()
            }

            let recommendations = FallRisk.recommendations(falls: falls.map(\.summaryInput), latestChecklistScore: screens.first?.score)
            if !recommendations.isEmpty {
                Section("What to do") { ForEach(recommendations) { WarningRow(warning: $0) } }
            }

            Section("Prevent falls") {
                Button { checking = true } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fall risk checklist (CDC Stay Independent)")
                            Text(screens.first.map { "Last done \($0.date.shortDate)" } ?? "12 quick yes/no questions").font(.caption).foregroundStyle(.secondary)
                        }
                    } icon: { Image(systemName: "checklist") }
                }
                NavigationLink { HomeSafetyView(profile: profile) } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Home safety check")
                            Text("\(profile.homeSafetyDoneIDs.count) of \(AfterFallAdvice.homeSafety.count) done").font(.caption).foregroundStyle(.secondary)
                        }
                    } icon: { Image(systemName: "house") }
                }
                NavigationLink { ExerciseCategoryView(category: .balance) } label: { Label("Balance exercises", systemImage: "figure.stand") }
            }

            Section("If you fall") {
                NavigationLink { AfterFallView() } label: { Label("What to do after a fall", systemImage: "cross.case") }
            }

            Section("Falls history") {
                if falls.isEmpty { Text("No falls recorded.").foregroundStyle(.secondary) }
                ForEach(falls) { fall in
                    NavigationLink { FallDetailView(fall: fall) } label: { FallRow(fall: fall) }
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(falls[i]) }
                    try? context.save()
                }
            }
        }
        .navigationTitle("Falls")
        .sheet(isPresented: $logging) { LogFallView() }
        .sheet(isPresented: $checking) { FallChecklistView() }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FallRow: View {
    let fall: FallRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(fall.isNearMiss ? "Near-miss" : "Fall").font(.subheadline.bold())
                if fall.wasInjured { Text("Injured").font(.caption2).foregroundStyle(.white).padding(.horizontal, 6).padding(.vertical, 2).background(.red, in: Capsule()) }
            }
            Text("\(fall.date.shortDateTime) · \(fall.location.label)").font(.caption).foregroundStyle(.secondary)
            if !fall.causes.isEmpty { Text(fall.causes.map(\.label).joined(separator: ", ")).font(.caption) }
        }
    }
}

struct FallDetailView: View {
    let fall: FallRecord

    var body: some View {
        List {
            Section {
                LabeledContent("Type", value: fall.isNearMiss ? "Near-miss (didn't hit the ground)" : "Fall")
                LabeledContent("When", value: fall.date.shortDateTime)
                LabeledContent("Where", value: fall.location.label)
                if !fall.activity.isEmpty { LabeledContent("Doing", value: fall.activity) }
            }
            if !fall.causes.isEmpty { Section("What happened") { BulletList(items: fall.causes.map(\.label)) } }
            if !fall.isNearMiss {
                Section("Injuries and care") {
                    BulletList(items: fall.injuries.map(\.label) + (fall.hitHead && !fall.injuries.contains(.headInjury) ? ["Hit my head"] : []))
                    if !fall.fractureSite.isEmpty { LabeledContent("Broken bone", value: fall.fractureSite) }
                    LabeledContent("Got up without help", value: fall.couldGetUpAlone ? "Yes" : "No")
                    LabeledContent("On the floor an hour or more", value: fall.longLie ? "Yes" : "No")
                    LabeledContent("Care", value: fall.care.label)
                }
            }
            if !fall.notes.isEmpty { Section("Notes") { Text(fall.notes) } }
        }
        .navigationTitle(fall.isNearMiss ? "Near-miss" : "Fall")
    }
}

struct LogFallView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var isNearMiss = false
    @State private var date = Date()
    @State private var location: FallLocation = .homeInside
    @State private var activity = ""
    @State private var causes: [String] = []
    @State private var injuries: [String] = []
    @State private var fractureSite = ""
    @State private var hitHead = false
    @State private var gotUpAlone = true
    @State private var longLie = false
    @State private var care: CareSought = CareSought.none
    @State private var notes = ""
    @State private var addFracture = false
    @State private var saved = false

    private var injured: Bool { hitHead || injuries.contains { $0 != FallInjury.none.rawValue } }

    var body: some View {
        NavigationStack {
            Form {
                if saved {
                    Section {
                        Label("Saved", systemImage: "checkmark.circle.fill").foregroundStyle(.green).font(.headline)
                        if injuries.contains(FallInjury.fracture.rawValue) {
                            Button("Add this broken bone to my medical history") { addFracture = true }
                        }
                    }
                    AfterFallAdviceSections(compact: true)
                } else {
                    Section {
                        Picker("What happened", selection: $isNearMiss) {
                            Text("I fell").tag(false)
                            Text("Near-miss").tag(true)
                        }
                        .pickerStyle(.segmented)
                        DatePicker("When", selection: $date, in: ...Date())
                        Picker("Where", selection: $location) {
                            ForEach(FallLocation.allCases) { Text($0.label).tag($0) }
                        }
                        TextField("What were you doing? (e.g. walking to the bathroom at night)", text: $activity, axis: .vertical)
                    } footer: {
                        if isNearMiss { Text("A near-miss is a trip, slip or stumble where you caught yourself before hitting the ground.") }
                    }
                    Section("Why do you think it happened?") {
                        TagPicker(options: FallCause.allCases.map(\.rawValue), selection: $causes,
                                  labels: Dictionary(uniqueKeysWithValues: FallCause.allCases.map { ($0.rawValue, $0.label) }))
                    }
                    if !isNearMiss {
                        Section("Injuries") {
                            TagPicker(options: FallInjury.allCases.map(\.rawValue), selection: $injuries,
                                      labels: Dictionary(uniqueKeysWithValues: FallInjury.allCases.map { ($0.rawValue, $0.label) }))
                            Toggle("I hit my head", isOn: $hitHead)
                            if injuries.contains(FallInjury.fracture.rawValue) {
                                TextField("Which bone?", text: $fractureSite)
                            }
                        }
                        Section("Afterwards") {
                            Toggle("I got up without help", isOn: $gotUpAlone)
                            Toggle("I was on the floor for an hour or more", isOn: $longLie)
                            Picker("Medical care", selection: $care) {
                                ForEach(CareSought.allCases) { Text($0.label).tag($0) }
                            }
                        }
                        if hitHead || injured || !gotUpAlone {
                            Section("Get help if you need it") {
                                WarningRow(warning: SafetyWarning(id: "after-fall", severity: .stop,
                                    message: "Call 911 if you hit your head and take a blood thinner, lost consciousness, can't put weight on a leg, or have severe pain. New pain in your hip, back or wrist after a fall should be checked by a doctor today."))
                            }
                        }
                    }
                    Section("Notes") {
                        TextField("Anything else (footwear, lighting, medicines that day)…", text: $notes, axis: .vertical)
                    }
                }
            }
            .navigationTitle(saved ? "After a fall" : "Record a fall")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if saved {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.bold() }
                } else {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.bold() }
                }
            }
            .sheet(isPresented: $addFracture) { EditFractureView(fracture: nil, initialDate: date) }
        }
    }

    private func save() {
        let fall = FallRecord(date: date, isNearMiss: isNearMiss)
        fall.locationRaw = location.rawValue
        fall.activity = activity
        fall.causesRaw = causes
        if !isNearMiss {
            fall.injuriesRaw = injuries
            fall.fractureSite = fractureSite
            fall.hitHead = hitHead
            fall.couldGetUpAlone = gotUpAlone
            fall.longLie = longLie
            fall.careRaw = care.rawValue
        }
        fall.notes = notes
        context.insert(fall)
        try? context.save()
        if isNearMiss { dismiss() } else { saved = true }
    }
}

struct FallChecklistView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var yes: Set<Int> = []
    @State private var result: Int?

    var body: some View {
        NavigationStack {
            Form {
                if let result {
                    Section {
                        Text("Your score: \(result) of \(FallRiskChecklist.maximum)").font(.title3.bold())
                            .foregroundStyle(FallRiskChecklist.isAtRisk(score: result) ? Color.orange : Color.green)
                        Text(FallRiskChecklist.interpretation(score: result))
                    }
                    let answered = FallRiskChecklist.items.filter { yes.contains($0.id) }
                    if !answered.isEmpty {
                        Section("Why these matter") {
                            ForEach(answered) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.text).font(.subheadline.bold())
                                    Text(item.why).font(.caption)
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        Text("Answer yes or no to each statement.").font(.subheadline)
                    }
                    ForEach(FallRiskChecklist.items) { item in
                        Toggle(isOn: Binding(get: { yes.contains(item.id) }, set: { on in
                            if on { yes.insert(item.id) } else { yes.remove(item.id) }
                        })) {
                            VStack(alignment: .leading) {
                                Text(item.text)
                                Text(item.points == 2 ? "Yes = 2 points" : "Yes = 1 point").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Section {
                        Text("Adapted from the CDC STEADI Stay Independent brochure (Rubenstein et al., 2011).").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Fall risk checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if result == nil {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Score") {
                            let screen = FallRiskScreen(yesItemIDs: yes)
                            context.insert(screen)
                            try? context.save()
                            result = screen.score
                        }
                        .bold()
                    }
                } else {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.bold() }
                }
            }
        }
    }
}

struct HomeSafetyView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        List {
            Section {
                Text("Most falls happen at home. Tick off each item as you sort it out.").font(.subheadline)
            }
            Section {
                ForEach(AfterFallAdvice.homeSafety) { item in
                    Toggle(item.text, isOn: Binding(
                        get: { profile.homeSafetyDoneIDs.contains(item.id) },
                        set: { on in
                            if on { if !profile.homeSafetyDoneIDs.contains(item.id) { profile.homeSafetyDoneIDs.append(item.id) } }
                            else { profile.homeSafetyDoneIDs.removeAll { $0 == item.id } }
                        }))
                    .font(.subheadline)
                }
            } footer: {
                Text("Based on the CDC \"Check for Safety\" home checklist. An occupational therapist can do a full home safety visit — ask your doctor.")
            }
        }
        .navigationTitle("Home safety")
    }
}

struct AfterFallView: View {
    var body: some View {
        List { AfterFallAdviceSections(compact: false) }
            .navigationTitle("After a fall")
    }
}

struct AfterFallAdviceSections: View {
    var compact: Bool

    var body: some View {
        Section("Call 911 if you") {
            BulletList(items: AfterFallAdvice.call911, tint: .red)
            Link(destination: URL(string: "tel:911")!) { Label("Call 911", systemImage: "phone.fill") }.bold()
        }
        Section("See a doctor today if") { BulletList(items: AfterFallAdvice.seeDoctorToday, tint: .orange) }
        if !compact {
            Section("How to get up safely") {
                ForEach(Array(AfterFallAdvice.gettingUp.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(i + 1)").font(.subheadline.bold()).foregroundStyle(.tint)
                        Text(step).font(.subheadline)
                    }
                }
            }
        }
        Section {
            Text("Tell your doctor about every fall, even if you weren't hurt. Falls are often a sign of something that can be treated.")
                .font(.subheadline)
        }
    }
}
