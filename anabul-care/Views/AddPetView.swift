import SwiftUI
import SwiftData

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: AddPetViewModel
    
    init(petToEdit: PetProfile? = nil, modelContext: ModelContext) {
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: AddPetViewModel(petToEdit: petToEdit, repository: repository))
    }
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, breed, weight, customBreed
    }
    
    // Design Tokens
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let bgApp = Color(red: 0.98, green: 0.98, blue: 0.97)
    
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
                                Text(viewModel.name.isEmpty ? (viewModel.petToEdit == nil ? "New Companion" : "Edit Profile") : "Hi, \(viewModel.name)!")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(viewModel.petToEdit == nil ? "Let's build a health profile" : "Update health profile")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 2. PRIMARY INFO CARD
                        VStack(spacing: 20) {
                            PremiumTextField(
                                title: "Nama",
                                placeholder: "What's their name?",
                                text: $viewModel.name,
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
                                
                                Picker("Species", selection: $viewModel.species) {
                                    ForEach(PetSpecies.allCases, id: \.self) { species in
                                        Label(species.rawValue.capitalized, systemImage: iconForSpecies(species)).tag(species)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .scaleEffect(1.02)
                                .onChange(of: viewModel.species) { oldValue, newValue in
                                    viewModel.updateSpecies(newValue)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("RACE / BREED")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(focusedField == .breed ? tangerine : .secondary)
                                    .padding(.leading, 4)
                                
                                Menu {
                                    Picker("Breed", selection: $viewModel.breed) {
                                        ForEach(viewModel.currentBreeds, id: \.self) { b in
                                            Text(b).tag(b)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "pawprint.circle.fill")
                                            .foregroundColor(viewModel.breed.isEmpty ? .secondary.opacity(0.8) : tangerine)
                                            .frame(width: 20)
                                        
                                        Text(viewModel.breed.isEmpty ? "Select race..." : viewModel.breed)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(viewModel.breed.isEmpty ? .secondary : .primary)
                                        
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
                            
                            if viewModel.breed == "Other (Type manually)" {
                                PremiumTextField(
                                    title: "Custom Breed",
                                    placeholder: "Type breed manually...",
                                    text: $viewModel.customBreed,
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
                            DatePicker("Birth Date", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tint(tangerine)
                            
                            Divider()
                            
                            HStack {
                                Label("Weight", systemImage: "scalemass.fill")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(focusedField == .weight ? tangerine : .primary)
                                
                                Spacer()
                                
                                TextField("0.0", text: $viewModel.weightString)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .focused($focusedField, equals: .weight)
                                
                                Text("kg")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            Toggle(isOn: $viewModel.isNeutered) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Neutered?")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text("Important for MER calculations")
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
                        Button(action: viewModel.savePet) {
                            HStack {
                                Text(viewModel.petToEdit == nil ? "Save Profile" : "Update Profile")
                                Image(systemName: "checkmark.seal.fill")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(viewModel.isFormValid ? tangerine : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                            .shadow(color: viewModel.isFormValid ? tangerine.opacity(0.3) : .clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!viewModel.isFormValid)
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.top, 8)
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(viewModel.petToEdit == nil ? "Add Anabul" : "Edit Anabul")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.isSaved)
        .onChange(of: viewModel.isSaved) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
    
    private var speciesIcon: String {
        switch viewModel.species {
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
    let container = try! ModelContainer(for: PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    AddPetView(modelContext: container.mainContext)
        .modelContainer(container)
}
