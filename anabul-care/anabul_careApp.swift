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
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            TidbitModel.self,
            ToxicityModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            ClimateManager.shared.registerBackgroundTask(modelContainer: container)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    LocationManager.shared.requestPermission()
                    LocationManager.shared.start()
                    ClimateManager.shared.requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                ClimateManager.shared.scheduleNextCheck()
            }
        }
    }
}
