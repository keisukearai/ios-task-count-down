import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(LanguageManager.self) private var lm
    @Environment(\.dismiss) private var dismiss
    @State private var product: Product?
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    featuresSection
                    Spacer(minLength: 0)
                    purchaseSection
                }
                .padding(.vertical, 24)
            }
            .navigationTitle(lm.l("paywall_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.l("cancel_button")) { dismiss() }
                }
            }
        }
        .task {
            product = await purchaseService.loadProduct()
        }
        .alert(lm.l("error_title"), isPresented: $showingError) {
            Button(lm.l("ok_button")) {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: purchaseService.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text(lm.l("paywall_title"))
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(lm.l("paywall_subtitle"))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "infinity", text: lm.l("feature_unlimited"))
        }
        .padding(20)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await performPurchase() }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(purchaseButtonLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor)
                )
            }
            .disabled(isPurchasing)
            .padding(.horizontal)

            Button(lm.l("restore_button")) {
                Task { await performRestore() }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Link(lm.l("privacy_policy"), destination: URL(string: "https://kotoragk.com/taskcountdown/privacy")!)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var purchaseButtonLabel: String {
        if let product {
            return lm.lf("purchase_button", product.displayPrice)
        }
        return lm.l("purchase_button_loading")
    }

    private func performPurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchaseService.purchase()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }

    private func performRestore() async {
        do {
            try await purchaseService.restore()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            Text(text)
                .font(.body)
        }
    }
}
