import Foundation

struct RoutineTask: Codable, Sendable {
    let type: String
    let title: String
    let time: String
    let detail: String
    let icon: String
}

struct RoutineTrigger: Codable, Sendable {
    let age_max_months: Int?
    let age_min_months: Int?
    let trait: String?
    let weekday: Int? // 1 = Sunday, 7 = Saturday
}

struct RoutineModifier: Codable, Sendable {
    let id: String
    let trigger: RoutineTrigger
    let action: String // "add", "modify", "remove"
    let task: RoutineTask?
    let target_type: String?
    let new_title: String?
    let new_detail: String?
    let new_icon: String?
}

struct DetailedMetadataRegistry: Codable, Sendable {
    let species_rules: [SpeciesRule]
    let behavioral_tidbits: [BehavioralTidbit]
    let breed_metadata: [String: [String: [String]]] // Species -> BreedName -> [Traits]
    let base_routines: [String: [RoutineTask]] // Species -> [Tasks]
    let routine_modifiers: [RoutineModifier]
}

class RoutineRuleEngine {
    static let shared = RoutineRuleEngine()
    
    private var registry: DetailedMetadataRegistry?
    
    private init() {
        loadRegistry()
    }
    
    private func loadRegistry() {
        guard let url = Bundle.main.url(forResource: "MetadataRegistry", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("RoutineRuleEngine: Failed to find MetadataRegistry.json")
            return
        }
        
        do {
            self.registry = try JSONDecoder().decode(DetailedMetadataRegistry.self, from: data)
            print("RoutineRuleEngine: Successfully loaded registry with \(registry?.routine_modifiers.count ?? 0) modifiers.")
        } catch {
            print("RoutineRuleEngine: Failed to decode JSON: \(error)")
        }
    }
    
    func getBaseRoutine(for species: String) -> [RoutineTask] {
        return registry?.base_routines[species] ?? []
    }
    
    func getTraits(for species: String, breed: String) -> [String] {
        return registry?.breed_metadata[species]?[breed] ?? []
    }
    
    func getModifiers() -> [RoutineModifier] {
        return registry?.routine_modifiers ?? []
    }
}
