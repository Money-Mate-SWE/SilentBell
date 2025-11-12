//
//  DeviceViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/19/25.
//

import Foundation
import SwiftUI
import CoreBluetooth

@MainActor
class DevicesViewModel: NSObject, ObservableObject {

    @Published var availableNetworks: [String] = []
    @Published var devices: [Devices] = []
    @Published var lights: [Lights] = []

    @Published var scannedDevices: [CBPeripheral] = [] // BLE discovered

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var incomingWiFiData = Data()

    
    private var centralManager: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    
    private var connectedPeripheral: CBPeripheral?
    private var deviceKeyChar: CBCharacteristic?
    private var wifiListChar: CBCharacteristic?
    private var wifiCredChar: CBCharacteristic?
    
    @Published var isProvisioned = false
    @Published var shouldPromptForName = false


    private let DEVICE_KEY_UUID = "abcd9999-1234-5678-9999-abcdef999999"
    private let WIFI_CHAR_UUID = "abcd5678-1234-5678-1234-abcdef654321"



    override init() {
            super.init()
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        func startScan() {
            scannedDevices.removeAll()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        func stopScan() {
            centralManager.stopScan()
        }
        
        func connectToDevice(_ peripheral: CBPeripheral) {
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    
    func loadDevices() {
        isLoading = true
        errorMessage = nil

        APIService().fetchDevices { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let devices):
                    print("✅ Loaded devices: \(devices)")
                    self.devices = devices
                case .failure(let error):
                    self.errorMessage = "Failed to load devices: \(error.localizedDescription)"
                }
            }
        }
    }
    func loadLights() {
        isLoading = true
        errorMessage = nil

        APIService().fetchLights { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let devices):
                    print("✅ Loaded devices: \(devices)")
                    self.lights = devices
                case .failure(let error):
                    self.errorMessage = "Failed to load devices: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addDevice(name: String, completion: @escaping (String?) -> Void) {
        APIService().registerDevice(deviceName: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let deviceKey):
                    print("✅ Device registered successfully — Key: \(deviceKey)")
                    self.sendDeviceTokenToESP(token: deviceKey, name: name) // ✅ Send token to ESP
                    completion(deviceKey)
                case .failure(let error):
                    print("❌ Device registration failed:", error.localizedDescription)
                    self.errorMessage = "Failed to register device: \(error.localizedDescription)"
                    completion(nil)
                }
            }
        }

    }
    
    func deleteDevice(at offsets: IndexSet) {
       
    }
    
    func sendDeviceTokenToESP(token: String, name: String) {
        guard let peripheral = connectedPeripheral,
              let char = deviceKeyChar else {
            print("⚠️ Device key characteristic not found.")
            return
        }
        let json: [String: String] = ["token": token, "name": name]

        if let data = try? JSONSerialization.data(withJSONObject: json) {
            peripheral.writeValue(data, for: char, type: .withResponse)
            print("📡 Sent device token to ESP32: \(token)")
            
            // Optionally, read back response to confirm
            peripheral.readValue(for: char)
        }
    }
    
    func sendWiFiCredentials(ssid: String, password: String) {
        guard let char = wifiCredChar,
              let peripheral = connectedPeripheral else {
            print("⚠️ Wi-Fi characteristic not found.")
            return
        }
        
        let creds: [String: String] = ["ssid": ssid, "password": password]
        if let data = try? JSONSerialization.data(withJSONObject: creds) {
            peripheral.writeValue(data, for: char, type: .withResponse)
            print("📡 Sent Wi-Fi credentials for SSID: \(ssid)")
//            peripheral.readValue(for: char)
        }
    }
    
    //optional
    func refreshWiFiList() {
        guard let peripheral = connectedPeripheral, let char = wifiListChar else { return }
        peripheral.readValue(for: char)
    }

}


extension DevicesViewModel: CBCentralManagerDelegate, CBPeripheralDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            Task { @MainActor in
                            self.errorMessage = "Bluetooth not available"
                        }
        }
    }
    
    nonisolated func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
           name == "SilentBell-Setup" {
            Task { @MainActor in
                        if !self.scannedDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                            self.scannedDevices.append(peripheral)
                        }
            }
        }
        
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics {
            switch char.uuid.uuidString.lowercased() {
            case DEVICE_KEY_UUID.lowercased(): // replace with your ESP32 characteristic UUID
                Task { @MainActor in
                    self.deviceKeyChar = char
                }
            case WIFI_CHAR_UUID.lowercased(): // Wi-Fi list + credential
                Task { @MainActor in
                    self.wifiListChar = char
                    self.wifiCredChar = char
                }
                peripheral.setNotifyValue(true, for: char)
                print("✅ Wi-Fi characteristic found. Refreshing Wi-Fi list...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshWiFiList()
                }
            default:
                break
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        guard let data = characteristic.value else { return }

        switch characteristic.uuid.uuidString.lowercased() {
        case WIFI_CHAR_UUID.lowercased():
            // Append incoming chunk
            Task { @MainActor in
                let chunkString = String(data: data, encoding: .utf8) ?? "?"

                if chunkString.trimmingCharacters(in: .whitespacesAndNewlines) == "EOF" {
                    if self.incomingWiFiData.isEmpty {
                        print("🚫 Ignored duplicate EOF")
                        return
                    }
                    
                }

                self.incomingWiFiData.append(data)
                print("Start adding data")
                print (chunkString)

                // Optional: check for a delimiter if your ESP32 adds one, e.g., "\n" or "EOF"
                if let jsonString = String(data: self.incomingWiFiData, encoding: .utf8),
                   jsonString.contains("EOF")  {
                    print("Start full string")

                    let jsonString = jsonString.replacingOccurrences(of: "EOF", with: "")
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "\r", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    print(jsonString)
                    
                    do{
                        // Parse the full JSON
                        if let jsonData = jsonString.data(using: .utf8),
                           let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                            
                            if let networks = json["networks"] as? [[String: Any]] {
                                let ssidList = networks.compactMap { $0["ssid"] as? String }
                                print("📶 Available Wi-Fi networks: \(ssidList)")
                                Task { @MainActor in
                                    self.availableNetworks = ssidList
                                }
                            } else if let status = json["status"] as? String {
                                Task { @MainActor in
                                    if status == "success" {
                                        self.isProvisioned = true
                                        self.shouldPromptForName = true
                                        print("✅ Wi-Fi connected successfully for \(peripheral.name ?? "Device")")
                                    } else {
                                        self.errorMessage = "Wi-Fi connection failed."
                                        print("❌ Wi-Fi connection failed.")
                                    }
                                }
                            }
                        }
                    } catch {
                        print("❌ JSON parse error: \(error)")
                        print("🧾 Raw data:\n\(jsonString)")
                    }
                    
                    
                    // Reset buffer for next message
                    self.incomingWiFiData.removeAll()
                }
                
            }
            

        default:
            break
        }
    }

    
    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        
    }
    
}
