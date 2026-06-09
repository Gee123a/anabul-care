import Foundation
import SwiftData

// Move structs outside the actor and mark them as Sendable to resolve Swift 6 concurrency warnings
struct ToxicHazard: Codable, Sendable {
    let keyword_id: String
    let danger_level: String
    let alternative_id: String
}

struct SpeciesRule: Codable, Sendable {
    let species: String
    let rer_constant: Int
    let heat_threshold_celsius: Double
    let toxic_hazards: [ToxicHazard]
}

struct BehavioralTidbit: Codable, Sendable {
    let id: String
    let species_target: String
    let title_id: String
    let body_id: String
    let citation: String
}

struct MetadataRegistry: Codable, Sendable {
    let species_rules: [SpeciesRule]
    let behavioral_tidbits: [BehavioralTidbit]
}

struct MasterToxicItem: Codable, Sendable {
    let name: String
    let severity: String
    let symptoms: String
    let match_keywords: [String]
}

struct MasterToxicityData: Codable, Sendable {
    let dog: [MasterToxicItem]
    let cat: [MasterToxicItem]
    let hamster: [MasterToxicItem]
}

actor DataManager {
    static let shared = DataManager()
    
    private init() {}
    
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
    
    // MARK: - Fun Facts Loader
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
