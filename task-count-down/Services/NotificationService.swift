import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {
    private static let enabledKey  = "notification_global_enabled"
    private static let hourKey     = "notification_hour"
    private static let minuteKey   = "notification_minute"

    var globalEnabled: Bool {
        didSet { UserDefaults.standard.set(globalEnabled, forKey: Self.enabledKey) }
    }

    var notificationTime: Date {
        didSet {
            let c = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            UserDefaults.standard.set(c.hour   ?? 9, forKey: Self.hourKey)
            UserDefaults.standard.set(c.minute ?? 0, forKey: Self.minuteKey)
        }
    }

    init() {
        globalEnabled = UserDefaults.standard.object(forKey: Self.enabledKey) != nil
            ? UserDefaults.standard.bool(forKey: Self.enabledKey)
            : true

        let hour   = UserDefaults.standard.object(forKey: Self.hourKey)   != nil
            ? UserDefaults.standard.integer(forKey: Self.hourKey)   : 9
        let minute = UserDefaults.standard.object(forKey: Self.minuteKey) != nil
            ? UserDefaults.standard.integer(forKey: Self.minuteKey) : 0

        var comps = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        notificationTime = Calendar.current.date(from: comps) ?? Date()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(for item: DeadlineItem) {
        cancel(for: item)
        guard globalEnabled, item.notificationEnabled, !item.isCompleted else { return }

        let calendar = Calendar.current
        let timeComps = calendar.dateComponents([.hour, .minute], from: notificationTime)
        var trigger = calendar.dateComponents([.year, .month, .day], from: item.targetDate)
        trigger.hour   = timeComps.hour
        trigger.minute = timeComps.minute
        trigger.second = 0

        guard let fireDate = calendar.date(from: trigger), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body  = NSLocalizedString("notification_body", comment: "")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(for item: DeadlineItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [item.id.uuidString]
        )
    }

    func rescheduleAll(items: [DeadlineItem]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard globalEnabled else { return }
        items
            .filter { !$0.isCompleted && $0.notificationEnabled }
            .sorted { $0.targetDate < $1.targetDate }
            .prefix(64)
            .forEach { schedule(for: $0) }
    }
}
