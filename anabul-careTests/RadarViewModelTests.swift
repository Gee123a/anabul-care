//
//  RadarViewModelTests.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import XCTest
import MapKit
@testable import anabul_care

@MainActor
final class RadarViewModelTests: XCTestCase {
    var viewModel: RadarViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = RadarViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_initialState() {
        // Assert
        XCTAssertTrue(viewModel.clinics.isEmpty, "Clinics should initially be empty")
        XCTAssertEqual(viewModel.selectedCategory, .all, "Default category should be .all")
        XCTAssertTrue(viewModel.searchText.isEmpty, "Search text should be empty")
        XCTAssertNil(viewModel.selectedClinic, "No clinic should be selected initially")
    }
    
    func test_filteredClinics_returnsAll_whenCategoryIsAll() {
        // Arrange
        let vet = ClinicModel(name: "Vet A", coordinate: CLLocationCoordinate2D(), address: "", phone: "", category: .vet, mapItem: nil)
        let park = ClinicModel(name: "Park A", coordinate: CLLocationCoordinate2D(), address: "", phone: "", category: .park, mapItem: nil)
        viewModel.clinics = [vet, park]
        
        // Act
        viewModel.selectedCategory = .all
        
        // Assert
        XCTAssertEqual(viewModel.filteredClinics.count, 2, "Should return all clinics")
    }
    
    func test_filteredClinics_filtersCorrectly_whenCategoryIsSelected() {
        // Arrange
        let vet = ClinicModel(name: "Vet A", coordinate: CLLocationCoordinate2D(), address: "", phone: "", category: .vet, mapItem: nil)
        let park = ClinicModel(name: "Park A", coordinate: CLLocationCoordinate2D(), address: "", phone: "", category: .park, mapItem: nil)
        viewModel.clinics = [vet, park]
        
        // Act
        viewModel.selectedCategory = .vet
        
        // Assert
        XCTAssertEqual(viewModel.filteredClinics.count, 1, "Should only return one item")
        XCTAssertEqual(viewModel.filteredClinics.first?.category, .vet, "Should only return the vet clinic")
    }
}
