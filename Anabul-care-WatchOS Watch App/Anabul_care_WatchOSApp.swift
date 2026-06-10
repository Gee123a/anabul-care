//
//  Anabul_care_WatchOSApp.swift
//  Anabul-care-WatchOS Watch App
//
//  Created by Stevanus Ivan Santoso on 03/06/26.
//

import SwiftUI
import SwiftData

@main
struct Anabul_care_WatchOSApp: App {
    // Starts listening for the iPhone immediately
    private let connectivity = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Uses purely local Watch storage instead of the iPhone's App Group
        .modelContainer(for: [
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
            TaskPreference.self,
            TaskDeactivation.self
        ])
    }
}
