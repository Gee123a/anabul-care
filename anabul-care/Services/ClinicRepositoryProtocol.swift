//
//  ClinicRepositoryProtocol.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import Foundation

    protocol ClinicRepositoryProtocol {
        func fetchClinics() -> [ClinicModel]
    }
