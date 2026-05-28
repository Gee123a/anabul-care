//
//  RadarViewModelTests.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import XCTest

    @testable import anabul_care
    class MockRadarService: RadarServiceProtocol {
        func getNearbyClinics() -> [ClinicModel] {
            return []
        }
    }

    @MainActor
    final class RadarViewModelTests: XCTestCase {
        func testLoadClinicsUpdatesArray() {
            let mockService = MockRadarService()
            let viewModel = RadarViewModel(radarService: mockService)
            viewModel.loadClinics()
    
            XCTAssertTrue(viewModel.clinics.isEmpty)
        }
    }
