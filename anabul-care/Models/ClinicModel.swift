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
    let address: String
    let phone: String
    let category: POICategory
    let mapItem: MKMapItem?
    
    static func == (lhs: ClinicModel, rhs: ClinicModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
