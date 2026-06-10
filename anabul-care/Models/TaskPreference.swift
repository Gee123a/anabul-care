import Foundation
import SwiftData

/// Stores user-defined timing preferences for specific pet care tasks.
/// Overrides the default engine recommendations.
@Model
public final class TaskPreference {
    /// The ID of the pet this preference applies to.
    public var petID: UUID
    /// The type of task (e.g., "feeding").
    public var taskType: String
    /// The user's preferred time string (e.g., "07:30 AM").
    public var preferredTime: String
    /// Flag indicating if this was a conscious manual override by the user.
    public var isManualOverride: Bool
    
    /// Initializes a task preference.
    /// - Parameters:
    ///   - petID: Pet identifier.
    ///   - taskType: The RawValue of LogType.
    ///   - preferredTime: Formatted time string.
    ///   - isManualOverride: Defaults to true for user-set times.
    public init(petID: UUID, taskType: String, preferredTime: String, isManualOverride: Bool = true) {
        self.petID = petID
        self.taskType = taskType
        self.preferredTime = preferredTime
        self.isManualOverride = isManualOverride
    }
}
