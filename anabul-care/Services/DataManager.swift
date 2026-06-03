import Foundation
import SwiftData

// Existing structs for MetadataRegistry
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

// NEW: Structs to parse the full Master database
struct MasterToxicItem: Codable {
    let name: String
    let severity: String
    let symptoms: String
    let match_keywords: [String]
}

struct MasterToxicityData: Codable {
    let dog: [MasterToxicItem]
    let cat: [MasterToxicItem]
    let hamster: [MasterToxicItem]
}

actor DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func seedData(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        
        // Check if we've already seeded rules. If count > 0, it skips seeding.
        let descriptor = FetchDescriptor<SpeciesRuleModel>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        
        // Step 1: Seed Species Rules & Tidbits from MetadataRegistry
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
        
        // Step 2: Seed the comprehensive Toxicity list from MasterToxicityDatabase.json
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
                        alternative: item.symptoms // We map symptoms to the "alternative" property
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
}
