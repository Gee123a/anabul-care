import SwiftUI
import SwiftData

@main
struct watchos_petcare_Watch_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
