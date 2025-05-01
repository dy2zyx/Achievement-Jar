//
//  Item.swift
//  Achievement Jar
//
//  Created by Yu Du on 01/05/2025.
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
