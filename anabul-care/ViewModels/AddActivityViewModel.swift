import Foundation
import SwiftData
import SwiftUI

@Observable
public final class AddActivityViewModel {
    public var logType: LogType = .feeding
    public var durationMinutes: Int = 0
    public var details: String = ""
    
    public var pet: PetProfile
    private let repository: PetRepositoryProtocol
    
    public init(pet: PetProfile, repository: PetRepositoryProtocol) {
        self.pet = pet
        self.repository = repository
    }
    
    public func saveActivity() {
        let newLog = ActivityLog(
            timestamp: Date(),
            type: logType.rawValue,
            durationMinutes: durationMinutes,
            detail: details
        )
        newLog.pet = pet
        
        do {
            // We need to add the activity through the repository
            // Since ActivityLog is a relationship of PetProfile, we might need a separate addLog method or use repository.save() after appending
            pet.activities.append(newLog)
            try repository.save()
        } catch {
            print("AddActivityViewModel: Error saving activity: \(error)")
        }
    }
}
