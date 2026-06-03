//
//  MetabolismEngineTests.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import XCTest
@testable import anabul_care // Make sure this matches your exact project name

final class MetabolismEngineTests: XCTestCase {
    
    func test_calculateMER_forNeuteredDog() {
        // Arrange: Create a mock PetProfile with the exact stats you want to test
        let mockDog = PetProfile(
            name: "TestDog",
            species: "dog",
            breed: "Mixed",
            dateOfBirth: Date(),
            weightKg: 10.0,
            isNeutered: true
        )
        
        // Act: Pass ONLY the pet object into your static function
        let calculatedMER = MetabolismEngine.calculateMER(pet: mockDog)
        
        // Assert: 70 * (10 ^ 0.75) * 1.6
        let expectedRER = 70.0 * pow(10.0, 0.75)
        let expectedMER = expectedRER * 1.6
        
        XCTAssertEqual(calculatedMER, expectedMER, accuracy: 0.1, "MER for neutered dog calculated incorrectly")
    }
    
    func test_calculateMER_forIntactCat() {
        // Arrange
        let mockCat = PetProfile(
            name: "TestCat",
            species: "cat",
            breed: "Mixed",
            dateOfBirth: Date(),
            weightKg: 5.0,
            isNeutered: false
        )
        
        // Act
        let calculatedMER = MetabolismEngine.calculateMER(pet: mockCat)
        
        // Assert: 70 * (5 ^ 0.75) * 1.4
        let expectedRER = 70.0 * pow(5.0, 0.75)
        let expectedMER = expectedRER * 1.4
        
        XCTAssertEqual(calculatedMER, expectedMER, accuracy: 0.1, "MER for intact cat calculated incorrectly")
    }
}
