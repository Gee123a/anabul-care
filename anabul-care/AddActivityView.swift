import SwiftUI
import SwiftData

struct AddActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: PetProfile
    
    @State private var logType: LogType = .feeding
    @State private var durationMinutes: Int = 0
    @State private var details: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Jenis Aktivitas", selection: $logType) {
                    ForEach(LogType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                
                if logType == .walk || logType == .play {
                    Stepper("Durasi: \(durationMinutes) menit", value: $durationMinutes, in: 0...120, step: 5)
                }
                
                Section(header: Text("Catatan")) {
                    TextField("Detail (opsional)", text: $details)
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
                        saveActivity()
                    }
                }
            }
        }
    }
    
    private func saveActivity() {
        let newLog = ActivityLog(
            logType: logType,
            durationMinutes: durationMinutes,
            details: details
        )
        newLog.pet = pet
        pet.activityLogs.append(newLog)
        dismiss()
    }
}
