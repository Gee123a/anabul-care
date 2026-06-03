//
//  SpotlightManager.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 03/06/26.
//


import Foundation
import CoreSpotlight
import MobileCoreServices

class SpotlightManager {
    static let shared = SpotlightManager()
    
    func indexToxicityDatabase(items: [ToxicityModel]) {
        var searchableItems = [CSSearchableItem]()
        
        for item in items {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            // What the user sees in the iPhone search results
            attributeSet.title = "Is \(item.keyword.capitalized) safe for my pet?"
            attributeSet.contentDescription = "Danger Level: \(item.dangerLevel) \nAlternative: \(item.alternative)"
            
            // Adding extra keywords for fuzzy matching
            attributeSet.keywords = [item.keyword, "pet food", "toxic", "safe", "anabul"]
            
            // Unique ID to catch when they tap it
            let uniqueID = "toxicity_\(item.keyword.lowercased())"
            
            let searchableItem = CSSearchableItem(
                uniqueIdentifier: uniqueID,
                domainIdentifier: "com.Gee.anabulcare",
                attributeSet: attributeSet
            )
            
            searchableItems.append(searchableItem)
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print("Spotlight Indexing failed: \(error.localizedDescription)")
            } else {
                print("Successfully indexed \(searchableItems.count) safety items into iOS CoreSpotlight!")
            }
        }
    }
}
