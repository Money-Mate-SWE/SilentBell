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

    var body: some View{
        NavigationStack {
            Form {
                // MARK: - Account
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(UserDefaults.standard.string(forKey: "user_name") ?? "Unknown")
                                .font(.headline)
                            Text(UserDefaults.standard.string(forKey: "user_email") ?? "Unknown")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Text("Log Out")
                    }
                    .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Log Out", role: .destructive) {
                            viewModel.logout()
                            print("User logged out")
                        }
                    }
                }

                // MARK: - Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $settingViewModel.settings.enable_push)
                        .onChange(of: settingViewModel.settings.enable_push) {
                            let previous = settingViewModel.settings
                            Task {
                                let center = UNUserNotificationCenter.current()
                                let settings = await center.notificationSettings()
                                switch settings.authorizationStatus {
                                case .notDetermined:
                                    // Request permission only if not determined
                                    let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
                                    if granted == true {
                                        await settingViewModel.saveSettings(previousSettings: previous)
                                    }
                                case .authorized, .provisional, .ephemeral:
                                    // Already authorized → just save
                                    await settingViewModel.saveSettings(previousSettings: previous)
                                default:
                                    // Denied
                                    let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
                                    if granted == true {
                                        await settingViewModel.saveSettings(previousSettings: previous)
                                    }
                                }
                            }
                        }
                    Toggle("Vibration Alerts", isOn: $settingViewModel.settings.enable_vibration)
                        .onChange(of: settingViewModel.settings.enable_vibration) {
                            let previous = settingViewModel.settings
                            Task { await settingViewModel.saveSettings(previousSettings: previous) }
                        }
                    Toggle("Light Alerts", isOn: $settingViewModel.settings.enable_light)
                        .onChange(of: settingViewModel.settings.enable_light) {
                            let previous = settingViewModel.settings
                            Task { await settingViewModel.saveSettings(previousSettings: previous) }
                        }
                }
                .task {
                    await settingViewModel.loadSettings()
                }
//                .overlay {
//                    if settingViewModel.isLoading {
//                        ProgressView("Loading...")
//                    }
//                }

                // MARK: - App Info
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    Link("Privacy Policy", destination: URL(string: "https://silentbell.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://silentbell.com/terms")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingView(viewModel: AuthViewModel())
    .modelContainer(for: Item.self, inMemory: true)
}
