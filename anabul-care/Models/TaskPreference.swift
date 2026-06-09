import Foundation
import SwiftData

@Model
final class TaskPreference {
    var petID: UUID
    var taskType: String
    var preferredTime: String // e.g., "07:30 AM"
    var isManualOverride: Bool
    
    init(petID: UUID, taskType: String, preferredTime: String, isManualOverride: Bool = true) {
        self.petID = petID
        self.taskType = taskType
        self.preferredTime = preferredTime
        self.isManualOverride = isManualOverride
    }
}
