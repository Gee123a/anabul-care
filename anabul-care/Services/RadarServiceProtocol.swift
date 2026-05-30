//
//  RadarServiceProtocol.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import Foundation

    protocol RadarServiceProtocol {
        func getNearbyClinics() async -> [ClinicModel]
    }
