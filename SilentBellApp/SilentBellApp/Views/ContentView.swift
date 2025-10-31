//
//  ContentView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/4/25
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var hasAppeared = false
    
    // State for Bell Animation
    @State private var bellOffset: CGFloat = 0.0
    @State private var bellRotation: Angle = .zero
    
    let appGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.63, green: 1.0, blue: 0.81), // Minty Green
            Color(red: 0.98, green: 1.0, blue: 0.69)  // Light Yellow
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    let titleColor = Color(red: 0.3, green: 0.1, blue: 0.5)

    var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter.string(from: currentDate)
    }

    var body: some View {
        ZStack {
            
            // --- LAYER 1: The Main Content ---
            VStack(spacing: 20) {
                
                // Custom Header (Simplified to just center the title)
                HStack {
                    Spacer()
                    Text("SILENT BELL")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(titleColor)
                    Spacer()
                }
                .padding(.horizontal)
                
                // --- BLOCK 1: GREETING (MOVED UP) ---
                VStack(spacing: 12) {
                    // Bell Animation
                    Image(systemName: "bell.fill")
                        .font(.system(size: 50))
                        .foregroundColor(titleColor)
                        .offset(x: bellOffset)
                        .rotationEffect(bellRotation)
                        .onAppear {
                            // Set the starting position to the "left"
                            bellOffset = -15
                            bellRotation = .degrees(-15)
                            
                            // Start the animation
                            animateBell()
                        }
                    
                    // Greeting
                    Text(currentGreeting)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .animation(.spring(), value: currentGreeting)
                    
                    // Time
                    Text(currentTimeString)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                }
                .foregroundColor(titleColor)
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.3)) // Frosted glass effect
                )
                .cornerRadius(20)
                .shadow(radius: 5)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 30)

                // --- BLOCK 2: BUTTONS (MOVED DOWN) ---
                HStack(spacing: 20) {
                    DashboardButton(
                        iconName: "clock.arrow.circlepath",
                        iconColor: .blue,
                        title: "History",
                        subtitle: "Tap to view",
                        animationType: .rotate, // Tell the button to rotate
                        action: { print("History button tapped") }
                    )
                    
                    DashboardButton(
                        iconName: "bell.fill",
                        iconColor: .green,
                        title: "Notifications",
                        subtitle: "Tap to view",
                        animationType: .shake, // Tell the button to shake
                        action: { print("Notifications button tapped") }
                    )
                }
                .padding()
                
                Spacer()
            }
            .safeAreaPadding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appGradient.ignoresSafeArea())
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    hasAppeared = true
                }
            }
        }
        .onReceive(timer) { input in
            currentDate = input
        }
    }
    
    // --- Animation Function for the Bell ---
    func animateBell() {
        // Animate from the "left" (current state) to the "right"
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            bellOffset = 15 // Swing right
            bellRotation = .degrees(15) // Tilt right
        }
    }
}

// ---
// --- THIS IS THE UPDATED HELPER VIEW ---
// ---
struct DashboardButton: View {
    // Define the different animation types
    enum AnimationType {
        case none, rotate, shake
    }
    
    // Properties for the button
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let animationType: AnimationType // New property
    let action: () -> Void
    
    // @State variables to control the animation
    @State private var rotation: Angle = .zero
    @State private var offset: CGFloat = 0

    var body: some View {
        Button(action: {
            // Trigger the animation
            triggerAnimation()
            
            // Run the original action
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundColor(iconColor)
                    .padding(.top, 10)
                    // Apply the animation modifiers
                    .rotationEffect(rotation)
                    .offset(x: offset)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // --- THIS FUNCTION CONTAINS THE CHANGE ---
    func triggerAnimation() {
        switch animationType {
        case .rotate:
            // A single 360-degree rotation over 2 seconds
            withAnimation(.easeInOut(duration: 2.0)) {
                rotation = .degrees(360)
            }
            // Reset the rotation after the animation is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Set rotation back to 0 without animation
                // (it looks the same as 360, so it's not a visible jump)
                rotation = .zero
            }
            
        case .shake:
            // A quick left-right-center shake
            withAnimation(.easeInOut(duration: 0.1)) {
                offset = -10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    offset = 10
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    offset = 0
                }
            }
            
        case .none:
            break
        }
    }
}

#Preview {
    ContentView()
}
