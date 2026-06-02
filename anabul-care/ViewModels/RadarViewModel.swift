import Foundation
import SwiftData
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
        distance: 4000
    ))
    @Published var clinics: [ClinicModel] = []
    @Published var selectedClinic: ClinicModel?
    @Published var searchText: String = ""
    @Published var selectedCategory: POICategory = .all
    
    var filteredClinics: [ClinicModel] {
        clinics.filter { clinic in
            let categoryMatch = (selectedCategory == .all) || (clinic.category == selectedCategory)
            let searchMatch = searchText.isEmpty || clinic.name.localizedCaseInsensitiveContains(searchText)
            return categoryMatch && searchMatch
        }
    }

    func performSearch(in region: MKCoordinateRegion) async {
        var newClinics: [ClinicModel] = []
        
        let searchQueries: [(String, POICategory)] = [
            ("Klinik Hewan", .vet),
            ("Petcare", .vet),
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
