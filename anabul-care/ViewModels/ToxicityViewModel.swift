import Foundation
import SwiftData
import Combine

/// ViewModel for searching and filtering toxicity hazards.
/// Handles data fetching from SwiftData and filtering based on user search input.
@Observable
public final class ToxicityViewModel {
    /// The current search text input by the user.
    public var searchText: String
    
    /// All hazards fetched from the database.
    public var hazards: [ToxicityModel] = []
    
    private let modelContext: ModelContext
    
    /// Initializes the view model with an optional initial search text.
    /// - Parameters:
    ///   - initialText: The starting search query.
    ///   - modelContext: The SwiftData model context for database operations.
    public init(initialText: String = "", modelContext: ModelContext) {
        self.searchText = initialText
        self.modelContext = modelContext
        fetchHazards()
    }
    
    /// Fetches all toxicity hazards from the SwiftData store.
    public func fetchHazards() {
        let descriptor = FetchDescriptor<ToxicityModel>(sortBy: [SortDescriptor(\.keyword)])
        do {
            self.hazards = try modelContext.fetch(descriptor)
        } catch {
            print("ToxicityViewModel: Error fetching hazards: \(error)")
        }
    }
    
    /// Returns hazards filtered by the current search text.
    public var filteredHazards: [ToxicityModel] {
        if searchText.isEmpty {
            return hazards
        } else {
            return hazards.filter { $0.keyword.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
