import SwiftUI
import MapKit

struct AnimatedMapPin: View {
    let category: POICategory
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Animate the pulsing effect for the map pin background
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var viewModel = RadarViewModel()
    @Binding var selectedTab: Int
    
    @State private var isZoomMenuExpanded = false
    @State private var showingMapsSelector = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // The core MapKit UI component.
            // position binds the viewport to the ViewModel
            // interactionModes specifies what gestures the map allows naturally
            // selection binds to a tapped map pin marker
            Map(position: $viewModel.position, interactionModes: [.pan, .zoom], selection: $viewModel.selectedClinic) {
                
                ForEach(viewModel.filteredClinics) { clinic in
                    // Annotation renders a custom SwiftUI view at a precise CLLocationCoordinate2D
                    Annotation(clinic.name, coordinate: clinic.coordinate) {
                        AnimatedMapPin(category: clinic.category)
                    }
                    .tag(clinic) // The tag is necessary to match the Annotation to the 'selection' binding
                }
                
                // Displays the user's current physical GPS location (the blue dot)
                UserAnnotation()
            }
            // Applies realistic 3D elevation and removes default Apple Map POI clutter (like restaurants/shops)
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll))
            
            // Tracks the camera position constantly while the user is actively dragging the map
            .onMapCameraChange(frequency: .continuous) { context in
                viewModel.currentCenter = context.region.center
                viewModel.currentDistance = context.camera.distance
            }
            
            // Triggers a network search ONLY when the map camera completely stops moving
            .onMapCameraChange(frequency: .onEnd) { context in
                            Task {
                                await viewModel.performSearch(in: context.region)
                            }
                        }
            // Allows the map to stretch behind the top notch and dynamic island
            .ignoresSafeArea()
            
            // Injects custom UIKit gesture recognizers to override default map panning behaviors
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
                    
                    // Toggle Radar / List Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = 0 // Transition back to dashboard
                        }
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF6B33"))
                            .frame(width: 48, height: 48)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)
                
                // CATEGORY SELECTOR CAROUSEL
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(POICategory.allCases, id: \.self) { category in
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    viewModel.selectedCategory = category
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.systemIcon)
                                        .font(.system(size: 13, weight: .bold))
                                    Text(category.rawValue.capitalized)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedCategory == category ? Color(hex: "FF6B33") : Color.white)
                                .foregroundColor(viewModel.selectedCategory == category ? .white : Color(hex: "1C1C1A"))
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // FLOATING ZOOM BUTTONS (replaces standard controls, moves up when bottom sheet displays)
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Expandable Zoom Menu Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isZoomMenuExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B33"))
                                .frame(width: 52, height: 52)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                        }
                        
                        // Expanded Zoom controls
                        if isZoomMenuExpanded {
                            VStack(spacing: 8) {
                                Button(action: { viewModel.zoomIn() }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "1C1C1A"))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: { viewModel.zoomOut() }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "1C1C1A"))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale),
                                removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale)
                            ))
                        }
                        
                        // Recenter user GPS position button
                        Button(action: {
                            viewModel.position = .userLocation(fallback: .automatic)
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .frame(width: 52, height: 52)
                                .background(Color(hex: "1C1C1A"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                
                if let clinic = viewModel.selectedClinic {
                    HStack {
                        if horizontalSizeClass == .regular { Spacer() }
                        
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
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 450 : .infinity)
                        
                        if horizontalSizeClass == .regular { Spacer() }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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
                    viewModel.openInAppleMaps(clinic: clinic)
                }
            }
            Button("Google Maps") {
                if let clinic = viewModel.selectedClinic {
                    viewModel.openInGoogleMaps(clinic: clinic)
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
        // Recursively digs through the UI hierarchy to find the underlying MKMapView native layer
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
        // Forces the underlying MapKit pan gesture to require exactly 2 fingers, leaving 1-finger gestures for the TabView
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
