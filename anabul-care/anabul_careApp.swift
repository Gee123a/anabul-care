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
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
                    ContextualDashboardView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    LaunchScreenView()
                        .task {
                            // Wait for the background seeding to complete
                            await DataManager.shared.seedData(modelContainer: sharedModelContainer)
                            
                            // Once finished, flip the switch on the main thread
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isDatabaseReady = true
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
                .scaleEffect(1.2)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .ignoresSafeArea()
    }
}
