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
    
    // Dynamic query matching the active pet species profile context
    @Query var tipModels: [TidbitModel]
    
    init(targetSpecies: String) {
        self.targetSpecies = targetSpecies
        let speciesLower = targetSpecies.lowercased()
        _tipModels = Query(filter: #Predicate<TidbitModel> { $0.speciesTarget == speciesLower })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("FUN FACT")
                        .tracking(1.0)
                }
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 255/255, green: 107/255, blue: 51/255))
                
                Spacer()
                Image(systemName: "pawprint.circle.fill")
                    .foregroundColor(Color(red: 255/255, green: 107/255, blue: 51/255).opacity(0.2))
            }
            
            // Fallback gracefully onto core database content
            Text(tipModels.first?.title ?? "Structured Routines")
                .font(.system(size: 17, weight: .bold, design: .rounded))
            
            Text(tipModels.first?.bodyText ?? "Providing physical stimulus tasks contextually builds emotional security inside indoor spaces. Try to align tasks inside the queue tracker.")
                .font(.system(size: 13.5, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text(tipModels.first?.citation ?? "Anabul Care, 2026")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary) // Changed to standard .secondary or .primary.opacity(0.55)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color(red: 255/255, green: 107/255, blue: 51/255)).frame(width: 6, height: 6)
                    Circle().fill(Color.secondary.opacity(0.3)).frame(width: 6, height: 6)
                    Circle().fill(Color.secondary.opacity(0.3)).frame(width: 6, height: 6)
                }
            }
        }
        .padding(16)
        .background(LinearGradient(colors: [Color(red: 252/255, green: 226/255, blue: 205/255).opacity(0.4), Color.white.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.5), lineWidth: 0.5))
    }
}
