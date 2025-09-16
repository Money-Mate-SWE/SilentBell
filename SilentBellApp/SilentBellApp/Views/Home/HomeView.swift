//
//  HomeView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct HomeView: View {

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                    Text("Home")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "video.doorbell.fill")
                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                    Text("Devices")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                    Text("Settings")
                }
            
        }
    }
}


#Preview {
HomeView()
    .modelContainer(for: Item.self, inMemory: true)
}
