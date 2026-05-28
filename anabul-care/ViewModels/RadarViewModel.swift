import Foundation
import SwiftData
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385), distance: 5000))
    @Published var clinics: [ClinicModel] = []
    @Published var selectedClinic: ClinicModel?
    @Published var searchText: String = ""

    private let radarService: RadarServiceProtocol

    // Use a nonisolated init that accepts a service, and provide a MainActor factory for the default
    nonisolated init(radarService: RadarServiceProtocol) {
        self.radarService = radarService
    }

    // Factory initializer confined to the main actor for constructing default service safely
    @MainActor
    convenience init() {
        self.init(radarService: RadarViewModel.makeDefaultService())
    }

    @MainActor
    private static func makeDefaultService() -> RadarServiceProtocol {
        // Construct the default service on the main actor to avoid cross-actor init warnings
        return RadarService()
    }

    // Async load that can be awaited from callers already on the main actor
    func loadClinics() async {
        let result = await radarService.getNearbyClinics()
        self.clinics = result
    }

    // Convenience sync wrapper for existing call sites; hops to the main actor as needed
    func loadClinicsSync() {
        Task { @MainActor in
            let result = await radarService.getNearbyClinics()
            self.clinics = result
        }
    }
}
