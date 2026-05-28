//
//  ClinicModel.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import Foundation
import MapKit

    struct ClinicModel: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
        let isEmergency: Bool
        let address: String
        let operatingHours: String
            static func == (lhs: ClinicModel, rhs: ClinicModel) -> Bool {
                lhs.id == rhs.id
            }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
