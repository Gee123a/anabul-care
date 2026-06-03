//
//  MockServices.swift
//  anabul-careTests
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import Foundation
import MapKit
@testable import anabul_care

// MARK: - Mock Clinic Repository
class MockClinicRepository: ClinicRepositoryProtocol {
    func fetchClinics() -> [anabul_care.ClinicModel] {
        <#code#>
    }
    
    var shouldReturnError = false
    var mockClinics: [ClinicModel] = []
    
    func fetchClinics(in region: MKCoordinateRegion) async throws -> [ClinicModel] {
        if shouldReturnError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockClinics
    }
}

// MARK: - Mock Radar Service
class MockRadarService: RadarServiceProtocol {
    func getNearbyClinics() async -> [anabul_care.ClinicModel] {
        <#code#>
    }
    
    var mockLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385)
    var isAuthorized: Bool = true
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        if !isAuthorized {
            throw NSError(domain: "LocationError", code: 1, userInfo: nil)
        }
        return mockLocation
    }
    
    func requestAuthorization() {
        isAuthorized = true
    }
}
