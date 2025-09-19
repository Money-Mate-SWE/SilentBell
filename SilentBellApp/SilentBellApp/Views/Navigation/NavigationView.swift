//
//  HomeView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct NavigationView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
                    // MARK: - Main Content
                    ZStack {
                        switch selectedTab {
                        case 0:
                            ContentView() // Home
                        case 1:
                            ContentView() // Devices
                        case 2:
                            ContentView() // Settings
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
    NavigationView()
    .modelContainer(for: Item.self, inMemory: true)
}
