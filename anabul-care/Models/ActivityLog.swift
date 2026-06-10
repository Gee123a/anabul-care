//
//  ActivityLog.swift
//  anabul-care
//

import Foundation
import SwiftData

@Model
public final class ActivityLog {
    public var id: UUID
    public var timestamp: Date
    public var type: String // "feeding", "grooming", "walk", "play", "hydration"
    public var durationMinutes: Int
    public var detail: String
    
    public var pet: PetProfile?
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), type: String, durationMinutes: Int = 0, detail: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.durationMinutes = durationMinutes
        self.detail = detail
    }
}
