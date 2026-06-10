import SwiftUI
import SwiftData

struct AddActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: AddActivityViewModel
    
    init(pet: PetProfile, modelContext: ModelContext) {
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: AddActivityViewModel(pet: pet, repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Jenis Aktivitas", selection: $viewModel.logType) {
                    ForEach(LogType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                
                if viewModel.logType == .walk || viewModel.logType == .play {
                    Stepper("Durasi: \(viewModel.durationMinutes) menit", value: $viewModel.durationMinutes, in: 0...120, step: 5)
                }
                
                Section(header: Text("Catatan")) {
                    TextField("Detail (opsional)", text: $viewModel.details)
                }
            }
            .navigationTitle("Catat Aktivitas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        viewModel.saveActivity()
                        dismiss()
                    }
                }
            }
        }
    }
}
