//
//  TodayQueueCardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//

import SwiftUI
import SwiftData
import Combine

struct TodayQueueCardView: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    
    // Generate filtered daily list metrics
    var completedCount: Int {
        pet.activities.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Pane: 30-Day Calendar Strip Math
            VStack(spacing: 12) {
                Text("CALENDAR")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.2)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(25...29, id: \.self) { day in
                            let isToday = day == 28 // Anchored on the May 28, 2026 data handoff timeline
                            VStack {
                                Text("\(day)")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(isToday ? tangerine : .white)
                            }
                            .frame(width: 38, height: 38)
                            .background(isToday ? Color.white : Color.clear)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: isToday ? 0 : 1))
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Tracked completions out of structural targets
                Text("\(completedCount)/6")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .frame(width: 112)
            .background(LinearGradient(colors: [tangerine, tangerine.opacity(0.85)], startPoint: .top, endPoint: .bottom))
            
            // Right Pane: Active Tasks Row Items matching your LogType Enum
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Queue")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        InteractiveQueueRow(pet: pet, type: .feeding, title: "Morning Feeding", detail: "½ cup kibble", icon: "fork.knife", categoryColor: Color(red: 0.84, green: 0.94, blue: 0.88))
                        InteractiveQueueRow(pet: pet, type: .hydration, title: "Refresh Water", detail: "Clean bowl setup", icon: "drop.fill", categoryColor: Color(red: 0.88, green: 0.92, blue: 0.98))
                        InteractiveQueueRow(pet: pet, type: .grooming, title: "Brush Coat", detail: "Check eyes & ears", icon: "scissors", categoryColor: Color(red: 0.99, green: 0.89, blue: 0.80))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.ultraThinMaterial)
        }
        .frame(height: 340)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Color.white.opacity(0.5), lineWidth: 0.5))
    }
}

struct InteractiveQueueRow: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile
    let type: LogType
    let title: String
    let detail: String
    let icon: String
    let categoryColor: Color
    
    var isLogged: Bool {
        pet.activities.contains { $0.type == type.rawValue && Calendar.current.isDateInToday($0.timestamp) }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(categoryColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack(workspace: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .strikethrough(isLogged)
                    .opacity(isLogged ? 0.5 : 1.0)
                Text(detail)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    if isLogged {
                        // Cleanup logic if toggled back
                        if let index = pet.activities.firstIndex(where: { $0.type == type.rawValue && Calendar.current.isDateInToday($0.timestamp) }) {
                            let logToDelete = pet.activities[index]
                            modelContext.delete(logToDelete)
                            pet.activities.remove(at: index)
                        }
                    } else {
                        // Persist activity to SwiftData context securely
                        let newLog = ActivityLog(type: type.rawValue, durationMinutes: 15, detail: detail)
                        newLog.pet = pet
                        modelContext.insert(newLog)
                        pet.activities.append(newLog)
                    }
                }
            }) {
                Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isLogged ? Color(red: 123/255, green: 211/255, blue: 179/255) : .secondary.opacity(0.5)) // #7BD3B3 Success Mint
            }
        }
        .padding(10)
        .background(isLogged ? Color(red: 123/255, green: 211/255, blue: 179/255).opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// Layout text helper
extension VStack {
    init(workspace alignment: HorizontalAlignment, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing, content: content)
    }
}
