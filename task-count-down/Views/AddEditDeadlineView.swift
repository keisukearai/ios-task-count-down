import SwiftUI

struct AddEditDeadlineView: View {
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(NotificationService.self) private var notificationService
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    let item: DeadlineItem?
    var initialCategory: DeadlineCategory? = nil
    var onSave: (() -> Void)? = nil

    @State private var title: String = ""
    @State private var targetDate: Date = Date().addingTimeInterval(86400)
    @State private var hasTime: Bool = false
    @State private var category: DeadlineCategory = .none
    @State private var notificationEnabled: Bool = true
    @State private var note: String = ""
    @State private var showingDeleteConfirm = false

    private var isEditing: Bool { item != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(lm.l("section_title")) {
                    TextField(lm.l("title_placeholder"), text: $title)
                }

                Section(lm.l("section_category")) {
                    Picker(lm.l("section_category"), selection: $category) {
                        ForEach(DeadlineCategory.allCases, id: \.rawValue) { cat in
                            Label {
                                Text(lm.l(cat.localizedKey))
                            } icon: {
                                Image(systemName: cat.icon)
                                    .foregroundStyle(cat.color)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section(lm.l("section_date")) {
                    if item?.isCompleted == true {
                        LabeledContent(lm.l("date_label")) {
                            Text(sharedDateFormatter.string(from: targetDate))
                        }
                        if hasTime {
                            LabeledContent(lm.l("time_label")) {
                                Text(sharedTimeFormatter.string(from: targetDate))
                            }
                        }
                    } else {
                        if sizeClass == .regular {
                            DatePicker(
                                lm.l("date_label"),
                                selection: $targetDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        } else {
                            DatePicker(
                                lm.l("date_label"),
                                selection: $targetDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }

                        Toggle(lm.l("time_toggle"), isOn: $hasTime)

                        if hasTime {
                            DatePicker(
                                lm.l("time_toggle"),
                                selection: $targetDate,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }
                    }
                }

                Section(lm.l("section_note")) {
                    TextField(lm.l("note_placeholder"), text: $note, axis: .vertical)
                        .lineLimit(4...)
                }

                Section(lm.l("section_notification")) {
                    Toggle(lm.l("notification_task_toggle"), isOn: $notificationEnabled)
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Text(lm.l("delete_button"))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? lm.l("edit_title") : lm.l("add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.l("cancel_button")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lm.l("save_button")) { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog(
                lm.l("delete_confirm_title"),
                isPresented: $showingDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(lm.l("delete_button"), role: .destructive) {
                    if let item {
                        notificationService.cancel(for: item)
                        viewModel.delete(item)
                    }
                    dismiss()
                }
                Button(lm.l("cancel_button"), role: .cancel) {}
            } message: {
                Text(lm.l("delete_confirm_message"))
            }
        }
        .presentationDetents([.large])
        .onAppear {
            if let item {
                title               = item.title
                targetDate          = item.targetDate
                hasTime             = item.hasTime
                category            = item.category
                notificationEnabled = item.notificationEnabled
                note                = item.note
            } else {
                category = initialCategory ?? .none
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let date = hasTime ? targetDate : Calendar.current.startOfDay(for: targetDate)

        if var existing = item {
            existing.title               = trimmed
            existing.targetDate          = date
            existing.hasTime             = hasTime
            existing.category            = category
            existing.notificationEnabled = notificationEnabled
            existing.note                = note
            viewModel.update(existing)
            notificationService.schedule(for: existing)
        } else {
            var newItem = DeadlineItem(title: trimmed, targetDate: date)
            newItem.hasTime             = hasTime
            newItem.category            = category
            newItem.notificationEnabled = notificationEnabled
            newItem.note                = note
            viewModel.add(newItem)
            notificationService.schedule(for: newItem)
        }
        onSave?()
        dismiss()
    }
}
