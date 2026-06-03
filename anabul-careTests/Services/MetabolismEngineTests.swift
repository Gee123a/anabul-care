//
//  MetabolismEngineTests.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import XCTest
@testable import anabul_care

final class MetabolismEngineTests: XCTestCase {
    var engine: MetabolismEngine!
    
    override func setUp() {
        super.setUp()
        engine = MetabolismEngine()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    func test_calculateMER_forNeuteredDog() {
        // Arrange
        let weight: Double = 10.0 // 10kg
        let isNeutered = true
        let species = PetSpecies.dog
        
        // Act
        // Assuming standard RER formula: 70 * (weight ^ 0.75)
        // Assuming dog neutered multiplier is 1.6
        let expectedRER = 70.0 * pow(weight, 0.75)
        let expectedMER = expectedRER * 1.6
        
        let calculatedMER = MetabolismEngine.calculateMER(pet: <#PetProfile#>, weight: weight, species: species, isNeutered: isNeutered)
        
        // Assert
        XCTAssertEqual(calculatedMER, expectedMER, accuracy: 0.1, "MER for neutered dog calculated incorrectly")
    }
    
    func test_calculateMER_forIntactCat() {
        // Arrange
        let weight: Double = 5.0
        let isNeutered = false
        let species = PetSpecies.cat
        
        // Act
        // Assuming cat intact multiplier is 1.4
        let expectedRER = 70.0 * pow(weight, 0.75)
        let expectedMER = expectedRER * 1.4
        
        let calculatedMER = MetabolismEngine.calculateMER(pet: <#PetProfile#>, weight: weight, species: species, isNeutered: isNeutered)
        
        // Assert
        XCTAssertEqual(calculatedMER, expectedMER, accuracy: 0.1, "MER for intact cat calculated incorrectly")
    }
}
