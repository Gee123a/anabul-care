//
//  WatchDashboardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//


import SwiftUI
import SwiftData

// MARK: - View 1: Today's Dashboard
struct WatchDashboardView: View {
    let pet: PetProfile
    
    var body: some View {
        NavigationStack {
            List {
                // Generates the same dynamic schedule you use on the iOS Dashboard
                let tasks = DailyRoutineGenerator.generate(for: pet)
                
                if tasks.isEmpty {
                    Text("No tasks scheduled for today!")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .listRowBackground(Color.clear)
                } else {
                    // DailyTaskItem is Identifiable, so we can just pass the array directly
                    ForEach(tasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.system(.body, design: .rounded, weight: .medium))
                                
                                // Uses your String-based timeRecommendation
                                Text(task.timeRecommendation)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            
                            // Check completion dynamically against the PetProfile
                            if isTaskCompleted(task) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Today's Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function matching the logic from TodayQueueCardView
    private func isTaskCompleted(_ task: DailyTaskItem) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return pet.activities.contains { activity in
            activity.type == task.type.rawValue &&
            Calendar.current.isDate(activity.timestamp, inSameDayAs: today)
        }
    }
}
