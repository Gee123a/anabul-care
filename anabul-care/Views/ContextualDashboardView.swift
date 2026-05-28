//
//  ContextualDashboardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//

import SwiftUI
import SwiftData
import Combine

struct ContextualDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Dynamic Query to pull live pet profiles and logs
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    @Query(sort: \ActivityLog.timestamp, order: .reverse) private var activities: [ActivityLog]
    
    // UI Aesthetic Configurations
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255) // #FF6B33
    private let dashWidth: CGFloat = 381 // Exact width from spec to preserve the 12px Map Peek
    
    @State private var showingAddPet = false
    @State private var showingSafetyLookup = false
    
    var body: some View {
        let currentPet = pets.first // Defaulting framework to active pet context
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // TOP BAR (Date & Action triggers)
                HStack {
                    Text("THU · MAY 28")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(1.2)
                    
                    Spacer()
                    
                    // Add Pet Action Modal Trigger
                    Button(action: { showingAddPet.toggle() }) {
                        Image(systemName: "plus")
                            .font(.system(.body, design: .rounded).bold())
                            .foregroundColor(.white)
                            .frame(width: 46, height: 46)
                            .background(tangerine)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PressedScaleButtonStyle())
                }
                .padding(.top, 16)
                
                // DYNAMIC GREETING WITH NATIVE HIG-COMPLIANT WEIGHTS
                VStack(alignment: .leading, spacing: 2) {
                    Text("Good morning,")
                        .font(.system(size: 34, weight: .black, design: .rounded)) // Fixed to structural token
                        .foregroundColor(.primary)
                    Text(currentPet?.name ?? "Anabul")
                        .font(.system(size: 34, weight: .black, design: .rounded)) // Fixed to structural token
                        .foregroundColor(tangerine)
                }
                
                // SAFETY SEARCH CAPSULE (Opens native lookups)
                Button(action: { showingSafetyLookup.toggle() }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Is it safe to feed \(currentPet?.name ?? "Anabul")...")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "shield.alert.fill")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 46)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
                }
                .buttonStyle(PressedScaleButtonStyle())
                
                // TODAY'S QUEUE BENTO (Injecting selected pet profile reference)
                if let pet = currentPet {
                    TodayQueueCardView(pet: pet)
                } else {
                    ContentUnavailableView("No Pet Found", systemImage: "pawprint.circle", description: Text("Tap the + button to build your first pet profile."))
                        .frame(height: 340)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                }
                
                // CONTEXTUAL INSIGHTS PANEL (Bakes local SwiftData entries)
                InlineInsightPanelView(targetSpecies: currentPet?.species ?? "cat")
            }
            .padding(.horizontal, 16)
            .frame(width: dashWidth)
        }
        .background(
            ZStack {
                Circle()
                    .fill(tangerine.opacity(0.12))
                    .frame(width: 260, height: 260)
                    .blur(radius: 40)
                    .offset(x: -120, y: -200)
                
                Circle()
                    .fill(Color.blue.opacity(0.10))
                    .frame(width: 280, height: 280)
                    .blur(radius: 45)
                    .offset(x: 140, y: 100)
            },
            alignment: .top
        )
        .sheet(isPresented: $showingAddPet) {
            AddPetView()
        }
        .sheet(isPresented: $showingSafetyLookup) {
            ToxicityLookupView()
        }
    }
}

struct PressedScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
