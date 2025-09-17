//
//  TabBarButton.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/17/25.
//
import SwiftUI

struct TabBarButton: View {
    let icon: String
    let tab: Int
    @Binding var selectedTab: Int
    let title: String
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(1))
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
            }
        }
    }
}
