import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class RadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
        distance: 4000
    ))
    @Published var clinics: [ClinicModel] = []
    @Published var selectedClinic: ClinicModel?
    @Published var searchText: String = ""
    @Published var selectedCategory: POICategory = .all
    
    init() {}
    
    var filteredClinics: [ClinicModel] {
        clinics.filter { clinic in
            let categoryMatch = (selectedCategory == .all) || (clinic.category == selectedCategory)
            let searchMatch = searchText.isEmpty || clinic.name.localizedCaseInsensitiveContains(searchText)
            return categoryMatch && searchMatch
        }
    }

    func searchForRegion(query: String) async {
        guard !query.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let firstItem = response.mapItems.first {
                withAnimation {
                    self.position = .camera(MapCamera(
                        centerCoordinate: firstItem.placemark.coordinate,
                        distance: 8000
                    ))
                }
            }
        } catch {
            print("Search failed")
        }
    }

    func performSearch(in region: MKCoordinateRegion) async {
        var newClinics: [ClinicModel] = []
        
        let searchQueries: [(String, POICategory)] = [
            ("Klinik Hewan", .vet),
            ("Pet Hotel", .hotel),
            ("Taman", .park)
        ]
        
        for query in searchQueries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query.0
            request.region = region
            
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                for item in response.mapItems {
                    let name = item.name ?? "Unknown"
                    guard isRelevant(name: name, category: query.1) else { continue }
                    
                    let clinic = ClinicModel(
                        name: name,
                        coordinate: item.placemark.coordinate,
                        address: item.placemark.title ?? "",
                        phone: item.phoneNumber ?? "No Phone",
                        category: query.1,
                        mapItem: item
                    )
                    newClinics.append(clinic)
                }
            } catch {
                continue
            }
        }
        
        var uniqueClinics: [ClinicModel] = []
        var seen = Set<String>()
        
        for clinic in newClinics {
            let key = clinic.name + String(clinic.coordinate.latitude)
            if !seen.contains(key) {
                seen.insert(key)
                uniqueClinics.append(clinic)
            }
        }
        
        withAnimation {
            self.clinics = uniqueClinics
        }
    }
    
    private func isRelevant(name: String, category: POICategory) -> Bool {
        let lowercaseName = name.lowercased()
        let petKeywords = [
            "pet", "hewan", "kucing", "anjing", "cat", "dog", "paw", "animal",
            "boarding", "grooming", "penitipan", "vet", "klinik", "clinic",
            "care", "drh", "dokter", "aquatic", "reptile", "bird", "burung",
            "meow", "bark", "tail", "fur", "fauna"
        ]
        
        switch category {
        case .hotel:
            if lowercaseName.contains("hotel") {
                return petKeywords.contains { lowercaseName.contains($0) }
            }
            return petKeywords.contains { lowercaseName.contains($0) }
            
        case .vet:
            let isVetOrPet = petKeywords.contains { lowercaseName.contains($0) } || lowercaseName.contains("drh")
            if lowercaseName.contains("klinik") || lowercaseName.contains("clinic") || lowercaseName.contains("hospital") || lowercaseName.contains("rumah sakit") || lowercaseName.contains("rs ") || lowercaseName.contains("puskesmas") {
                return isVetOrPet
            }
            return isVetOrPet
            
        case .park:
            return true
            
        case .all:
            return true
        }
    }
}
