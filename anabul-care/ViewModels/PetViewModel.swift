//
//  PetViewModel.swift
//  anabul-care
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@Observable
final class PetViewModel {
    var pets: [PetProfile] = []
    var isLoading = false
    
    private let repository: PetRepositoryProtocol
    private let metabolismEngine = MetabolismEngine()
    
    init(repository: PetRepositoryProtocol) {
        self.repository = repository
        fetchPets()
    }
    
    func fetchPets() {
        isLoading = true
        do {
            self.pets = try repository.fetchPets()
        } catch {
            print("Error fetching pets: \(error)")
        }
        isLoading = false
    }
    
    func addNewPet(name: String, species: PetSpecies, breed: String, weight: Double, dob: Date) {
        let newPet = PetProfile(name: name, species: species.rawValue, breed: breed, dateOfBirth: dob, weightKg: weight)
        do {
            try repository.addPet(newPet)
            fetchPets()
        } catch {
            print("Error adding pet: \(error)")
        }
    }
    
    func getDailyCalories(for pet: PetProfile) -> Double {
        return MetabolismEngine.calculateMER(pet: pet)
    }
}
