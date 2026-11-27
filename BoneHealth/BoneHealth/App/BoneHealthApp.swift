import SwiftUI
import SwiftData

@main
struct BoneHealthApp: App {
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
            RecordsView(profile: profile)
                .tabItem { Label("Records", systemImage: "folder.badge.person.crop") }
            MedicinesView(profile: profile)
                .tabItem { Label("Medicines", systemImage: "pills") }
            ExerciseHomeView()
                .tabItem { Label("Exercise", systemImage: "figure.strengthtraining.functional") }
            MoreView(profile: profile)
                .tabItem { Label("More", systemImage: "ellipsis.circle") }
        }
    }
}
