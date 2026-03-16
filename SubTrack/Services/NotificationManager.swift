import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminder(for subscription: SubscriptionEntity) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming billing reminder"
        content.body = "\(subscription.name) renews tomorrow for \(Self.currencyString(from: subscription.price))."
        content.sound = .default

        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: subscription.nextRenewalDate) ?? subscription.nextRenewalDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: subscription.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeReminder(for subscription: SubscriptionEntity) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [subscription.id.uuidString])
    }

    private static func currencyString(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
