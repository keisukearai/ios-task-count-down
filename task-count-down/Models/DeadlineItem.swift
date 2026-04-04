import Foundation

struct DeadlineItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var targetDate: Date
    var createdAt: Date = Date()
    var category: DeadlineCategory = .other
    var color: String = "blue"
    var note: String = ""

    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }

    var urgency: Urgency {
        let days = daysRemaining
        if days < 0 { return .overdue }
        if days == 0 { return .today }
        if days <= 7 { return .soon }
        return .future
    }

    enum Urgency {
        case overdue, today, soon, future
    }
}
