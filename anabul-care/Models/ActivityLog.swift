//
//  ActivityLog.swift
//  anabul-care
//

import Foundation
import SwiftData

/// Represents a single recorded activity for a pet.
/// Used to track historical data and identify behavioral patterns.
@Model
public final class ActivityLog {
    /// Unique identifier for the log entry.
    public var id: UUID
    /// The exact date and time the activity occurred.
    public var timestamp: Date
    /// The category of activity (e.g., feeding, grooming).
    /// Used by the routine engine to analyze habits.
    public var type: String // "feeding", "grooming", "walk", "play", "hydration"
    /// How long the activity lasted, if applicable.
    public var durationMinutes: Int
    /// Additional user notes or specific details about the activity.
    public var detail: String
    
    /// The pet profile this log belongs to.
    public var pet: PetProfile?
    
    /// Initializes a new activity log entry.
    /// - Parameters:
    ///   - id: Unique UUID.
    ///   - timestamp: Occurrence date.
    ///   - type: Category string from LogType.
    ///   - durationMinutes: Time spent on activity.
    ///   - detail: Textual notes.
    public init(id: UUID = UUID(), timestamp: Date = Date(), type: String, durationMinutes: Int = 0, detail: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.durationMinutes = durationMinutes
        self.detail = detail
    }
}
