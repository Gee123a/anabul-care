import Foundation
import MapKit

class LocalClinicRepository: ClinicRepositoryProtocol {
    func fetchClinics() -> [ClinicModel] {
        return [
            ClinicModel(
                name: "Puskeswan Wonokromo",
                coordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
                address: "Area Wonokromo, Surabaya",
                phone: "031-1234567",
                category: .vet,
                mapItem: nil
            ),
            ClinicModel(
                name: "Surabaya Pet Hotel",
                coordinate: CLLocationCoordinate2D(latitude: -7.2800, longitude: 112.7400),
                address: "Pusat Kota Surabaya",
                phone: "031-7654321",
                category: .hotel,
                mapItem: nil
            ),
            ClinicModel(
                name: "Taman Bungkul (Pet Zone)",
                coordinate: CLLocationCoordinate2D(latitude: -7.2910, longitude: 112.7400),
                address: "Darmo, Surabaya",
                phone: "No Phone",
                category: .park,
                mapItem: nil
            )
        ]
    }
}
