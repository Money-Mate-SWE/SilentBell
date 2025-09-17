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
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                    completion(false)
                case .success(let credentials):
                    print("Credentials: \(credentials)")
                    print("ID token: (credentials.idToken)")
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
            completion(nil)
            return
        }
        
        if expiry > Date(), let accessToken = TokenStorage.shared.getAccessToken() {
            completion(accessToken)  // Token still valid
        } else {
            // Refresh token if expired
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
   

  
}
