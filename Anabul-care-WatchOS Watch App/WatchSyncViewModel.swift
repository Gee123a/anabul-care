import Foundation
import SwiftData
import SwiftUI

/// Owns all Watch ↔ Phone synchronisation logic on the watchOS side.
/// The View holds no database or payload-parsing knowledge —
/// it passes raw notification payloads here and this ViewModel decides what to do.
@Observable
@MainActor
final class WatchSyncViewModel {

    // MARK: - Dependencies
    private let modelContext: ModelContext

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Payload Routing

    /// Entry point called by the View's `.onReceive` block.
    /// Routes the action to the appropriate handler.
    func handlePayload(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }
        switch action {
        case "full_state_sync":
            let petsData = payload["pets"] as? [[String: Any]] ?? []
            let prefsData = payload["preferences"] as? [[String: Any]] ?? []
            rebuildDatabase(petsData: petsData, prefsData: prefsData)
        default:
            print("WatchSyncViewModel: Unhandled action '\(action)'")
        }
    }

    // MARK: - Database Reconstruction

    /// Wipes the Watch's local SwiftData store and rebuilds it
    /// from the iPhone's authoritative state payload.
    private func rebuildDatabase(
        petsData: [[String: Any]],
        prefsData: [[String: Any]]
    ) {
        print("WatchSyncViewModel: Processing full state sync…")

        // 1. Clear stale data safely
        if let oldLogs = try? modelContext.fetch(FetchDescriptor<ActivityLog>()) {
            oldLogs.forEach { modelContext.delete($0) }
        }
        if let oldPets = try? modelContext.fetch(FetchDescriptor<PetProfile>()) {
            oldPets.forEach { modelContext.delete($0) }
        }
        if let oldPrefs = try? modelContext.fetch(FetchDescriptor<TaskPreference>()) {
            oldPrefs.forEach { modelContext.delete($0) }
        }

        // 2. Rebuild Pets and their ActivityLogs
        for petDict in petsData {
            let newPet = buildPetProfile(from: petDict)
            modelContext.insert(newPet)

            let activities = petDict["activities"] as? [[String: Any]] ?? []
            for actDict in activities {
                let log = buildActivityLog(from: actDict)
                log.pet = newPet
                modelContext.insert(log)
                newPet.activities.append(log)
            }
        }

        // 3. Rebuild TaskPreferences
        for prefDict in prefsData {
            let petID = UUID(uuidString: prefDict["petID"] as? String ?? "") ?? UUID()
            let type = prefDict["taskType"] as? String ?? ""
            let time = prefDict["preferredTime"] as? String ?? ""
            let manual = prefDict["isManualOverride"] as? Bool ?? false
            let pref = TaskPreference(
                petID: petID,
                taskType: type,
                preferredTime: time,
                isManualOverride: manual
            )
            modelContext.insert(pref)
        }

        try? modelContext.save()
        print("WatchSyncViewModel: Sync complete — database mirrored.")
    }

    // MARK: - Builder Helpers

    private func buildPetProfile(from dict: [String: Any]) -> PetProfile {
        PetProfile(
            id: UUID(uuidString: dict["id"] as? String ?? "") ?? UUID(),
            name: dict["name"] as? String ?? "Unknown",
            species: dict["species"] as? String ?? "cat",
            breed: dict["breed"] as? String ?? "Mixed",
            dateOfBirth: Date(),
            weightKg: dict["weight"] as? Double ?? 0.0,
            isNeutered: dict["isNeutered"] as? Bool ?? false
        )
    }

    private func buildActivityLog(from dict: [String: Any]) -> ActivityLog {
        ActivityLog(
            id: UUID(uuidString: dict["id"] as? String ?? "") ?? UUID(),
            timestamp: Date(timeIntervalSince1970: dict["timestamp"] as? Double ?? 0.0),
            type: dict["type"] as? String ?? "feeding",
            durationMinutes: 15,
            detail: dict["detail"] as? String ?? ""
        )
    }
}
