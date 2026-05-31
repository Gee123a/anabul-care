import SwiftUI
import SwiftData

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var species: PetSpecies = .dog
    @State private var breed: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var weightString: String = ""
    @State private var isNeutered: Bool = false
    
    private var parsedWeight: Double {
        Double(weightString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informasi Dasar")) {
                    TextField("Nama Anabul", text: $name)
                    Picker("Spesies", selection: $species) {
                        ForEach(PetSpecies.allCases, id: \.self) { species in
                            Text(species.rawValue.capitalized).tag(species)
                        }
                    }
                    TextField("Ras / Breed", text: $breed)
                }
                
                Section(header: Text("Detail Fisik")) {
                    DatePicker("Tanggal Lahir", selection: $dateOfBirth, displayedComponents: .date)
                    HStack {
                        Text("Berat (kg)")
                        Spacer()
                        TextField("0.0", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Sudah Steril", isOn: $isNeutered)
                }
            }
            .navigationTitle("Tambah Anabul")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let newPet = PetProfile(
                            name: name,
                            species: species.rawValue,
                            breed: breed,
                            dateOfBirth: dateOfBirth,
                            weightKg: parsedWeight,
                            isNeutered: isNeutered
                        )
                        modelContext.insert(newPet)
                        dismiss()
                    }
                    .disabled(name.isEmpty || parsedWeight <= 0)
                }
            }
        }
    }
}

#Preview {
    AddPetView()
        .modelContainer(for: PetProfile.self, inMemory: true)
}
