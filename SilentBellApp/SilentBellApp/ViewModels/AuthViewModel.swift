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


    func login() {
        guard !isLoading else { return } // prevent multiple calls
               isLoading = true
        AuthService.shared.login() { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
                self.isLoading=false
                
                if success {
                    // ✅ Call backend to register/fetch user
                    APIService().registerUser { result in
                        switch result {
                        case .success(let user):
                            print("✅ User registered/fetched: \(user)")
                            UserDefaults.standard.set(user.user_id, forKey: "currentUserId")
                            print(UserDefaults.standard.value(forKey: "currentUserID") as Any)
                        case .failure(let error):
                            print("❌ Failed to register user: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("Login failed")
                }
            }
        }
    }
    
    func logout() {
        AuthService.shared.logout() { success in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = false
                    print("User logged out successfully")
                }
                else {
                    print("Logout failed")
                }
            }
            
        }
    }

    
}
