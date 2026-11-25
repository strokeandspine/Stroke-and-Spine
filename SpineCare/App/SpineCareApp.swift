import SwiftUI
import SwiftData

@main
struct SpineCareApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: AppSchema.models)
    }
}

struct RootView: View {
    @Query(sort: \PatientProfile.createdAt) private var profiles: [PatientProfile]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false

    var body: some View {
        Group {
            if let profile = profiles.first, profile.isOnboarded {
                MainTabView(profile: profile)
                    .overlay {
                        if profile.appLockEnabled && !isUnlocked {
                            LockView { isUnlocked = true }
                        }
                    }
            } else {
                OnboardingView(existingProfile: profiles.first)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { isUnlocked = false }
        }
    }
}

struct MainTabView: View {
    @Bindable var profile: PatientProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem { Label("Today", systemImage: "sun.max") }
            TrendsView()
                .tabItem { Label("Trends", systemImage: "chart.xyaxis.line") }
            MedicationsView(profile: profile)
                .tabItem { Label("Medicines", systemImage: "pills") }
            HistoryListView()
                .tabItem { Label("History", systemImage: "list.clipboard") }
            MoreView(profile: profile)
                .tabItem { Label("More", systemImage: "ellipsis.circle") }
        }
    }
}
