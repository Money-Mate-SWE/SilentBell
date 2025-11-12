//
//  DeviceModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 10/23/25.
//

struct Devices: Codable, Identifiable {
    let device_id: String
    let user_id: String
    let device_name: String
    let status: String
    let last_seen: String?
    let created_at: String?
    let device_key: String?
    
    var id: String { device_id }

}

struct Lights: Codable, Identifiable {
    let device_id: String
    let user_id: String
    let device_name: String
    let status: String
    let last_seen: String?
    let created_at: String?
    let device_key: String?
    
    var id: String { device_id }

}
