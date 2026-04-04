import SwiftUI

struct AddEditDeadlineView: View {
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss

    let item: DeadlineItem?

    @State private var title: String = ""
    @State private var targetDate: Date = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
    @State private var showingDeleteConfirm = false

    private var isEditing: Bool { item != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(lm.l("section_title")) {
                    TextField(lm.l("title_placeholder"), text: $title)
                }

                Section(lm.l("section_date")) {
                    DatePicker(
                        lm.l("date_label"),
                        selection: $targetDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
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
                    if let item { viewModel.delete(item) }
                    dismiss()
                }
                Button(lm.l("cancel_button"), role: .cancel) {}
            } message: {
                Text(lm.l("delete_confirm_message"))
            }
        }
        .onAppear {
            if let item {
                title = item.title
                targetDate = item.targetDate
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if var existing = item {
            existing.title = trimmed
            existing.targetDate = targetDate
            viewModel.update(existing)
        } else {
            viewModel.add(DeadlineItem(title: trimmed, targetDate: targetDate))
        }
        dismiss()
    }
}
