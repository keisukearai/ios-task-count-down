import Foundation
import Observation

enum SortOrder: String, CaseIterable {
    case deadline  // 期限が近い順
    case createdAt // 追加日が新しい順
}

@Observable
class DeadlineViewModel {
    private(set) var items: [DeadlineItem] = []
    var sortOrder: SortOrder = .deadline
    private let storage = StorageService()

    let freeLimit: Int = {
        #if DEBUG
        return 100
        #else
        return 3
        #endif
    }()

    init() {
        items = storage.load()
        sort()
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

    func toggleComplete(_ item: DeadlineItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
        sort()
        storage.save(items)
    }

    func canAdd(isPremium: Bool) -> Bool {
        isPremium || items.count < freeLimit
    }

    func applySortOrder(_ order: SortOrder) {
        sortOrder = order
        sort()
    }

    private func sort() {
        switch sortOrder {
        case .deadline:
            items.sort {
                if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
                return $0.daysRemaining < $1.daysRemaining
            }
        case .createdAt:
            items.sort {
                if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
                return $0.createdAt > $1.createdAt
            }
        }
    }
}
