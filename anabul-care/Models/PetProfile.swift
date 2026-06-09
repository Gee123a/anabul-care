//
//  PetProfile.swift
//  anabul-care
//

import Foundation
import SwiftData

@Model
final class PetProfile {
    var id: UUID
    var name: String
    var species: String // "dog", "cat", "hamster"
    var breed: String
    var dateOfBirth: Date
    var weightKg: Double
    var isNeutered: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityLog.pet)
    var activities: [ActivityLog] = []
    
    init(id: UUID = UUID(), name: String, species: String, breed: String, dateOfBirth: Date, weightKg: Double, isNeutered: Bool = false) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.weightKg = weightKg
        self.isNeutered = isNeutered
    }
    
    // Metabolic Calculations
    var petSpecies: PetSpecies {
        PetSpecies(rawValue: species.lowercased()) ?? .cat
    }
    
    var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
        return components.month ?? 0
    }
    
    var lifeStage: LifeStage {
        if ageInMonths < 12 {
            return .puppyKitten
        } else if ageInMonths < 84 { // 7 years
            return .adult
        } else {
            return .senior
        }
    }
    
    var rmr: Double {
        let constant = species.lowercased() == "hamster" ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
}
