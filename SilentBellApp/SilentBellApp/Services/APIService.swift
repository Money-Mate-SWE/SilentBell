//
//  APIService.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/29/25.
//

import Foundation

class APIService {
    private let baseURL = "https://vv2buyx9a0.execute-api.us-east-1.amazonaws.com/"
    
    func registerDeviceToken(token: String) async throws -> Void {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing user ID."])
        }

        guard let url = URL(string: "\(baseURL)/user/device/\(userId)") else {
            throw NSError(domain: "URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        guard let usertoken = TokenStorage.shared.getAccessToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid access token"])
        }


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["token": token]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        if httpResponse.statusCode == 201 {
            print("✅ Device token registered successfully")
        } else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("⚠️ Server returned status code \(httpResponse.statusCode)")
            throw NSError(domain: "Server", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
    }
    
    func registerUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user") else { return }
        
        guard let token = TokenStorage.shared.getAccessToken() else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No valid access token"]
            )))
            return
        }
        
        // for debugging token
        let segments = token.split(separator: ".")
            guard segments.count == 3 else {
                print("❌ Invalid JWT format")
                return
            }

            let payloadSegment = segments[1]
            var base64 = String(payloadSegment)

            // Pad base64 if necessary
            let remainder = base64.count % 4
            if remainder > 0 {
                base64 += String(repeating: "=", count: 4 - remainder)
            }

            guard let payloadData = Data(base64Encoded: base64) else {
                print("❌ Failed to base64 decode")
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: payloadData, options: []),
               let dict = json as? [String: Any] {
                print("✅ Decoded JWT payload:")
                for (key, value) in dict {
                    print("  \(key): \(value)")
                }
            } else {
                print("❌ Failed to parse JSON")
            }
        
        //ends
        
        guard let name = UserDefaults.standard.string(forKey: "user_name"),
              let email = UserDefaults.standard.string(forKey: "user_email") else {
            completion(.failure(NSError(
                domain: "UserData",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Missing user name or email"]
            )))
            return
        }
        
        // Create JSON body
        let body: [String: Any] = [
            "name": name,
            "email": email
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
           completion(.failure(NSError(
               domain: "Encoding",
               code: 500,
               userInfo: [NSLocalizedDescriptionKey: "Failed to encode user data"]
           )))
           return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "Network",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"]
                )))
                return
            }
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw response from backend:", rawString)
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func registerDevice(deviceName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("⚠️ Missing user ID. Make sure it's saved after login.")
            return
        }

        guard let url = URL(string: "\(baseURL)/device/\(userId)") else {
            completion(.failure(NSError(
                domain: "URL",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )))
            return
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No valid access token"]
            )))
            return
        }
        
        let body: [String: Any] = [
            "device_name": deviceName
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(
                domain: "Encoding",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode device data"]
            )))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "Network",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"]
                )))
                return
            }
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw response from backend:", rawString)
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let deviceKey = json["device_key"] as? String {
                    print("✅ Device registered with key:", deviceKey)
                    completion(.success(deviceKey))
                } else {
                    completion(.failure(NSError(
                        domain: "Decoding",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Missing device_key in response"]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchDevices(completion: @escaping (Result<[Devices], Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("⚠️ Missing user ID. Make sure it's saved after login.")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/device/devices/\(userId)") else {
            completion(.failure(NSError(
                domain: "URL",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )))
            return
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No valid access token"]
            )))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(
                    domain: "Network",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"]
                )))
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw response from backend:", rawString)
            }

            // 6️⃣ Decode response into Device array
            do {
                let devices = try JSONDecoder().decode([Devices].self, from: data)
                completion(.success(devices))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func fetchLights(completion: @escaping (Result<[Lights], Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("⚠️ Missing user ID. Make sure it's saved after login.")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/device/devices/\(userId)") else {
            completion(.failure(NSError(
                domain: "URL",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )))
            return
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No valid access token"]
            )))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(
                    domain: "Network",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"]
                )))
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw response from backend:", rawString)
            }

            // 6️⃣ Decode response into Device array
            do {
                let devices = try JSONDecoder().decode([Lights].self, from: data)
                completion(.success(devices))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func fetchPreferences() async throws -> Preference {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing user ID."])
        }

        guard let url = URL(string: "\(baseURL)/user/\(userId)/preferences") else {
            throw NSError(domain: "URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid access token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        if let rawString = String(data: data, encoding: .utf8) {
            print("📦 Raw preferences response:", rawString)
        }

        let prefs = try JSONDecoder().decode(Preference.self, from: data)
        return prefs
    }

    // MARK: - Update Preferences
    func updatePreferences(preferences: Preference) async throws -> Preference {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing user ID."])
        }

        guard let url = URL(string: "\(baseURL)/user/\(userId)/preferences") else {
            throw NSError(domain: "URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid access token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(preferences)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let rawString = String(data: data, encoding: .utf8) {
            print("📦 Raw updated preferences response:", rawString)
        }

        let updatedPrefs = try JSONDecoder().decode(Preference.self, from: data)
        return updatedPrefs
    }
    
    // MARK: - Fetch log events
    func fetchLogs() async throws -> [Log] {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing user ID."])
        }

        guard let url = URL(string: "\(baseURL)/user/\(userId)/events") else {
            throw NSError(domain: "URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        guard let token = TokenStorage.shared.getAccessToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid access token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        if let rawString = String(data: data, encoding: .utf8) {
            print("📦 Raw preferences response:", rawString)
        }

        let logs = try JSONDecoder().decode([Log].self, from: data)
        return logs
    }
}
