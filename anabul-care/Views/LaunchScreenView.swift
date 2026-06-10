//
//  LaunchScreenView.swift
//  anabul-care
//

import SwiftUI

struct LaunchScreenView: View {
    private let brand = Color(red: 255/255, green: 107/255, blue: 51/255)

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(brand.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 52))
                    .foregroundColor(brand)
            }
            VStack(spacing: 8) {
                Text("ANABUL CARE")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .tracking(2.0)
                Text("Preparing your workspace...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            ProgressView()
                .tint(brand)
                .scaleEffect(1.2)
            Spacer()
            Spacer()
        }
    }
}
