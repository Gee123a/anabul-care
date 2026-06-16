//
//  anabul_careApp.swift
//  anabul-care
//
//  Created by Stevanus Ivan Santoso on 21/05/26.
//

import SwiftUI
import SwiftData

@main
struct anabul_careApp: App {
    @State private var isDatabaseReady = false
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    init() {
        // Register the background task immediately on launch
        ClimateManager.shared.registerBackgroundTask(modelContainer: sharedModelContainer)
        WatchConnectivityManager.shared.modelContainer = sharedModelContainer
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
            TaskPreference.self,
            TaskDeactivation.self,
        ])
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare")!
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isDatabaseReady {
                    ContentView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    LaunchScreenView()
                        .task {
                            // 1. Wait for background seeding
                            await DataManager.shared.seedData(modelContainer: sharedModelContainer)
                            
                            // 2. Fetch the newly seeded Toxicity Models and index them into iOS Spotlight
                            let context = ModelContext(sharedModelContainer)
                            let descriptor = FetchDescriptor<ToxicityModel>()
                            if let hazards = try? context.fetch(descriptor) {
                                SpotlightManager.shared.indexToxicityDatabase(items: hazards)
                            }
                            
                            // 3. Initialize Climate & Location Services
                            ClimateManager.shared.requestNotificationPermission()
                            LocationManager.shared.requestPermission()
                            LocationManager.shared.start()
                            ClimateManager.shared.scheduleNextCheck()
                            
                            // 4. Dismiss Launch Screen smoothly
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isDatabaseReady = true
                            }
                        }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
