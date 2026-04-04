import SwiftUI

struct DeadlineListView: View {
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(LanguageManager.self) private var lm
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingLanguage = false
    @State private var editingItem: DeadlineItem?
    @State private var selectedCategory: DeadlineCategory? = nil

    private var filteredItems: [DeadlineItem] {
        guard let cat = selectedCategory else { return viewModel.items }
        return viewModel.items.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    EmptyStateView { handleAddTap() }
                } else {
                    listContent
                }
            }
            .navigationTitle(lm.l("list_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingLanguage = true } label: {
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
                        Button { handleAddTap() } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdd) { AddEditDeadlineView(item: nil) }
        .sheet(item: $editingItem) { item in AddEditDeadlineView(item: item) }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
        .sheet(isPresented: $showingLanguage) { LanguageSettingsView() }
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !purchaseService.isPremium {
                    freeUsageBanner
                }
                categoryFilter
                if filteredItems.isEmpty {
                    emptyFilterView
                } else {
                    ForEach(filteredItems) { item in
                        DeadlineRowView(item: item)
                            .onTapGesture { editingItem = item }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: lm.l("filter_all"), icon: "tray.full.fill",
                           color: .primary, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(DeadlineCategory.allCases, id: \.rawValue) { cat in
                    filterChip(label: lm.l(cat.localizedKey), icon: cat.icon,
                               color: cat.color, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(label: String, icon: String, color: Color,
                             isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2)
                Text(label).font(.caption).fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? color : color.opacity(0.12),
                        in: Capsule())
        }
    }

    private var emptyFilterView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(lm.l("filter_empty"))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }

    private var freeUsageBanner: some View {
        HStack {
            Image(systemName: "info.circle").foregroundStyle(.secondary)
            Text(lm.lf("free_usage_banner", viewModel.items.count, viewModel.freeLimit))
                .font(.caption).foregroundStyle(.secondary)
            Spacer()
            Button(lm.l("upgrade_button")) { showingPaywall = true }
                .font(.caption).fontWeight(.semibold)
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
