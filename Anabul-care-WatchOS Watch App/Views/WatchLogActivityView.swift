//
//  WatchLogActivityView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//

import SwiftData
import SwiftUI
import WatchKit

struct WatchLogActivityView: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile

    // Activity types matching your widget
    let activities = [
            ("feeding", "dog.bowl.fill", Color.orange), // "bowl.fill" -> "dog.bowl.fill" or "fork.knife"
            ("hydration", "drop.fill", Color.blue),     // Ensure this matches iPhone
            ("walk", "figure.walk", Color.green),       // "Walked" -> "walk"
            ("medication", "pills.fill", Color.red),    // "cross.pills.fill" -> "pills.fill"
        ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(activities, id: \.0) { activity in
                    Button {
                        logActivity(type: activity.0)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: activity.1)
                                .font(.title3)
                                .foregroundColor(activity.2)
                                .frame(width: 24)

                            Text(activity.0)
                                .font(
                                    .system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    )
                                )

                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Log Action")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func logActivity(type: String) {
        // 1. Initialize using your app's actual ActivityLog properties
        let newLog = ActivityLog(
            timestamp: Date(),
            type: type,  // Or map this to your exact LogType.rawValue if needed
            durationMinutes: 15,
            detail: "Logged from Apple Watch"
        )

        // 2. Safely link the log to the specific pet profile
        newLog.pet = pet

        // 3. Insert into the SwiftData context
        modelContext.insert(newLog)

        do {
            try modelContext.save()

            // 4. Send the log to the iPhone immediately via WatchConnectivity
            WatchConnectivityManager.shared.sendActivityLogToPhone(
                activityType: type,
                petName: pet.name
            )

            // 5. Trigger a success vibration on the user's wrist
            WKInterfaceDevice.current().play(.success)

        } catch {
            print("Failed to save WatchOS log: \(error)")
            WKInterfaceDevice.current().play(.failure)  // Trigger error vibration
        }
    }
}
