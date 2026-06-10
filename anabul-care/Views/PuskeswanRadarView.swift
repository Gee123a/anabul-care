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
            
            Image(systemName: category.systemIcon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "FF6B33"))
        }
        .onAppear {
            isPulsing = true
        }
    }
}

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    @Binding var selectedTab: Int
    
    @State private var isZoomMenuExpanded = false
    @State private var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -7.2950, longitude: 112.7385)
    @State private var currentDistance: Double = 5000
    @State private var showingMapsSelector = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $viewModel.position, interactionModes: [.pan, .zoom], selection: $viewModel.selectedClinic) {
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
                            Task {
                                await viewModel.performSearch(in: context.region)
                            }
                        }
            .ignoresSafeArea()
            .background(MapGestureConfigurator())
            
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
                        // Fixed size Category Icon container
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "FF6B33").opacity(0.15))
                            
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(hex: "FF6B33").opacity(0.3), lineWidth: 1)
                            
                            Image(systemName: clinic.category.systemIcon)
                                .foregroundColor(Color(hex: "FF6B33"))
                                .font(.system(size: 22))
                        }
                        .frame(width: 52, height: 52)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clinic.category.rawValue.uppercased())
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "FF6B33"))
                                .tracking(0.5)
                            
                            Text(clinic.name)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if !clinic.address.isEmpty {
                                Text(clinic.address)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            // Phone Call Action
                            if clinic.phone != "No Phone" {
                                Button(action: {
                                    if let url = URL(string: "tel://\(clinic.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))"),
                                       UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 11))
                                        Text(clinic.phone)
                                            .font(.system(size: 12, design: .rounded))
                                    }
                                    .foregroundColor(Color(hex: "FF6B33"))
                                }
                                .buttonStyle(.plain)
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.slash.fill")
                                        .font(.system(size: 11))
                                    Text("No Phone")
                                        .font(.system(size: 12, design: .rounded))
                                }
                                .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Route Action
                        Button(action: {
                            showingMapsSelector = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .font(.system(size: 18))
                                Text("Route")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "1A1A1A"))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .confirmationDialog(
            "Pilih Aplikasi Peta",
            isPresented: $showingMapsSelector,
            titleVisibility: .visible
        ) {
            Button("Apple Maps") {
                if let clinic = viewModel.selectedClinic {
                    openInAppleMaps(clinic: clinic)
                }
            }
            Button("Google Maps") {
                if let clinic = viewModel.selectedClinic {
                    openInGoogleMaps(clinic: clinic)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            if let clinic = viewModel.selectedClinic {
                Text("Dapatkan rute ke \(clinic.name)")
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.selectedClinic)
        }
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
    
    private func openInAppleMaps(clinic: ClinicModel) {
        if let mapItem = clinic.mapItem {
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } else {
            // Use non-deprecated iOS 26+ API: MKMapItem(location:address:)
            let location = CLLocation(
                latitude: clinic.coordinate.latitude,
                longitude: clinic.coordinate.longitude
            )
            let mapItem = MKMapItem(location: location, address: nil)
            mapItem.name = clinic.name
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
    
    private func openInGoogleMaps(clinic: ClinicModel) {
        let lat = clinic.coordinate.latitude
        let lon = clinic.coordinate.longitude
        let appUrl = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving")!
        let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)&travelmode=driving")!
        
        UIApplication.shared.open(appUrl, options: [:]) { success in
            if !success {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        }
    }
}



// MARK: - Map Gesture Configurator (Forces 2-finger pan recursively on layout updates)
struct MapGestureConfigurator: UIViewRepresentable {
    func makeUIView(context: Context) -> GestureInterceptorView {
        GestureInterceptorView()
    }
    
    func updateUIView(_ uiView: GestureInterceptorView, context: Context) {}
}

class GestureInterceptorView: UIView {
    private weak var parentMapView: MKMapView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if parentMapView == nil {
            parentMapView = findMapView(from: self)
        }
        if let mapView = parentMapView {
            configureGestures(in: mapView)
        }
    }
    
    private func findMapView(from view: UIView) -> MKMapView? {
        if let superview = view.superview, let found = findDescendantMapView(in: superview) {
            return found
        }
        if let window = view.window, let found = findDescendantMapView(in: window) {
            return found
        }
        return nil
    }
    
    private func findDescendantMapView(in view: UIView) -> MKMapView? {
        if let mapView = view as? MKMapView {
            return mapView
        }
        for subview in view.subviews {
            if let found = findDescendantMapView(in: subview) {
                return found
            }
        }
        return nil
    }
    
    private func configureGestures(in view: UIView) {
        if let gestures = view.gestureRecognizers {
            for gesture in gestures {
                if let pan = gesture as? UIPanGestureRecognizer {
                    pan.minimumNumberOfTouches = 2
                    pan.maximumNumberOfTouches = 2
                }
            }
        }
        for subview in view.subviews {
            configureGestures(in: subview)
        }
    }
}
