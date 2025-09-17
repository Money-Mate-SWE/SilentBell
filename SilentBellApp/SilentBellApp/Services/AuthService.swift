//
//  AuthService.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import Foundation
import Auth0

class AuthService {
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
                    completion(true)
                }
            }
    }

  
}
