//
//  Networkmanager.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 11/11/25.
//

import Foundation

struct WiFiNetwork: Identifiable, Decodable, Hashable {
    var id: String { ssid }
    let ssid: String
}


struct ConnectResponse: Decodable {
    let status: String
    let ip: String?
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let bulbBaseURL = "http://192.168.4.1" // Bulb AP default IP
    
    
    
    // 1. Get list of Wi-Fi networks from bulb
    func fetchWiFiNetworks() async throws -> [WiFiNetwork] {
        let url = URL(string: "\(bulbBaseURL)/wifi/list")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let ssids = try JSONDecoder().decode([String].self, from: data)
        return ssids.map { WiFiNetwork(ssid: $0) }
    }
    
    // 2. Send Wi-Fi credentials to bulb
    func sendWiFiCredentials(ssid: String, password: String) async throws -> ConnectResponse {
        let url = URL(string: "\(bulbBaseURL)/wifi/connect")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["ssid": ssid, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ConnectResponse.self, from: data)
    }
    
}

