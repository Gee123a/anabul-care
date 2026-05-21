import Foundation
import SwiftData

/// Enumeration defining the strictly supported companion species.
public enum PetSpecies: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case hamster = "hamster"
}

/// Enumeration defining the specific operational classes of user activity logging.
public enum LogType: String, Codable, CaseIterable {
    case feeding = "feeding"
    case grooming = "grooming"
    case walk = "walk"
    case play = "play"
    case hydration = "hydration"
}

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

@Model
public final class ActivityLog {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var logTypeRaw: String
    public var durationMinutes: Int
    public var details: String
    public var pet: PetProfile?
    
    @Transient
    public var logType: LogType {
        get { LogType(rawValue: logTypeRaw) ?? .feeding }
        set { logTypeRaw = newValue.rawValue }
    }
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), logType: LogType, durationMinutes: Int = 0, details: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.logTypeRaw = logType.rawValue
        self.durationMinutes = durationMinutes
        self.details = details
    }
}

@Model
public final class SpeciesRuleModel {
    @Attribute(.unique) public var species: String
    public var rerConstant: Int
    public var heatThresholdCelsius: Double
    
    @Relationship(deleteRule: .cascade) 
    public var hazards: [ToxicityModel] = []
    
    public init(species: String, rerConstant: Int, heatThresholdCelsius: Double) {
        self.species = species
        self.rerConstant = rerConstant
        self.heatThresholdCelsius = heatThresholdCelsius
    }
}

@Model
public final class ToxicityModel {
    @Attribute(.unique) public var id: UUID
    public var keyword: String
    public var dangerLevel: String
    public var alternative: String
    public var speciesRule: SpeciesRuleModel?
    
    public init(id: UUID = UUID(), keyword: String, dangerLevel: String, alternative: String) {
        self.id = id
        self.keyword = keyword
        self.dangerLevel = dangerLevel
        self.alternative = alternative
    }
}

@Model
public final class TidbitModel {
    @Attribute(.unique) public var id: String
    public var speciesTarget: String
    public var title: String
    public var bodyText: String
    public var citation: String
    
    public init(id: String, speciesTarget: String, title: String, bodyText: String, citation: String) {
        self.id = id
        self.speciesTarget = speciesTarget
        self.title = title
        self.bodyText = bodyText
        self.citation = citation
    }
}
