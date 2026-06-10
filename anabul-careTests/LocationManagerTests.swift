//
//  LocationManagerTests.swift
//  anabul-careTests
//

import XCTest
import CoreLocation
@testable import anabul_care

@MainActor
final class LocationManagerTests: XCTestCase {
    
    func testConcurrentGetLocation() async throws {
        let locationManager = LocationManager.shared
        
        let expectation = XCTestExpectation(description: "All concurrent tasks resumed")
        expectation.expectedFulfillmentCount = 10
        
        var results: [CLLocation?] = []
        let resultsLock = NSLock()
        
        // Launch 10 concurrent requests to getLocation
        for _ in 0..<10 {
            Task {
                let location = await locationManager.getLocation()
                resultsLock.lock()
                results.append(location)
                resultsLock.unlock()
                expectation.fulfill()
            }
        }
        
        // Give concurrent tasks time to start and queue up
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Simulate delegate callback updating location
        let dummyManager = CLLocationManager()
        let expectedLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
            altitude: 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        
        locationManager.locationManager(dummyManager, didUpdateLocations: [expectedLocation])
        
        // Wait for all tasks to resume
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Verify we got the correct location in all tasks without crashes or race conditions
        resultsLock.lock()
        let count = results.count
        let nonNilResults = results.compactMap { $0 }
        resultsLock.unlock()
        
        XCTAssertEqual(count, 10, "Should have received 10 results")
        XCTAssertEqual(nonNilResults.count, 10, "Should have 10 non-nil locations")
        
        for location in nonNilResults {
            XCTAssertEqual(location.coordinate.latitude, -7.3055, accuracy: 0.0001)
            XCTAssertEqual(location.coordinate.longitude, 112.7385, accuracy: 0.0001)
        }
    }
}
