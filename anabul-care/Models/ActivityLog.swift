//
//  ActivityLog.swift
//  anabul-care
//

import Foundation
import SwiftData

@Model
final class ActivityLog {
    var id: UUID
    var timestamp: Date
    var type: String // "feeding", "grooming", "walk", "play", "hydration"
    var durationMinutes: Int
    var detail: String
    
    var pet: PetProfile?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), type: String, durationMinutes: Int = 0, detail: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.durationMinutes = durationMinutes
        self.detail = detail
    }
}
