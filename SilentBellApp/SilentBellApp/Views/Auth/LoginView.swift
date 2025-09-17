//
//  LoginView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20){
            
            Text("SilentBell Login")
                .font(.largeTitle)
                .bold()
            
            // Login button
            Button(action: {
                viewModel.login()
            }) {
                
                Text(viewModel.isLoading ? "Logging in..." : "Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
        .modelContainer(for: Item.self, inMemory: true)
}
