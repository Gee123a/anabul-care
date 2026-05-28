//
//  SafetyService.swift
//  anabul-care
//

import Foundation

struct ToxicItem: Codable, Identifiable {
    var id: String { name }
    let name: String
    let severity: String
    let symptoms: String
    let match_keywords: [String]
}

struct ToxicityData: Codable {
    let dog: [ToxicItem]
    let cat: [ToxicItem]
    let hamster: [ToxicItem]
}

class SafetyService {
    static let shared = SafetyService()
    private var database: ToxicityData?
    
    init() {
        loadDatabase()
    }
    
    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "MasterToxicityDatabase", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load Toxicity Database")
            return
        }
        
        do {
            self.database = try JSONDecoder().decode(ToxicityData.self, from: data)
        } catch {
            print("Failed to decode Toxicity Database: \(error)")
        }
    }
    
    /// Checks a query string against the toxicity database for a specific species
    /// - Parameters:
    ///   - species: "dog", "cat", or "hamster"
    ///   - query: The food or item name (e.g., "Is chocolate safe?")
    /// - Returns: A list of matching toxic items found
    func checkSafety(for species: String, query: String) -> [ToxicItem] {
        guard let db = database else { return [] }
        
        let items: [ToxicItem]
        switch species.lowercased() {
        case "dog": items = db.dog
        case "cat": items = db.cat
        case "hamster": items = db.hamster
        default: return []
        }
        
        let lowerQuery = query.lowercased()
        
        // Intelligent Fuzzy Matcher: Checks if any of our toxic keywords exist in the user's query
        return items.filter { item in
            item.match_keywords.contains { keyword in
                lowerQuery.contains(keyword.lowercased())
            }
        }
    }
}
