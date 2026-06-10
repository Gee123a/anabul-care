import Foundation
import SwiftData
import SwiftUI

@Observable
public final class DashboardViewModel {
    public var pets: [PetProfile] = []
    public var selectedPetID: UUID?
    
    private let repository: PetRepositoryProtocol
    
    public init(repository: PetRepositoryProtocol) {
        self.repository = repository
        fetchPets()
    }
    
    public func fetchPets() {
        do {
            self.pets = try repository.fetchPets()
            if selectedPetID == nil {
                selectedPetID = pets.first?.id
            }
        } catch {
            print("DashboardViewModel: Error fetching pets: \(error)")
        }
    }
    
    public var currentPet: PetProfile? {
        if let id = selectedPetID {
            return pets.first { $0.id == id }
        }
        return pets.first
    }
    
    public var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · MMM d"
        return formatter.string(from: Date())
    }
    
    public func todayTaskCount(for pet: PetProfile?) -> Int {
        guard let pet = pet else { return 0 }
        return DailyRoutineGenerator.generate(for: pet).count
    }
    
    public func dynamicGreetingSubtext(for pet: PetProfile?) -> String {
        guard let pet = pet else { return "Morning sunlight helps regulate sleep cycles for your companions." }
        return "Did you know morning sunlight helps regulate \(pet.name)'s sleep cycle?"
    }
}
