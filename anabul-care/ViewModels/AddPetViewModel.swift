import Foundation
import SwiftData
import SwiftUI

@Observable
public final class AddPetViewModel {
    public var name: String = ""
    public var species: PetSpecies = .dog
    public var breed: String = ""
    public var customBreed: String = ""
    public var dateOfBirth: Date = Date()
    public var weightString: String = ""
    public var isNeutered: Bool = false
    public var breedsRegistry: [String: [String]] = [:]
    public var isSaved = false
    
    public var petToEdit: PetProfile?
    private let repository: PetRepositoryProtocol
    
    public init(petToEdit: PetProfile? = nil, repository: PetRepositoryProtocol) {
        self.petToEdit = petToEdit
        self.repository = repository
        loadBreeds()
        
        if let pet = petToEdit {
            self.name = pet.name
            self.species = PetSpecies(rawValue: pet.species) ?? .dog
            self.dateOfBirth = pet.dateOfBirth
            self.weightString = String(format: "%.1f", pet.weightKg)
            self.isNeutered = pet.isNeutered
            
            let availableBreeds = breedsRegistry[pet.species] ?? []
            if availableBreeds.contains(pet.breed) {
                self.breed = pet.breed
            } else {
                self.breed = "Other (Type manually)"
                self.customBreed = pet.breed
            }
        } else {
            self.breed = breedsRegistry[species.rawValue]?.first ?? ""
        }
    }
    
    public func loadBreeds() {
        guard let url = Bundle.main.url(forResource: "BreedRegistry", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let registry = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return
        }
        self.breedsRegistry = registry
    }
    
    public var parsedWeight: Double {
        Double(weightString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    public var currentBreeds: [String] {
        breedsRegistry[species.rawValue] ?? []
    }
    
    public var isFormValid: Bool {
        let breedValid = breed == "Other (Type manually)" ? !customBreed.isEmpty : !breed.isEmpty
        return !name.isEmpty && parsedWeight > 0 && breedValid
    }
    
    public func updateSpecies(_ newSpecies: PetSpecies) {
        self.species = newSpecies
        self.breed = breedsRegistry[newSpecies.rawValue]?.first ?? ""
    }
    
    public func savePet() {
        let finalBreed = (breed == "Other (Type manually)") ? customBreed : breed
        
        do {
            if let pet = petToEdit {
                pet.name = name
                pet.species = species.rawValue
                pet.breed = finalBreed
                pet.dateOfBirth = dateOfBirth
                pet.weightKg = parsedWeight
                pet.isNeutered = isNeutered
                try repository.save()
            } else {
                let newPet = PetProfile(
                    name: name,
                    species: species.rawValue,
                    breed: finalBreed,
                    dateOfBirth: dateOfBirth,
                    weightKg: parsedWeight,
                    isNeutered: isNeutered
                )
                try repository.addPet(newPet)
            }
            self.isSaved = true
        } catch {
            print("AddPetViewModel: Error saving pet: \(error)")
        }
    }
}
