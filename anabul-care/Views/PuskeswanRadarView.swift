import SwiftUI
import MapKit

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $viewModel.position, selection: $viewModel.selectedClinic) {
                ForEach(viewModel.filteredClinics) { clinic in
                    Annotation(clinic.name, coordinate: clinic.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF6B33").opacity(0.25))
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 26, height: 26)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: iconForCategory(clinic.category))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B33"))
                        }
                    }
                    .tag(clinic)
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateRegion(context.region)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Cari Puskeswan, taman...", text: $viewModel.searchText)
                            .font(.system(size: 16, design: .rounded))
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
                
                Spacer()
            }
            .padding(.top, 60)
            
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
                            .lineLimit(1)
                        Text(clinic.phone)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let mapItem = clinic.mapItem {
                            mapItem.openInMaps(launchOptions: [
                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                            ])
                        }
                    }) {
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.selectedClinic)
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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
