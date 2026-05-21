import Foundation
import SwiftData

@Model
public final class PetProfile {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var speciesRaw: String
    public var breed: String
    public var dateOfBirth: Date
    public var weightKg: Double
    public var isNeutered: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityLog.pet) 
    public var activityLogs: [ActivityLog] = []
    
    // Computed property for strict type enforcement across extensions
    @Transient
    public var species: PetSpecies {
        get { PetSpecies(rawValue: speciesRaw) ?? .dog }
        set { speciesRaw = newValue.rawValue }
    }
    
    public init(id: UUID = UUID(), name: String, species: PetSpecies, breed: String, dateOfBirth: Date, weightKg: Double, isNeutered: Bool = false) {
        self.id = id
        self.name = name
        self.speciesRaw = species.rawValue
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.weightKg = weightKg
        self.isNeutered = isNeutered
    }
}
