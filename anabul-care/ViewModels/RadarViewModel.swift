import Foundation
import SwiftUI
import MapKit
import Combine

import Foundation
import SwiftUI
import MapKit
import Combine

/// ViewModel for the Radar feature, managing map state, clinic searches, and navigation.
@Observable
@MainActor
public final class RadarViewModel {
    /// The current camera position on the map.
    public var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
        distance: 4000
    ))
    
    /// List of clinics found in the current region.
    public var clinics: [ClinicModel] = []
    
    /// The currently selected clinic on the map.
    public var selectedClinic: ClinicModel?
    
    /// User's search text for filtering or regional search.
    public var searchText: String = ""
    
    /// The active category filter.
    public var selectedCategory: POICategory = .all
    
    /// The current center coordinate of the map view.
    public var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385)
    
    /// The current distance (altitude) of the map camera.
    public var currentDistance: Double = 5000
    
    public init() {}
    
    /// Returns clinics filtered by category and search text.
    public var filteredClinics: [ClinicModel] {
        clinics.filter { clinic in
            let categoryMatch = (selectedCategory == .all) || (clinic.category == selectedCategory)
            let searchMatch = searchText.isEmpty || clinic.name.localizedCaseInsensitiveContains(searchText)
            return categoryMatch && searchMatch
        }
    }

    /// Searches for a specific region by name and updates the map position.
    /// - Parameter query: The name of the city or region to search for.
    public func searchForRegion(query: String) async {
        guard !query.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let firstItem = response.mapItems.first {
                withAnimation {
                    self.position = .camera(MapCamera(
                        centerCoordinate: firstItem.placemark.coordinate,
                        distance: 8000
                    ))
                }
            }
        } catch {
            print("RadarViewModel: Regional search failed: \(error)")
        }
    }

    /// Performs a search for pet-related points of interest in a given region.
    /// - Parameter region: The coordinate region to search within.
    public func performSearch(in region: MKCoordinateRegion) async {
        var newClinics: [ClinicModel] = []
        
        let searchQueries: [(String, POICategory)] = [
            ("Klinik Hewan", .vet),
            ("Pet Hotel", .hotel),
            ("Taman", .park)
        ]
        
        for query in searchQueries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query.0
            request.region = region
            
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                for item in response.mapItems {
                    let name = item.name ?? "Unknown"
                    guard isRelevant(name: name, category: query.1) else { continue }
                    
                    let clinic = ClinicModel(
                        name: name,
                        coordinate: item.placemark.coordinate,
                        address: item.placemark.title ?? "",
                        phone: item.phoneNumber ?? "No Phone",
                        category: query.1,
                        mapItem: item
                    )
                    newClinics.append(clinic)
                }
            } catch {
                continue
            }
        }
        
        // Ensure uniqueness
        var uniqueClinics: [ClinicModel] = []
        var seen = Set<String>()
        
        for clinic in newClinics {
            let key = clinic.name + String(clinic.coordinate.latitude)
            if !seen.contains(key) {
                seen.insert(key)
                uniqueClinics.append(clinic)
            }
        }
        
        withAnimation {
            self.clinics = uniqueClinics
        }
    }
    
    /// Filters search results to ensure they are actually relevant to pets.
    private func isRelevant(name: String, category: POICategory) -> Bool {
        let lowercaseName = name.lowercased()
        let petKeywords = [
            "pet", "hewan", "kucing", "anjing", "cat", "dog", "paw", "animal",
            "boarding", "grooming", "penitipan", "vet", "klinik", "clinic",
            "care", "drh", "dokter", "aquatic", "reptile", "bird", "burung",
            "meow", "bark", "tail", "fur", "fauna"
        ]
        
        switch category {
        case .hotel:
            return petKeywords.contains { lowercaseName.contains($0) } || lowercaseName.contains("hotel")
        case .vet:
            let isPetRelated = petKeywords.contains { lowercaseName.contains($0) } || lowercaseName.contains("drh")
            let isMedical = lowercaseName.contains("klinik") || lowercaseName.contains("clinic") || 
                            lowercaseName.contains("hospital") || lowercaseName.contains("rumah sakit") || 
                            lowercaseName.contains("rs ") || lowercaseName.contains("puskesmas")
            return isPetRelated && isMedical
        case .park:
            return true
        case .all:
            return true
        }
    }
    
    // MARK: - Navigation & Zoom
    
    /// Increases the map zoom level.
    public func zoomIn() {
        let newDistance = max(currentDistance * 0.4, 500)
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance))
        }
    }
    
    /// Decreases the map zoom level.
    public func zoomOut() {
        let newDistance = min(currentDistance * 2.5, 500000)
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance))
        }
    }
    
    /// Opens the selected clinic in Apple Maps for directions.
    /// - Parameter clinic: The clinic to navigate to.
    public func openInAppleMaps(clinic: ClinicModel) {
        let mapItem: MKMapItem
        if let existing = clinic.mapItem {
            mapItem = existing
        } else {
            let location = CLLocation(latitude: clinic.coordinate.latitude, longitude: clinic.coordinate.longitude)
            mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            mapItem.name = clinic.name
        }
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    /// Attempts to open the selected clinic in Google Maps, falling back to web if needed.
    /// - Parameter clinic: The clinic to navigate to.
    public func openInGoogleMaps(clinic: ClinicModel) {
        let lat = clinic.coordinate.latitude
        let lon = clinic.coordinate.longitude
        let appUrl = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving")!
        let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)&travelmode=driving")!
        
        if UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.open(appUrl)
        } else {
            UIApplication.shared.open(webUrl)
        }
    }
}
