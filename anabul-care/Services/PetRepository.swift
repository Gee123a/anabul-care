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
}
