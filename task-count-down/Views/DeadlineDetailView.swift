import SwiftUI

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy/MM/dd"
    return f
}()

struct DeadlineDetailView: View {
    let itemID: UUID
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false

    private var item: DeadlineItem? {
        viewModel.items.first { $0.id == itemID }
    }

    var body: some View {
        NavigationStack {
            if let item {
                List {
                    Section {
                        HStack(spacing: 6) {
                            Image(systemName: item.category.icon)
                                .foregroundStyle(item.category.color)
                            Text(item.title)
                                .font(.headline)
                        }
                    }

                    Section {
                        LabeledContent(lm.l("date_label")) {
                            Text(dateFormatter.string(from: item.targetDate))
                        }
                        LabeledContent(lm.l("created_at_label")) {
                            Text(dateFormatter.string(from: item.createdAt))
                        }
                    }

                    Section {
                        LabeledContent(lm.l("countdown_label")) {
                            Text(countdownText(for: item))
                                .fontWeight(.bold)
                                .foregroundStyle(urgencyColor(for: item))
                        }
                    }
                }
                .navigationTitle(item.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(lm.l("cancel_button")) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(lm.l("edit_title")) { showingEdit = true }
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    AddEditDeadlineView(item: item, onSave: { dismiss() })
                }
            }
        }
        .onChange(of: item == nil) { _, isNil in
            if isNil { dismiss() }
        }
    }

    private func urgencyColor(for item: DeadlineItem) -> Color {
        switch item.urgency {
        case .overdue: return .red
        case .today:   return .blue
        case .soon:    return .orange
        case .future:  return .green
        }
    }

    private func countdownText(for item: DeadlineItem) -> String {
        let days = item.daysRemaining
        if days == 1 {
            return lm.lf("countdown_future_singular", days)
        } else if days > 1 {
            return lm.lf("countdown_future_plural", days)
        } else if days == 0 {
            return lm.l("countdown_today")
        } else if abs(days) == 1 {
            return lm.lf("countdown_overdue_singular", abs(days))
        } else {
            return lm.lf("countdown_overdue_plural", abs(days))
        }
    }
}
