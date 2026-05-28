import SwiftUI
import MapKit
import Combine

enum POICategory: String, CaseIterable {
    case all = "Semua Kategori"
    case vet = "Klinik Hewan & Puskeswan"
    case hotel = "Pet Hotel"
    case park = "Taman Hewan"
}

struct LocalClinic: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distance: String
    let statusText: String
    let category: POICategory

    static func == (lhs: LocalClinic, rhs: LocalClinic) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
class LocalRadarViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
        distance: 4000
    ))
    
    @Published var allClinics: [LocalClinic] = [
        LocalClinic(
            name: "Puskeswan Wonokromo",
            coordinate: CLLocationCoordinate2D(latitude: -7.3055, longitude: 112.7385),
            distance: "0.6 km",
            statusText: "Buka sampai 20:00",
            category: .vet
        ),
        LocalClinic(
            name: "Surabaya Pet Hotel",
            coordinate: CLLocationCoordinate2D(latitude: -7.2800, longitude: 112.7400),
            distance: "2.1 km",
            statusText: "Buka 24 Jam",
            category: .hotel
        ),
        LocalClinic(
            name: "Taman Bungkul (Pet Zone)",
            coordinate: CLLocationCoordinate2D(latitude: -7.2910, longitude: 112.7400),
            distance: "1.2 km",
            statusText: "Buka sampai 17:00",
            category: .park
        )
    ]
    
    @Published var selectedClinic: LocalClinic?
    @Published var searchText: String = ""
    @Published var selectedCategory: POICategory = .all
    
    var filteredClinics: [LocalClinic] {
        if selectedCategory == .all {
            return allClinics
        }
        return allClinics.filter { $0.category == selectedCategory }
    }
    
    init() {
        self.selectedClinic = allClinics.first
    }
}

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = LocalRadarViewModel()
    
    var body: some View {
        ZStack {
            Map(position: $viewModel.position, selection: $viewModel.selectedClinic) {
                ForEach(viewModel.filteredClinics) { clinic in
                    Annotation(clinic.name, coordinate: clinic.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF6B33").opacity(0.2))
                                .frame(width: 55, height: 55)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 26, height: 26)
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            
                            Circle()
                                .fill(Color(hex: "FF6B33"))
                                .frame(width: 16, height: 16)
                        }
                    }
                    .tag(clinic)
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Search Bar and Filter Menu
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Cari Puskeswan, taman...", text: $viewModel.searchText)
                            .font(.system(.body, design: .rounded))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    
                    Menu {
                        Picker("Kategori", selection: $viewModel.selectedCategory) {
                            ForEach(POICategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(hex: "FF6B33"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 6) {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "FF6B33"))
                    Text("Surabaya, East Java")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                if let clinic = viewModel.selectedClinic {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "FF6B33"))
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: iconForCategory(clinic.category))
                                .foregroundColor(.white)
                                .font(.system(size: 22))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clinic.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            Text("\(clinic.distance) · \(clinic.statusText)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Route")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(hex: "1A1A1A"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(.white.opacity(0.93))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
                }
            }
            .padding(.top, 60)
        }
    }
    
    private func iconForCategory(_ category: POICategory) -> String {
        switch category {
        case .vet: return "cross.case.fill"
        case .hotel: return "house.lodge.fill"
        case .park: return "tree.fill"
        case .all: return "mappin"
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    PuskeswanRadarView()
}
