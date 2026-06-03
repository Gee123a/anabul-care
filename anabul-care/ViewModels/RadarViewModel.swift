import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385),
        distance: 5000
    ))
    @Published var clinics: [ClinicModel] = []
    @Published var selectedClinic: ClinicModel?
    @Published var searchText: String = ""
    @Published var selectedCategory: POICategory = .all
    
    var filteredClinics: [ClinicModel] {
        if selectedCategory == .all {
            return clinics
        }
        return clinics.filter { $0.category == selectedCategory }
    }
    
    func searchForRegion(query: String) async {
        guard !query.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
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
    
    func performSearch(in region: MKCoordinateRegion) async {
        var newClinics: [ClinicModel] = []
        
        // FIX: Added International terms so Apple Maps can categorize places globally
        let searchQueries: [(String, POICategory)] = [
            ("Klinik Hewan", .vet),
            ("Veterinarian", .vet),
            ("Animal Hospital", .vet),
            ("Petcare", .vet),
            ("Pet Hotel", .hotel),
            ("Pet Boarding", .hotel),
            ("Taman", .park),
            ("Park", .park),
            ("Dog Park", .park)
        ]
        
        for query in searchQueries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query.0
            request.region = region
            
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                for item in response.mapItems {
                    let clinic = ClinicModel(
                        name: item.name ?? "Unknown",
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
        
        var uniqueClinics: [ClinicModel] = []
        var seen = Set<String>()
        
        for clinic in newClinics {
            let key = clinic.name + String(clinic.coordinate.latitude)
            if !seen.contains(key) {
                seen.insert(key)
                uniqueClinics.append(clinic)
            }
        }
        
        self.clinics = uniqueClinics
    }
}
