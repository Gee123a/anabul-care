import SwiftUI
import SwiftData

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var species: PetSpecies = .dog
    @State private var breed: String = ""
    @State private var customBreed: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var weightString: String = ""
    @State private var isNeutered: Bool = false
    
    @State private var breedsRegistry: [String: [String]] = [:]
    @State private var isSaved = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, breed, weight, customBreed
    }
    
    // Design Tokens
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let bgApp = Color(red: 0.98, green: 0.98, blue: 0.97)
    
    private var parsedWeight: Double {
        Double(weightString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    private var currentBreeds: [String] {
        breedsRegistry[species.rawValue] ?? []
    }
    
    private var isFormValid: Bool {
        let breedValid = breed == "Other (Type manually)" ? !customBreed.isEmpty : !breed.isEmpty
        return !name.isEmpty && parsedWeight > 0 && breedValid
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
                                
                                Text("Let's build a health profile")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 2. PRIMARY INFO CARD
                        VStack(spacing: 20) {
                            PremiumTextField(
                                title: "Nama",
                                placeholder: "Siapa namanya?",
                                text: $name,
                                icon: "tag.fill",
                                isFocused: focusedField == .name,
                                accentColor: tangerine
                            )
                            .focused($focusedField, equals: .name)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SPESIES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                                
                                Picker("Spesies", selection: $species) {
                                    ForEach(PetSpecies.allCases, id: \.self) { species in
                                        Label(species.rawValue.capitalized, systemImage: iconForSpecies(species)).tag(species)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .scaleEffect(1.02)
                                .onChange(of: species) {
                                    // Reset breed selection when species changes
                                    breed = currentBreeds.first ?? ""
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("RAS / BREED")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(focusedField == .breed ? tangerine : .secondary)
                                    .padding(.leading, 4)
                                
                                Menu {
                                    Picker("Breed", selection: $breed) {
                                        ForEach(currentBreeds, id: \.self) { b in
                                            Text(b).tag(b)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "pawprint.circle.fill")
                                            .foregroundColor(breed.isEmpty ? .secondary.opacity(0.8) : tangerine)
                                            .frame(width: 20)
                                        
                                        Text(breed.isEmpty ? "Pilih ras..." : breed)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(breed.isEmpty ? .secondary : .primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 54)
                                    .background(Color.gray.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                            }
                            
                            if breed == "Other (Type manually)" {
                                PremiumTextField(
                                    title: "Custom Breed",
                                    placeholder: "Type breed manually...",
                                    text: $customBreed,
                                    icon: "pencil.line",
                                    isFocused: focusedField == .customBreed,
                                    accentColor: tangerine
                                )
                                .focused($focusedField, equals: .customBreed)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                        
                        // 3. PHYSICAL DETAILS CARD
                        VStack(spacing: 20) {
                            DatePicker("Tanggal Lahir", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tint(tangerine)
                            
                            Divider()
                            
                            HStack {
                                Label("Berat", systemImage: "scalemass.fill")
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
                                    Text("Sudah Steril")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text("Penting untuk perhitungan MER")
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
                                Text("Simpan Profil")
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
            .navigationTitle("Tambah Anabul")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sensoryFeedback(.success, trigger: isSaved)
        .onAppear(perform: loadBreeds)
    }
    
    private var speciesIcon: String {
        switch species {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .hamster: return "hare.fill"
        }
    }
    
    private func iconForSpecies(_ s: PetSpecies) -> String {
        switch s {
        case .dog: return "dog"
        case .cat: return "cat"
        case .hamster: return "hare"
        }
    }
    
    private func loadBreeds() {
        guard let url = Bundle.main.url(forResource: "BreedRegistry", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let registry = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return
        }
        self.breedsRegistry = registry
        // Default selection
        if breed.isEmpty {
            breed = registry[species.rawValue]?.first ?? ""
        }
    }
    
    private func savePet() {
        let finalBreed = (breed == "Other (Type manually)") ? customBreed : breed
        
        let newPet = PetProfile(
            name: name,
            species: species.rawValue,
            breed: finalBreed,
            dateOfBirth: dateOfBirth,
            weightKg: parsedWeight,
            isNeutered: isNeutered
        )
        modelContext.insert(newPet)
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
