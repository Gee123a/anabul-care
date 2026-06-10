import SwiftUI
import SwiftData

struct ToxicityLookupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ToxicityViewModel
    
    init(initialQuery: String = "", modelContext: ModelContext) {
        _viewModel = State(initialValue: ToxicityViewModel(initialText: initialQuery, modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.filteredHazards) { hazard in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hazard.keyword.capitalized)
                                .font(.headline)
                            
                            if let species = hazard.speciesRule?.species {
                                Text("Toxic to: \(species.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(hazard.dangerLevel.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.colorForDangerLevel(hazard.dangerLevel).opacity(0.2))
                            .foregroundColor(viewModel.colorForDangerLevel(hazard.dangerLevel))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(viewModel.colorForDangerLevel(hazard.dangerLevel).opacity(0.5), lineWidth: 1)
                            )
                            .accessibilityLabel("Danger level: \(hazard.dangerLevel)")
                    }
                    
                    if hazard.alternative != "none" {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill") // Warning icon
                                .font(.caption)
                            Text("Symptoms: \(hazard.alternative)")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }
            .navigationTitle("Toxicity Lookup")
            .searchable(text: $viewModel.searchText, prompt: "Search foods...")
            .toolbar {
                // Added the top-left button to match the Pet Profile view
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.title3.weight(.semibold))
                    }
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: ToxicityModel.self, SpeciesRuleModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ToxicityLookupView(modelContext: container.mainContext)
        .modelContainer(container)
}
