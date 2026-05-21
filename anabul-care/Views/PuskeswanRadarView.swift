import SwiftUI
import MapKit

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    
    var body: some View {
        NavigationStack {
            Map(position: $viewModel.position) {
                ForEach(viewModel.results, id: \.self) { item in
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
                await viewModel.searchNearby()
            }
        }
    }
}

#Preview {
    PuskeswanRadarView()
}
