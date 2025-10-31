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
                guard success else {
                    print("❌ Auth0 login failed")
                    self.isLoading = false
                    self.isAuthenticated = false
                    return
                }                    // ✅ Call backend to register/fetch user
                APIService().registerUser { result in
                    DispatchQueue.main.async {
                        
                        switch result {
                        case .success(let user):
                            print("✅ User registered/fetched: \(user)")
                            UserDefaults.standard.set(user.user_id, forKey: "currentUserId")
                            self.isAuthenticated = true
                            print(UserDefaults.standard.value(forKey: "currentUserID") as Any)
                        case .failure(let error):
                            print("❌ Failed to register user: \(error.localizedDescription)")
                            self.isAuthenticated = false
                        }
                        
                        self.isLoading = false
                    }
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
