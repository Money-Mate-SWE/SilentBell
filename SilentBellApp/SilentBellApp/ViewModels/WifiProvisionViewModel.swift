//
//  WifiProvisionViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 11/11/25.
//

import Foundation

@MainActor
class WiFiProvisionViewModel: ObservableObject {
    @Published var networks: [WiFiNetwork] = []
    @Published var selectedNetwork: WiFiNetwork?
    @Published var password: String = ""
    @Published var statusMessage: String = ""
    
    func loadNetworks() async {
        do {
            networks = try await NetworkManager.shared.fetchWiFiNetworks()
        } catch {
            statusMessage = "Failed to load Wi-Fi networks."
        }
    }
    
    func connectToWiFi(newDeviceName: String) async {
        
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            statusMessage = "User not logged in."
            return
        }
        
        guard let ssid = selectedNetwork?.ssid else {
            statusMessage = "Please select a network."
            return
        }
        statusMessage = "Connecting to \(ssid)..."
        
        do {
            let response = try await NetworkManager.shared.sendWiFiCredentials(ssid: ssid, password: password, user_id: userId, device_name: newDeviceName)
            
            if response.status == "connected" {
                statusMessage = "✅ Connected to Bulb "
                
                // Optional: Register with backend
//                try await NetworkManager.shared.registerBulb(ip: ip, mac: "AA:BB:CC:DD:EE:FF")
            } else {
                statusMessage = "❌ Failed to connect."
            }
        } catch {
            statusMessage = "Error sending credentials"
        }
    }
}
