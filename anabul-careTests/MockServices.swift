//
//  MockServices.swift
//  anabul-careTests
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//

import Foundation
import MapKit
@testable import anabul_care

protocol ClinicRepositoryProtocol {
    func fetchClinics() -> [ClinicModel]
    func fetchClinics(in region: MKCoordinateRegion) async throws -> [ClinicModel]
}

protocol RadarServiceProtocol {
    func getNearbyClinics() async -> [ClinicModel]
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func requestAuthorization()
}

// MARK: - Mock Clinic Repository
class MockClinicRepository: ClinicRepositoryProtocol {
    var shouldReturnError = false
    var mockClinics: [ClinicModel] = []
    
    // FIXED: Replaced <#code#> placeholder with actual return
    func fetchClinics() -> [anabul_care.ClinicModel] {
        return mockClinics
    }
    
    func fetchClinics(in region: MKCoordinateRegion) async throws -> [ClinicModel] {
        if shouldReturnError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockClinics
    }
}

// MARK: - Mock Radar Service
class MockRadarService: RadarServiceProtocol {
    var mockLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385)
    var isAuthorized: Bool = true
    var mockNearbyClinics: [ClinicModel] = [] // Added to support the function below
    
    // FIXED: Replaced <#code#> placeholder with actual return
    func getNearbyClinics() async -> [anabul_care.ClinicModel] {
        return mockNearbyClinics
    }
    
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
