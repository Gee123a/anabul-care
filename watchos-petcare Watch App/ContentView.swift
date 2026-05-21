import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    
    var body: some View {
        NavigationStack {
            if pets.isEmpty {
                Text("Tambah Anabul di iPhone")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            } else {
                List {
                    ForEach(pets) { pet in
                        NavigationLink {
                            WatchLoggingView(pet: pet)
                        } label: {
                            Text(pet.name)
                        }
                    }
                }
                .navigationTitle("Anabul Care")
            }
        }
    }
}

struct WatchLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let pet: PetProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Button(action: { logActivity(.feeding) }) {
                    Label("Makan", systemImage: "fork.knife")
                }
                Button(action: { logActivity(.walk) }) {
                    Label("Jalan", systemImage: "figure.walk")
                }
                Button(action: { logActivity(.play) }) {
                    Label("Main", systemImage: "tennisball")
                }
                Button(action: { logActivity(.grooming) }) {
                    Label("Grooming", systemImage: "scissors")
                }
            }
        }
        .navigationTitle(pet.name)
    }
    
    private func logActivity(_ type: LogType) {
        let newLog = ActivityLog(logType: type)
        newLog.pet = pet
        pet.activityLogs.append(newLog)
        dismiss()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self], inMemory: true)
}
