import Foundation
import SwiftData
import SwiftUI

@Observable
public final class InsightViewModel {
    public var allTips: [TidbitModel] = []
    public var targetSpecies: String
    
    private let modelContext: ModelContext
    
    public init(targetSpecies: String, modelContext: ModelContext) {
        self.targetSpecies = targetSpecies
        self.modelContext = modelContext
        fetchTips()
    }
    
    public func fetchTips() {
        let descriptor = FetchDescriptor<TidbitModel>()
        do {
            self.allTips = try modelContext.fetch(descriptor)
        } catch {
            print("InsightViewModel: Error fetching tips: \(error)")
        }
    }
    
    public var tip: TidbitModel? {
        let speciesLower = targetSpecies.lowercased()
        return allTips.first { $0.speciesTarget == speciesLower }
    }
}
