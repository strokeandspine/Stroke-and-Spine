import SwiftUI

@main
struct SmoothieLabApp: App {
    @State private var store = RecipeStore()
    @State private var favorites = Favorites()
    @AppStorage("acceptedDisclaimer") private var acceptedDisclaimer = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(favorites)
                .sheet(isPresented: Binding(get: { !acceptedDisclaimer }, set: { _ in })) {
                    WelcomeView { acceptedDisclaimer = true }
                        .interactiveDismissDisabled()
                }
        }
    }
}

struct RootView: View {
    @Environment(RecipeStore.self) private var store

    var body: some View {
        if let error = store.loadError {
            ContentUnavailableView("Recipes unavailable", systemImage: "exclamationmark.triangle", description: Text(error))
        } else {
            TabView {
                GoalsView()
                    .tabItem { Label("Goals", systemImage: "target") }
                BrowseView()
                    .tabItem { Label("Recipes", systemImage: "list.bullet") }
                SavedView()
                    .tabItem { Label("Saved", systemImage: "heart") }
                GuideView()
                    .tabItem { Label("Guide", systemImage: "book") }
            }
        }
    }
}

/// Shown once on first launch.
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text("Smoothie Lab").font(.largeTitle.bold())
            Text("Flavorful, high-protein smoothies built from whole foods, organized by your goal — with calories and macros for every recipe.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                Label("Recipes are general nutrition information, not medical advice.", systemImage: "info.circle")
                Label("Check with your doctor before using supplements if you are pregnant, nursing, under 18, take medicines or have kidney, liver or heart conditions.", systemImage: "cross.case")
                Label("Always check ingredient labels for allergens.", systemImage: "exclamationmark.triangle")
            }
            .font(.subheadline)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            Spacer()
            Button(action: onContinue) {
                Text("I understand").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
    }
}
