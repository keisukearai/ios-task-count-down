import SwiftUI

struct DeadlineRowView: View {
    let item: DeadlineItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(urgencyColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.targetDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(countdownText)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(urgencyColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var urgencyColor: Color {
        switch item.urgency {
        case .overdue: return .red
        case .today: return .blue
        case .soon: return .orange
        case .future: return .green
        }
    }

    private var countdownText: String {
        let days = item.daysRemaining
        if days == 1 {
            return String(format: String(localized: "countdown_future_singular"), days)
        } else if days > 1 {
            return String(format: String(localized: "countdown_future_plural"), days)
        } else if days == 0 {
            return String(localized: "countdown_today")
        } else if abs(days) == 1 {
            return String(format: String(localized: "countdown_overdue_singular"), abs(days))
        } else {
            return String(format: String(localized: "countdown_overdue_plural"), abs(days))
        }
    }
}

#Preview {
    let future = DeadlineItem(title: "Exam", targetDate: Date().addingTimeInterval(86400 * 5))
    let today = DeadlineItem(title: "Meeting", targetDate: Date())
    let overdue = DeadlineItem(title: "Invoice", targetDate: Date().addingTimeInterval(-86400 * 3))

    return VStack {
        DeadlineRowView(item: future)
        DeadlineRowView(item: today)
        DeadlineRowView(item: overdue)
    }
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
