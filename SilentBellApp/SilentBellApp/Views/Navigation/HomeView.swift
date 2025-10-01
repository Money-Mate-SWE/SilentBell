//
//  HomeView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {
                    // MARK: - Main Content
                    ZStack {
                        switch selectedTab {
                        case 0:
                            ContentView() // Home
                        case 1:
                            DeviceView() // Devices
                        case 2:
                            SettingView(viewModel: authViewModel) // Profile
                        default:
                            ContentView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // MARK: - Custom Tab Bar
                    HStack {
                        TabBarButton(icon: "house.fill", tab: 0, selectedTab: $selectedTab, title: "Home")
                        Spacer()
                        TabBarButton(icon: "video.doorbell.fill", tab: 1, selectedTab: $selectedTab, title: "Devices")
                        Spacer()
                        TabBarButton(icon: "gearshape.fill", tab: 2, selectedTab: $selectedTab, title: "Settings")
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                }
    }
}


#Preview {
    HomeView(authViewModel: AuthViewModel())
    .modelContainer(for: Item.self, inMemory: true)
}
