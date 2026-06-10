//
//  Protocols.swift
//  anabul-care
//

import Foundation
import SwiftData


public protocol PetRepositoryProtocol {
    func fetchPets() throws -> [PetProfile]
    func addPet(_ pet: PetProfile) throws
    func deletePet(_ pet: PetProfile) throws
    func save() throws
    
    func fetchPreferences(for petID: UUID) throws -> [TaskPreference]
    func fetchDeactivations(for petID: UUID) throws -> [TaskDeactivation]
    
    func addPreference(_ preference: TaskPreference) throws
    func addDeactivation(_ deactivation: TaskDeactivation) throws
    func deletePreference(_ preference: TaskPreference) throws
}

protocol ToxicityRepositoryProtocol {
    func fetchToxicityRules() throws -> [ToxicityModel]
    func fetchSpeciesRules() throws -> [SpeciesRuleModel]
}


protocol PetServiceProtocol {
    func calculateDailyNeeds(for pet: PetProfile) -> Double
    func logActivity(_ activity: ActivityLog, for pet: PetProfile)
}

protocol SafetyServiceProtocol {
    func isSafe(item: String, for species: String) -> [ToxicityModel]
}
