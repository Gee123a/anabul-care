import Foundation
import SwiftData
import SwiftUI

/// ViewModel for the main Dashboard screen.
/// Owns pet selection state, Watch payload handling, and full-state sync.
/// The View holds zero business logic — all coordination lives here.
@Observable
public final class DashboardViewModel {
    // MARK: - Published State
    public var pets: [PetProfile] = []
    public var selectedPetID: UUID?

    // MARK: - Dependencies
    private let repository: PetRepositoryProtocol
    private let modelContext: ModelContext

    // MARK: - Init
    public init(repository: PetRepositoryProtocol, modelContext: ModelContext) {
        self.repository = repository
        self.modelContext = modelContext
        fetchPets()
    }

    // MARK: - Pet Management

    public func fetchPets() {
        do {
            self.pets = try repository.fetchPets()
            if selectedPetID == nil {
                selectedPetID = pets.first?.id
            }
        } catch {
            print("DashboardViewModel: Error fetching pets: \(error)")
        }
    }

    public var currentPet: PetProfile? {
        if let id = selectedPetID {
            return pets.first { $0.id == id }
        }
        return pets.first
    }

    public var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · MMM d"
        return formatter.string(from: Date())
    }

    public func todayTaskCount(for pet: PetProfile?) -> Int {
        guard let pet = pet else { return 0 }
        return DailyRoutineGenerator.generate(for: pet).count
    }

    public func dynamicGreetingSubtext(for pet: PetProfile?) -> String {
        guard let pet = pet else {
            return "Morning sunlight helps regulate sleep cycles for your companions."
        }
        return "Did you know morning sunlight helps regulate \(pet.name)'s sleep cycle?"
    }

    // MARK: - Watch Integration

    /// Routes an incoming WCSession payload to the appropriate handler.
    /// Called by the View's `.onReceive` — the View passes the raw payload
    /// and this ViewModel decides what to do with it.
    public func handleWatchPayload(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }
        
        switch action {
        case "request_full_sync":
            print("DashboardViewModel: Received full sync request from Watch")
            syncAllToWatch()
            
        case "log_activity":
            let petName = payload["petName"] as? String ?? ""
            let activityType = payload["activityType"] as? String ?? ""
            logActivityFromWatch(petName: petName, activityType: activityType)
            
        default:
            break
        }
    }

    /// Creates and persists an ActivityLog received from the Watch,
    /// updates habit-learning preference, then replies with a full state sync.
    private func logActivityFromWatch(petName: String, activityType: String) {
        guard let targetPet = pets.first(where: {
            $0.name.lowercased() == petName.lowercased()
        }) else {
            print("DashboardViewModel: No pet found named '\(petName)'")
            return
        }

        // Build and save the log
        let newLog = ActivityLog(
            timestamp: Date(),
            type: activityType,
            durationMinutes: 15,
            detail: "Logged via Watch"
        )
        newLog.pet = targetPet
        modelContext.insert(newLog)
        targetPet.activities.append(newLog)

        // Smart habit learning: record the actual logged time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        repository.updatePreference(
            for: targetPet.id,
            taskType: activityType,
            preferredTime: formatter.string(from: Date()),
            isManualOverride: true
        )

        do {
            try modelContext.save()
            fetchPets()
            syncAllToWatch()
        } catch {
            print("DashboardViewModel: Failed to save Watch log: \(error)")
        }
    }

    /// Pushes the full phone state (pets + preferences) to the Watch.
    /// Call on launch and after any state mutation.
    public func syncAllToWatch() {
        guard let allPets = try? repository.fetchPets(),
              let allPrefs = try? repository.fetchAllPreferences() else { return }
        WatchConnectivityManager.shared.syncFullStateToWatch(pets: allPets, preferences: allPrefs)
    }
}
