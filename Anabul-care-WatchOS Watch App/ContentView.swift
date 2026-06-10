//
//  ContentView.swift
//  Anabul-care-WatchOS Watch App
//
//  Created by Stevanus Ivan Santoso on 03/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    
    var body: some View {
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
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self], inMemory: true)
}
