//
//  Item.swift
//  anabul-care
//
//  Created by Stevanus Ivan Santoso on 21/05/26.
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
