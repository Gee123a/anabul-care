import Foundation
import SwiftData

struct ToxicHazard: Codable {
    let keyword_id: String
    let danger_level: String
    let alternative_id: String
}

struct SpeciesRule: Codable {
    let species: String
    let rer_constant: Int
    let heat_threshold_celsius: Double
    let toxic_hazards: [ToxicHazard]
}

struct BehavioralTidbit: Codable {
    let id: String
    let species_target: String
    let title_id: String
    let body_id: String
    let citation: String
}

struct MetadataRegistry: Codable {
    let species_rules: [SpeciesRule]
    let behavioral_tidbits: [BehavioralTidbit]
}

/// Actor-based DataManager to ensure thread-safe, background data operations.
actor DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    /// Seeds the database from JSON on a background thread.
    func seedData(modelContainer: ModelContainer) {
        // Use detached task with background priority to move work off the Main Actor
        Task.detached(priority: .background) {
            // Create a dedicated context for this background work
            let context = ModelContext(modelContainer)
            
            // 1. Initial check: If rules already exist, we don't need to seed.
            let descriptor = FetchDescriptor<SpeciesRuleModel>()
            if let count = try? context.fetchCount(descriptor), count > 0 {
                return
            }
            
            // 2. Load and Decode JSON
            guard let url = Bundle.main.url(forResource: "MetadataRegistry", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                return
            }
            
            do {
                let registry = try JSONDecoder().decode(MetadataRegistry.self, from: data)
                
                // 3. Process Species Rules and Hazards
                for rule in registry.species_rules {
                    let ruleModel = SpeciesRuleModel(
                        species: rule.species,
                        rerConstant: rule.rer_constant,
                        heatThresholdCelsius: rule.heat_threshold_celsius
                    )
                    context.insert(ruleModel)
                    
                    // Process hazards in chunks to avoid blocking
                    for hazard in rule.toxic_hazards {
                        let hazardModel = ToxicityModel(
                            keyword: hazard.keyword_id,
                            dangerLevel: hazard.danger_level,
                            alternative: hazard.alternative_id
                        )
                        hazardModel.speciesRule = ruleModel
                        context.insert(hazardModel)
                    }
                    
                    // Save and yield after each species to prevent long database locks
                    try context.save()
                    await Task.yield()
                }
                
                // 4. Process Behavioral Tidbits
                for tidbit in registry.behavioral_tidbits {
                    let model = TidbitModel(
                        id: tidbit.id,
                        speciesTarget: tidbit.species_target,
                        title: tidbit.title_id,
                        bodyText: tidbit.body_id,
                        citation: tidbit.citation
                    )
                    context.insert(model)
                    
                    // Periodically save and yield
                    if context.hasChanges {
                        try context.save()
                        await Task.yield()
                    }
                }
                
                print("Successfully seeded data in background chunks.")
            } catch {
                print("Failed to seed MetadataRegistry: \(error)")
            }
        }
    }
}
