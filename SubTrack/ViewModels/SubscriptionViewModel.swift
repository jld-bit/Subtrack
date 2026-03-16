import CoreData
import Foundation

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var name = ""
    @Published var price = ""
    @Published var billingDate = Date()
    @Published var category: SubscriptionCategory = .entertainment

    func addSubscription(
        context: NSManagedObjectContext,
        purchaseManager: PurchaseManager,
        currentCount: Int
    ) -> Bool {
        if !purchaseManager.hasUnlimitedAccess && currentCount >= 5 {
            return false
        }

        guard let parsedPrice = Double(price), parsedPrice > 0, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let item = SubscriptionEntity(context: context)
        item.id = UUID()
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.price = parsedPrice
        item.billingDate = billingDate
        item.category = category

        save(context)
        NotificationManager.shared.scheduleReminder(for: item)
        resetForm()
        return true
    }

    func delete(_ subscription: SubscriptionEntity, context: NSManagedObjectContext) {
        NotificationManager.shared.removeReminder(for: subscription)
        context.delete(subscription)
        save(context)
    }

    func totalMonthlySpending(for items: [SubscriptionEntity]) -> Double {
        items.reduce(0) { $0 + $1.price }
    }

    func categoryTotals(for items: [SubscriptionEntity]) -> [(String, Double)] {
        let grouped = Dictionary(grouping: items, by: { $0.category.title })
        return grouped
            .map { key, value in (key, value.reduce(0) { $0 + $1.price }) }
            .sorted(by: { $0.1 > $1.1 })
    }

    private func resetForm() {
        name = ""
        price = ""
        billingDate = Date()
        category = .entertainment
    }

    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
