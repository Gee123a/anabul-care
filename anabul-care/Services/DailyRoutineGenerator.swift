import Foundation
import SwiftData

struct DailyTaskItem: Identifiable {
    let id = UUID()
    let type: LogType
    let title: String
    let timeRecommendation: String
    let detail: String
    let icon: String
}

struct DailyRoutineGenerator {
    static func generate(for pet: PetProfile, on date: Date = Date(), preferences: [TaskPreference] = [], deactivations: [TaskDeactivation] = []) -> [DailyTaskItem] {
        let engine = RoutineRuleEngine.shared
        let species = pet.species.lowercased()
        let breed = pet.breed
        let traits = engine.getTraits(for: species, breed: breed)
        let ageInMonths = pet.ageInMonths
        let weekday = Calendar.current.component(.weekday, from: date)

        // 1. Get Base Routine
        var tasks = engine.getBaseRoutine(for: species).map { task in
            DailyTaskItem(
                type: LogType(rawValue: task.type) ?? .play,
                title: task.title,
                timeRecommendation: task.time,
                detail: task.detail,
                icon: task.icon
            )
        }

        // 2. Apply Modifiers
        let modifiers = engine.getModifiers()

        for modifier in modifiers {
            if shouldApply(modifier: modifier, age: ageInMonths, traits: traits, weekday: weekday) {
                applyModifier(modifier: modifier, to: &tasks)
            }
        }

        // 3. Apply Deactivations (Filtering out removed tasks)
        tasks.removeAll { task in
            deactivations.contains { deactivation in
                deactivation.taskType == task.type.rawValue && 
                (deactivation.date == nil || Calendar.current.isDate(deactivation.date!, inSameDayAs: date))
            }
        }

        // 4. Apply Personalization (Manual Overrides & Habit Learning)
        for i in 0..<tasks.count {
            let taskType = tasks[i].type.rawValue

            // Priority 1: Manual User Override
            if let manual = preferences.first(where: { $0.taskType == taskType && $0.isManualOverride }) {
                tasks[i] = updatedTime(for: tasks[i], newTime: manual.preferredTime)
            } 
            // Priority 2: Habit Learning
            else if let habitTime = HabitLearningService.shared.detectHabit(for: pet, taskType: taskType) {
                tasks[i] = updatedTime(for: tasks[i], newTime: habitTime)
            }
        }

        // 5. Sort tasks by time
        return tasks.sorted { compareTimes($0.timeRecommendation, $1.timeRecommendation) }
    }
    private static func updatedTime(for task: DailyTaskItem, newTime: String) -> DailyTaskItem {
        DailyTaskItem(
            type: task.type,
            title: task.title,
            timeRecommendation: newTime,
            detail: task.detail,
            icon: task.icon
        )
    }

    private static func compareTimes(_ t1: String, _ t2: String) -> Bool {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        guard let d1 = f.date(from: t1), let d2 = f.date(from: t2) else { return t1 < t2 }
        return d1 < d2
    }

    private static func shouldApply(modifier: RoutineModifier, age: Int, traits: [String], weekday: Int) -> Bool {
        let trigger = modifier.trigger

        // Check Weekday
        if let targetWeekday = trigger.weekday, weekday != targetWeekday {
            return false
        }

        // Check Age Max
        if let maxAge = trigger.age_max_months, age > maxAge {
            return false
        }

        // Check Age Min
        if let minAge = trigger.age_min_months, age < minAge {
            return false
        }
        
        // Check Traits
        if let requiredTrait = trigger.trait, !traits.contains(requiredTrait) {
            return false
        }
        
        return true
    }
    
    private static func applyModifier(modifier: RoutineModifier, to tasks: inout [DailyTaskItem]) {
        switch modifier.action {
        case "add":
            if let newTask = modifier.task {
                tasks.append(DailyTaskItem(
                    type: LogType(rawValue: newTask.type) ?? .play,
                    title: newTask.title,
                    timeRecommendation: newTask.time,
                    detail: newTask.detail,
                    icon: newTask.icon
                ))
            }
        case "modify":
            if let targetType = modifier.target_type {
                for i in 0..<tasks.count {
                    if tasks[i].type.rawValue == targetType {
                        let current = tasks[i]
                        tasks[i] = DailyTaskItem(
                            type: current.type,
                            title: modifier.new_title ?? current.title,
                            timeRecommendation: current.timeRecommendation,
                            detail: modifier.new_detail ?? current.detail,
                            icon: modifier.new_icon ?? current.icon
                        )
                    }
                }
            }
        case "remove":
            if let targetType = modifier.target_type {
                tasks.removeAll { $0.type.rawValue == targetType }
            }
        default:
            break
        }
    }
}
