import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WatchViewModel
    
    init(modelContext: ModelContext) {
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: WatchViewModel(repository: repository, modelContext: modelContext))
    }
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    var body: some View {
        NavigationStack {
            if viewModel.pets.isEmpty {
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
                    ForEach(viewModel.pets) { pet in
                        NavigationLink {
                            WatchPetDashboardView(viewModel: viewModel, pet: pet)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.iconForSpecies(pet.species))
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
        .onAppear {
            viewModel.fetchPets()
        }
    }
}

struct WatchPetDashboardView: View {
    var viewModel: WatchViewModel
    let pet: PetProfile
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                // Progress Header
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(viewModel.completedCount(for: pet))/\(viewModel.dailyTasks.count)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(tangerine)
                        Text("Completed")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                    Spacer()
                    
                    ProgressView(value: Double(viewModel.completedCount(for: pet)), total: Double(viewModel.dailyTasks.count))
                        .progressViewStyle(.circular)
                        .tint(tangerine)
                        .scaleEffect(0.8)
                }
                .padding(.horizontal)
                
                Divider().opacity(0.3)
                
                // Task List
                VStack(spacing: 8) {
                    ForEach(viewModel.dailyTasks) { task in
                        WatchTaskRow(viewModel: viewModel, pet: pet, task: task)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .navigationTitle(pet.name)
        .onAppear {
            viewModel.updateTasks(for: pet)
        }
    }
}

struct WatchTaskRow: View {
    var viewModel: WatchViewModel
    let pet: PetProfile
    let task: DailyTaskItem
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let mint = Color(red: 123/255, green: 211/255, blue: 179/255)
    
    var isLogged: Bool {
        viewModel.isTaskCompleted(task, for: pet)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.toggleTask(task, for: pet)
            }
        }) {
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
}

#Preview {
    ContentView()
        .modelContainer(for: [PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self, TaskPreference.self, TaskDeactivation.self], inMemory: true)
}
