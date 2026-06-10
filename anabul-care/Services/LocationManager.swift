//
//  LocationManager.swift
//  anabul-care
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    private let lock = NSLock()
    private var lastLocation: CLLocation?
    private var continuations: [CheckedContinuation<CLLocation?, Never>] = []
    private var isRequestingLocation = false
    
    // Testing flag to prevent the simulator hardware from returning coordinates before our tests can inject them
    var isMockedForTesting = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func getLocation() async -> CLLocation? {
        lock.lock()
        if let location = lastLocation {
            lock.unlock()
            return location
        }
        
        return await withCheckedContinuation { continuation in
            continuations.append(continuation)
            
            let shouldRequest = !isRequestingLocation
            if shouldRequest {
                isRequestingLocation = true
            }
            lock.unlock()
            
            if shouldRequest {
                // Must call CLLocationManager methods on main actor/thread since it's an NSObject delegate
                Task { @MainActor in
                    if !self.isMockedForTesting {
                        self.manager.requestLocation()
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lock.lock()
        let currentLocations = locations
        let queuedContinuations = continuations
        continuations.removeAll()
        isRequestingLocation = false
        if let first = locations.first {
            lastLocation = first
        }
        lock.unlock()
        
        for continuation in queuedContinuations {
            continuation.resume(returning: currentLocations.first)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager: Location error: \(error.localizedDescription)")
        lock.lock()
        let queuedContinuations = continuations
        continuations.removeAll()
        isRequestingLocation = false
        lock.unlock()
        
        for continuation in queuedContinuations {
            continuation.resume(returning: nil)
        }
    }
    
    // Testing helper to ensure a clean state
    func resetTestState() {
        lock.lock()
        lastLocation = nil
        continuations.removeAll()
        isRequestingLocation = false
        lock.unlock()
    }
}
