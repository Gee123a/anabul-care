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

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func seedData(context: ModelContext) {
        // Check if we've already seeded rules
        let descriptor = FetchDescriptor<SpeciesRuleModel>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "MetadataRegistry", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to find or read MetadataRegistry.json")
            return
        }
        
        do {
            let registry = try JSONDecoder().decode(MetadataRegistry.self, from: data)
            
            for rule in registry.species_rules {
                let ruleModel = SpeciesRuleModel(
                    species: rule.species,
                    rerConstant: rule.rer_constant,
                    heatThresholdCelsius: rule.heat_threshold_celsius
                )
                context.insert(ruleModel)
                
                for hazard in rule.toxic_hazards {
                    let hazardModel = ToxicityModel(
                        keyword: hazard.keyword_id,
                        dangerLevel: hazard.danger_level,
                        alternative: hazard.alternative_id
                    )
                    hazardModel.speciesRule = ruleModel
                    context.insert(hazardModel)
                }
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
            
            try context.save()
            print("Successfully seeded data from MetadataRegistry.json")
        } catch {
            print("Failed to decode or save MetadataRegistry: \(error)")
        }
    }
    
    // MARK: - Math Engine
    
    func calculateRER(weightKg: Double, species: PetSpecies) -> Double {
        let constant: Double = (species == .hamster) ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
    
    func calculateMER(rer: Double, species: PetSpecies, ageMonths: Int, isNeutered: Bool) -> Double {
        switch species {
        case .dog:
            if ageMonths < 12 { return rer * 3.0 }
            return isNeutered ? rer * 1.6 : rer * 1.8
        case .cat:
            if ageMonths < 12 { return rer * 2.5 }
            return isNeutered ? rer * 1.2 : rer * 1.4
        case .hamster:
            return ageMonths < 6 ? rer * 1.2 : rer * 1.0
        }
    }
}
