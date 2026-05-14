import Foundation

let sharedDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy/MM/dd"
    return f
}()

let sharedTimeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f
}()

struct DeadlineItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var targetDate: Date
    var createdAt: Date = Date()
    var category: DeadlineCategory = .none
    var color: String = "blue"
    var note: String = ""
    var isCompleted: Bool = false
    var hasTime: Bool = false
    var notificationEnabled: Bool = true

    init(title: String, targetDate: Date) {
        self.title = title
        self.targetDate = targetDate
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                  = try c.decodeIfPresent(UUID.self,             forKey: .id)                  ?? UUID()
        title               = try c.decode(String.self,                    forKey: .title)
        targetDate          = try c.decode(Date.self,                      forKey: .targetDate)
        createdAt           = try c.decodeIfPresent(Date.self,             forKey: .createdAt)           ?? Date()
        category            = try c.decodeIfPresent(DeadlineCategory.self, forKey: .category)           ?? .none
        color               = try c.decodeIfPresent(String.self,           forKey: .color)               ?? "blue"
        note                = try c.decodeIfPresent(String.self,           forKey: .note)                ?? ""
        isCompleted         = try c.decodeIfPresent(Bool.self,             forKey: .isCompleted)         ?? false
        hasTime             = try c.decodeIfPresent(Bool.self,             forKey: .hasTime)             ?? false
        notificationEnabled = try c.decodeIfPresent(Bool.self,             forKey: .notificationEnabled) ?? true
    }

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
