import Foundation
import SwiftData

@Model
public final class ActivityLog {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var logTypeRaw: String
    public var durationMinutes: Int
    public var details: String
    public var pet: PetProfile?
    
    @Transient
    public var logType: LogType {
        get { LogType(rawValue: logTypeRaw) ?? .feeding }
        set { logTypeRaw = newValue.rawValue }
    }
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), logType: LogType, durationMinutes: Int = 0, details: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.logTypeRaw = logType.rawValue
        self.durationMinutes = durationMinutes
        self.details = details
    }
}
