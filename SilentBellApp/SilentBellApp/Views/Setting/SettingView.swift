//
//  SettingView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//

import Foundation
import SwiftUI

struct SettingView: View {
    
    @ObservedObject var viewModal: AuthViewModel
    
    @State private var notificationsEnabled = true
    @State private var vibrationEnabled = true
    @State private var lightEnabled = true
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
                                    viewModal.logout()
                                    print("User logged out")
                                }
                            }
                        }

                        // MARK: - Notifications
                        Section(header: Text("Notifications")) {
                            Toggle("Push Notifications", isOn: $notificationsEnabled)
                            Toggle("Vibration Alerts", isOn: $vibrationEnabled)
                            Toggle("Light Alerts", isOn: $lightEnabled)
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
    SettingView(viewModal: AuthViewModel())
    .modelContainer(for: Item.self, inMemory: true)
}
