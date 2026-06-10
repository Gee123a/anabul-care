//
//  PetProfile.swift
//  anabul-care
//

import Foundation
import SwiftData

/// Data model representing a pet's profile, including physical attributes and activity history.
@Model
public final class PetProfile {
    /// Unique identifier for the pet.
    public var id: UUID
    /// Display name of the pet.
    public var name: String
    /// Species of the pet (dog, cat, hamster).
    public var species: String
    /// Breed of the pet.
    public var breed: String
    /// Date when the pet was born.
    public var dateOfBirth: Date
    /// Current weight of the pet in kilograms.
    public var weightKg: Double
    /// Whether the pet has been neutered/spayed.
    public var isNeutered: Bool
    
    /// Historical logs of activities associated with this pet.
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
    
    /// Computed property to return the strongly-typed PetSpecies.
    public var petSpecies: PetSpecies {
        PetSpecies(rawValue: species.lowercased()) ?? .cat
    }
    
    /// Calculates the pet's age in months based on the current date.
    public var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
        return components.month ?? 0
    }
    
    /// Determines the life stage of the pet based on its age.
    public var lifeStage: LifeStage {
        if ageInMonths < 12 {
            return .puppyKitten
        } else if ageInMonths < 84 { // 7 years
            return .adult
        } else {
            return .senior
        }
    }
}
