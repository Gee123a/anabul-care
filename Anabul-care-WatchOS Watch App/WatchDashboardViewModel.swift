import Foundation
import SwiftData

/// ViewModel for WatchDashboardView.
/// Owns task generation and completion-check logic so the View body
/// contains zero direct calls to DailyRoutineGenerator or ActivityLog.
@Observable
@MainActor
final class WatchDashboardViewModel {

    // MARK: - Published State
    var dailyTasks: [DailyTaskItem] = []

    // MARK: - Private State
    private let pet: PetProfile

    // MARK: - Init
    init(pet: PetProfile) {
        self.pet = pet
        loadTasks()
    }

    // MARK: - Task Management

    /// Regenerates today's task list for the current pet.
    func loadTasks() {
        let prefs = (try? pet.modelContext?.fetch(FetchDescriptor<TaskPreference>())) ?? []
        let deacts = (try? pet.modelContext?.fetch(FetchDescriptor<TaskDeactivation>())) ?? []
        dailyTasks = DailyRoutineGenerator.generate(for: pet, preferences: prefs, deactivations: deacts)
    }

    /// Returns true if a given task has been logged for today.
    func isTaskCompleted(_ task: DailyTaskItem) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return pet.activities.contains { activity in
            activity.type == task.type.rawValue &&
            Calendar.current.isDate(activity.timestamp, inSameDayAs: today)
        }
    }
}
