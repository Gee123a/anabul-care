import Foundation
import SwiftData
import SwiftUI
import WidgetKit

@Observable
public final class PetProfileViewModel {
    public var pet: PetProfile
    private let repository: PetRepositoryProtocol
    
    public init(pet: PetProfile, repository: PetRepositoryProtocol) {
        self.pet = pet
        self.repository = repository
    }
    
    public var formattedAge: String {
        let years = pet.ageInMonths / 12
        let months = pet.ageInMonths % 12
        if years > 0 {
            return "\(years) Yrs \(months) Mos"
        } else {
            return "\(months) Mos"
        }
    }
    
    public var formattedWeight: String {
        return String(format: "%.1f kg", pet.weightKg)
    }
    
    public func deletePet() {
        do {
            try repository.deletePet(pet)
            WidgetCenter.shared.reloadAllTimelines()
            
            // SYNC TO WATCH: Push the full updated state after deletion
            if let allPets = try? repository.fetchPets(),
               let allPrefs = try? repository.fetchAllPreferences() {
                WatchConnectivityManager.shared.syncFullStateToWatch(pets: allPets, preferences: allPrefs)
            }
        } catch {
            print("PetProfileViewModel: Error deleting pet: \(error)")
        }
    }
}
