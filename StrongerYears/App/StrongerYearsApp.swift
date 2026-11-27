import SwiftUI
import SwiftData

@main
struct StrongerYearsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: AppSchema.models)
    }
}

struct RootView: View {
    @Query(sort: \TrainerProfile.createdAt) private var profiles: [TrainerProfile]

    var body: some View {
        Group {
            if let profile = profiles.first, profile.isOnboarded {
                MainTabView(profile: profile)
                    // Seniors' default: one size larger than the system setting, still respecting Dynamic Type.
                    .dynamicTypeSize(profile.largerText ? TextSizes.larger : TextSizes.standard)
            } else {
                OnboardingView(existingProfile: profiles.first)
                    .dynamicTypeSize(TextSizes.larger)
            }
        }
    }
}

struct MainTabView: View {
    @Bindable var profile: TrainerProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem { Label("Today", systemImage: "sun.max") }
            PlanView(profile: profile)
                .tabItem { Label("My plan", systemImage: "calendar") }
            LogView()
                .tabItem { Label("Log", systemImage: "list.bullet.clipboard") }
            LearnView()
                .tabItem { Label("Learn", systemImage: "book") }
            SettingsView(profile: profile)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

enum TextSizes {
    static let larger: ClosedRange<DynamicTypeSize> = DynamicTypeSize.xLarge ... DynamicTypeSize.accessibility3
    static let standard: ClosedRange<DynamicTypeSize> = DynamicTypeSize.xSmall ... DynamicTypeSize.accessibility3
}

enum AppInfo {
    static let name = "Stronger Years"
    static let disclaimer = "Stronger Years gives general exercise information for older adults. It isn't medical advice and doesn't replace your doctor or physical therapist. Check with your doctor before starting a new exercise program, especially if you have a health condition. Stop exercising and get help if you feel chest pain, severe shortness of breath, dizziness or faintness."
}
