import SwiftUI
import UserNotifications

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var lm
    @Environment(NotificationService.self) private var notificationService
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var notificationTime: Date = Date()
    @State private var notificationDenied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    notificationSection
                    languageSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.l("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lm.l("done_button")) { dismiss() }
                }
            }
            .onAppear {
                notificationTime = notificationService.notificationTime
            }
            .task {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                notificationDenied = settings.authorizationStatus == .denied
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lm.l("notification_section"))
                .font(.footnote).foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: "bell.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.orange, in: RoundedRectangle(cornerRadius: 6))
                    Text(lm.l("notification_enabled_toggle"))
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { notificationService.globalEnabled },
                        set: { newValue in
                            notificationService.globalEnabled = newValue
                            notificationService.rescheduleAll(items: viewModel.items)
                        }
                    ))
                    .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))

                if notificationService.globalEnabled {
                    Divider().padding(.leading, 16)

                    HStack(spacing: 14) {
                        Image(systemName: "clock.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 6))
                        Text(lm.l("notification_time_label"))
                            .foregroundStyle(.primary)
                        Spacer()
                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: notificationTime) { _, newValue in
                                notificationService.notificationTime = newValue
                                notificationService.rescheduleAll(items: viewModel.items)
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }

                if notificationDenied {
                    Divider().padding(.leading, 16)

                    Button {
                        if let url = URL(string: "app-settings:") {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(lm.l("notification_open_settings"))
                                .font(.footnote)
                                .foregroundStyle(.orange)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lm.l("language_section"))
                .font(.footnote).foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                languageRow(.system)
                languageRow(.english)
                languageRow(.japanese)
                languageRow(.chinese)
                languageRow(.vietnamese)
                languageRow(.thai)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
