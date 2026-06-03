//
//  PetRepositoryTests.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import XCTest
import SwiftData
@testable import anabul_care

@MainActor
final class PetRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var repository: PetRepository!
    
    override func setUpWithError() throws {
        // Arrange: Create IN-MEMORY SwiftData container
        let schema = Schema([PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        repository = PetRepository(context: context)
    }
    
    override func tearDownWithError() throws {
        repository = nil
        context = nil
        container = nil
    }
    
    func test_addPet_successfullySavesToContext() throws {
        // Arrange
        let newPet = PetProfile(name: "Budi", species: "dog", breed: "Golden Retriever", dateOfBirth: Date(), weightKg: 15.0, isNeutered: false)
        
        // Act
        try repository.addPet(newPet)
        
        // Assert
        let descriptor = FetchDescriptor<PetProfile>()
        let fetchedPets = try context.fetch(descriptor)
        
        XCTAssertEqual(fetchedPets.count, 1, "There should be exactly 1 pet in the database")
        XCTAssertEqual(fetchedPets.first?.name, "Budi", "The saved pet's name should match")
    }
    
    func test_deletePet_successfullyRemovesFromContext() throws {
        // Arrange
        let pet = PetProfile(name: "Luna", species: "cat", breed: "Persian", dateOfBirth: Date(), weightKg: 4.0, isNeutered: true)
        try repository.addPet(pet)
        
        // Act
        try repository.deletePet(pet)
        
        // Assert
        let descriptor = FetchDescriptor<PetProfile>()
        let fetchedPets = try context.fetch(descriptor)
        
        XCTAssertTrue(fetchedPets.isEmpty, "The database should be empty after deletion")
    }
}
