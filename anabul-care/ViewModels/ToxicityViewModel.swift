import SwiftUI
import SwiftData
import Combine

@MainActor
class ToxicityViewModel: ObservableObject {
    // 1. Remove the = "" default value here so we can inject it
    @Published var searchText: String
    
    // 2. Add this initializer so the View can pass the Spotlight text in!
    init(initialText: String = "") {
        self.searchText = initialText
    }
    
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
