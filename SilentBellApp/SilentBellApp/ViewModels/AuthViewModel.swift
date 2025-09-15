//
//  AuthViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false

    private let authService = AuthService()

    func login() {
        authService.login() { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
            }
        }
    }

    
}
