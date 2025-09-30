//
//  AuthService.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import Foundation
import Auth0

class AuthService {
    static let shared = AuthService()
    
    func login(completion: @escaping (Bool) -> Void) {
        Auth0
            .webAuth()
            .audience("https://api.silentbell.com")
            .scope("openid profile offline_access")
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                    completion(false)
                case .success(let credentials):
                    print("Credentials: \(credentials)")
                    TokenStorage.shared.saveTokens(
                                            accessToken: credentials.accessToken,
                                            idToken: credentials.idToken,
                                            expiresIn: credentials.expiresIn,
                                            refreshToken: credentials.refreshToken
                                        )
                    completion(true)
                }
            }
    }
    
    func ensureValidToken(completion: @escaping (String?) -> Void) {
        guard let expiry = TokenStorage.shared.getExpiryDate(),
              let refreshToken = TokenStorage.shared.getRefreshToken() else {
            print("⚠️ No expiry or refresh token found")
            completion(nil)
            return
        }
        
        if expiry > Date(), let accessToken = TokenStorage.shared.getAccessToken() {
            completion(accessToken)  // Token still valid
            print("✅ Using cached token")
        } else {
            // Refresh token if expired
            print("🔄 Refreshing token")

            Auth0
                .authentication()
                .renew(withRefreshToken: refreshToken)
                .start { result in
                    switch result {
                    case .success(let credentials):
                        TokenStorage.shared.saveTokens(
                            accessToken: credentials.accessToken,
                            idToken: credentials.idToken,
                            expiresIn: credentials.expiresIn,
                            refreshToken: credentials.refreshToken
                        )
                        completion(credentials.accessToken)
                    case .failure(let error):
                        print("Failed to refresh token: \(error)")
                        completion(nil)
                    }
                }
        }
    }
   
    func logout(completion: @escaping (Bool) -> Void) {
        // 1. Clear local tokens
        TokenStorage.shared.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        
        // 2. Clear Auth0 session (optional, removes SSO cookie in Safari/WebKit)
        Auth0
            .webAuth()
            .clearSession(federated: false) { result in
                switch result {
                case .success:
                    print(" Logged out successfully")
                    completion(true)
                case .failure(let error):
                    print(" Failed to clear session: \(error)")
                    completion(false)
                }
            }
    }

  
}
