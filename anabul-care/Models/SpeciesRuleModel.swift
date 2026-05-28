import Foundation
import SwiftData

@Model
public final class SpeciesRuleModel {
    public var species: String
    public var rerConstant: Int
    public var heatThresholdCelsius: Double
    
    @Relationship(deleteRule: .cascade) 
    public var hazards: [ToxicityModel] = []
    
    public init(species: String, rerConstant: Int, heatThresholdCelsius: Double) {
        self.species = species
        self.rerConstant = rerConstant
        self.heatThresholdCelsius = heatThresholdCelsius
    }
}
