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
        let tasksOfType = dailyTasks.filter { $0.type == task.type }
        guard let taskIndex = tasksOfType.firstIndex(where: { $0.id == task.id }) else {
            return false
        }
        let logCount = pet.activities.filter {
            $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: date)
        }.count
        return taskIndex < logCount
    }
    
    private func isWithinTwoHours(currentTime: Date, recommendationTimeStr: String) -> Bool {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        guard let recommendationDate = f.date(from: recommendationTimeStr) else { return false }
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        let recComponents = calendar.dateComponents([.hour, .minute], from: recommendationDate)
        guard let curHour = currentComponents.hour, let curMin = currentComponents.minute,
              let recHour = recComponents.hour, let recMin = recComponents.minute else { return false }
        let curTotalMinutes = curHour * 60 + curMin
        let recTotalMinutes = recHour * 60 + recMin
        let diff = abs(curTotalMinutes - recTotalMinutes)
        let absoluteDiff = min(diff, 1440 - diff)
        return absoluteDiff <= 120
    }
    
    /// Toggles the completion status of a task by adding or removing an ActivityLog.
    public func toggleTask(_ task: DailyTaskItem, on date: Date) {
        let taskType = task.type.rawValue
        let context = pet.modelContext ?? modelContext
        let completed = isTaskCompleted(task, on: date)
        
        let dayLogs = pet.activities.filter {
            $0.type == taskType && Calendar.current.isDate($0.timestamp, inSameDayAs: date)
        }.sorted(by: { $0.timestamp < $1.timestamp })
        
        if completed {
            // Uncheck: delete the last log
            if let lastLog = dayLogs.last {
                context.delete(lastLog)
                pet.activities.removeAll(where: { $0.id == lastLog.id })
            }
        } else {
            // Check: Create new log to mark task as completed
            let newLog = ActivityLog(
                timestamp: Date(), // Log at the actual current time
                type: taskType,
                durationMinutes: 15,
                detail: task.detail
            )
            newLog.pet = pet
            context.insert(newLog)
            pet.activities.append(newLog)
            
            // SMART LEARNING: Auto-adjust preferred time for tomorrow based on current click (only within 2h)
            let now = Date()
            if isWithinTwoHours(currentTime: now, recommendationTimeStr: task.timeRecommendation) {
                let f = DateFormatter()
                f.dateFormat = "h:mm a"
                f.locale = Locale(identifier: "en_US_POSIX")
                let currentTimeString = f.string(from: now)
                let specificKey = "\(taskType)_\(task.timeRecommendation)"
                repository.updatePreference(for: pet.id, taskType: specificKey, preferredTime: currentTimeString, isManualOverride: true)
            }
        }
        
        // Save changes and refresh widgets
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        // SYNC TO WATCH: Push the full updated state (pets + preferences + deactivations)
        if let allPets = try? repository.fetchPets(), 
           let allPrefs = try? modelContext.fetch(FetchDescriptor<TaskPreference>()),
           let allDeacts = try? modelContext.fetch(FetchDescriptor<TaskDeactivation>()) {
            WatchConnectivityManager.shared.syncFullStateToWatch(pets: allPets, preferences: allPrefs, deactivations: allDeacts)
        }
        
        // Refresh local tasks
        updateTasks()
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
