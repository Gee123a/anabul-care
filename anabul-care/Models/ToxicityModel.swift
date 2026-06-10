import Foundation
import SwiftData

/// Stores information about substances that are toxic to specific species.
/// Used by the toxicity lookup feature to warn users.
@Model
public final class ToxicityModel {
    /// Unique identifier for the toxicity record.
    public var id: UUID
    /// The name or keyword of the substance (e.g., "Chocolate").
    public var keyword: String
    /// Severity level of the toxicity (e.g., "Fatal", "Mild").
    public var dangerLevel: String
    /// Safe alternatives or symptoms to watch for.
    public var alternative: String
    /// Reference to the species-specific rules this hazard belongs to.
    public var speciesRule: SpeciesRuleModel?
    
    /// Initializes a toxicity record.
    /// - Parameters:
    ///   - id: Unique UUID.
    ///   - keyword: Substance name.
    ///   - dangerLevel: Severity description.
    ///   - alternative: Remedial info or alternatives.
    public init(id: UUID = UUID(), keyword: String, dangerLevel: String, alternative: String) {
        self.id = id
        self.keyword = keyword
        self.dangerLevel = dangerLevel
        self.alternative = alternative
    }
}
