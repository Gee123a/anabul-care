//
//  RadarService.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//


import Foundation
import MapKit
import CoreLocation

class RadarService: NSObject, RadarServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func getNearbyClinics() async -> [ClinicModel] {
        guard let location = await getCurrentLocation() else {
            return []
        }

        let searchQueries = ["Puskeswan", "Klinik Hewan", "Pet Hotel", "Penitipan Hewan"]
        var allResults: [ClinicModel] = []

        await withTaskGroup(of: [ClinicModel].self) { group in
            for query in searchQueries {
                group.addTask {
                    await self.performSearch(query: query, at: location)
                }
            }

            for await results in group {
                allResults.append(contentsOf: results)
            }
        }

        // Deduplicate by name and coordinates (approximate)
        return deduplicateResults(allResults)
    }

    private func getCurrentLocation() async -> CLLocation? {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func performSearch(query: String, at location: CLLocation) async -> [ClinicModel] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return response.mapItems.map { item in
                let distanceInMeters = item.placemark.location?.distance(from: location) ?? 0
                let distanceString = String(format: "%.1f km", distanceInMeters / 1000)
                
                return ClinicModel(
                    name: item.name ?? "Unknown Clinic",
                    coordinate: item.placemark.coordinate,
                    distance: distanceString,
                    statusText: "Buka", // MapKit doesn't easily provide real-time status in simple searches
                    address: item.placemark.title ?? "",
                    operatingHours: "Cek detail di peta"
                )
            }
        } catch {
            print("Search error for query '\(query)': \(error)")
            return []
        }
    }

    private func deduplicateResults(_ clinics: [ClinicModel]) -> [ClinicModel] {
        var seenNames = Set<String>()
        var uniqueClinics: [ClinicModel] = []
        
        for clinic in clinics {
            if !seenNames.contains(clinic.name) {
                seenNames.insert(clinic.name)
                uniqueClinics.append(clinic)
            }
        }
        
        return uniqueClinics.sorted { $0.distance < $1.distance }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
}
