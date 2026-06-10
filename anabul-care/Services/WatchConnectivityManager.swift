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
    
    // MARK: - Receiving Data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleIncomingPayload(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            self.handleIncomingPayload(userInfo)
        }
    }
    
    private func handleIncomingPayload(_ payload: [String: Any]) {
        // Broadcast the data using NotificationCenter so your views/SwiftData can catch it
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
    
    // These two methods are strictly required by iOS, but not available on watchOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate if the session drops
        WCSession.default.activate()
    }
    #endif
}
