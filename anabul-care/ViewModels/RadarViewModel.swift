import Foundation
import SwiftData
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var results: [MKMapItem] = []
    
    func searchNearby() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Puskeswan Klinik Hewan"
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            results = response.mapItems
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}
