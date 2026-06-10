import Foundation
import SwiftData

@Model
public final class TaskDeactivation {
    public var petID: UUID
    public var taskType: String
    public var date: Date? // nil means permanent deactivation
    
    public init(petID: UUID, taskType: String, date: Date? = nil) {
        self.petID = petID
        self.taskType = taskType
        self.date = date
    }
}
