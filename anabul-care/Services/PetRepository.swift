//
//  PetRepository.swift
//  anabul-care
//

import Foundation
import SwiftData

final class PetRepository: PetRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchPets() throws -> [PetProfile] {
        let descriptor = FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    func addPet(_ pet: PetProfile) throws {
        context.insert(pet)
        try save()
    }
    
    func deletePet(_ pet: PetProfile) throws {
        context.delete(pet)
        try save()
    }
    
    func save() throws {
        try context.save()
    }
    
    func fetchPreferences(for petID: UUID) throws -> [TaskPreference] {
        let descriptor = FetchDescriptor<TaskPreference>(
            predicate: #Predicate<TaskPreference> { $0.petID == petID }
        )
        return try context.fetch(descriptor)
    }
    
    func fetchDeactivations(for petID: UUID) throws -> [TaskDeactivation] {
        let descriptor = FetchDescriptor<TaskDeactivation>(
            predicate: #Predicate<TaskDeactivation> { $0.petID == petID }
        )
        return try context.fetch(descriptor)
    }
    
    func addPreference(_ preference: TaskPreference) throws {
        context.insert(preference)
        try save()
    }
    
    func addDeactivation(_ deactivation: TaskDeactivation) throws {
        context.insert(deactivation)
        try save()
    }
    
    func deletePreference(_ preference: TaskPreference) throws {
        context.delete(preference)
        try save()
    }
}
