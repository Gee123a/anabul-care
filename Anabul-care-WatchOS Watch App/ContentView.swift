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

    /// Lazily initialised once modelContext is available from the environment.
    @State private var syncViewModel: WatchSyncViewModel?

    var body: some View {
        Group {
            if pets.isEmpty {
                emptyState
            } else {
                TabView {
                    WatchDashboardView(pet: pets.first!)
                    WatchLogActivityView(pet: pets.first!)
                }
                .tabViewStyle(.verticalPage)
            }
        }
        .onAppear {
            // Initialise sync ViewModel as soon as the environment context is ready
            if syncViewModel == nil {
                syncViewModel = WatchSyncViewModel(modelContext: modelContext)
            }
        }
        // The View owns the subscription lifecycle; the ViewModel owns the logic
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReceivedWatchData"))) { notification in
            guard let payload = notification.userInfo as? [String: Any] else { return }
            syncViewModel?.handlePayload(payload)
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            PetProfile.self, ActivityLog.self, SpeciesRuleModel.self,
            ToxicityModel.self, TidbitModel.self,
            TaskPreference.self, TaskDeactivation.self
        ], inMemory: true)
}
