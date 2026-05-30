import Foundation

/// Specialized engine for metabolic calculations to decouple logic from data management.
struct MetabolismEngine {
    
    /// Calculates the Resting Energy Requirement (RER)
    /// Formula: 70 * (weight)^0.75 for Dogs/Cats, 145 * (weight)^0.75 for Hamsters
    static func calculateRER(weightKg: Double, species: PetSpecies) -> Double {
        let constant: Double = (species == .hamster) ? 145.0 : 70.0
        return constant * pow(weightKg, 0.75)
    }
    
    /// Calculates the Maintenance Energy Requirement (MER)
    static func calculateMER(pet: PetProfile) -> Double {
        let rer = calculateRER(weightKg: pet.weightKg, species: pet.petSpecies)
        let ageMonths = Calendar.current.dateComponents([.month], from: pet.dateOfBirth, to: Date()).month ?? 0

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

    // Extend PetProfile to provide easy access to these calculations
    extension PetProfile {
    var rer: Double {
        MetabolismEngine.calculateRER(weightKg: weightKg, species: petSpecies)
    }

    var dailyTargetCalories: Double {
        MetabolismEngine.calculateMER(pet: self)
    }
    }
