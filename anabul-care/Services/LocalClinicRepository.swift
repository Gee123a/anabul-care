import Foundation
import MapKit

class LocalClinicRepository: ClinicRepositoryProtocol {
    func fetchClinics() -> [ClinicModel] {
        return [
            ClinicModel(
                name: "Puskeswan Wonokromo",
                coordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
                distance: "0.6 km",
                statusText: "Open until 8 PM",
                address: "Area Wonokromo, Surabaya",
                operatingHours: "08:00 - 20:00"
            )
        ]
    }
}
