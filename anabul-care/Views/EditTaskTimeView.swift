import SwiftUI
import SwiftData

struct EditTaskTimeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: PetProfile
    let task: DailyTaskItem
    let date: Date
    
    @Query private var allPreferences: [TaskPreference]
    @Query private var allDeactivations: [TaskDeactivation]
    @State private var selectedTime: Date = Date()
    @State private var showingRemoveConfirmation = false
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    init(pet: PetProfile, task: DailyTaskItem, date: Date) {
        self.pet = pet
        self.task = task
        self.date = date
        
        // Initializing the state from existing preference if it exists
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        let initialDate = f.date(from: task.timeRecommendation) ?? Date()
        _selectedTime = State(initialValue: initialDate)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(tangerine.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: task.icon)
                            .font(.system(size: 32))
                            .foregroundColor(tangerine)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Manage \(task.title)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("Customize or remove this task.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Time Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("RECOMMENDED TIME")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                    
                    DatePicker("Preferred Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: savePreference) {
                        Text("Save Preference")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(tangerine)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: resetToDefault) {
                            Text("Reset Time")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Button(action: { showingRemoveConfirmation = true }) {
                            Text("Remove Task")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.97).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .confirmationDialog("Remove Task", isPresented: $showingRemoveConfirmation, titleVisibility: .visible) {
                Button("Remove for Today Only") { removeTask(permanent: false) }
                Button("Remove Permanently", role: .destructive) { removeTask(permanent: true) }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(impactWarning)
            }
        }
    }
    
    private var impactWarning: String {
        let base = "Removing this task might impact \(pet.name)'s health. "
        switch task.type {
        case .feeding: return base + "Consistent feeding is crucial for metabolism and energy levels."
        case .walk, .play: return base + "Lack of exercise can lead to obesity and behavioral issues."
        case .grooming: return base + "Regular grooming prevents skin issues and monitors for parasites."
        case .hydration: return base + "Hydration is essential for kidney function and overall health."
        }
    }
    
    private func savePreference() {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        let timeString = f.string(from: selectedTime)
        
        if let existing = allPreferences.first(where: { $0.petID == pet.id && $0.taskType == task.type.rawValue }) {
            existing.preferredTime = timeString
            existing.isManualOverride = true
        } else {
            let newPref = TaskPreference(petID: pet.id, taskType: task.type.rawValue, preferredTime: timeString, isManualOverride: true)
            modelContext.insert(newPref)
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func resetToDefault() {
        if let existing = allPreferences.first(where: { $0.petID == pet.id && $0.taskType == task.type.rawValue }) {
            modelContext.delete(existing)
            try? modelContext.save()
        }
        dismiss()
    }
    
    private func removeTask(permanent: Bool) {
        let deactivation = TaskDeactivation(
            petID: pet.id,
            taskType: task.type.rawValue,
            date: permanent ? nil : date
        )
        modelContext.insert(deactivation)
        try? modelContext.save()
        dismiss()
    }
}
