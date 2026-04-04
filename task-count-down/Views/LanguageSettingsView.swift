import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    languageRow(.system)
                    languageRow(.english)
                    languageRow(.japanese)
                    languageRow(.chinese)
                    languageRow(.vietnamese)
                    languageRow(.thai)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.l("language_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lm.l("done_button")) { dismiss() }
                }
            }
        }
    }

    private func languageRow(_ language: Language) -> some View {
        VStack(spacing: 0) {
            Button {
                lm.setLanguage(language)
            } label: {
                HStack(spacing: 14) {
                    Text(language.badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 28)
                        .background(lm.currentLanguage == language ? Color.accentColor : Color.secondary,
                                    in: RoundedRectangle(cornerRadius: 6))
                    Text(language.nativeName)
                        .foregroundStyle(.primary)
                    Spacer()
                    if lm.currentLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
            }
            Divider()
                .padding(.leading, 16)
        }
    }
}
