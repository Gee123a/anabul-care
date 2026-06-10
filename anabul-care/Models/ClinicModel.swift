import Foundation
import MapKit

/// Categories for points of interest in the map view.
/// Defines filtering logic for veterinary clinics, hotels, and parks.
public enum POICategory: String, CaseIterable {
    case all = "Semua Kategori"
    case vet = "Klinik Hewan & Puskeswan"
    case hotel = "Pet Hotel"
    case park = "Taman Hewan"
    
    /// Returns the SF Symbol name associated with the category.
    public var systemIcon: String {
        switch self {
        case .vet: return "cross.case.fill"
        case .hotel: return "house.lodge.fill"
        case .park: return "tree.fill"
        case .all: return "mappin"
        }
    }
}

/// Represents a clinic or pet-related facility found via MapKit.
/// Used for displaying locations on the radar view.
public struct ClinicModel: Identifiable, Hashable {
    /// Unique identifier for the facility.
    public let id = UUID()
    /// Display name of the facility.
    public let name: String
    /// Geographical coordinates for map placement.
    public let coordinate: CLLocationCoordinate2D
    /// Physical address of the facility.
    public let address: String
    /// Contact phone number.
    public let phone: String
    /// The classification of the facility.
    public let category: POICategory
    /// The underlying MapKit item for navigation.
    public let mapItem: MKMapItem?
    
    public init(name: String, coordinate: CLLocationCoordinate2D, address: String, phone: String, category: POICategory, mapItem: MKMapItem? = nil) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.phone = phone
        self.category = category
        self.mapItem = mapItem
    }
    
    public static func == (lhs: ClinicModel, rhs: ClinicModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
