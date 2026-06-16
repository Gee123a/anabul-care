//
//  WatchConnectivityManager.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//

import Foundation
import WatchConnectivity
import SwiftUI
import Combine
import SwiftData

/// Manages data synchronization between iOS and watchOS using WCSession.
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable = false
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // MARK: - Full State Sync (Phone -> Watch)
    
    /// Bundles all relevant pet data and sends it to the watch to ensure a perfect mirror.
    /// This method is called whenever the phone's state changes.
    func syncFullStateToWatch(pets: [PetProfile], preferences: [TaskPreference], deactivations: [TaskDeactivation]) {
        guard WCSession.default.activationState == .activated else { return }
        
        let petsData = pets.map { pet in
            return [
                "id": pet.id.uuidString,
                "name": pet.name,
                "species": pet.species,
                "breed": pet.breed,
                "weight": pet.weightKg,
                "isNeutered": pet.isNeutered,
                "activities": pet.activities.map { [
                    "id": $0.id.uuidString,
                    "type": $0.type,
                    "timestamp": $0.timestamp.timeIntervalSince1970,
                    "detail": $0.detail
                ]}
            ]
        }
        
        let prefsData = preferences.map { [
            "petID": $0.petID.uuidString,
            "taskType": $0.taskType,
            "preferredTime": $0.preferredTime,
            "isManualOverride": $0.isManualOverride
        ]}
        
        let deactsData = deactivations.map { [
            "petID": $0.petID.uuidString,
            "taskType": $0.taskType,
            "date": $0.date?.timeIntervalSince1970 ?? 0.0
        ]}
        
        let payload: [String: Any] = [
            "action": "full_state_sync",
            "pets": petsData,
            "preferences": prefsData,
            "deactivations": deactsData,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try WCSession.default.updateApplicationContext(payload)
            print("🚨 MANAGER: FULL STATE SYNC QUEUED FROM IPHONE")
        } catch {
            print("🚨 MANAGER: Full state sync failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Pet Switch Signal (Phone -> Watch)
    
    /// Sends a lightweight signal to the Watch indicating which pet is currently selected.
    /// Called when the user switches pets from the Dashboard pet-switcher menu.
    func sendPetToWatch(petName: String, species: String, breed: String) {
        guard WCSession.default.activationState == .activated else {
            print("🚨 MANAGER: Cannot send pet switch — session not activated.")
            return
        }
        let payload: [String: Any] = [
            "action": "pet_switch",
            "petName": petName,
            "species": species,
            "breed": breed
        ]
        do {
            try WCSession.default.updateApplicationContext(payload)
            print("🚨 MANAGER: Pet switch queued to Watch → \(petName)")
        } catch {
            print("🚨 MANAGER: Pet switch failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Activity Logging (Watch -> Phone)
    
    /// Requests a full state sync from the iPhone upon Watch startup.
    func requestFullSyncFromPhone() {
        let payload: [String: Any] = [
            "action": "request_full_sync",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("🚨 MANAGER: Failed to send full sync request: \(error.localizedDescription)")
            }
        } else {
            WCSession.default.transferUserInfo(payload)
            print("🚨 MANAGER: Queued full sync request")
        }
    }
    
    /// Sends a request from the Watch to the Phone to log a specific activity.
    func sendActivityLogToPhone(activityType: String, petName: String) {
        let payload: [String: Any] = [
            "action": "log_activity",
            "activityType": activityType,
            "petName": petName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("🚨 MANAGER: Failed to send instant log message: \(error.localizedDescription)")
            }
        } else {
            WCSession.default.transferUserInfo(payload)
            print("🚨 MANAGER: Queued activity log for phone sync")
        }
    }
    
    // MARK: - Receiving Data
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("🚨 MANAGER: RECEIVED INSTANT MESSAGE: \(message["action"] ?? "unknown")")
        DispatchQueue.main.async { self.handleIncomingPayload(message) }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("🚨 MANAGER: RECEIVED USER INFO: \(userInfo["action"] ?? "unknown")")
        DispatchQueue.main.async { self.handleIncomingPayload(userInfo) }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("🚨 MANAGER: RECEIVED BACKGROUND CONTEXT: \(applicationContext["action"] ?? "unknown")")
        DispatchQueue.main.async { self.handleIncomingPayload(applicationContext) }
    }
    
    #if os(iOS)
    var modelContainer: ModelContainer?
    #endif
    
    private func handleIncomingPayload(_ payload: [String: Any]) {
        #if os(iOS)
        if let action = payload["action"] as? String {
            if action == "request_full_sync" {
                DispatchQueue.main.async {
                    self.handleRequestFullSyncBackground()
                }
            } else if action == "log_activity" {
                let petName = payload["petName"] as? String ?? ""
                let activityType = payload["activityType"] as? String ?? ""
                DispatchQueue.main.async {
                    self.logActivityBackground(petName: petName, activityType: activityType)
                }
            }
        }
        #endif
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ReceivedWatchData"),
            object: nil,
            userInfo: payload
        )
    }
    
    #if os(iOS)
    @MainActor
    private func handleRequestFullSyncBackground() {
        guard let container = modelContainer else {
            print("🚨 MANAGER: ModelContainer is nil in WatchConnectivityManager")
            return
        }
        let context = ModelContext(container)
        let petsDescriptor = FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)])
        let allPets = (try? context.fetch(petsDescriptor)) ?? []
        
        let prefsDescriptor = FetchDescriptor<TaskPreference>()
        let allPrefs = (try? context.fetch(prefsDescriptor)) ?? []
        
        let deactsDescriptor = FetchDescriptor<TaskDeactivation>()
        let allDeacts = (try? context.fetch(deactsDescriptor)) ?? []
        
        print("🚨 MANAGER: Syncing all pets (\(allPets.count)) to watch in background")
        syncFullStateToWatch(pets: allPets, preferences: allPrefs, deactivations: allDeacts)
    }
    
    @MainActor
    private func logActivityBackground(petName: String, activityType: String) {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)
        
        let petsDescriptor = FetchDescriptor<PetProfile>()
        let allPets = (try? context.fetch(petsDescriptor)) ?? []
        
        guard let targetPet = allPets.first(where: {
            $0.name.lowercased() == petName.lowercased()
        }) else {
            print("🚨 MANAGER: No pet found named '\(petName)' in background")
            return
        }
        
        let newLog = ActivityLog(
            timestamp: Date(),
            type: activityType,
            durationMinutes: 15,
            detail: "Logged via Watch"
        )
        newLog.pet = targetPet
        context.insert(newLog)
        targetPet.activities.append(newLog)
        
        // Smart habit learning
        let now = Date()
        let petID = targetPet.id
        
        let prefsDescriptor = FetchDescriptor<TaskPreference>(
            predicate: #Predicate<TaskPreference> { $0.petID == petID }
        )
        let prefs = (try? context.fetch(prefsDescriptor)) ?? []
        
        let deactsDescriptor = FetchDescriptor<TaskDeactivation>(
            predicate: #Predicate<TaskDeactivation> { $0.petID == petID }
        )
        let deacts = (try? context.fetch(deactsDescriptor)) ?? []
        
        let todayTasks = DailyRoutineGenerator.generate(for: targetPet, preferences: prefs, deactivations: deacts)
        let matchingTasks = todayTasks.filter { $0.type.rawValue == activityType }
        
        var closestTask: DailyTaskItem? = nil
        var smallestDiff = Int.max
        
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let curHour = currentComponents.hour ?? 0
        let curMin = currentComponents.minute ?? 0
        let curTotalMinutes = curHour * 60 + curMin
        
        for task in matchingTasks {
            if let recDate = f.date(from: task.timeRecommendation) {
                let recComponents = calendar.dateComponents([.hour, .minute], from: recDate)
                let recHour = recComponents.hour ?? 0
                let recMin = recComponents.minute ?? 0
                let recTotalMinutes = recHour * 60 + recMin
                
                let diff = abs(curTotalMinutes - recTotalMinutes)
                let absoluteDiff = min(diff, 1440 - diff)
                
                if absoluteDiff < smallestDiff {
                    smallestDiff = absoluteDiff
                    closestTask = task
                }
            }
        }
        
        if let task = closestTask, smallestDiff <= 120 {
            let specificKey = "\(activityType)_\(task.timeRecommendation)"
            if let existing = prefs.first(where: { $0.taskType == specificKey }) {
                existing.preferredTime = f.string(from: now)
                existing.isManualOverride = true
            } else {
                let newPref = TaskPreference(
                    petID: petID,
                    taskType: specificKey,
                    preferredTime: f.string(from: now),
                    isManualOverride: true
                )
                context.insert(newPref)
            }
        }
        
        do {
            try context.save()
            print("🚨 MANAGER: Saved logged activity in background, resyncing")
            let updatedPets = (try? context.fetch(FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)]))) ?? []
            let updatedPrefs = (try? context.fetch(FetchDescriptor<TaskPreference>())) ?? []
            let updatedDeacts = (try? context.fetch(FetchDescriptor<TaskDeactivation>())) ?? []
            syncFullStateToWatch(pets: updatedPets, preferences: updatedPrefs, deactivations: updatedDeacts)
        } catch {
            print("🚨 MANAGER: Failed to save background logged activity: \(error)")
        }
    }
    #endif
    
    // MARK: - WCSessionDelegate Required Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
