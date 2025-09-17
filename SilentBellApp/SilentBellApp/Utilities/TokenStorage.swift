//
//  TokenStorage.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/17/25.
//
import Foundation
import KeychainAccess

class TokenStorage {
    static let shared = TokenStorage()
    private let keychain = Keychain(service: "com.silentbell.app")

    // Save tokens securely
    func saveTokens(accessToken: String, idToken: String, expiresIn: Date, refreshToken: String? = nil) {
        try? keychain.set(accessToken, key: "access_token")
        try? keychain.set(idToken, key: "id_token")
        if let refresh = refreshToken {
            try? keychain.set(refresh, key: "refresh_token")
        }
        try? keychain.set("\(expiresIn.timeIntervalSince1970)", key: "token_expiry")
    }

    // Retrieve tokens
    func getAccessToken() -> String? {
        return try? keychain.get("access_token")
    }

    func getIdToken() -> String? {
        return try? keychain.get("id_token")
    }

    func getRefreshToken() -> String? {
        return try? keychain.get("refresh_token")
    }

    func getExpiryDate() -> Date? {
        if let expiryString = try? keychain.get("token_expiry"),
           let timeInterval = TimeInterval(expiryString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }

    // Clear tokens
    func clearTokens() {
        try? keychain.remove("access_token")
        try? keychain.remove("id_token")
        try? keychain.remove("refresh_token")
        try? keychain.remove("token_expiry")
    }
}
