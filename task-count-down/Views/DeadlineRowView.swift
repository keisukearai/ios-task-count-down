import SwiftUI

struct DeadlineRowView: View {
    let item: DeadlineItem
    @Environment(LanguageManager.self) private var lm

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(item.isCompleted ? Color(.systemGray3) : urgencyColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: item.category.icon)
                        .font(.caption)
                        .foregroundStyle(item.isCompleted ? Color(.systemGray3) : item.category.color)
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(1)
                        .strikethrough(item.isCompleted, color: .secondary)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                }

                Label {
                    Text(sharedDateFormatter.string(from: item.targetDate))
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .layoutPriority(1)

            Spacer()

            if item.isCompleted {
                Text("完了")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.systemGray3))
            } else {
                Text(countdownText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(urgencyColor)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(item.isCompleted ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: .black.opacity(item.isCompleted ? 0.02 : 0.06), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .opacity(item.isCompleted ? 0.7 : 1.0)
    }

    private var urgencyColor: Color {
        switch item.urgency {
        case .overdue: return .red
        case .today:   return .blue
        case .soon:    return .orange
        case .future:  return .green
        }
    }

    private var countdownText: String {
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
