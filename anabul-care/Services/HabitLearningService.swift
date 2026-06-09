import Foundation
import SwiftData

class HabitLearningService {
    static let shared = HabitLearningService()
    
    private init() {}
    
    /// Analyzes logs for a specific pet and task type to find a "habitual" time.
    /// Returns a time string if a habit is detected, otherwise nil.
    func detectHabit(for pet: PetProfile, taskType: String) -> String? {
        let logs = pet.activities.filter { $0.type == taskType }
        
        // We need at least 3 logs to establish a habit
        guard logs.count >= 3 else { return nil }
        
        // Get the last 7 days of logs for this type
        let recentLogs = logs.filter { 
            Calendar.current.isDate($0.timestamp, inNextDays: 7) // Using a custom helper logic
        }
        
        // For simplicity in this prototype, we'll look at the hour/minute of all logs
        // and see if there's a cluster.
        let times = logs.map { log -> Int in
            let components = Calendar.current.dateComponents([.hour, .minute], from: log.timestamp)
            return (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }
        
        // Find a cluster (e.g., within a 60-minute window)
        // This is a basic implementation of habit detection.
        for time in times {
            let countInWindow = times.filter { abs($0 - time) <= 30 }.count
            if countInWindow >= 3 {
                // Return the average time of this cluster
                let cluster = times.filter { abs($0 - time) <= 30 }
                let averageMinutes = cluster.reduce(0, +) / cluster.count
                return formatMinutesToTimeString(averageMinutes)
            }
        }
        
        return nil
    }
    
    private func formatMinutesToTimeString(_ totalMinutes: Int) -> String {
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}

extension Calendar {
    func isDate(_ date: Date, inNextDays days: Int) -> Bool {
        guard let threshold = self.date(byAdding: .day, value: -days, to: Date()) else { return false }
        return date >= threshold
    }
}
