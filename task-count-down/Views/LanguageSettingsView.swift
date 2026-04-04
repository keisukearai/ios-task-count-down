import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    languageRow(.system)
                    languageRow(.english)
                    languageRow(.japanese)
                    languageRow(.chinese)
                    languageRow(.vietnamese)
                    languageRow(.thai)
                }
            }
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
        Button {
            lm.setLanguage(language)
        } label: {
            HStack(spacing: 14) {
                Text(language.flagEmoji)
                    .font(.title2)
                Text(language.nativeName)
                    .foregroundStyle(.primary)
                Spacer()
                if lm.currentLanguage == language {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
