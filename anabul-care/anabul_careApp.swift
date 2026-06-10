//
//  anabul_careApp.swift
//  anabul-care
//
//  Created by Stevanus Ivan Santoso on 21/05/26.
//

import SwiftUI
import SwiftData

@main
struct anabul_careApp: App {
    @State private var isDatabaseReady = false
    
    // MARK: - WatchOS Connectivity
    // Initialize it immediately so it listens for the Apple Watch the second the app opens
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    init() {
        // Register the background task immediately on launch
        ClimateManager.shared.registerBackgroundTask(modelContainer: sharedModelContainer)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
            TaskPreference.self,
            TaskDeactivation.self,
        ])
        // Uses the App Group so the Widget and WatchOS can access this same database
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare")!
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isDatabaseReady {
                    ContextualDashboardView(modelContext: sharedModelContainer.mainContext)
                } else {
                    LaunchScreenView()
                        .onAppear {
                            // 1. Let the splash screen render immediately
                            // 2. Perform the heavy SwiftData seeding in the background
                            Task(priority: .userInitiated) {
                                await DataManager.shared.seedData(modelContainer: sharedModelContainer)
                                
                                // 3. Ensure a minimum splash screen duration so it doesn't flicker
                                try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds
                                
                                // 4. Dismiss Launch Screen smoothly
                                await MainActor.run {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isDatabaseReady = true
                                    }
                                }
                            }
                        }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

// Simple but elegant Launch Screen to mask the SwiftData initialization
struct LaunchScreenView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 255/255, green: 107/255, blue: 51/255).opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 52))
                    .foregroundColor(Color(red: 255/255, green: 107/255, blue: 51/255))
            }
            VStack(spacing: 8) {
                Text("ANABUL CARE")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .tracking(2.0)
                Text("Preparing your workspace...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            ProgressView()
                .tint(Color(red: 255/255, green: 107/255, blue: 51/255))
                .padding(.top, 12)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
    }
}
