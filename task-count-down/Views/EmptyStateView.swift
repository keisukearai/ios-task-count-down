import SwiftUI

struct EmptyStateView: View {
    @Environment(LanguageManager.self) private var lm
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text(lm.l("empty_title"))
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(lm.l("empty_subtitle"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                onAdd()
            } label: {
                Label(lm.l("add_first_button"), systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Color.accentColor, in: Capsule())
            }

            Spacer()
        }
    }
}
