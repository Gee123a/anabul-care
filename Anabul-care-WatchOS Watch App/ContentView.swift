//
//  ContentView.swift
//  Anabul-care-WatchOS Watch App
//
//  Created by Stevanus Ivan Santoso on 03/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    
    var body: some View {
        
        Group {
            if pets.isEmpty {
                // Fallback if the user hasn't synced or added a pet on their iPhone
                VStack {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .padding(.bottom, 4)
                    Text("No Pets Found")
                        .font(.headline)
                    Text("Open the iPhone app to add your first pet.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                // WatchOS Native Vertical Paging
                TabView {
                    WatchDashboardView(pet: pets.first!)
                    WatchLogActivityView(pet: pets.first!)
                }
                .tabViewStyle(.verticalPage)
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReceivedWatchData"))) { notification in
            print("🚨 CONTENT VIEW HEARD THE NOTIFICATION!")
            
            if let payload = notification.userInfo {
                print("🚨 PAYLOAD EXTRACTED: \(payload)")
                
                // ⭐️ Extract the action string first
                if let action = payload["action"] as? String {
                    
                    // --- SCENARIO 1: SYNCING A PET ---
                    if action == "sync_pet" {
                        let name = payload["name"] as? String ?? "Unknown"
                        let species = payload["species"] as? String ?? "Dog"
                        let breed = payload["breed"] as? String ?? "Unknown"
                        let weight = payload["weight"] as? Double ?? 0.0
                        
                        let newWatchPet = PetProfile(name: name, species: species, breed: breed, dateOfBirth: Date(), weightKg: weight)
                        modelContext.insert(newWatchPet)
                        
                        do {
                            try modelContext.save()
                            print("🚨 SUCCESS! PET SAVED TO WATCH DATABASE!")
                        } catch {
                            print("🚨 FATAL ERROR SAVING PET ON WATCH: \(error)")
                        }
                    }
                    
                    // --- SCENARIO 2: SYNCING A COMPLETED TASK ---
                    else if action == "sync_activity" {
                        let petName = payload["petName"] as? String ?? ""
                        let activityType = payload["activityType"] as? String ?? ""
                        
                        // Find the pet on the watch to attach this log to
                        if let targetPet = pets.first(where: { $0.name == petName }) ?? pets.first {
                            
                            // Initialize matching your ActivityLog schema
                            let newLog = ActivityLog(
                                timestamp: Date(),
                                type: activityType,
                                durationMinutes: 15,
                                detail: "Synced from iPhone"
                            )
                            
                            newLog.pet = targetPet
                            modelContext.insert(newLog)
                            targetPet.activities.append(newLog) // Manually append to trigger UI refresh
                            
                            do {
                                try modelContext.save()
                                print("🚨 SUCCESS! ACTIVITY LOGGED ON WATCH: \(activityType)")
                            } catch {
                                print("🚨 FATAL ERROR SAVING ACTIVITY ON WATCH: \(error)")
                            }
                        } else {
                            print("🚨 FAILED TO LOG ACTIVITY: Could not find pet matching \(petName) on Watch.")
                        }
                    }
                    // --- SCENARIO 3: DELETING A TASK (UN-CHECKING) ---
                                        else if action == "delete_activity" {
                                            let petName = payload["petName"] as? String ?? ""
                                            let activityType = payload["activityType"] as? String ?? ""
                                            
                                            // 1. Find the target pet
                                            if let targetPet = pets.first(where: { $0.name == petName }) {
                                                
                                                // 2. Find the specific log for today that matches this activity type
                                                if let logToDelete = targetPet.activities.first(where: {
                                                    $0.type == activityType && Calendar.current.isDateInToday($0.timestamp)
                                                }) {
                                                    
                                                    // 3. Nuke it from the Watch database
                                                    modelContext.delete(logToDelete)
                                                    targetPet.activities.removeAll(where: { $0.id == logToDelete.id })
                                                    
                                                    do {
                                                        try modelContext.save()
                                                        print("🚨 SUCCESS! ACTIVITY DELETED ON WATCH: \(activityType)")
                                                    } catch {
                                                        print("🚨 FATAL ERROR DELETING ACTIVITY: \(error)")
                                                    }
                                                }
                                            }
                                        }
                    
                } else {
                    print("🚨 NO VALID ACTION FOUND IN PAYLOAD")
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self], inMemory: true)
}
