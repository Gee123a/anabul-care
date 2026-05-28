import Foundation
import SwiftData

@Model
public final class ToxicityModel {
    public var id: UUID
    public var keyword: String
    public var dangerLevel: String
    public var alternative: String
    public var speciesRule: SpeciesRuleModel?
    
    public init(id: UUID = UUID(), keyword: String, dangerLevel: String, alternative: String) {
        self.id = id
        self.keyword = keyword
        self.dangerLevel = dangerLevel
        self.alternative = alternative
    }
}
