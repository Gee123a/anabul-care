import SwiftUI
import SwiftData

struct ToxicityLookupView: View {
    @Query(sort: \ToxicityModel.keyword) private var hazards: [ToxicityModel]
    @StateObject private var viewModel = ToxicityViewModel()
    
    init(initialQuery: String = "") {
            _viewModel = StateObject(wrappedValue: ToxicityViewModel(initialText: initialQuery))
        }
    
    var body: some View {
        NavigationStack {
            List(viewModel.filterHazards(hazards)) { hazard in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hazard.keyword.capitalized)
                                .font(.headline)
                            
                            if let species = hazard.speciesRule?.species {
                                Text("Berbahaya untuk: \(species.capitalized)")
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
                            .accessibilityLabel("Tingkat bahaya: \(hazard.dangerLevel)")
                    }
                    
                    if hazard.alternative != "none" {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Alternatif: \(hazard.alternative)")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }
            .navigationTitle("Cek Toksisitas")
            .searchable(text: $viewModel.searchText, prompt: "Cari bahan makanan...")
        }
    }
}

#Preview {
    ToxicityLookupView()
        .modelContainer(for: ToxicityModel.self, inMemory: true)
}
