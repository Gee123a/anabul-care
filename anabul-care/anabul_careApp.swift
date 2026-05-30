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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await DataManager.shared.seedData(modelContainer: sharedModelContainer)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
