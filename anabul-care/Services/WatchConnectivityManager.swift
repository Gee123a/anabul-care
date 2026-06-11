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
    func syncFullStateToWatch(pets: [PetProfile], preferences: [TaskPreference]) {
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
                    "detail": $0.detail ?? ""
                ]}
            ]
        }
        
        let prefsData = preferences.map { [
            "petID": $0.petID.uuidString,
            "taskType": $0.taskType,
            "preferredTime": $0.preferredTime,
            "isManualOverride": $0.isManualOverride
        ]}
        
        let payload: [String: Any] = [
            "action": "full_state_sync",
            "pets": petsData,
            "preferences": prefsData,
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
    
    private func handleIncomingPayload(_ payload: [String: Any]) {
        NotificationCenter.default.post(
            name: NSNotification.Name("ReceivedWatchData"),
            object: nil,
            userInfo: payload
        )
    }
    
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
