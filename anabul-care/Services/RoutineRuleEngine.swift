import Foundation

public struct RoutineTask: Codable, Sendable {
    public let type: String
    public let title: String
    public let time: String
    public let detail: String
    public let icon: String
}

public struct RoutineTrigger: Codable, Sendable {
    public let age_max_months: Int?
    public let age_min_months: Int?
    public let trait: String?
    public let weekday: Int? // 1 = Sunday, 7 = Saturday
}

public struct RoutineModifier: Codable, Sendable {
    public let id: String
    public let trigger: RoutineTrigger
    public let action: String // "add", "modify", "remove"
    public let task: RoutineTask?
    public let target_type: String?
    public let new_title: String?
    public let new_detail: String?
    public let new_icon: String?
}

public struct DetailedMetadataRegistry: Codable, Sendable {
    public let species_rules: [SpeciesRule]
    public let behavioral_tidbits: [BehavioralTidbit]
    public let breed_metadata: [String: [String: [String]]]? // Species -> BreedName -> [Traits]
    public let base_routines: [String: [RoutineTask]]? // Species -> [Tasks]
    public let routine_modifiers: [RoutineModifier]?
}

public class RoutineRuleEngine {
    public static let shared = RoutineRuleEngine()
    
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
            print("RoutineRuleEngine: Successfully loaded registry.")
        } catch {
            print("RoutineRuleEngine: Failed to decode JSON: \(error)")
        }
    }
    
    public func getBaseRoutine(for species: String) -> [RoutineTask] {
        return registry?.base_routines?[species] ?? []
    }
    
    public func getTraits(for species: String, breed: String) -> [String] {
        return registry?.breed_metadata?[species]?[breed] ?? []
    }
    
    public func getModifiers() -> [RoutineModifier] {
        return registry?.routine_modifiers ?? []
    }
}
