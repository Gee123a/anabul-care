import Foundation
import SwiftData

/// Defines biological and environmental rules for a specific species.
/// Used to calculate metabolic rates and safety thresholds.
@Model
public final class SpeciesRuleModel {
    /// The name of the species (e.g., "dog", "cat").
    public var species: String
    /// Constant used in Resting Energy Requirement (RER) calculations.
    public var rerConstant: Int
    /// Ambient temperature threshold above which health risks increase.
    public var heatThresholdCelsius: Double
    
    /// List of toxic substances and hazards specific to this species.
    @Relationship(deleteRule: .cascade) 
    public var hazards: [ToxicityModel] = []
    
    /// Initializes a new species rule.
    /// - Parameters:
    ///   - species: Species identifier.
    ///   - rerConstant: Base metabolic constant.
    ///   - heatThresholdCelsius: Critical temperature limit.
    public init(species: String, rerConstant: Int, heatThresholdCelsius: Double) {
        self.species = species
        self.rerConstant = rerConstant
        self.heatThresholdCelsius = heatThresholdCelsius
    }
}
