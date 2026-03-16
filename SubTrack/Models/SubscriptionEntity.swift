import CoreData
import Foundation

@objc(SubscriptionEntity)
public class SubscriptionEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionEntity> {
        NSFetchRequest<SubscriptionEntity>(entityName: "SubscriptionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var price: Double
    @NSManaged public var billingDate: Date
    @NSManaged public var categoryRaw: String

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var nextRenewalDate: Date {
        let calendar = Calendar.current
        let now = Date()

        if billingDate >= now {
            return billingDate
        }

        guard let monthDiff = calendar.dateComponents([.month], from: billingDate, to: now).month else {
            return billingDate
        }

        return calendar.date(byAdding: .month, value: monthDiff + 1, to: billingDate) ?? billingDate
    }
}
