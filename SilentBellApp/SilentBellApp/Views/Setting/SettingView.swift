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
                                    Text("SilentBell User")
                                        .font(.headline)
                                    Text("user@email.com")
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
                            Toggle("Push Notifications", isOn: $settingViewModel.settings.pushNotifications)
                                .onChange(of: settingViewModel.settings.pushNotifications) {
                                    Task { await settingViewModel.saveSettings() }
                                }
                            Toggle("Vibration Alerts", isOn: $settingViewModel.settings.vibrationEnabled)
                                .onChange(of: settingViewModel.settings.vibrationEnabled) {
                                    Task { await settingViewModel.saveSettings() }
                                }
                            Toggle("Light Alerts", isOn: $settingViewModel.settings.smartLightsEnabled)
                                .onChange(of: settingViewModel.settings.smartLightsEnabled) {
                                    Task { await settingViewModel.saveSettings() }
                                }
                        }
                        .task {
                            await settingViewModel.loadSettings()
                        }
                        .overlay {
                            if settingViewModel.isLoading {
                                ProgressView("Loading...")
                            }
                        }

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
