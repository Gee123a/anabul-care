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
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: PetProfileViewModel
    
    init(pet: PetProfile, modelContext: ModelContext) {
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: PetProfileViewModel(pet: pet, repository: repository))
    }
    
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
                            Text(viewModel.pet.name)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(primaryDark)
                                .tracking(-0.6)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(tangerine)
                                Text("\(viewModel.pet.species.capitalized)")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(secondaryDark)
                            }
                        }
                    }
                    .padding(.top, 32)
                    
                    // 2. STATS ROW (Bento Cards)
                    HStack(spacing: 12) {
                        StatCard(icon: "birthday.cake.fill", label: "AGE", value: viewModel.formattedAge)
                        StatCard(icon: "scalemass.fill", label: "WEIGHT", value: viewModel.formattedWeight)
                        StatCard(icon: "syringe.fill", label: "VACCINES", value: "Up to Date")
                    }
                    .padding(.horizontal, 20)
                    
                    // 3. HEALTH OVERVIEW SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HEALTH OVERVIEW")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(secondaryDark)
                            .tracking(1.0)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 10) {
                            HealthRowItem(icon: "heart.fill", title: "Wellness Check", subtitle: "Due in 2 months", iconColor: tangerine)
                            HealthRowItem(icon: "syringe.fill", title: "Rabies Booster", subtitle: "Completed May 2025", iconColor: .blue)
                            HealthRowItem(icon: "birthday.cake.fill", title: "Birthday", subtitle: "March 3rd", iconColor: .purple)
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
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 15, weight: .bold))
//                            .foregroundColor(primaryDark)
//                            .frame(width: 36, height: 36)
//                            .background(.ultraThinMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//                    }
//                }
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
                "Delete \(viewModel.pet.name)?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deletePet()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone and will permanently delete all of \(viewModel.pet.name)'s activity logs and data.")
            }
            
            .sheet(isPresented: $showingEditPet) {
                AddPetView(petToEdit: viewModel.pet, modelContext: modelContext)
            }
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

struct HealthRowItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(iconColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 26/255))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.secondary.opacity(0.5))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
        )
    }
}

