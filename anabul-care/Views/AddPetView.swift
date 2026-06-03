import SwiftUI
import SwiftData

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 1. Variable to accept an existing pet if editing
    var petToEdit: PetProfile?
    
    @State private var name: String
    @State private var species: PetSpecies
    @State private var breed: String
    @State private var dateOfBirth: Date
    @State private var weightString: String
    @State private var isNeutered: Bool
    
    @State private var isSaved = false
    @FocusState private var focusedField: Field?
    
    // 2. Custom Initializer to preload existing pet data
    init(petToEdit: PetProfile? = nil) {
        self.petToEdit = petToEdit
        
        // If petToEdit exists, use its data. Otherwise, start blank.
        _name = State(initialValue: petToEdit?.name ?? "")
        _species = State(initialValue: PetSpecies(rawValue: petToEdit?.species ?? PetSpecies.cat.rawValue) ?? .cat)
        _breed = State(initialValue: petToEdit?.breed ?? "")
        _dateOfBirth = State(initialValue: petToEdit?.dateOfBirth ?? Date())
        
        // Convert the existing double back to a string for the text field
        if let existingWeight = petToEdit?.weightKg {
            _weightString = State(initialValue: String(format: "%.1f", existingWeight))
        } else {
            _weightString = State(initialValue: "")
        }
        
        _isNeutered = State(initialValue: petToEdit?.isNeutered ?? false)
    }
    
    enum Field {
        case name, breed, weight
    }
    
    // Design Tokens
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let bgApp = Color(red: 0.98, green: 0.98, blue: 0.97)
    
    private var parsedWeight: Double {
        Double(weightString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && parsedWeight > 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgApp.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // 1. PREMIUM HEADER
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(tangerine.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: speciesIcon)
                                    .font(.system(size: 44))
                                    .foregroundColor(tangerine)
                                    .contentTransition(.symbolEffect(.replace))
                                
                                // Decorative ring
                                Circle()
                                    .stroke(tangerine.opacity(0.2), lineWidth: 1)
                                    .frame(width: 116, height: 112)
                            }
                            .padding(.top, 20)
                            
                            VStack(spacing: 4) {
                                Text(name.isEmpty ? "New Companion" : "Hi, \(name)!")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Health & wellness profile")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 2. PRIMARY INFO CARD
                        VStack(spacing: 20) {
                            PremiumTextField(
                                title: "Name",
                                placeholder: "What's their name?",
                                text: $name,
                                icon: "tag.fill",
                                isFocused: focusedField == .name,
                                accentColor: tangerine
                            )
                            .focused($focusedField, equals: .name)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SPECIES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                                
                                Picker("Species", selection: $species) {
                                    ForEach(PetSpecies.allCases, id: \.self) { species in
                                        Label(species.rawValue.capitalized, systemImage: iconForSpecies(species)).tag(species)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .scaleEffect(1.02)
                            }
                            
                            PremiumTextField(
                                title: "Breed",
                                placeholder: "e.g. Golden Retriever",
                                text: $breed,
                                icon: "pawprint.circle.fill",
                                isFocused: focusedField == .breed,
                                accentColor: tangerine
                            )
                            .focused($focusedField, equals: .breed)
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                        
                        // 3. PHYSICAL DETAILS CARD
                        VStack(spacing: 20) {
                            DatePicker("Date of Birth", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tint(tangerine)
                            
                            Divider()
                            
                            HStack {
                                Label("Weight", systemImage: "scalemass.fill")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(focusedField == .weight ? tangerine : .primary)
                                
                                Spacer()
                                
                                TextField("0.0", text: $weightString)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .focused($focusedField, equals: .weight)
                                
                                Text("kg")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            Toggle(isOn: $isNeutered) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Spayed / Neutered")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text("Important for daily calorie goals")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .tint(tangerine)
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                        
                        // 4. ACTION BUTTON
                        Button(action: savePet) {
                            HStack {
                                Text(petToEdit != nil ? "Update Profile" : "Save Profile")
                                Image(systemName: "checkmark.seal.fill")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isFormValid ? tangerine : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                            .shadow(color: isFormValid ? tangerine.opacity(0.3) : .clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!isFormValid)
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.top, 8)
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(petToEdit != nil ? "Edit Profile" : "Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sensoryFeedback(.success, trigger: isSaved)
    }
    
    private var speciesIcon: String {
        switch species {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .hamster: return "hare.fill" // SF Symbol closest for hamster
        }
    }
    
    private func iconForSpecies(_ s: PetSpecies) -> String {
        switch s {
        case .dog: return "dog"
        case .cat: return "cat"
        case .hamster: return "hare"
        }
    }
    
    // 3. Updated save function to route edits correctly
    private func savePet() {
        if let existingPet = petToEdit {
            // Update mode
            existingPet.name = name
            existingPet.species = species.rawValue
            existingPet.breed = breed
            existingPet.dateOfBirth = dateOfBirth
            existingPet.weightKg = parsedWeight
            existingPet.isNeutered = isNeutered
        } else {
            // Create mode
            let newPet = PetProfile(
                name: name,
                species: species.rawValue,
                breed: breed,
                dateOfBirth: dateOfBirth,
                weightKg: parsedWeight,
                isNeutered: isNeutered
            )
            modelContext.insert(newPet)
        }
        
        isSaved = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - PREMIUM COMPONENTS

struct PremiumTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isFocused: Bool
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(isFocused ? accentColor : .secondary)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? accentColor : .secondary.opacity(0.8))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(isFocused ? accentColor.opacity(0.04) : Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isFocused ? accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .animation(.easeOut(duration: 0.2), value: isFocused)
        }
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    AddPetView()
        .modelContainer(for: PetProfile.self, inMemory: true)
}
