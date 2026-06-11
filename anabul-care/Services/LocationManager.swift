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
    
    private func getCachedLocationAndPrepareRequest() -> (CLLocation?, Bool) {
        lock.lock()
        defer { lock.unlock() }
        if let location = lastLocation {
            return (location, false)
        }
        let shouldRequest = !isRequestingLocation
        if shouldRequest {
            isRequestingLocation = true
        }
        return (nil, shouldRequest)
    }
    
    private func appendContinuation(_ continuation: CheckedContinuation<CLLocation?, Never>) {
        lock.lock()
        defer { lock.unlock() }
        continuations.append(continuation)
    }
    
    func getLocation() async -> CLLocation? {
        let (cached, shouldRequest) = getCachedLocationAndPrepareRequest()
        if let cached = cached {
            return cached
        }
        
        return await withCheckedContinuation { continuation in
            appendContinuation(continuation)
            
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
