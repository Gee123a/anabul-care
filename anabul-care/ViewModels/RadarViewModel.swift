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
    
    private let radarService: RadarServiceProtocol
    
    init(radarService: RadarServiceProtocol = RadarService()) {
        self.radarService = radarService
        self.clinics = radarService.getNearbyClinics()
        self.selectedClinic = clinics.first
    }
    
    func loadClinics() {
        clinics = radarService.getNearbyClinics()
    }
}
