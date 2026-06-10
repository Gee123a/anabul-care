//
//  PetRepository.swift
//  anabul-care
//

import Foundation
import SwiftData

/// Concrete implementation of PetRepositoryProtocol using SwiftData.
/// Handles all CRUD operations for pet profiles and their related preferences.
final class PetRepository: PetRepositoryProtocol {
    private let context: ModelContext
    
    /// Initializes the repository with a SwiftData model context.
    init(context: ModelContext) {
        self.context = context
    }
    
    /// Fetches all pet profiles from the database, sorted by name.
    func fetchPets() throws -> [PetProfile] {
        let descriptor = FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    /// Inserts a new pet profile into the database.
    func addPet(_ pet: PetProfile) throws {
        context.insert(pet)
        try save()
    }
    
    /// Removes a pet profile and its associated data from the database.
    func deletePet(_ pet: PetProfile) throws {
        context.delete(pet)
        try save()
    }
    
    /// Persists changes in the model context.
    func save() throws {
        try context.save()
    }
    
    /// Fetches timing preferences for a specific pet.
    func fetchPreferences(for petID: UUID) throws -> [TaskPreference] {
        let descriptor = FetchDescriptor<TaskPreference>(
            predicate: #Predicate<TaskPreference> { $0.petID == petID }
        )
        return try context.fetch(descriptor)
    }
    
    /// Fetches task deactivations for a specific pet.
    func fetchDeactivations(for petID: UUID) throws -> [TaskDeactivation] {
        let descriptor = FetchDescriptor<TaskDeactivation>(
            predicate: #Predicate<TaskDeactivation> { $0.petID == petID }
        )
        return try context.fetch(descriptor)
    }
    
    /// Fetches all task preferences in the database.
    func fetchAllPreferences() throws -> [TaskPreference] {
        let descriptor = FetchDescriptor<TaskPreference>()
        return try context.fetch(descriptor)
    }
    
    /// Adds a new timing preference.
    func addPreference(_ preference: TaskPreference) throws {
        context.insert(preference)
        try save()
    }
    
    /// Adds a new task deactivation record.
    func addDeactivation(_ deactivation: TaskDeactivation) throws {
        context.insert(deactivation)
        try save()
    }
    
    /// Deletes a specific timing preference.
    func deletePreference(_ preference: TaskPreference) throws {
        context.delete(preference)
        try save()
    }
    
    /// Updates or creates a timing preference for a specific task.
    func updatePreference(for petID: UUID, taskType: String, preferredTime: String, isManualOverride: Bool) {
        do {
            let preferences = try fetchPreferences(for: petID)
            if let existing = preferences.first(where: { $0.taskType == taskType }) {
                existing.preferredTime = preferredTime
                existing.isManualOverride = isManualOverride
            } else {
                let newPref = TaskPreference(petID: petID, taskType: taskType, preferredTime: preferredTime, isManualOverride: isManualOverride)
                context.insert(newPref)
            }
            try save()
        } catch {
            print("PetRepository: Error updating preference: \(error)")
        }
    }
}
