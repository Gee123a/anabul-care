import Foundation
import SwiftData
import SwiftUI
import WidgetKit

/// ViewModel for managing a pet's daily routine and task completion.
@Observable
public final class RoutineViewModel {
    /// The pet whose routine is being managed.
    public var pet: PetProfile
    /// The currently selected date for the routine view.
    public var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    /// Generated list of tasks for the selected date.
    public var dailyTasks: [DailyTaskItem] = []
    
    private let repository: PetRepositoryProtocol
    private let modelContext: ModelContext
    
    /// Initializes the view model with a pet, repository, and model context.
    public init(pet: PetProfile, repository: PetRepositoryProtocol, modelContext: ModelContext) {
        self.pet = pet
        self.repository = repository
        self.modelContext = modelContext
        updateTasks()
    }
    
    /// Updates the dailyTasks list by generating a new routine based on preferences and deactivations.
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
    
    /// Forces a refresh of the pet's activities from the database, useful when returning from background.
    public func refreshActivities() {
        let petID = pet.id
        let descriptor = FetchDescriptor<ActivityLog>(predicate: #Predicate { $0.pet?.id == petID })
        if let freshLogs = try? modelContext.fetch(descriptor) {
            pet.activities = freshLogs
        }
        updateTasks()
    }

    
    /// Selects a new date and refreshes the tasks.
    public func selectDate(_ date: Date) {
        self.selectedDate = Calendar.current.startOfDay(for: date)
        updateTasks()
    }
    
    /// Counts how many tasks are completed for a given date.
    public func completedCount(for date: Date) -> Int {
        dailyTasks.filter { isTaskCompleted($0, on: date) }.count
    }
    
    /// Checks if a specific task has been completed (logged) for a given date.
    public func isTaskCompleted(_ task: DailyTaskItem, on date: Date) -> Bool {
        pet.activities.contains { 
            $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: date) 
        }
    }
    
    /// Toggles the completion status of a task by adding or removing an ActivityLog.
    public func toggleTask(_ task: DailyTaskItem, on date: Date) {
        let taskType = task.type.rawValue
        let context = pet.modelContext ?? modelContext
        
        if let existingLog = pet.activities.first(where: { 
            $0.type == taskType && Calendar.current.isDate($0.timestamp, inSameDayAs: date) 
        }) {
            // Delete existing log to unmark task as completed
            context.delete(existingLog)
            pet.activities.removeAll(where: { $0.id == existingLog.id })
            
            WatchConnectivityManager.shared.sendActivityDeletion(
                            petName: pet.name,
                            activityType: taskType
                        )
        } else {
            // Create new log to mark task as completed
            let newLog = ActivityLog(
                timestamp: date,
                type: taskType,
                durationMinutes: 15,
                detail: task.detail
            )
            newLog.pet = pet
            context.insert(newLog)
            pet.activities.append(newLog)
            
            WatchConnectivityManager.shared.sendActivityToWatch(
                            petName: pet.name,
                            activityType: taskType
                        )
        }
        
        // Force the @Observable macro to detect a change in the relationship
        pet.activities = pet.activities 
        
        // Save changes and refresh widgets
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Formatted string for month and year.
    public var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    /// Formatted string for long date display.
    public var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }
}
