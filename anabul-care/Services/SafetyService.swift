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
        

        return items.filter { item in
            item.match_keywords.contains { keyword in
                lowerQuery.contains(keyword.lowercased())
            }
        }
    }
}
