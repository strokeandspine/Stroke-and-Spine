import SwiftUI
import StoreKit

/// Apple's built-in subscription screen (StoreKit 2). It shows prices, the free trial,
/// renewal terms and Restore, which App Review requires.
struct PaywallView: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(productIDs: Store.productIDs) {
            VStack(spacing: 16) {
                Image(systemName: "figure.strengthtraining.functional")
                    .font(.system(size: 52))
                    .foregroundStyle(.tint)
                Text("Stroke & Spine Premium").font(.title.bold())
                VStack(alignment: .leading, spacing: 10) {
                    Label("Every exercise program, with step-by-step guidance", systemImage: "figure.walk")
                    Label("Programs that adjust to how your back responds", systemImage: "chart.line.uptrend.xyaxis")
                    Label("The full exercise library", systemImage: "books.vertical")
                    Label("90-day and 1-year trends and pattern insights", systemImage: "calendar")
                }
                .font(.subheadline)
                Text("Safety features, check-ins, questionnaires, the medicine log and your spine history are always free.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .subscriptionStoreControlStyle(.prominentPicker)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .cancellation)
        .subscriptionStorePolicyDestination(url: Store.termsURL, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: Store.privacyURL, for: .privacyPolicy)
        .onInAppPurchaseCompletion { _, result in
            if case .success(.success(let verification)) = result {
                if case .verified(let transaction) = verification { await transaction.finish() }
                await store.refresh()
                if store.isPremium { dismiss() }
            }
        }
    }
}

/// Shown in More → Subscription.
struct SubscriptionStatusView: View {
    @Environment(Store.self) private var store
    @State private var showingPaywall = false
    @State private var showingManage = false
    @State private var restoring = false

    var body: some View {
        List {
            Section {
                if store.isPremium {
                    Label(store.activePlanName ?? "Premium", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                    if let date = store.expirationDate {
                        Text(store.willAutoRenew ? "Renews \(date.shortDate)" : "Ends \(date.shortDate)")
                            .foregroundStyle(.secondary)
                    }
                    Button("Manage subscription") { showingManage = true }
                } else {
                    Text("You're using the free version.")
                    Button("See Premium") { showingPaywall = true }.bold()
                }
            }
            Section {
                Button(restoring ? "Restoring…" : "Restore purchases") {
                    restoring = true
                    Task { await store.restore(); restoring = false }
                }
                .disabled(restoring)
            } footer: {
                Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel any time in Settings → Apple ID → Subscriptions.")
            }
        }
        .navigationTitle("Subscription")
        .sheet(isPresented: $showingPaywall) { PaywallView() }
        .manageSubscriptionsSheet(isPresented: $showingManage)
        .task { await store.refresh() }
    }
}

/// A row/card that opens the paywall for a locked feature.
struct PremiumLockedRow: View {
    let title: String
    @State private var showingPaywall = false

    var body: some View {
        Button { showingPaywall = true } label: {
            HStack {
                Text(title)
                Spacer()
                Label("Premium", systemImage: "lock.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
}
