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
    
    // Internal subject to handle debounced region changes
    private var regionChangeSubject = PassthroughSubject<MKCoordinateRegion, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup debounce for map searches to prevent throttling
        regionChangeSubject
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .sink { [weak self] region in
                Task {
                    await self?.performSearch(in: region)
                }
            }
            .store(in: &cancellables)
    }
    
    var filteredClinics: [ClinicModel] {
        clinics.filter { clinic in
            let categoryMatch = (selectedCategory == .all) || (clinic.category == selectedCategory)
            let searchMatch = searchText.isEmpty || clinic.name.localizedCaseInsensitiveContains(searchText)
            return categoryMatch && searchMatch
        }
    }

    /// Triggered from the View when the camera finishes moving
    func updateRegion(_ region: MKCoordinateRegion) {
        regionChangeSubject.send(region)
    }

    func performSearch(in region: MKCoordinateRegion) async {
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
        
        withAnimation {
            self.clinics = uniqueClinics
        }
    }
}
