import Foundation

/// Service responsible for calculating metabolic requirements (RER and MER) for pets.
struct MetabolismEngine {
    
    /// Calculates the Resting Energy Requirement (RER).
    /// Formula: 70 * (weight)^0.75 for Dogs/Cats, 145 * (weight)^0.75 for Hamsters.
    /// - Parameters:
    ///   - weightKg: The weight of the pet in kilograms.
    ///   - species: The species of the pet.
    /// - Returns: The RER in calories.
    static func calculateRER(weightKg: Double, species: PetSpecies) -> Double {
        let constant: Double = (species == .hamster) ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
    
    /// Calculates the Maintenance Energy Requirement (MER) based on species, age, and neutering status.
    /// - Parameter pet: The pet profile to calculate MER for.
    /// - Returns: The MER in calories.
    static func calculateMER(pet: PetProfile) -> Double {
        let rer = calculateRER(weightKg: pet.weightKg, species: pet.petSpecies)
        let ageMonths = pet.ageInMonths

        switch pet.petSpecies {
        case .dog:
            if ageMonths < 12 { return rer * 3.0 }
            return pet.isNeutered ? rer * 1.6 : rer * 1.8
        case .cat:
            if ageMonths < 12 { return rer * 2.5 }
            return pet.isNeutered ? rer * 1.2 : rer * 1.4
        case .hamster:
            return ageMonths < 6 ? rer * 1.2 : rer * 1.0
        }
    }
}

// MARK: - PetProfile Extension

extension PetProfile {
    /// Convenience property to get the Resting Energy Requirement.
    var rer: Double {
        MetabolismEngine.calculateRER(weightKg: weightKg, species: petSpecies)
    }

    /// Convenience property to get the target maintenance calories.
    var dailyTargetCalories: Double {
        MetabolismEngine.calculateMER(pet: self)
    }
}
