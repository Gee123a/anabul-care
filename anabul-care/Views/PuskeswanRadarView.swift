import SwiftUI
import MapKit

struct PuskeswanRadarView: View {
    @StateObject private var viewModel = RadarViewModel()
    @State private var currentColorIndex = 0
    let interchangingColors: [Color] = [.blue, .green, .orange, .purple, .red]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map as full background
                Map(position: $viewModel.position, selection: $viewModel.selectedClinic) {
                    ForEach(viewModel.clinics) { clinic in
                        Annotation(clinic.name, coordinate: clinic.coordinate) {
                            Circle()
                                .fill(Color(hex: "FF6B33"))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(radius: 3)
                        }
                        .tag(clinic)
                    }
                    UserAnnotation()
                }
                .edgesIgnoringSafeArea(.all)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        // Color-changing button
                        Button(action: {
                            currentColorIndex = (currentColorIndex + 1) % interchangingColors.count
                        }) {
                            Text("Refresh")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(interchangingColors[currentColorIndex])
                                .clipShape(Capsule())
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 16) // Spacing from top of screen
                    
                    TextField("Cari Klinik", text: $viewModel.searchText)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                        .padding(.top, 10) // Spacing from button row
                    
                    Spacer() // Push elements up/down
                }
                .padding(.top, 50) // Adjust overall top spacing for controls
                
                VStack {
                    Spacer()
                    if let clinic = viewModel.selectedClinic {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(clinic.name)
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(clinic.address)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                            Text("Buka: \(clinic.operatingHours)")
                                .font(.caption)
                                .foregroundColor(Color(hex: "FF6B33")) // Highlight operating hours
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding()
                        .padding(.bottom, 16) // Specific bottom spacing for result card
                    }
                }
            }
            .navigationTitle("Radar")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadClinics()
            }
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
