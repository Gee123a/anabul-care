import SwiftUI
import SwiftData
import Combine

@Observable
public final class ToxicityViewModel {
    public var searchText: String
    public var hazards: [ToxicityModel] = []
    
    private let modelContext: ModelContext
    
    public init(initialText: String = "", modelContext: ModelContext) {
        self.searchText = initialText
        self.modelContext = modelContext
        fetchHazards()
    }
    
    public func fetchHazards() {
        let descriptor = FetchDescriptor<ToxicityModel>(sortBy: [SortDescriptor(\.keyword)])
        do {
            self.hazards = try modelContext.fetch(descriptor)
        } catch {
            print("ToxicityViewModel: Error fetching hazards: \(error)")
        }
    }
    
    public var filteredHazards: [ToxicityModel] {
        if searchText.isEmpty {
            return hazards
        } else {
            return hazards.filter { $0.keyword.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    public func colorForDangerLevel(_ level: String) -> Color {
        switch level.lowercased() {
        case "low": return .yellow
        case "moderate": return .orange
        case "high": return .red
        case "critical": return .purple
        default: return .gray
        }
    }
}
