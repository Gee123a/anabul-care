import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetProfile.name) private var pets: [PetProfile]
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    var body: some View {
        NavigationStack {
            if pets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(tangerine.opacity(0.8))
                    
                    Text("Add a pet on your iPhone first")
                        .font(.system(.caption, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .navigationTitle("Anabul")
            } else {
                List {
                    ForEach(pets) { pet in
                        NavigationLink {
                            WatchPetDashboardView(pet: pet)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: iconForSpecies(pet.species))
                                    .foregroundColor(tangerine)
                                    .font(.system(size: 16, weight: .bold))
                                
                                Text(pet.name)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("Anabul Care")
                .listStyle(.carousel)
            }
        }
    }
    
    private func iconForSpecies(_ species: String) -> String {
        switch species.lowercased() {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "hamster": return "hare.fill"
        default: return "pawprint.fill"
        }
    }
}

struct WatchPetDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let mint = Color(red: 123/255, green: 211/255, blue: 179/255)
    
    // We get the dynamic tasks for this pet
    private var dailyTasks: [DailyTaskItem] {
        DailyRoutineGenerator.generate(for: pet)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                // Progress Header
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(completedCount)/\(dailyTasks.count)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(tangerine)
                        Text("Completed")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                    Spacer()
                    
                    ProgressView(value: Double(completedCount), total: Double(dailyTasks.count))
                        .progressViewStyle(.circular)
                        .tint(tangerine)
                        .scaleEffect(0.8)
                }
                .padding(.horizontal)
                
                Divider().opacity(0.3)
                
                // Task List
                VStack(spacing: 8) {
                    ForEach(dailyTasks) { task in
                        WatchTaskRow(pet: pet, task: task)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .navigationTitle(pet.name)
    }
    
    private var completedCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyTasks.filter { task in
            pet.activities.contains { $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
        }.count
    }
}

struct WatchTaskRow: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    let task: DailyTaskItem
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let mint = Color(red: 123/255, green: 211/255, blue: 179/255)
    
    var isLogged: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return pet.activities.contains { $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
    }
    
    var body: some View {
        Button(action: toggleActivity) {
            HStack(spacing: 10) {
                Image(systemName: task.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isLogged ? mint : tangerine)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(task.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .strikethrough(isLogged)
                    
                    Text(task.timeRecommendation)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isLogged {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(mint)
                        .font(.system(size: 16))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isLogged ? mint.opacity(0.15) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func toggleActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isLogged {
                if let index = pet.activities.firstIndex(where: { $0.type == task.type.rawValue && Calendar.current.isDate($0.timestamp, inSameDayAs: today) }) {
                    let logToDelete = pet.activities[index]
                    modelContext.delete(logToDelete)
                    pet.activities.remove(at: index)
                }
            } else {
                let newLog = ActivityLog(
                    timestamp: today,
                    type: task.type.rawValue,
                    durationMinutes: 0,
                    detail: "Logged via Watch"
                )
                newLog.pet = pet
                modelContext.insert(newLog)
                pet.activities.append(newLog)
            }
            
            // Explicit save to ensure Watch sends update to shared container
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self], inMemory: true)
}
