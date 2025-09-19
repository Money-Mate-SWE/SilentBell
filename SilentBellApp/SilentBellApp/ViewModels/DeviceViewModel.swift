//
//  DeviceViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/19/25.
//

import Foundation
import SwiftUI

@MainActor
class DevicesViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadDevices() async {
        
    }
    
    func addDevice(name: String) {
        
    }
    
    func deleteDevice(at offsets: IndexSet) {
       
    }
}
