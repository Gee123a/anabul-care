import AppIntents
import SwiftData
import Foundation

// 1. The actual Siri Action
struct ToxicityIntent: AppIntent {
    // These titles appear in the iOS Shortcuts app
    static var title: LocalizedStringResource = "Check Food Toxicity"
    static var description = IntentDescription("Checks the Anabul Care database to see if a food is safe or toxic.")
    
    // ADDED: requestValueDialog tells Siri what to ask the user!
    @Parameter(
        title: "Food Name",
        description: "The food you want to check (e.g., Chocolate, Grape)",
        requestValueDialog: "What food would you like to check?"
    )
    var foodName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check if \(\.$foodName) is safe")
    }
    
    // The function that runs when Siri is triggered
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            // Re-initialize the shared SwiftData container for the background Siri extension
            let schema = Schema([
                Item.self,
                PetProfile.self,
                ActivityLog.self,
                SpeciesRuleModel.self,
                ToxicityModel.self,
                TidbitModel.self
            ])
            // Ensure this matches your newly created App Group!
            let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare")!
            let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
            
            let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            // Fetch the hazards from SwiftData
            let descriptor = FetchDescriptor<ToxicityModel>()
            let hazards = try context.fetch(descriptor)
            
            // Search for the specific food the user asked Siri about
            if let foundHazard = hazards.first(where: { $0.keyword.localizedCaseInsensitiveContains(foodName) }) {
                let species = foundHazard.speciesRule?.species ?? "your pet"
                
                // Siri will read this exact string out loud!
                let dialog = IntentDialog("Warning. \(foundHazard.keyword.capitalized) is marked as \(foundHazard.dangerLevel) for \(species). Symptoms may include \(foundHazard.alternative).")
                
                return .result(dialog: dialog)
                
            } else {
                let dialog = IntentDialog("I couldn't find \(foodName) in the Anabul Care database. Please consult your vet to be safe.")
                return .result(dialog: dialog)
            }
            
        } catch {
            return .result(dialog: "There was an error accessing the Anabul Care database.")
        }
    }
}

// 2. The Shortcuts Provider
struct AnabulCareShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToxicityIntent(),
            // REMOVED: \(\.$foodName) interpolation from the phrases to fix the Xcode error
            phrases: [
                "Check food toxicity with \(.applicationName)",
                "Is this safe in \(.applicationName)?",
                "Food safety check in \(.applicationName)",
                "Use \(.applicationName) to check toxicity"
            ],
            shortTitle: "Check Toxicity",
            systemImageName: "exclamationmark.shield.fill"
        )
    }
}
