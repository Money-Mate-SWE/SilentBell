//
//  APIService.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/29/25.
//

import Foundation

class APIService {
    private let baseURL = "http://silentbell-staging.eba-h32kmksx.us-east-1.elasticbeanstalk.com/"
    
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
