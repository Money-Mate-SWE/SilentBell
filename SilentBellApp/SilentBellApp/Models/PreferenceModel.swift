//
//  PreferenceModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//

struct Preference: Codable {
    var enable_vibration: Bool = true
    var enable_light: Bool = true
    var enable_push: Bool = true
    var priority_mode: Bool = true
}
