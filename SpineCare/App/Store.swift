import Foundation
import StoreKit
import Observation

/// Premium subscription using StoreKit 2. There is no server: the App Store's signed
/// transactions on the device decide whether Premium is active.
///
/// Free forever: daily check-ins, questionnaires, warning-sign check, crisis support,
/// medicine log and limits, spine history, 30-day trends, appointment report, the
/// "Getting started" and "After surgery: early recovery" programs.
///
/// Premium: every exercise program and the full exercise library, 90-day and 1-year
/// trends, and pattern insights.
@Observable
final class Store {
    static let monthlyID = "com.strokeandspine.spinecare.premium.monthly"
    static let annualID = "com.strokeandspine.spinecare.premium.annual"
    static let productIDs = [monthlyID, annualID]
    static let subscriptionGroupName = "Premium"

    static var termsURL: URL { AppLinks.terms }
    static var privacyURL: URL { AppLinks.privacy }

    private(set) var isPremium = false
    private(set) var activeProductID: String?
    private(set) var expirationDate: Date?
    private(set) var willAutoRenew = true

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            // Renewals, refunds, Ask to Buy approvals and purchases made on other devices.
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self?.refresh()
            }
        }
        Task { [weak self] in await self?.refresh() }
    }

    deinit { updatesTask?.cancel() }

    var activePlanName: String? {
        switch activeProductID {
        case Self.monthlyID: return "Premium (monthly)"
        case Self.annualID: return "Premium (annual)"
        default: return nil
        }
    }

    @MainActor
    func refresh() async {
        var premium = false
        var productID: String?
        var expiration: Date?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil else { continue }
            if let expires = transaction.expirationDate, expires < Date() { continue }
            premium = true
            productID = transaction.productID
            expiration = transaction.expirationDate
        }
        var autoRenew = true
        if let productID,
           let product = try? await Product.products(for: [productID]).first,
           let statuses = try? await product.subscription?.status {
            for status in statuses {
                if case .verified(let info) = status.renewalInfo { autoRenew = info.willAutoRenew }
            }
        }
        isPremium = premium
        activeProductID = productID
        expirationDate = expiration
        willAutoRenew = autoRenew
    }

    /// "Restore purchases" — required by App Review.
    @MainActor
    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }
}
