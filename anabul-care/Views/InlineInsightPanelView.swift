//
//  InlineInsightPanelView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//

import SwiftUI
import SwiftData

struct InlineInsightPanelView: View {
    let targetSpecies: String
    
    // Use a standard query instead of a custom-initialized one to prevent Main Thread deadlocks
    @Query var allTips: [TidbitModel]
    
    // Filter the tips dynamically in memory rather than forcing a synchronous fetch in init
    private var tip: TidbitModel? {
        let speciesLower = targetSpecies.lowercased()
        return allTips.first { $0.speciesTarget == speciesLower }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Eyebrow row
            HStack {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 255/255, green: 140/255, blue: 90/255).opacity(0.16))
                            .frame(width: 22, height: 22)
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 192/255, green: 98/255, blue: 58/255))
                    }
                    
                    Text("FUN FACT")
                        .font(.system(size: 10.5, weight: .bold, design: .rounded))
                        .kerning(1.2)
                        .foregroundColor(Color(red: 192/255, green: 98/255, blue: 58/255))
                }
                
                Spacer()
                
                // Decorative paw badge
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 26, height: 26)
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 0.5))
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 192/255, green: 98/255, blue: 58/255))
                }
            }
            .padding(.bottom, 10)
            
            // Title
            Text(tip?.title ?? "Structured Routines")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 92/255, green: 58/255, blue: 40/255))
                .kerning(-0.3)
                .lineSpacing(0)
                .padding(.bottom, 6)
            
            // Body
            Text(tip?.bodyText ?? "Providing physical stimulus tasks contextually builds emotional security inside indoor spaces.")
                .font(.system(size: 13, weight: .regular, design: .default))
                .foregroundColor(Color(red: 92/255, green: 58/255, blue: 40/255).opacity(0.78))
                .kerning(-0.05)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)
            
            // Footer
            HStack {
                Text("Did you know?")
                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                    .kerning(0.4)
                    .foregroundColor(Color(red: 92/255, green: 58/255, blue: 40/255).opacity(0.55))
                    .textCase(.uppercase)
                
                Spacer()
                
                // Indicator dots
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 192/255, green: 98/255, blue: 58/255).opacity(0.7))
                        .frame(width: 14, height: 4)
                    Circle()
                        .fill(Color(red: 192/255, green: 98/255, blue: 58/255).opacity(0.22))
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(Color(red: 192/255, green: 98/255, blue: 58/255).opacity(0.22))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .background(
            ZStack {
                // Main Gradient Background
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 255/255, green: 235/255, blue: 222/255).opacity(0.55), location: 0),
                        .init(color: Color(red: 255/255, green: 222/205, blue: 205/255).opacity(0.38), location: 0.55),
                        .init(color: Color(red: 255/255, green: 235/255, blue: 222/255).opacity(0.28), location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Decorative ambient glows (Visual approximations of the React glows)
                Circle()
                    .fill(RadialGradient(colors: [.white.opacity(0.55), .clear], center: .center, startRadius: 0, endRadius: 70))
                    .frame(width: 140, height: 140)
                    .offset(x: 100, y: -80)
                
                Circle()
                    .fill(RadialGradient(colors: [Color(red: 255/255, green: 140/255, blue: 90/255).opacity(0.16), .clear], center: .center, startRadius: 0, endRadius: 80))
                    .frame(width: 160, height: 160)
                    .offset(x: -110, y: 90)
            }
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 0.5)
        )
        .shadow(color: Color(red: 160/255, green: 60/255, blue: 20/255).opacity(0.22), radius: 18, x: 0, y: 16)
    }
}
