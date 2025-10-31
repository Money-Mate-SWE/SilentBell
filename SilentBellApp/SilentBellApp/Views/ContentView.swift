//
//  ContentView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    
    // --- 1. State to control the menu ---
    @State private var isMenuOpen = false
    
    // --- 2. ACCEPT THE BINDING from HomeView ---
    @Binding var selectedTab: Int
    
    // --- 3. Define the gradient and colors ---
    let appGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.63, green: 1.0, blue: 0.81), // Minty Green
            Color(red: 0.98, green: 1.0, blue: 0.69)  // Light Yellow
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Custom purple color from your Figma
    let titleColor = Color(red: 0.3, green: 0.1, blue: 0.5)

    var body: some View {
        // --- 4. Use GeometryReader to get the screen's width ---
        GeometryReader { geometry in
            
            // --- 5. Use a ZStack to layer the menu on top of the content ---
            ZStack(alignment: .leading) { // Align everything to the left
                
                // --- LAYER 1: The Main Content ---
                VStack(spacing: 20) {
                    
                    // Custom Header
                    HStack {
                        Button(action: {
                            withAnimation(.spring()) {
                                isMenuOpen = true
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(titleColor)
                        }
                        
                        Spacer()
                        
                        Text("SILENT BELL")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(titleColor)
                        
                        Spacer()
                        
                        // Invisible button to keep title centered
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.clear)
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal)
                    
                    // Dashboard Buttons
                    HStack(spacing: 20) {
                        DashboardButton(
                            iconName: "clock.arrow.circlepath",
                            iconColor: .blue,
                            title: "History",
                            subtitle: "Tap to view",
                            action: {
                                print("History button tapped")
                            }
                        )
                        
                        DashboardButton(
                            iconName: "bell.fill",
                            iconColor: .green,
                            title: "Notifications",
                            subtitle: "Tap to view",
                            action: {
                                print("Notifications button tapped")
                            }
                        )
                    }
                    .padding()
                    
                    Spacer() // Pushes all content to the top
                }
                .safeAreaPadding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(appGradient.ignoresSafeArea()) // Correct background
                // Grey out the main content when menu is open
                .disabled(isMenuOpen)
                .blur(radius: isMenuOpen ? 3 : 0)

                // --- LAYER 2: The Dimming Overlay (Scrim) ---
                if isMenuOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isMenuOpen = false
                            }
                        }
                }
                
                // --- LAYER 3: The Side Menu View ---
                // --- 3. PASS THE BINDING to the SideMenuView ---
                SideMenuView(isMenuOpen: $isMenuOpen, selectedTab: $selectedTab)
                    .frame(width: geometry.size.width * 0.75) // 75% of screen width
                    .offset(x: isMenuOpen ? 0 : -geometry.size.width)
                    .transition(.move(edge: .leading))
            }
        }
        .ignoresSafeArea(edges: .bottom) // Let bottom tab bar handle bottom edge
    }
}

// --- Helper View for the two main buttons ---
struct DashboardButton: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundColor(iconColor)
                    .padding(.top, 10)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .frame(maxWidth: .infinity) // Make buttons share space
            .frame(height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

// --- The New Side Menu View ---
struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    
    // --- 4. ACCEPT THE BINDING from ContentView ---
    @Binding var selectedTab: Int
    
    // Get colors from Figma
    let titleColor = Color(red: 0.3, green: 0.1, blue: 0.5) // Custom Purple
    let subtitleColor = Color.gray
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading) {
                Text("SILENT BELL")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(titleColor)
                Text("Silent & Safety")
                    .font(.subheadline)
                    .foregroundColor(subtitleColor)
            }
            .padding(.top, 60) // Space for status bar
            .padding(.leading, 30)
            .padding(.bottom, 30)
            
            // Menu Buttons
            MenuButton(icon: "rectangle.grid.2x2", title: "Dashboard") {
                print("Dashboard Tapped")
                withAnimation { isMenuOpen = false }
                // Set tab to 0 (Home/Dashboard)
                selectedTab = 0
            }
            MenuButton(icon: "calendar", title: "Activity") {
                print("Activity Tapped")
                withAnimation { isMenuOpen = false }
                // You don't have an "Activity" tab yet,
                // but you could add one as case 3 in HomeView
            }
            
            // --- 5. THE ACTION to change the tab ---
            MenuButton(icon: "gearshape", title: "Settings") {
                print("Settings Tapped")
                withAnimation {
                    isMenuOpen = false // Close the menu
                    selectedTab = 2    // Set the tab to 2 (Settings)
                }
            }
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            
            Spacer() // Pushes items to top
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white) // Menu has a white background
        .ignoresSafeArea()
    }
}

// --- Helper View for the side menu buttons ---
struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    let iconColor = Color.gray
    let textColor = Color.black

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 25) // Align icons
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
    }
}


#Preview {
    // --- 6. Update the Preview to work ---
    // We must provide a .constant "fake" binding for the preview to work
    ContentView(selectedTab: .constant(0))
}
