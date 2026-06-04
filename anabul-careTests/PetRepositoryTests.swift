import XCTest
@testable import anabul_care

final class PetRepositoryTests: XCTestCase {
    
    
    
    func test_petProfile_initialization() {
        // Arrange
        let name = "Budi"
        let species = "dog"
        let breed = "Golden Retriever"
        let weight = 15.0
        
        // Act
        let pet = PetProfile(name: name, species: species, breed: breed, dateOfBirth: Date(), weightKg: weight, isNeutered: false)
        
        // Assert
        XCTAssertEqual(pet.name, name)
        XCTAssertEqual(pet.species, species)
        XCTAssertEqual(pet.weightKg, weight)
        XCTAssertEqual(pet.petSpecies, .dog)
    }
    
    func test_petProfile_activityRelationship() {
        // Arrange
        let pet = PetProfile(name: "Luna", species: "cat", breed: "Persian", dateOfBirth: Date(), weightKg: 4.0, isNeutered: true)
        let log = ActivityLog(timestamp: Date(), type: "feeding", detail: "Dinner")
        
        // Act
        pet.activities.append(log)
        log.pet = pet
        
        // Assert
        XCTAssertEqual(pet.activities.count, 1)
        XCTAssertEqual(pet.activities.first?.type, "feeding")
        XCTAssertEqual(log.pet?.name, "Luna")
    }
    
    func test_petProfile_metabolicCalculation() {
        // Arrange
        let pet = PetProfile(name: "Rex", species: "dog", breed: "German Shepherd", dateOfBirth: Date(), weightKg: 10.0)
        
        // Act
        let rmr = pet.rmr
        
        // Assert: 70 * (10 ^ 0.75) ≈ 393.6
        XCTAssertEqual(rmr, 70.0 * pow(10.0, 0.75), accuracy: 0.1)
    }
}
