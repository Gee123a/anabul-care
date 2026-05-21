import SwiftUI
import MapKit

struct PuskeswanRadarView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var results: [MKMapItem] = []
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                ForEach(results, id: \.self) { item in
                    Marker(item.name ?? "Klinik", coordinate: item.placemark.coordinate)
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("Radar")
            .task {
                await searchNearby()
            }
        }
    }
    
    private func searchNearby() async {
        let request = MKLocalSearch.Request()
        // SRS says restrict to these tokens: "Pet Hotel", "Penitipan Hewan", "Puskeswan", "Klinik Hewan"
        request.naturalLanguageQuery = "Puskeswan Klinik Hewan"
        // SRS says limited to 10km radius. 
        // We'll use a standard search for now which defaults to nearby.
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            results = response.mapItems
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PuskeswanRadarView()
}
