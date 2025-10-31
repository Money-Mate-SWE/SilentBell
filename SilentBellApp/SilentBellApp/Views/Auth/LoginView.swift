//
//  LoginView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
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

    var body: some View {
        // --- 2. Use a ZStack to layer the gradient behind the content ---
        ZStack {
            appGradient
                .ignoresSafeArea() // Make gradient fill the whole screen
            
            VStack(spacing: 20) {
                Spacer() // Push content to the center
                
                // --- 3. Apply the custom font and color to the title ---
                Text("SilentBell Login")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(titleColor)
                
                // Login button (functionality is unchanged)
                Button(action: {
                    viewModel.login()
                }) {
                    Text(viewModel.isLoading ? "Logging in..." : "Login")
                        .font(.headline) // Make button text a bit bolder
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // Kept the blue from your original screenshot
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40) // Add more horizontal padding
                
                Spacer() // Push content to the center
            }
            .padding()
        }
    }
}

#Preview {
    // Note: AuthViewModel is an ObservedObject, so it needs to be created for the preview
    LoginView(viewModel: AuthViewModel())
    // .modelContainer(for: Item.self, inMemory: true) // This line might be for a different preview setup
}
