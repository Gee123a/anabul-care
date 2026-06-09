//
//  PetProfileView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//

import SwiftUI
import SwiftData

struct PetProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext // Added to handle database deletion
    
    let pet: PetProfile
    
    // State variables for our new actions
    @State private var showingEditPet = false
    @State private var showingDeleteConfirmation = false
    
    // UI Colors from your Handoff
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255) // #FF6B33
    private let primaryDark = Color(red: 28/255, green: 28/255, blue: 26/255)
    private let secondaryDark = Color(red: 92/255, green: 92/255, blue: 88/255)
    private let backgroundBase = Color(red: 0.98, green: 0.98, blue: 0.97)
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. HERO SECTION
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 124, height: 124)
                                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
                            
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(30)
                                .foregroundColor(tangerine.opacity(0.8))
                                .frame(width: 124, height: 124)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 124, height: 124)
                        }
                        
                        VStack(spacing: 4) {
                            Text(pet.name)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(primaryDark)
                                .tracking(-0.6)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(tangerine)
                                Text("\(pet.species.capitalized)")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(secondaryDark)
                            }
                        }
                    }
                    .padding(.top, 32)
                    
                    // 2. STATS ROW (Bento Cards)
                    HStack(spacing: 12) {
                        StatCard(icon: "birthday.cake.fill", label: "AGE", value: ageString)
                        StatCard(icon: "scalemass.fill", label: "WEIGHT", value: String(format: "%.1f kg", pet.weightKg))
                        StatCard(icon: "syringe.fill", label: "VACCINES", value: "Up to Date")
                    }
                    .padding(.horizontal, 20)
                    
                    // 3. ACTIVITY HISTORY SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("RECENT ACTIVITY")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(secondaryDark)
                                .tracking(1.0)
                            
                            Spacer()
                            
                            if !pet.activities.isEmpty {
                                Text("\(pet.activities.count) total")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 4)
                        
                        if pet.activities.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary.opacity(0.3))
                                Text("No activity logged yet")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        } else {
                            VStack(spacing: 10) {
                                ForEach(pet.activities.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5)) { log in
                                    ActivityRowItem(log: log)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                }
                .padding(.bottom, 40)
            }
            .background(
                ZStack(alignment: .top) {
                    backgroundBase.ignoresSafeArea()
                    
                    // Ambient Tangerine Glow Top-Center
                    Circle()
                        .fill(tangerine.opacity(0.15))
                        .frame(width: 420, height: 420)
                        .blur(radius: 60)
                        .offset(y: -200)
                }
            )
            .navigationTitle("Pet Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(primaryDark)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // NEW: Native SwiftUI Menu Dropdown
                    Menu {
                        Button(action: { showingEditPet = true }) {
                            Label("Edit Pet Profile", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                            Label("Delete Pet Profile", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(primaryDark)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            
            // Delete Confirmation Dialog to prevent accidental data loss
            .confirmationDialog(
                "Delete \(pet.name)?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(pet)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone and will permanently delete all of \(pet.name)'s activity logs and data.")
            }
            
            .sheet(isPresented: $showingEditPet) {
                AddPetView(petToEdit: pet)
            }
        }
    }
    
    private var ageString: String {
        let months = pet.ageInMonths
        if months < 12 {
            return "\(months) Mos"
        } else {
            let years = months / 12
            return "\(years) Yrs"
        }
    }
}

// MARK: - Subcomponents

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 255/255, green: 107/255, blue: 51/255))
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 26/255))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
        )
    }
}

struct ActivityRowItem: View {
    let log: ActivityLog
    
    private var icon: String {
        switch LogType(rawValue: log.type) {
        case .feeding: return "fork.knife"
        case .grooming: return "scissors"
        case .walk: return "figure.walk"
        case .play: return "tennisball"
        case .hydration: return "drop.fill"
        default: return "star.fill"
        }
    }
    
    private var color: Color {
        switch LogType(rawValue: log.type) {
        case .feeding: return .orange
        case .grooming: return .purple
        case .walk: return .green
        case .play: return .blue
        case .hydration: return .cyan
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.type.capitalized)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 26/255))
                
                Text(log.timestamp.formatted(.relative(presentation: .named)))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !log.detail.isEmpty {
                Text(log.detail)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
        )
    }
}

