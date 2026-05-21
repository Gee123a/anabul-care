import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            PetListView()
                .tabItem {
                    Label("Anabul", systemImage: "pawprint.fill")
                }
            
            ToxicityLookupView()
                .tabItem {
                    Label("Keamanan", systemImage: "exclamationmark.shield.fill")
                }
            
            PuskeswanRadarView()
                .tabItem {
                    Label("Radar", systemImage: "map.fill")
                }
        }
        .task {
            await DataManager.shared.seedData(modelContainer: modelContext.container)
        }
    }
}

struct PetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    @Query private var tidbits: [TidbitModel]
    @StateObject private var viewModel = PetViewModel()
    @State private var showingAddPet = false
    
    var body: some View {
        NavigationSplitView {
            Group {
                if pets.isEmpty {
                    ContentUnavailableView {
                        Label("Belum ada Anabul", systemImage: "pawprint.circle")
                    } description: {
                        Text("Tambahkan profil peliharaan Anda untuk mulai mencatat dan memantau kesehatan mereka.")
                    } actions: {
                        Button(action: { showingAddPet = true }) {
                            Text("Tambah Anabul")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        if let tidbit = tidbits.randomElement() {
                            Section {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                        Text("Tips Hari Ini")
                                            .font(.headline)
                                    }
                                    
                                    Text(tidbit.bodyText)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text("Sumber: \(tidbit.citation)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            } header: {
                                Text("Wawasan")
                            }
                        }
                        
                        Section {
                            ForEach(pets) { pet in
                                NavigationLink {
                                    PetDetailView(pet: pet)
                                } label: {
                                    HStack(spacing: 15) {
                                        Image(systemName: pet.species == .dog ? "dog.fill" : (pet.species == .cat ? "cat.fill" : "hare.fill"))
                                            .font(.title2)
                                            .foregroundColor(.accentColor)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(pet.name)
                                                .font(.headline)
                                            Text(pet.species.rawValue.capitalized)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    viewModel.deletePet(pets[index], in: modelContext)
                                }
                            }
                        } header: {
                            Text("Anabul Anda")
                        }
                    }
                }
            }
            .navigationTitle("Anabul Care")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddPet = true }) {
                        Label("Tambah Anabul", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
        } detail: {
            ContentUnavailableView("Pilih Anabul", systemImage: "pawprint", description: Text("Pilih salah satu anabul dari daftar di samping untuk melihat detail kesehatan."))
        }
    }
}

struct PetDetailView: View {
    let pet: PetProfile
    @State private var showingAddActivity = false
    
    var body: some View {
        List {
            Section {
                LabeledContent {
                    Text(pet.species.rawValue.capitalized)
                } label: {
                    Label("Spesies", systemImage: "info.circle")
                }
                
                LabeledContent {
                    Text(pet.breed)
                } label: {
                    Label("Ras", systemImage: "tag")
                }
                
                LabeledContent {
                    Text("\(String(format: "%.2f", pet.weightKg)) kg")
                } label: {
                    Label("Berat", systemImage: "scalemass")
                }
                
                LabeledContent {
                    Text(pet.isNeutered ? "Ya" : "Tidak")
                } label: {
                    Label("Steril", systemImage: "checkmark.shield")
                }
            } header: {
                Text("Profil Dasar")
            }
            
            Section {
                LabeledContent {
                    Text("\(Int(pet.rer)) kCal")
                        .fontWeight(.semibold)
                } label: {
                    Label("RER", systemImage: "bolt.fill")
                }
                
                LabeledContent {
                    Text("\(Int(pet.dailyTargetCalories)) kCal")
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                } label: {
                    Label("Target Daily (MER)", systemImage: "target")
                }
            } header: {
                Text("Kebutuhan Energi")
            } footer: {
                Text("RER (Resting Energy Requirement) adalah kalori dasar saat istirahat.")
            }
            
            Section {
                Button(action: { showingAddActivity = true }) {
                    Label("Catat Aktivitas", systemImage: "plus.circle.fill")
                        .fontWeight(.medium)
                }
                
                if pet.activityLogs.isEmpty {
                    Text("Belum ada aktivitas tercatat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(pet.activityLogs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                        HStack {
                            Label(log.logType.rawValue.capitalized, systemImage: iconForActivity(log.logType))
                            Spacer()
                            Text(log.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("Riwayat Aktivitas")
            }
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView(pet: pet)
        }
    }
    
    private func iconForActivity(_ type: LogType) -> String {
        switch type {
        case .feeding: return "fork.knife"
        case .grooming: return "scissors"
        case .walk: return "figure.walk"
        case .play: return "tennisball"
        case .hydration: return "drop.fill"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PetProfile.self, inMemory: true)
}
