import Foundation
import SwiftData
import SwiftUI
import WidgetKit

@Observable
public final class RoutineViewModel {
    public var pet: PetProfile
    public var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    public var dailyTasks: [DailyTaskItem] = []
    
    private let repository: PetRepositoryProtocol
    private let modelContext: ModelContext
    
    public init(pet: PetProfile, repository: PetRepositoryProtocol, modelContext: ModelContext) {
        self.pet = pet
        self.repository = repository
        self.modelContext = modelContext
        updateTasks()
    }
    
    public func updateTasks() {
        do {
            let preferences = try repository.fetchPreferences(for: pet.id)
            let deactivations = try repository.fetchDeactivations(for: pet.id)
            self.dailyTasks = DailyRoutineGenerator.generate(
                for: pet,
                on: selectedDate,
                preferences: preferences,
                deactivations: deactivations
            )
        } catch {
            print("RoutineViewModel: Error fetching data: \(error)")
            self.dailyTasks = []
        }
    }
    
    public func selectDate(_ date: Date) {
        self.selectedDate = Calendar.current.startOfDay(for: date)
        updateTasks()
    }
    
    public func completedCount(for date: Date) -> Int {
        dailyTasks.filter { isTaskCompleted($0, on: date) }.count
    }
    
    public func isTaskCompleted(_ task: DailyTaskItem, on date: Date) -> Bool {
        pet.activities.contains { 
            $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: date) 
        }
    }
    
    public func toggleTask(_ task: DailyTaskItem, on date: Date) {
        let taskType = task.type.rawValue
        let context = pet.modelContext ?? modelContext
        
        if let index = pet.activities.firstIndex(where: { 
            $0.type == taskType && Calendar.current.isDate($0.timestamp, inSameDayAs: date) 
        }) {
            let logToDelete = pet.activities[index]
            context.delete(logToDelete)
            pet.activities.remove(at: index)
        } else {
            let newLog = ActivityLog(
                timestamp: date,
                type: taskType,
                durationMinutes: 15,
                detail: task.detail
            )
            newLog.pet = pet
            context.insert(newLog)
            pet.activities.append(newLog)
        }
        
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    public var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    public var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }
}
