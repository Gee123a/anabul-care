import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    
    // Set the initial camera position and zoom distance for the map
    @Published var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385),
        distance: 5000
    ))
    
    // Store the active map pins
    @Published var clinics: [ClinicModel] = []
    
    // Track the currently tapped map pin
    @Published var selectedClinic: ClinicModel?
    
    @Published var searchText: String = ""
    @Published var selectedCategory: POICategory = .all
    
    var filteredClinics: [ClinicModel] {
        if selectedCategory == .all {
            return clinics
        }
        return clinics.filter { $0.category == selectedCategory }
    }
    
    // Move the map camera to a specific city or area
    func searchForRegion(query: String) async {
        guard !query.isEmpty else { return }
        
        // Build a search request for the typed city name
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        do {
            // Ask Apple Maps servers for the coordinate data
            let response = try await search.start()
            
            // Extract the first map item and fly the camera to that coordinate
            if let firstItem = response.mapItems.first {
                await MainActor.run {
                    self.position = .camera(MapCamera(
                        centerCoordinate: firstItem.placemark.coordinate,
                        distance: 8000
                    ))
                }
            }
        } catch {
            print("Search failed")
        }
    }
    
    // Scan the visible map area for specific clinic types
    func performSearch(in region: MKCoordinateRegion) async {
        var newClinics: [ClinicModel] = []
        
        // Define Apple Maps search terms and their categories
        let searchQueries: [(String, POICategory)] = [
            // Vet
            ("Klinik Hewan", .vet),
            ("Puskeswan", .vet),
            ("Dokter Hewan", .vet),
            ("Veterinarian", .vet),
            ("Vet Clinic", .vet),
            ("Animal Hospital", .vet),
            ("Petcare", .vet),
            
            // Hotel
            ("Pet Hotel", .hotel),
            ("Pet Boarding", .hotel),
            ("Penitipan Hewan", .hotel),
            ("Hotel Hewan", .hotel),
            ("Dog Daycare", .hotel),
            ("Cat Hotel", .hotel),
            
            // Park
            ("Dog Park", .park),
            ("Taman Hewan", .park),
            ("Taman Anjing", .park),
            ("Pet Park", .park),
            ("Taman", .park),
            ("Park", .park)
        ]
        
        // Define strict terms to filter out human hotels and human clinics
        let petKeywords = [
            "pet", "hewan", "vet", "dog", "cat", "anjing", "kucing",
            "puskeswan", "animal", "satwa", "paw", "tail", "groom",
            "fur", "meow", "bark", "clinic", "klinik", "care",
            "kennel", "boarding", "penitipan", "peliharaan", "hospital",
            "dokter"
        ]
        
        for query in searchQueries {
            // Configure the MapKit search request for the current screen boundaries
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query.0
            request.region = region
            
            // Execute the local search
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                
                // Process each location returned by Apple Maps
                for item in response.mapItems {
                    let name = item.name ?? ""
                    let address = item.placemark.title ?? ""
                    let searchableText = "\(name) \(address)".lowercased()
                    
                    var isValid = false
                    
                    // Conditionally apply the Keyword Shield
                    if query.1 == .vet || query.1 == .hotel {
                        // Require a pet word for veterinarians and hotels
                        isValid = petKeywords.contains { searchableText.contains($0) }
                    } else {
                        // Allow all general parks to display
                        isValid = true
                    }
                    
                    if isValid {
                        // Convert the raw MKMapItem into your custom ClinicModel
                        let clinic = ClinicModel(
                            name: name.isEmpty ? "Unknown" : name,
                            coordinate: item.placemark.coordinate,
                            address: address,
                            phone: item.phoneNumber ?? "No Phone",
                            category: query.1,
                            mapItem: item
                        )
                        newClinics.append(clinic)
                    }
                }
            } catch {
                continue
            }
        }
        
        // Filter out duplicates (same coordinate + name)
        // Apple Maps often returns the exact same location for different search terms
        var uniqueClinics: [ClinicModel] = []
        var seen = Set<String>()
        
        for clinic in newClinics {
            // Generate a unique ID string using the name and the latitude
            let key = clinic.name + String(clinic.coordinate.latitude)
            
            // Add the clinic only if the ID string does not exist in the Set
            if !seen.contains(key) {
                seen.insert(key)
                uniqueClinics.append(clinic)
            }
        }
        
        // Update the user interface with the clean data array
        self.clinics = uniqueClinics
    }
}
