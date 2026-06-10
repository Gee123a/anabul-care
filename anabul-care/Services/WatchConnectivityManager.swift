//
//  WatchConnectivityManager.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//

import Foundation
import WatchConnectivity
import SwiftUI
import Combine // Required for ObservableObject and @Published

// 1. Conform to NSObject, ObservableObject, and WCSessionDelegate
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
    
    // MARK: - Sending Data (Watch -> Phone)
    func sendActivityLogToPhone(activityType: String, petName: String) {
        let payload: [String: Any] = [
            "action": "log_activity",
            "activityType": activityType,
            "petName": petName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if WCSession.default.isReachable {
            // Send immediately if the phone is awake and connected
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("Failed to send message: \(error.localizedDescription)")
            }
        } else {
            // Queue it up in the background if the phone is asleep/disconnected
            WCSession.default.transferUserInfo(payload)
        }
    }
    
    // MARK: - Sending Data (Phone -> Watch)
        func sendPetToWatch(petName: String, species: String, breed: String) {
            guard WCSession.default.activationState == .activated else {
                print("🚨 WCSession not activated yet!")
                return
            }
            
            let payload: [String: Any] = [
                "action": "sync_pet",
                "name": petName,
                "species": species,
                "breed": breed,
                "timestamp": Date().timeIntervalSince1970 // ⭐️ THIS FORCES EVERY SEND TO BE UNIQUE
            ]
            
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                    print("🚨 Instant message failed: \(error.localizedDescription)")
                }
                print("🚨 INSTANT MESSAGE SENT FROM IPHONE!")
            }
            
            do {
                try WCSession.default.updateApplicationContext(payload)
                print("🚨 BACKGROUND CONTEXT QUEUED FROM IPHONE!")
            } catch {
                print("🚨 Context failed: \(error.localizedDescription)")
            }
        }
    // MARK: - Sending Tasks (Phone -> Watch)
        func sendActivityToWatch(petName: String, activityType: String) {
            guard WCSession.default.activationState == .activated else { return }
            
            let payload: [String: Any] = [
                "action": "sync_activity",
                "petName": petName,
                "activityType": activityType,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                    print("🚨 Failed to send activity: \(error.localizedDescription)")
                }
                print("🚨 INSTANT ACTIVITY SENT TO WATCH: \(activityType)")
            } else {
                // If watch is asleep, queue it in the background
                WCSession.default.transferUserInfo(payload)
                print("🚨 QUEUED ACTIVITY FOR WATCH: \(activityType)")
            }
        }
        
        // MARK: - Receiving Data (Watch catching the data)
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            print("🚨 WATCH CAUGHT INSTANT MESSAGE: \(message)")
            DispatchQueue.main.async { self.handleIncomingPayload(message) }
        }
        
        func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
            print("🚨 WATCH CAUGHT USER INFO: \(userInfo)")
            DispatchQueue.main.async { self.handleIncomingPayload(userInfo) }
        }
        
        func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
            print("🚨 WATCH CAUGHT BACKGROUND CONTEXT: \(applicationContext)")
            DispatchQueue.main.async { self.handleIncomingPayload(applicationContext) }
        }
        
        private func handleIncomingPayload(_ payload: [String: Any]) {
            print("🚨 MANAGER BROADCASTING TO VIEWS...")
            NotificationCenter.default.post(
                name: NSNotification.Name("ReceivedWatchData"),
                object: nil,
                userInfo: payload
            )
        }
    
    // MARK: - Deleting Tasks (Bidirectional)
        func sendActivityDeletion(petName: String, activityType: String) {
            guard WCSession.default.activationState == .activated else { return }
            
            let payload: [String: Any] = [
                "action": "delete_activity", // The critical new action string
                "petName": petName,
                "activityType": activityType,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                    print("🚨 Failed to send deletion: \(error.localizedDescription)")
                }
                print("🚨 INSTANT DELETION SENT: \(activityType)")
            } else {
                WCSession.default.transferUserInfo(payload)
                print("🚨 QUEUED DELETION: \(activityType)")
            }
        }
    
    // MARK: - WCSessionDelegate Required Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    // These two methods are strictly required by iOS, but not available on watchOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate if the session drops
        WCSession.default.activate()
    }
    #endif // ⭐️ FIXED: Removed the extra os(iOS) text here so it compiles perfectly
}
