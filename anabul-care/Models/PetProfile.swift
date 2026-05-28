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
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityLog.pet)
    var activities: [ActivityLog] = []
    
    init(id: UUID = UUID(), name: String, species: String, breed: String, dateOfBirth: Date, weightKg: Double) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.weightKg = weightKg
    }
    
    // Metabolic Calculations
    var rmr: Double {
        let constant = species.lowercased() == "hamster" ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
}
