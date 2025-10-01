//
//  PreferenceModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//

import Foundation

struct Preference: Codable {
    var pushNotifications: Bool
    var vibrationEnabled: Bool
    var smartLightsEnabled: Bool
}
