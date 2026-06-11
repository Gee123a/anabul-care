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
                        .id(pets.first!.persistentModelID)
                    WatchLogActivityView(pet: pets.first!)
                        .id(pets.first!.persistentModelID)
                }
                .tabViewStyle(.page)
            }
        }
        .onAppear {
            WatchConnectivityManager.shared.requestFullSyncFromPhone()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReceivedWatchData"))) { notification in
            print("🚨 CONTENT VIEW HEARD THE NOTIFICATION!")
            
            if let payload = notification.userInfo as? [String: Any] {
                let viewModel = WatchSyncViewModel(modelContext: modelContext)
                viewModel.handlePayload(payload)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self], inMemory: true)
            
    }
