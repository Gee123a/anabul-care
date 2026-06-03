//
//  ContentView.swift
//  anabul-care
//
//  Created by Stevanus Ivan Santoso on 21/05/26.
//

import SwiftUI
import SwiftData
import CoreSpotlight

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showToxicityLookup = false
    
    // To pass the Spotlight text down to your Toxicity Lookup
    @State private var spotlightSearchQuery: String = ""

    var body: some View {
        // Horizontal Swipe Layout for Dashboard <-> Map
        TabView(selection: $selectedTab) {
            ContextualDashboardView()
                .tag(0)
            
            PuskeswanRadarView()
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Hides dots, allows seamless swiping
        .ignoresSafeArea(.keyboard, edges: .bottom)
        
        // Modal that pops up when a user taps a Spotlight Search Result
        .sheet(isPresented: $showToxicityLookup) {
            ToxicityLookupView(initialQuery: spotlightSearchQuery)
        }
        
        // ---------------------------------------------------------
        // THE MAGIC: Catches the tap from iOS Home Screen Spotlight
        // ---------------------------------------------------------
        .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                
                // If they tapped one of our food items...
                if uniqueIdentifier.hasPrefix("toxicity_") {
                    // Extract the food keyword from the ID
                    let keyword = uniqueIdentifier.replacingOccurrences(of: "toxicity_", with: "")
                    
                    // Route the app automatically
                    self.selectedTab = 0 // Snap back to dashboard if they were on the Map
                    self.spotlightSearchQuery = keyword
                    self.showToxicityLookup = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
