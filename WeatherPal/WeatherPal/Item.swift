//
//  Item.swift
//  WeatherPal
//
//  Created by Daniel Romero on 13-06-25.
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
