import SwiftUI

struct DeadlineListView: View {
    @Environment(DeadlineViewModel.self) private var viewModel
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(LanguageManager.self) private var lm
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingLanguage = false
    @State private var detailItem: DeadlineItem?
    @State private var selectedCategory: DeadlineCategory? = nil

    private var filteredItems: [DeadlineItem] {
        guard let cat = selectedCategory else { return viewModel.items }
        return viewModel.items.filter { $0.category == cat }
    }

    private func itemCount(for category: DeadlineCategory) -> Int {
        viewModel.items.filter { $0.category == category }.count
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
                    HStack(spacing: 12) {
                        if purchaseService.isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                        // ソートメニュー
                        Menu {
                            Button {
                                viewModel.applySortOrder(.deadline)
                            } label: {
                                Label(lm.l("sort_by_deadline"), systemImage: "calendar")
                                if viewModel.sortOrder == .deadline {
                                    Image(systemName: "checkmark")
                                }
                            }
                            Button {
                                viewModel.applySortOrder(.createdAt)
                            } label: {
                                Label(lm.l("sort_by_created"), systemImage: "plus.circle")
                                if viewModel.sortOrder == .createdAt {
                                    Image(systemName: "checkmark")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        Button { handleAddTap() } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
        // フィルター中に追加 → そのカテゴリを引き継ぎ、フィルターはそのまま維持
        .sheet(isPresented: $showingAdd) {
            AddEditDeadlineView(item: nil, initialCategory: selectedCategory)
        }
        .sheet(item: $detailItem) { item in DeadlineDetailView(itemID: item.id) }
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
                            .onTapGesture { detailItem = item }
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
                           color: Color(.systemGray), count: viewModel.items.count,
                           isSelected: selectedCategory == nil) { selectedCategory = nil }

                filterChip(label: lm.l("category_none"),     icon: DeadlineCategory.none.icon,    color: DeadlineCategory.none.color,    count: itemCount(for: .none),    isSelected: selectedCategory == .none)    { selectedCategory = selectedCategory == .none    ? nil : .none    }
                filterChip(label: lm.l("category_work"),     icon: DeadlineCategory.work.icon,     color: DeadlineCategory.work.color,     count: itemCount(for: .work),     isSelected: selectedCategory == .work)     { selectedCategory = selectedCategory == .work     ? nil : .work     }
                filterChip(label: lm.l("category_personal"), icon: DeadlineCategory.personal.icon, color: DeadlineCategory.personal.color, count: itemCount(for: .personal), isSelected: selectedCategory == .personal) { selectedCategory = selectedCategory == .personal ? nil : .personal }
                filterChip(label: lm.l("category_study"),    icon: DeadlineCategory.study.icon,    color: DeadlineCategory.study.color,    count: itemCount(for: .study),    isSelected: selectedCategory == .study)    { selectedCategory = selectedCategory == .study    ? nil : .study    }
                filterChip(label: lm.l("category_travel"),   icon: DeadlineCategory.travel.icon,   color: DeadlineCategory.travel.color,   count: itemCount(for: .travel),   isSelected: selectedCategory == .travel)   { selectedCategory = selectedCategory == .travel   ? nil : .travel   }
                filterChip(label: lm.l("category_finance"),  icon: DeadlineCategory.finance.icon,  color: DeadlineCategory.finance.color,  count: itemCount(for: .finance),  isSelected: selectedCategory == .finance)  { selectedCategory = selectedCategory == .finance  ? nil : .finance  }
                filterChip(label: lm.l("category_health"),   icon: DeadlineCategory.health.icon,   color: DeadlineCategory.health.color,   count: itemCount(for: .health),   isSelected: selectedCategory == .health)   { selectedCategory = selectedCategory == .health   ? nil : .health   }
                filterChip(label: lm.l("category_hobby"),    icon: DeadlineCategory.hobby.icon,    color: DeadlineCategory.hobby.color,    count: itemCount(for: .hobby),    isSelected: selectedCategory == .hobby)    { selectedCategory = selectedCategory == .hobby    ? nil : .hobby    }
                filterChip(label: lm.l("category_family"),   icon: DeadlineCategory.family.icon,   color: DeadlineCategory.family.color,   count: itemCount(for: .family),   isSelected: selectedCategory == .family)   { selectedCategory = selectedCategory == .family   ? nil : .family   }
                filterChip(label: lm.l("category_event"),    icon: DeadlineCategory.event.icon,    color: DeadlineCategory.event.color,    count: itemCount(for: .event),    isSelected: selectedCategory == .event)    { selectedCategory = selectedCategory == .event    ? nil : .event    }
                filterChip(label: lm.l("category_other"),    icon: DeadlineCategory.other.icon,    color: DeadlineCategory.other.color,    count: itemCount(for: .other),    isSelected: selectedCategory == .other)    { selectedCategory = selectedCategory == .other    ? nil : .other    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(label: String, icon: String, color: Color,
                             count: Int, isSelected: Bool,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : color)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .primary)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption).fontWeight(.bold)
                        .foregroundStyle(isSelected ? color : .secondary)
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(isSelected ? .white.opacity(0.9) : Color(.systemGray4), in: Capsule())
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(isSelected ? color : Color(.systemGray5), in: Capsule())
        }
        .opacity(count == 0 ? 0.4 : 1.0)
    }

    private var emptyFilterView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray").font(.system(size: 40)).foregroundStyle(.secondary)
            Text(lm.l("filter_empty")).foregroundStyle(.secondary)
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
        .padding(.horizontal).padding(.vertical, 8)
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
