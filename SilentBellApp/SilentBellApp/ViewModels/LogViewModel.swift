//
//  LogViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 11/3/25.
//

import SwiftUI


@MainActor
class LogViewModel: ObservableObject {
    @Published var logs: [Log] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchLogs() async {
        isLoading = true
        errorMessage = nil
//        defer { isLoading = false }
        
        do {
            let fetched = try await APIService().fetchLogs()
            logs = fetched
        } catch {
            errorMessage = "Failed to fetch logs: \(error.localizedDescription)"
            print("⚠️ Error fetching logs:", error)
        }
        
        isLoading = false
    }
}
