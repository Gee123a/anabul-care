import Foundation
import SwiftData

/// Tracks when a specific routine task has been disabled by the user.
/// Prevents the routine engine from suggesting unwanted tasks.
@Model
public final class TaskDeactivation {
    /// The ID of the pet for whom the task is deactivated.
    public var petID: UUID
    /// The type of task being suppressed (e.g., "walk").
    public var taskType: String
    /// The specific date for temporary deactivation.
    /// If nil, the task is considered permanently deactivated.
    public var date: Date? // nil means permanent deactivation
    
    /// Initializes a task deactivation record.
    /// - Parameters:
    ///   - petID: Pet identifier.
    ///   - taskType: The RawValue of LogType.
    ///   - date: Optional specific date for deactivation.
    public init(petID: UUID, taskType: String, date: Date? = nil) {
        self.petID = petID
        self.taskType = taskType
        self.date = date
    }
}
