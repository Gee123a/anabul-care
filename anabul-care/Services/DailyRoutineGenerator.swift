//
//  DailyRoutineGenerator.swift
//  anabul-care
//

import Foundation

struct DailyTaskItem: Identifiable {
    let id = UUID()
    let type: LogType
    let title: String
    let timeRecommendation: String
    let detail: String
    let icon: String
}

struct DailyRoutineGenerator {
    static func generate(for pet: PetProfile) -> [DailyTaskItem] {
        switch pet.petSpecies {
        case .dog:
            return [
                DailyTaskItem(type: .feeding, title: "Morning Feeding", timeRecommendation: "8:00 AM", detail: "Measure portions", icon: "fork.knife"),
                DailyTaskItem(type: .walk, title: "Morning Walk", timeRecommendation: "9:00 AM", detail: "20+ min", icon: "figure.walk"),
                DailyTaskItem(type: .hydration, title: "Hydration", timeRecommendation: "12:00 PM", detail: "Refresh bowl", icon: "drop.fill"),
                DailyTaskItem(type: .play, title: "Play Time", timeRecommendation: "4:00 PM", detail: "Fetch or tug", icon: "tennisball"),
                DailyTaskItem(type: .grooming, title: "Grooming", timeRecommendation: "8:00 PM", detail: "Brush coat", icon: "scissors")
            ]
        case .cat:
            return [
                DailyTaskItem(type: .feeding, title: "Morning Feeding", timeRecommendation: "7:00 AM", detail: "Wet food", icon: "fork.knife"),
                DailyTaskItem(type: .hydration, title: "Hydration", timeRecommendation: "10:00 AM", detail: "Clean fountain", icon: "drop.fill"),
                DailyTaskItem(type: .play, title: "Play Time", timeRecommendation: "6:00 PM", detail: "15 min wand toy", icon: "sparkles"),
                DailyTaskItem(type: .grooming, title: "Grooming", timeRecommendation: "8:00 PM", detail: "Brush to prevent hairballs", icon: "scissors")
            ]
        case .hamster:
            return [
                DailyTaskItem(type: .feeding, title: "Evening Feeding", timeRecommendation: "7:00 PM", detail: "Seeds & fresh veg", icon: "leaf.fill"),
                DailyTaskItem(type: .hydration, title: "Hydration", timeRecommendation: "8:00 PM", detail: "Check bottle", icon: "drop.fill"),
                DailyTaskItem(type: .play, title: "Wheel Time", timeRecommendation: "10:00 PM", detail: "Ensure wheel is clear", icon: "circle.dashed"),
                DailyTaskItem(type: .grooming, title: "Sand Bath", timeRecommendation: "11:00 PM", detail: "Check sand level", icon: "sparkles")
            ]
        }
    }
}
