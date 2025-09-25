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

    @Published var devices: [Device] = []
    @Published var scannedDevices: [CBPeripheral] = [] // BLE discovered

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var centralManager: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]

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
            centralManager.connect(peripheral, options: nil)
        }
    
    func loadDevices() async {
        
    }
    
    func addDevice(name: String) {
        
    }
    
    func deleteDevice(at offsets: IndexSet) {
       
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
    
    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        // Here you’d normally exchange WiFi credentials → ESP32 returns IP
        Task { @MainActor in
            self.devices.append(Device(name: peripheral.name ?? "Unnamed", status: "Connected"))
        }
    }
}
