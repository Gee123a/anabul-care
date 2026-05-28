//
//  RadarService.swift
//  anabul-care
//
//  Created by Filemon Jose Hagen on 28/05/26.
//

import Foundation

    class RadarService: RadarServiceProtocol {
        private let repository: ClinicRepositoryProtocol
        init(repository: ClinicRepositoryProtocol = LocalClinicRepository()) {
            self.repository = repository
        }

        func getNearbyClinics() -> [ClinicModel] {
            return repository.fetchClinics()
        }
    }
