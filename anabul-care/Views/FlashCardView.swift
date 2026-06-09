//
//  FlashCardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 09/06/26.
//


import SwiftUI

struct FlashCardView: View {
    let pet: PetProfile
    
    @State private var currentFact: String? = nil
    @State private var isLoading = true
    
    // UI Colors matching your original design
    private let textDarkBrown = Color(red: 84/255, green: 58/255, blue: 44/255)
    private let textLightBrown = Color(red: 140/255, green: 110/255, blue: 90/255)
    private let tangerine = Color(red: 220/255, green: 100/255, blue: 50/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(tangerine)
                        .frame(width: 24, height: 24)
                        .background(tangerine.opacity(0.15))
                        .clipShape(Circle())
                    
                    Text("FUN FACT")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(tangerine)
                }
                
                Spacer()
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 12))
                    .foregroundColor(tangerine)
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(tangerine)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Did you know this about \(pet.name)?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(textDarkBrown)
                    
                    // The hardcoded text is completely removed. It will only show an error if JSON fails completely.
                    Text(currentFact ?? "Gagal memuat data dari database.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(textLightBrown)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(minHeight: 60, alignment: .topLeading)
            
            // MARK: - Footer
            HStack {
                Text("DID YOU KNOW?")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.0)
                    .foregroundColor(textLightBrown.opacity(0.7))
                
                Spacer()
                
                // Pagination Dots
                HStack(spacing: 4) {
                    Capsule()
                        .fill(tangerine)
                        .frame(width: 12, height: 4)
                    Circle()
                        .fill(tangerine.opacity(0.3))
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(tangerine.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 242/255, blue: 230/255),
                    Color(red: 248/255, green: 255/255, blue: 235/255),
                    Color(red: 255/255, green: 238/255, blue: 232/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: tangerine.opacity(0.12), radius: 15, x: 0, y: 8)
        .task(id: pet.id) {
            await fetchFact()
        }
    }
    
    private func fetchFact() async {
        isLoading = true
        
        let allFacts = await DataManager.shared.loadFunFacts()
        let speciesFacts = allFacts[pet.species.lowercased()] ?? []
        
        // 1. Find ALL facts that match the pet's specific breed
        let matchingBreedFacts = speciesFacts.filter { $0.breed.lowercased() == pet.breed.lowercased() }
        
        // 2. Try to pick a random fact from their specific breed
        if let randomFact = matchingBreedFacts.randomElement() {
            withAnimation { self.currentFact = randomFact.fact }
        }
        // 3. NEW: If breed isn't found, read the generic fallback message from the JSON file!
        else if let generalFact = speciesFacts.first(where: { $0.breed.lowercased() == "general" }) {
            withAnimation { self.currentFact = generalFact.fact }
        }
        // 4. Absolute last resort if JSON is empty/broken
        else {
            self.currentFact = nil
        }
        
        isLoading = false
    }
}
