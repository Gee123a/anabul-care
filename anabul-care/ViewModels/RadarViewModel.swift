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
    
    private let radarService: RadarServiceProtocol
    
    init(radarService: RadarServiceProtocol = RadarService()) {
        self.radarService = radarService
        loadClinics()
    }
    
    func loadClinics() {
        Task {
            let fetchedClinics = await radarService.getNearbyClinics()
            await MainActor.run {
                self.clinics = fetchedClinics
                self.selectedClinic = fetchedClinics.first
            }
        }
    }
}
