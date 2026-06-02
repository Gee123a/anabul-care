import Foundation
import MapKit

enum POICategory: String, CaseIterable {
    case all = "Semua Kategori"
    case vet = "Klinik Hewan & Puskeswan"
    case hotel = "Pet Hotel"
    case park = "Taman Hewan"
}

struct ClinicModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distance: String
    let statusText: String
    let address: String
    let operatingHours: String
    var category: POICategory = .vet

    static func == (lhs: ClinicModel, rhs: ClinicModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
