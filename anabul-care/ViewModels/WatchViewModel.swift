import Foundation
import SwiftData
import SwiftUI

@Observable
public final class WatchViewModel {
    public var pets: [PetProfile] = []
    public var dailyTasks: [DailyTaskItem] = []
    
    private let repository: PetRepositoryProtocol
    private let modelContext: ModelContext
    
    public init(repository: PetRepositoryProtocol, modelContext: ModelContext) {
        self.repository = repository
        self.modelContext = modelContext
        fetchPets()
    }
    
    public func fetchPets() {
        do {
            self.pets = try repository.fetchPets()
        } catch {
            print("WatchViewModel: Error fetching pets: \(error)")
        }
    }
    
    public func updateTasks(for pet: PetProfile) {
        do {
            let preferences = try repository.fetchPreferences(for: pet.id)
            let deactivations = try repository.fetchDeactivations(for: pet.id)
            self.dailyTasks = DailyRoutineGenerator.generate(
                for: pet,
                on: Date(),
                preferences: preferences,
                deactivations: deactivations
            )
        } catch {
            print("WatchViewModel: Error updating tasks: \(error)")
            self.dailyTasks = []
        }
    }
    
    public func completedCount(for pet: PetProfile) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyTasks.filter { task in
            pet.activities.contains { 
                $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: today) 
            }
        }.count
    }
    
    public func isTaskCompleted(_ task: DailyTaskItem, for pet: PetProfile) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return pet.activities.contains { 
            $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: today) 
        }
    }
    
    public func toggleTask(_ task: DailyTaskItem, for pet: PetProfile) {
        let today = Calendar.current.startOfDay(for: Date())
        let taskType = task.type.rawValue
        let context = pet.modelContext ?? modelContext
        
        if let index = pet.activities.firstIndex(where: { 
            $0.type == taskType && Calendar.current.isDate($0.timestamp, inSameDayAs: today) 
        }) {
            let logToDelete = pet.activities[index]
            context.delete(logToDelete)
            pet.activities.remove(at: index)
        } else {
            let newLog = ActivityLog(
                timestamp: today,
                type: taskType,
                durationMinutes: 0,
                detail: "Logged via Watch"
            )
            newLog.pet = pet
            context.insert(newLog)
            pet.activities.append(newLog)
        }
        
        try? context.save()
    }
    
    public func iconForSpecies(_ species: String) -> String {
        switch species.lowercased() {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "hamster": return "hare.fill"
        default: return "pawprint.fill"
        }
    }
}
