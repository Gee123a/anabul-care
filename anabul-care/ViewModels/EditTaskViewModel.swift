import Foundation
import SwiftData
import SwiftUI

@Observable
public final class EditTaskViewModel {
    public var pet: PetProfile
    public var task: DailyTaskItem
    public var date: Date
    public var selectedTime: Date
    
    private let repository: PetRepositoryProtocol
    
    public init(pet: PetProfile, task: DailyTaskItem, date: Date, repository: PetRepositoryProtocol) {
        self.pet = pet
        self.task = task
        self.date = date
        
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        self.selectedTime = f.date(from: task.timeRecommendation) ?? Date()
        self.repository = repository
    }
    
    public var impactWarning: String {
        let base = "Removing this task might impact \(pet.name)'s health. "
        switch task.type {
        case .feeding: return base + "Consistent feeding is crucial for metabolism and energy levels."
        case .walk, .play: return base + "Lack of exercise can lead to obesity and behavioral issues."
        case .grooming: return base + "Regular grooming prevents skin issues and monitors for parasites."
        case .hydration: return base + "Hydration is essential for kidney function and overall health."
        case .medication: return base + "Missing medication or supplements can lead to complications."
        }
    }
    
    public func savePreference() {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        let timeString = f.string(from: selectedTime)
        
        do {
            let preferences = try repository.fetchPreferences(for: pet.id)
            if let existing = preferences.first(where: { $0.taskType == task.type.rawValue }) {
                existing.preferredTime = timeString
                existing.isManualOverride = true
                try repository.save()
            } else {
                let newPref = TaskPreference(petID: pet.id, taskType: task.type.rawValue, preferredTime: timeString, isManualOverride: true)
                try repository.addPreference(newPref)
            }
            
            // SYNC TO WATCH: Update preferences on the watch
            triggerSync()
            
        } catch {
            print("EditTaskViewModel: Error saving preference: \(error)")
        }
    }
    
    public func resetToDefault() {
        do {
            let preferences = try repository.fetchPreferences(for: pet.id)
            if let existing = preferences.first(where: { $0.taskType == task.type.rawValue }) {
                try repository.deletePreference(existing)
                
                // SYNC TO WATCH: Reset preferences on the watch
                triggerSync()
            }
        } catch {
            print("EditTaskViewModel: Error resetting preference: \(error)")
        }
    }
    
    public func removeTask(permanent: Bool) {
        let deactivation = TaskDeactivation(
            petID: pet.id,
            taskType: task.type.rawValue,
            date: permanent ? nil : date
        )
        do {
            try repository.addDeactivation(deactivation)
            
            // SYNC TO WATCH: Removed task sync
            triggerSync()
            
        } catch {
            print("EditTaskViewModel: Error removing task: \(error)")
        }
    }
    
    private func triggerSync() {
        if let allPets = try? repository.fetchPets(),
           let allPrefs = try? repository.fetchAllPreferences() {
            WatchConnectivityManager.shared.syncFullStateToWatch(pets: allPets, preferences: allPrefs)
        }
    }}
