//
//  Item.swift
//  SilentBell
//
//  Created by Kritan Aryal on 9/4/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
