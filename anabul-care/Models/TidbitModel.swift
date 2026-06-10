import Foundation
import SwiftData

/// Represents a small piece of educational information or "fun fact".
/// Displayed to users to improve their understanding of pet behavior.
@Model
public final class TidbitModel {
    /// Unique identifier for the tidbit.
    public var id: String
    /// The species this information applies to.
    public var speciesTarget: String
    /// Short, catchy title for the information card.
    public var title: String
    /// The full text content of the tidbit.
    public var bodyText: String
    /// Academic or professional source for the information.
    public var citation: String
    
    /// Initializes a tidbit record.
    /// - Parameters:
    ///   - id: Unique ID.
    ///   - speciesTarget: Targeted species string.
    ///   - title: Display title.
    ///   - bodyText: Main content.
    ///   - citation: Source reference.
    public init(id: String, speciesTarget: String, title: String, bodyText: String, citation: String) {
        self.id = id
        self.speciesTarget = speciesTarget
        self.title = title
        self.bodyText = bodyText
        self.citation = citation
    }
}
