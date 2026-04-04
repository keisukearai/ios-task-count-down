//
//  task_count_downApp.swift
//  task-count-down
//
//  Created by keisuke arai on 2026/04/04.
//

import SwiftUI

@main
struct task_count_downApp: App {
    @State private var viewModel       = DeadlineViewModel()
    @State private var purchaseService = PurchaseService()
    @State private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            DeadlineListView()
                .environment(viewModel)
                .environment(purchaseService)
                .environment(languageManager)
        }
    }
}
