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
    @Published var scannedDevices: [CBPeripheral] = [] // BLE discovered

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var centralManager: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    
    private var connectedPeripheral: CBPeripheral?
    private var deviceKeyChar: CBCharacteristic?
    private var wifiListChar: CBCharacteristic?
    private var wifiCredChar: CBCharacteristic?
    
    @Published var isProvisioned = false



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
                    self.devices = devices
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
                    self.sendDeviceTokenToESP(token: deviceKey) // ✅ Send token to ESP
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
    
    func sendDeviceTokenToESP(token: String) {
        guard let peripheral = connectedPeripheral,
              let char = deviceKeyChar else {
            print("⚠️ Device key characteristic not found.")
            return
        }

        if let data = token.data(using: .utf8) {
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
            peripheral.readValue(for: char)
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
            case "uuid-for-device-key-char": // replace with your ESP32 characteristic UUID
                Task { @MainActor in
                    self.deviceKeyChar = char
                }
            case "abcd1234-5678-90ab-cdef-1234567890ab": // Wi-Fi list
                Task { @MainActor in
                    self.wifiListChar = char
                }
                peripheral.readValue(for: char)
            case "abcd9876-5432-10fe-dcba-0987654321ab": // Wi-Fi credentials
                Task { @MainActor in
                    self.wifiCredChar = char
                }
            default:
                break
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        switch characteristic.uuid.uuidString.lowercased() {
        case "abcd1234-5678-90ab-cdef-1234567890ab":
            // Wi-Fi list
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]],
               let networks = json["networks"] {
                Task { @MainActor in
                    self.availableNetworks = networks
                    print("📶 Available Wi-Fi networks: \(networks)")
                }
            }

        case "abcd9876-5432-10fe-dcba-0987654321ab":
            // Wi-Fi provisioning result
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let status = json["status"] {
                Task { @MainActor in
                    if status == "success" {
                        self.isProvisioned = true
                        //self.devices.append(Device(name: peripheral.name ?? "Unnamed", status: "Connected"))
                        print("✅ Wi-Fi connected successfully for \(peripheral.name ?? "Device")")
                    } else {
                        self.errorMessage = "Wi-Fi connection failed."
                        print("❌ Wi-Fi connection failed.")
                    }
                }
            }

        default:
            break
        }
    }

    
    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        // Here you’d normally exchange WiFi credentials → ESP32 returns IP
        Task { @MainActor in
//            self.devices.append(Device(name: peripheral.name ?? "Unnamed", status: "Connected"))
        }
    }
}
