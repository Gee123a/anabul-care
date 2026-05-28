import Foundation
import SwiftData

@Model
public final class TidbitModel {
    public var id: String
    public var speciesTarget: String
    public var title: String
    public var bodyText: String
    public var citation: String
    
    public init(id: String, speciesTarget: String, title: String, bodyText: String, citation: String) {
        self.id = id
        self.speciesTarget = speciesTarget
        self.title = title
        self.bodyText = bodyText
        self.citation = citation
    }
}
