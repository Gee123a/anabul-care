//
//  PetProfile.swift
//  anabul-care
//

import Foundation
import SwiftData

@Model
public final class PetProfile {
    public var id: UUID
    public var name: String
    public var species: String // "dog", "cat", "hamster"
    public var breed: String
    public var dateOfBirth: Date
    public var weightKg: Double
    public var isNeutered: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityLog.pet)
    public var activities: [ActivityLog] = []
    
    public init(id: UUID = UUID(), name: String, species: String, breed: String, dateOfBirth: Date, weightKg: Double, isNeutered: Bool = false) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.weightKg = weightKg
        self.isNeutered = isNeutered
    }
    
    // Metabolic Calculations
    public var petSpecies: PetSpecies {
        PetSpecies(rawValue: species.lowercased()) ?? .cat
    }
    
    public var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
        return components.month ?? 0
    }
    
    public var lifeStage: LifeStage {
        if ageInMonths < 12 {
            return .puppyKitten
        } else if ageInMonths < 84 { // 7 years
            return .adult
        } else {
            return .senior
        }
    }
    
    public var rmr: Double {
        let constant = species.lowercased() == "hamster" ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
}
