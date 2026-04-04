import SwiftUI

struct DeadlineListView: View {
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(LanguageManager.self) private var lm
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingLanguage = false
    @State private var editingItem: DeadlineItem?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    EmptyStateView {
                        handleAddTap()
                    }
                } else {
                    listContent
                }
            }
            .navigationTitle(lm.l("list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingLanguage = true
                    } label: {
                        Image(systemName: "globe")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
                        if purchaseService.isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                        Button {
                            handleAddTap()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditDeadlineView(item: nil)
        }
        .sheet(item: $editingItem) { item in
            AddEditDeadlineView(item: item)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingLanguage) {
            LanguageSettingsView()
        }
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !purchaseService.isPremium {
                    freeUsageBanner
                }
                ForEach(viewModel.items) { item in
                    DeadlineRowView(item: item)
                        .onTapGesture {
                            editingItem = item
                        }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var freeUsageBanner: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text(lm.lf("free_usage_banner", viewModel.items.count, viewModel.freeLimit))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button(lm.l("upgrade_button")) {
                showingPaywall = true
            }
            .font(.caption)
            .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private func handleAddTap() {
        if viewModel.canAdd(isPremium: purchaseService.isPremium) {
            showingAdd = true
        } else {
            showingPaywall = true
        }
    }
}
