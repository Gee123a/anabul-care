//
//  ContextualDashboardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//


import SwiftUI
import SwiftData

struct ContextualDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let textGray = Color(red: 138/255, green: 138/255, blue: 133/255)
    private let primaryDark = Color(red: 28/255, green: 28/255, blue: 26/255)
    private let secondaryDark = Color(red: 92/255, green: 92/255, blue: 88/255)
    
    @State private var showingAddPet = false
    @State private var showingSafetyLookup = false
    
    var body: some View {
        TabView {
            dashboardPage
            
            PuskeswanRadarView()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var dashboardPage: some View {
        let currentPet = pets.first
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentDateString)
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(textGray)
                                .tracking(0.4)
                                .textCase(.uppercase)
                        }
                        
                        Spacer()
                        
                        if let pet = currentPet {
                            NavigationLink(destination: PetProfileView(pet: pet)) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(systemName: "pawprint.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .frame(width: 52, height: 52)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1.5))
                                        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 4)
                                    
                                    Circle()
                                        .fill(Color(red: 155/255, green: 217/255, blue: 180/255))
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                }
                            }
                        } else {
                            Button(action: { showingAddPet = true }) {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 52, height: 52)
                                    .overlay(Image(systemName: "plus").foregroundColor(.gray))
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentPet != nil ? "Good morning," : "Good morning!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(primaryDark)
                            .tracking(-0.5)
                        
                        if let pet = currentPet {
                            Text("\(pet.name) is up.")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(tangerine)
                                .tracking(-0.5)
                                .padding(.top, -14)
                        }
                        
                        Text(dynamicGreetingSubtext(for: currentPet))
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .foregroundColor(secondaryDark)
                            .lineSpacing(4)
                            .tracking(-0.2)
                            .padding(.top, 4)
                    }
                    
                    Button(action: { showingSafetyLookup.toggle() }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            Text("Is it safe to feed \(currentPet?.name ?? "Anabul")...")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Circle())
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 46)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PressedScaleButtonStyle())
                    
                    HStack {
                        Text("TODAY")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryDark)
                            .tracking(0.2)
                        
                        Spacer()
                        
                        Text("\(todayTaskCount(for: currentPet)) tasks")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(textGray)
                    }
                    .padding(.top, 4)
                    
                    if let pet = currentPet {
                        TodayQueueCardView(pet: pet)
                            .padding(.top, -12)
                    } else {
                        EmptyPetStateView(showingAddPet: $showingAddPet)
                    }
                    
                    InlineInsightPanelView(targetSpecies: currentPet?.species ?? "cat")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.97))
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .sheet(isPresented: $showingSafetyLookup) {
                ToxicityLookupView()
            }
        }
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · MMM d"
        return formatter.string(from: Date())
    }
    
    private func todayTaskCount(for pet: PetProfile?) -> Int {
        guard let pet = pet else { return 0 }
        return DailyRoutineGenerator.generate(for: pet).count
    }
    
    private func dynamicGreetingSubtext(for pet: PetProfile?) -> String {
        guard let pet = pet else { return "Morning sunlight helps regulate sleep cycles for your companions." }
        return "Did you know morning sunlight helps regulate \(pet.name)'s sleep cycle?"
    }
}

struct EmptyPetStateView: View {
    @Binding var showingAddPet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Pet Found")
                .font(.headline)
            Text("Tap the + button to build your first pet profile.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Pet") {
                showingAddPet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 340)
        .background(RoundedRectangle(cornerRadius: 32).fill(Color.white))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct PressedScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
