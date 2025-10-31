//
//  SettingView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//

import Foundation
import SwiftUI

struct SettingView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    
    @StateObject private var settingViewModel = SettingsViewModel()

    @State private var showLogoutAlert = false
    
    // --- 1. Define the gradient and colors from your design ---
    let appGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.63, green: 1.0, blue: 0.81), // Minty Green
            Color(red: 0.98, green: 1.0, blue: 0.69)  // Light Yellow
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let titleColor = Color(red: 0.3, green: 0.1, blue: 0.5) // Custom Purple
    let rowBackgroundColor = Color.white.opacity(0.7) // Semi-transparent white for rows

    var body: some View {
        // --- 2. Wrap in a ZStack to add the gradient background ---
        ZStack {
            appGradient
                .ignoresSafeArea()
            
            NavigationStack {
                // --- 3. Change Form to List to allow styling ---
                List {
                    // MARK: - Account
                    Section(header: Text("Account")
                        .foregroundColor(titleColor) // Style header
                        .fontWeight(.medium)
                    ) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(titleColor) // Use theme color
                            VStack(alignment: .leading) {
                                Text("SilentBell User")
                                    .font(.headline)
                                    .foregroundColor(titleColor) // Use theme color
                                Text("user@email.com")
                                    .font(.subheadline)
                                    .foregroundColor(titleColor.opacity(0.7)) // Use theme color
                            }
                        }
                        
                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Text("Log Out")
                        }
                    }
                    .listRowBackground(rowBackgroundColor) // Make rows semi-transparent
                    .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Log Out", role: .destructive) {
                            viewModel.logout()
                            print("User logged out")
                        }
                    }
                    
                    // MARK: - Notifications
                    Section(header: Text("Notifications")
                        .foregroundColor(titleColor) // Style header
                        .fontWeight(.medium)
                    ) {
                        Toggle("Push Notifications", isOn: $settingViewModel.settings.pushNotifications)
                            .onChange(of: settingViewModel.settings.pushNotifications) {
                                Task { await settingViewModel.saveSettings() }
                            }
                            .tint(titleColor) // Style the toggle
                        
                        Toggle("Vibration Alerts", isOn: $settingViewModel.settings.vibrationEnabled)
                            .onChange(of: settingViewModel.settings.vibrationEnabled) {
                                Task { await settingViewModel.saveSettings() }
                            }
                            .tint(titleColor) // Style the toggle
                        
                        Toggle("Light Alerts", isOn: $settingViewModel.settings.smartLightsEnabled)
                            .onChange(of: settingViewModel.settings.smartLightsEnabled) {
                                Task { await settingViewModel.saveSettings() }
                            }
                            .tint(titleColor) // Style the toggle
                    }
                    .listRowBackground(rowBackgroundColor) // Make rows semi-transparent
                    .task {
                        await settingViewModel.loadSettings()
                    }
                    .overlay {
                        if settingViewModel.isLoading {
                            ProgressView("Loading...")
                        }
                    }
                    
                    // MARK: - App Info
                    Section(header: Text("App Info")
                        .foregroundColor(titleColor) // Style header
                        .fontWeight(.medium)
                    ) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(titleColor.opacity(0.7))
                        }
                        
                        Link("Privacy Policy", destination: URL(string: "https://silentbell.com/privacy")!)
                        Link("Terms of Service", destination: URL(string: "https://silentbell.com/terms")!)
                    }
                    .listRowBackground(rowBackgroundColor) // Make rows semi-transparent
                    .foregroundStyle(titleColor) // Make links match theme color
                }
                .listStyle(.insetGrouped) // Keep the grouped appearance
                .scrollContentBackground(.hidden) // --- 4. Make List background transparent ---
                .navigationTitle("Settings")
                // --- 5. Make Nav Bar transparent to show gradient ---
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
    }
}

#Preview {
    SettingView(viewModel: AuthViewModel())
    // .modelContainer(for: Item.self, inMemory: true)
}
