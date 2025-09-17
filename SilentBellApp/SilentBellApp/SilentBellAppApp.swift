//
//  SilentBellAppApp.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/4/25.
//

import SwiftUI
import SwiftData

@main
struct SilentBellAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group{
                if authViewModel.isAuthenticated {
                    HomeView()
                } else {
                    LoginView(viewModel: authViewModel)
                }
            }
            .onAppear {
                        // Auto-login if token exists and valid
                        if let expiry = TokenStorage.shared.getExpiryDate(),
                           expiry > Date(),
                           TokenStorage.shared.getAccessToken() != nil {
                            authViewModel.isAuthenticated = true
                        }
                    }
            
        }
        .modelContainer(sharedModelContainer)
    }
}
