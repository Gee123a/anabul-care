//
//  LocalClinicRepository.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import Foundation
import MapKit

    class LocalClinicRepository: ClinicRepositoryProtocol {
        func fetchClinics() -> [ClinicModel] {
            return [
                ClinicModel(
                    name: "Puskeswan Wonokromo",
                    coordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
                    isEmergency: false,
                    address: "Area Wonokromo",
                    operatingHours: "08:00 - 15:00"
                ),
                
                ClinicModel(
                    name: "Surabaya Animal Clinic",
                    coordinate: CLLocationCoordinate2D(latitude: -7.2800, longitude: 112.7400),
                    isEmergency: true,
                    address: "Pusat Kota Surabaya",
                    operatingHours: "Buka 24 Jam"
                )
            ]
        }
    }
