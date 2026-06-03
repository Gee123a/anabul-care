import SwiftUI
import MapKit

struct AnimatedMapPin: View {
    let category: POICategory
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "FF6B33").opacity(0.3))
                .frame(width: isPulsing ? 60 : 25, height: isPulsing ? 60 : 25)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            
            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            Image(systemName: iconForCategory(category))
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "FF6B33"))
        }
        .onAppear {
            isPulsing = true
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

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    @Binding var selectedTab: Int
    
    @State private var isZoomMenuExpanded = false
    @State private var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385)
    @State private var currentDistance: Double = 5000
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $viewModel.position, selection: $viewModel.selectedClinic) {
                ForEach(viewModel.filteredClinics) { clinic in
                    Annotation(clinic.name, coordinate: clinic.coordinate) {
                        AnimatedMapPin(category: clinic.category)
                    }
                    .tag(clinic)
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .continuous) { context in
                currentCenter = context.region.center
                currentDistance = context.camera.distance
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateRegion(context.region)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    
                    // Search bar stretches to take space previously used by the back button
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.gray)
                        TextField("Cari kota, klinik...", text: $viewModel.searchText)
                            .font(.system(size: 16, design: .rounded))
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    await viewModel.searchForRegion(query: viewModel.searchText)
                                }
                            }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    
                    Menu {
                        Picker("Kategori", selection: $viewModel.selectedCategory) {
                            ForEach(POICategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.white)
                            .frame(width: 48, height: 48)
                            .background(Color(hex: "FF6B33"))
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "FF6B33").opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.position = .userLocation(fallback: .automatic)
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "FF6B33"))
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    // Expandable Zoom Controls
                    VStack(spacing: 12) {
                        if isZoomMenuExpanded {
                            Button(action: zoomIn) {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "FF6B33"))
                                    .frame(width: 48, height: 48)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            }
                            .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 20)))
                            
                            Button(action: zoomOut) {
                                Image(systemName: "minus.magnifyingglass")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "FF6B33"))
                                    .frame(width: 48, height: 48)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            }
                            .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 10)))
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isZoomMenuExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isZoomMenuExpanded ? "xmark" : "magnifyingglass")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.white)
                                .frame(width: 54, height: 54)
                                .background(Color(hex: "1C1C1A"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                
                if let clinic = viewModel.selectedClinic {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "FF6B33").opacity(0.15))
                                .frame(width: 52, height: 52)
                            
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(hex: "FF6B33").opacity(0.3), lineWidth: 1)
                            
                            Image(systemName: iconForCategory(clinic.category))
                                .foregroundColor(Color(hex: "FF6B33"))
                                .font(.system(size: 22))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clinic.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black)
                                .lineLimit(1)
                            Text(clinic.phone)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color.gray)
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
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(hex: "1A1A1A"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.85))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.selectedClinic)
    }
    
    private func zoomIn() {
        let newDistance = max(currentDistance * 0.4, 500)
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance))
        }
    }
    
    private func zoomOut() {
        let newDistance = min(currentDistance * 2.5, 500000)
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance))
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
        if hex.count == 6 {
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        } else {
            (r, g, b) = (1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
