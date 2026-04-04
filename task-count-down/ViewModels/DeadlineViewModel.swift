import Foundation
import Observation

@Observable
class DeadlineViewModel {
    private(set) var items: [DeadlineItem] = []
    private let storage = StorageService()
    let freeLimit: Int = {
        #if DEBUG
        return 100  // no practical limit during development
        #else
        return 3
        #endif
    }()

    init() {
        items = storage.load().sorted { $0.daysRemaining < $1.daysRemaining }
    }

    func add(_ item: DeadlineItem) {
        items.append(item)
        sort()
        storage.save(items)
    }

    func update(_ item: DeadlineItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        sort()
        storage.save(items)
    }

    func delete(_ item: DeadlineItem) {
        items.removeAll { $0.id == item.id }
        storage.save(items)
    }

    func canAdd(isPremium: Bool) -> Bool {
        isPremium || items.count < freeLimit
    }

    private func sort() {
        items.sort { $0.daysRemaining < $1.daysRemaining }
    }
}
