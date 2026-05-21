import SwiftUI
import SwiftData

@MainActor
class ToxicityViewModel: ObservableObject {
    @Published var searchText = ""
    
    func filterHazards(_ hazards: [ToxicityModel]) -> [ToxicityModel] {
        if searchText.isEmpty {
            return hazards
        } else {
            return hazards.filter { $0.keyword.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func colorForDangerLevel(_ level: String) -> Color {
        switch level.lowercased() {
        case "low": return .yellow
        case "moderate": return .orange
        case "high": return .red
        case "critical": return .purple
        default: return .gray
        }
    }
}
