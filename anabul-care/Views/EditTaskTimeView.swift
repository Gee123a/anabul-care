import SwiftUI
import SwiftData

struct EditTaskTimeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: EditTaskViewModel
    @State private var showingRemoveConfirmation = false
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    init(pet: PetProfile, task: DailyTaskItem, date: Date, modelContext: ModelContext) {
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: EditTaskViewModel(pet: pet, task: task, date: date, repository: repository))
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
                        Image(systemName: viewModel.task.icon)
                            .font(.system(size: 32))
                            .foregroundColor(tangerine)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Manage \(viewModel.task.title)")
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
                    
                    DatePicker("Preferred Time", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
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
                    Button(action: {
                        viewModel.savePreference()
                        dismiss()
                    }) {
                        Text("Save Preference")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(tangerine)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.resetToDefault()
                            dismiss()
                        }) {
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
                Button("Remove for Today Only") { 
                    viewModel.removeTask(permanent: false)
                    dismiss()
                }
                Button("Remove Permanently", role: .destructive) { 
                    viewModel.removeTask(permanent: true)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.impactWarning)
            }
        }
    }
}
