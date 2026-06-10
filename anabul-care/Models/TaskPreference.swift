import Foundation
import SwiftData

@Model
public final class TaskPreference {
    public var petID: UUID
    public var taskType: String
    public var preferredTime: String // e.g., "07:30 AM"
    public var isManualOverride: Bool
    
    public init(petID: UUID, taskType: String, preferredTime: String, isManualOverride: Bool = true) {
        self.petID = petID
        self.taskType = taskType
        self.preferredTime = preferredTime
        self.isManualOverride = isManualOverride
    }
}
