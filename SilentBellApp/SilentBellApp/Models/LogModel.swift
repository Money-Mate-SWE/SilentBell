//
//  LogModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 11/3/25.
//

struct Log: Identifiable, Codable {
    let event_id: String
    let device_name: String
    let event_type: String
    let event_time: String
    
    var id: String { event_id }
}
