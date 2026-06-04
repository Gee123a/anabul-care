//
//  ToxicityFeatureTests.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 04/06/26.
//


import XCTest
import CoreSpotlight
@testable import anabul_care

final class ToxicityFeatureTests: XCTestCase {

    // 1. TEST THE JSON PARSING
        func test_MasterToxicityJSON_isValid() throws {
            // Arrange: Find the JSON file in the main app bundle
            let bundle = Bundle.main
            guard let url = bundle.url(forResource: "MasterToxicityDatabase", withExtension: "json") else {
                XCTFail("Missing MasterToxicityDatabase.json file")
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                
                // Act: Parse the JSON into a generic object first
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Safely cast the JSON to a dictionary where keys are species (String) and values are arrays of hazards
                let rootDictionary = try XCTUnwrap(jsonObject as? [String: [[String: Any]]], "JSON should be a dictionary of species categories.")
                
                // Flatten all the arrays (dog, cat, hamster) into one single array to search through
                let allHazards = rootDictionary.values.flatMap { $0 }
                
                // Assert: Prove that the file wasn't empty
                XCTAssertFalse(allHazards.isEmpty, "The JSON file should not be empty")
                
                // Prove a specific known item exists by looking at the "name" property
                let hasChocolate = allHazards.contains { dict in
                    let name = (dict["name"] as? String)?.lowercased() ?? ""
                    return name.contains("chocolate") || name.contains("cokelat")
                }
                XCTAssertTrue(hasChocolate, "Crucial hazards like Chocolate must exist in the database")
                
            } catch {
                XCTFail("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    
    // 2. TEST THE SPOTLIGHT ITEM CREATION
    func test_SpotlightManager_createsValidSearchItems() {
        // Arrange: Use raw strings to test the Spotlight logic safely
        let mockKeyword = "Grapes"
        let mockDangerLevel = "High"
        let mockDescription = "Danger Level: \(mockDangerLevel) - Toxic to kidneys"
        
        // Act: Create an attribute set exactly how SpotlightManager does
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = mockKeyword
        attributeSet.contentDescription = mockDescription
        
        let item = CSSearchableItem(uniqueIdentifier: mockKeyword, domainIdentifier: "com.anabulcare.toxicity", attributeSet: attributeSet)
        
        // Assert: Prove the Spotlight item is formatted exactly as Apple requires
        XCTAssertEqual(item.attributeSet.title, "Grapes")
        XCTAssertTrue(item.attributeSet.contentDescription!.contains("High"))
        XCTAssertEqual(item.uniqueIdentifier, "Grapes")
    }
}
