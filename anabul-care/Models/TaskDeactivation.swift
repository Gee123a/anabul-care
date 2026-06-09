import Foundation
import SwiftData

@Model
final class TaskDeactivation {
    var petID: UUID
    var taskType: String
    var date: Date? // nil means permanent deactivation
    
    init(petID: UUID, taskType: String, date: Date? = nil) {
        self.petID = petID
        self.taskType = taskType
        self.date = date
    }
}
