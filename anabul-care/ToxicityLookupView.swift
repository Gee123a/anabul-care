import SwiftUI
import SwiftData

struct ToxicityLookupView: View {
    @Query(sort: \ToxicityModel.keyword) private var hazards: [ToxicityModel]
    @State private var searchText = ""
    
    var filteredHazards: [ToxicityModel] {
        if searchText.isEmpty {
            return hazards
        } else {
            return hazards.filter { $0.keyword.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredHazards) { hazard in
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
                            .background(colorForDangerLevel(hazard.dangerLevel).opacity(0.2))
                            .foregroundColor(colorForDangerLevel(hazard.dangerLevel))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(colorForDangerLevel(hazard.dangerLevel).opacity(0.5), lineWidth: 1)
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
            .searchable(text: $searchText, prompt: "Cari bahan makanan...")
        }
    }
    
    private func colorForDangerLevel(_ level: String) -> Color {
        switch level.lowercased() {
        case "low": return .yellow
        case "moderate": return .orange
        case "high": return .red
        case "critical": return .purple
        default: return .gray
        }
    }
}

#Preview {
    ToxicityLookupView()
        .modelContainer(for: ToxicityModel.self, inMemory: true)
}
