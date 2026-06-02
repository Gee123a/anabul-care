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
    
    func getNearbyClinics() async -> [ClinicModel] {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let rawClinics = repository.fetchClinics()
        return rawClinics
    }
}
