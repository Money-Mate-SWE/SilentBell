//
//  AuthViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false


    private let authService = AuthService()

    func login() {
        guard !isLoading else { return } // prevent multiple calls
               isLoading = true
        authService.login() { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
                self.isLoading=false
            }
        }
    }

    
}
