import Foundation
import SwiftData

/// DTO for toxic hazard data imported from JSON.
public struct ToxicHazard: Codable, Sendable {
    public let keyword_id: String
    public let danger_level: String
    public let alternative_id: String
}

/// DTO for species rule data imported from JSON.
public struct SpeciesRule: Codable, Sendable {
    public let species: String
    public let rer_constant: Int
    public let heat_threshold_celsius: Double
    public let toxic_hazards: [ToxicHazard]
}

/// DTO for behavioral tidbit data imported from JSON.
public struct BehavioralTidbit: Codable, Sendable {
    public let id: String
    public let species_target: String
    public let title_id: String
    public let body_id: String
    public let citation: String
}

/// Root DTO for the metadata registry JSON file.
public struct MetadataRegistry: Codable, Sendable {
    public let species_rules: [SpeciesRule]
    public let behavioral_tidbits: [BehavioralTidbit]
}

/// DTO for items in the master toxicity database.
struct MasterToxicItem: Codable, Sendable {
    let name: String
    let severity: String
    let symptoms: String
    let match_keywords: [String]
}

/// Root DTO for the master toxicity database JSON file.
struct MasterToxicityData: Codable, Sendable {
    let dog: [MasterToxicItem]
    let cat: [MasterToxicItem]
    let hamster: [MasterToxicItem]
}

/// Actor responsible for initial data seeding and loading static resources.
/// Ensures the SwiftData store is populated with necessary reference data.
actor DataManager {
    /// Shared singleton instance.
    static let shared = DataManager()
    
    private init() {}
    
    /// Seeds the SwiftData container with initial metadata if empty.
    /// Loads from bundled JSON files: MetadataRegistry and MasterToxicityDatabase.
    /// - Parameter modelContainer: The SwiftData container to seed.
    func seedData(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        
        // 1. Initial check: If rules already exist, we don't need to seed.
        let descriptor = FetchDescriptor<SpeciesRuleModel>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        
        // 2. Step 1: Seed Species Rules & Tidbits from MetadataRegistry
        if let url = Bundle.main.url(forResource: "MetadataRegistry", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let registry = try? JSONDecoder().decode(MetadataRegistry.self, from: data) {
            
            for rule in registry.species_rules {
                let ruleModel = SpeciesRuleModel(
                    species: rule.species,
                    rerConstant: rule.rer_constant,
                    heatThresholdCelsius: rule.heat_threshold_celsius
                )
                context.insert(ruleModel)
            }
            
            for tidbit in registry.behavioral_tidbits {
                let model = TidbitModel(
                    id: tidbit.id,
                    speciesTarget: tidbit.species_target,
                    title: tidbit.title_id,
                    bodyText: tidbit.body_id,
                    citation: tidbit.citation
                )
                context.insert(model)
            }
            try? context.save()
        }
        
        // 3. Step 2: Seed the comprehensive Toxicity list from MasterToxicityDatabase.json
        if let masterUrl = Bundle.main.url(forResource: "MasterToxicityDatabase", withExtension: "json"),
           let masterData = try? Data(contentsOf: masterUrl),
           let db = try? JSONDecoder().decode(MasterToxicityData.self, from: masterData) {
           
            // Fetch the rules we just inserted so we can link them to the foods
            let rules = (try? context.fetch(FetchDescriptor<SpeciesRuleModel>())) ?? []
            let dogRule = rules.first(where: { $0.species == "dog" })
            let catRule = rules.first(where: { $0.species == "cat" })
            let hamsterRule = rules.first(where: { $0.species == "hamster" })
            
            func insertHazards(_ items: [MasterToxicItem], rule: SpeciesRuleModel?) {
                for item in items {
                    let hazardModel = ToxicityModel(
                        keyword: item.name,
                        dangerLevel: item.severity.capitalized,
                        alternative: item.symptoms
                    )
                    hazardModel.speciesRule = rule
                    context.insert(hazardModel)
                }
            }
            
            insertHazards(db.dog, rule: dogRule)
            insertHazards(db.cat, rule: catRule)
            insertHazards(db.hamster, rule: hamsterRule)
        }
        
        do {
            try context.save()
            print("Successfully seeded all data from JSONs.")
        } catch {
            print("Failed to seed Data: \(error)")
        }
    }
    
    /// Loads breed-specific fun facts from local JSON.
    /// - Returns: A dictionary mapping breed names to lists of FunFactModel.
    func loadFunFacts() -> [String: [FunFactModel]] {
        guard let url = Bundle.main.url(forResource: "BreedFunFacts", withExtension: "json") else {
            print("Could not find BreedFunFacts.json")
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let factsDictionary = try decoder.decode([String: [FunFactModel]].self, from: data)
            return factsDictionary
        } catch {
            print("Failed to decode fun facts: \(error)")
            return [:]
        }
    }
}
