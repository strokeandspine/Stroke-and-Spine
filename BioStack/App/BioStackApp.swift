import SwiftUI
import SwiftData

@main
struct BioStackApp: App {
    @State private var catalog = Catalog.load()
    @State private var health = HealthService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(catalog)
                .environment(health)
        }
        .modelContainer(for: [StackItem.self, DoseLog.self, LabResult.self, EffectNote.self])
    }
}

struct RootView: View {
    @AppStorage("acceptedDisclaimer") private var accepted = false

    var body: some View {
        if accepted {
            TabView {
                TodayView().tabItem { Label("Today", systemImage: "checklist") }
                LibraryView().tabItem { Label("Library", systemImage: "books.vertical") }
                GoalsView().tabItem { Label("Goals", systemImage: "target") }
                LabsView().tabItem { Label("Labs", systemImage: "chart.xyaxis.line") }
                MoreView().tabItem { Label("More", systemImage: "ellipsis.circle") }
            }
            .tint(.teal)
        } else {
            DisclaimerView { accepted = true }
        }
    }
}

struct DisclaimerView: View {
    var onAccept: () -> Void
    @State private var adult = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("BioStack").font(.largeTitle.bold())
                Text("Track supplements, prescriptions and biomarkers, and see what the evidence says about each one.")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 10) {
                    Label("General information, not medical advice.", systemImage: "info.circle")
                    Label("Supplement doses are typical ranges from research. Check with a clinician before starting anything, especially if you take medication, are pregnant or have a health condition.", systemImage: "stethoscope")
                    Label("Prescription and clinical entries are reference only. Your prescriber sets the dose.", systemImage: "cross.case")
                    Label("Your data stays on this iPhone.", systemImage: "lock")
                }
                .font(.callout)
                Toggle("I am 18 or older", isOn: $adult)
                Button("Agree and continue", action: onAccept)
                    .buttonStyle(.borderedProminent)
                    .disabled(!adult)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
    }
}
