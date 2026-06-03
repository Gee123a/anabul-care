import AppIntents
import SwiftData
import Foundation

// MARK: - 1. The AppEntity
// This teaches Siri what a "Food" is in the context of your app
struct FoodEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Food"
    static var defaultQuery = FoodEntityQuery()
    
    // We use the food's keyword as its unique ID
    var id: String
    var keyword: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(keyword.capitalized)")
    }
}

// MARK: - 2. The Entity Query
// This tells Siri how to search your SwiftData database when the user speaks a word
struct FoodEntityQuery: EntityStringQuery {
    
    // Siri uses this to find specific entities by their ID
    func entities(for identifiers: [String]) async throws -> [FoodEntity] {
        let hazards = try await fetchHazards()
        return hazards
            .filter { identifiers.contains($0.keyword) }
            .map { FoodEntity(id: $0.keyword, keyword: $0.keyword) }
    }
    
    // Siri uses this when the user speaks a word (e.g., "Chocolate")
    func entities(matching string: String) async throws -> [FoodEntity] {
        let hazards = try await fetchHazards()
        return hazards
            .filter { $0.keyword.localizedCaseInsensitiveContains(string) }
            .map { FoodEntity(id: $0.keyword, keyword: $0.keyword) }
    }
    
    // Siri uses this to build its vocabulary model in advance
    func suggestedEntities() async throws -> [FoodEntity] {
        let hazards = try await fetchHazards()
        return hazards.map { FoodEntity(id: $0.keyword, keyword: $0.keyword) }
    }
    
    // Helper function to safely fetch from SwiftData in the background
    @MainActor
    private func fetchHazards() throws -> [ToxicityModel] {
        let schema = Schema([
            PetProfile.self, ActivityLog.self,
            SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self
        ])
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare.nicholas")!
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<ToxicityModel>()
        return try context.fetch(descriptor)
    }
}

// MARK: - 3. The Intent
// The action that runs when the user speaks the command
struct ToxicityIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Food Toxicity"
    static var description = IntentDescription("Checks the Anabul Care database to see if a food is safe or toxic.")
    
    // We are now using our custom FoodEntity instead of a raw String!
    @Parameter(title: "Food Name", description: "The food you want to check")
    var food: FoodEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check if \(\.$food) is safe")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let schema = Schema([
                Item.self, PetProfile.self, ActivityLog.self,
                SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self
            ])
            let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare.nicholas")!
            let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
            
            let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<ToxicityModel>()
            let hazards = try context.fetch(descriptor)
            
            // Search for the entity the user asked about
            if let foundHazard = hazards.first(where: { $0.keyword.lowercased() == food.keyword.lowercased() }) {
                let species = foundHazard.speciesRule?.species ?? "your pet"
                
                let dialog = IntentDialog("Warning. \(foundHazard.keyword.capitalized) is marked as \(foundHazard.dangerLevel) for \(species). Symptoms may include \(foundHazard.alternative).")
                return .result(dialog: dialog)
                
            } else {
                let dialog = IntentDialog("I couldn't find \(food.keyword) in the Anabul Care database. Please consult your vet.")
                return .result(dialog: dialog)
            }
            
        } catch {
            return .result(dialog: "There was an error accessing the Anabul Care database.")
        }
    }
}

// MARK: - 4. The Shortcuts Provider
struct AnabulCareShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToxicityIntent(),
            // We can now safely interpolate the variable directly into the phrase!
            phrases: [
                "Is \(\.$food) dangerous according to \(.applicationName)?",
                "Check if \(\.$food) is safe in \(.applicationName)",
                "Ask \(.applicationName) if \(\.$food) is toxic"
            ],
            shortTitle: "Check Toxicity",
            systemImageName: "exclamationmark.shield.fill"
        )
    }
}
