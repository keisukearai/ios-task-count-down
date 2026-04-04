import Foundation

struct StorageService {
    private let key = "deadline_items_v1"

    func load() -> [DeadlineItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([DeadlineItem].self, from: data) else {
            return []
        }
        return items
    }

    func save(_ items: [DeadlineItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
