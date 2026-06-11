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
                // WatchOS Native Horizontal Paging
                TabView {
                    WatchDashboardView(pet: pets.first!)
                    WatchLogActivityView(pet: pets.first!)
                }
                .tabViewStyle(.page)
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReceivedWatchData"))) { notification in
            print("🚨 CONTENT VIEW HEARD THE NOTIFICATION!")
            
            if let payload = notification.userInfo {
                print("🚨 PAYLOAD EXTRACTED: \(payload)")
                
                if let action = payload["action"] as? String, action == "sync_pet" {
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
                } else {
                    print("🚨 ACTION WAS NOT SYNC_PET")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self], inMemory: true)    
            
    }
        
                
