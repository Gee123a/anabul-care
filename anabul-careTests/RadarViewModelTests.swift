//
//  RadarViewModelTests.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import XCTest
import CoreLocation

@testable import anabul_care

class MockRadarService: RadarServiceProtocol {
    func getNearbyClinics() async -> [ClinicModel] {
        return [
            ClinicModel(
                name: "Mock Clinic",
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                distance: "1.0 km",
                statusText: "Open",
                address: "Mock Address",
                operatingHours: "24/7"
            )
        ]
    }
}

@MainActor
final class RadarViewModelTests: XCTestCase {
    func testLoadClinicsUpdatesArray() async {
        let mockService = MockRadarService()
        let viewModel = RadarViewModel(radarService: mockService)
        
        // Wait for async load in init to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        XCTAssertEqual(viewModel.clinics.count, 1)
        XCTAssertEqual(viewModel.clinics.first?.name, "Mock Clinic")
    }
}
