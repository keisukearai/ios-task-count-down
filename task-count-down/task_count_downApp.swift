import SwiftUI

@main
struct task_count_downApp: App {
    @State private var viewModel            = DeadlineViewModel()
    @State private var purchaseService      = PurchaseService()
    @State private var languageManager      = LanguageManager()
    @State private var notificationService  = NotificationService()

    var body: some Scene {
        WindowGroup {
            DeadlineListView()
                .environment(viewModel)
                .environment(purchaseService)
                .environment(languageManager)
                .environment(notificationService)
                .onAppear {
                    notificationService.requestPermission()
                }
        }
    }
}
