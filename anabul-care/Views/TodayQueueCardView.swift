//
//  TodayQueueCardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 28/05/26.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TodayQueueCardView: View {
    @State private var viewModel: RoutineViewModel
    private let modelContext: ModelContext
    @Environment(\.scenePhase) private var scenePhase
    
    init(pet: PetProfile, modelContext: ModelContext) {
        self.modelContext = modelContext
        let repository = PetRepository(context: modelContext)
        _viewModel = State(initialValue: RoutineViewModel(pet: pet, repository: repository, modelContext: modelContext))
    }
    
    // Design Tokens
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255) // #FF6B33
    private let mint = Color(red: 123/255, green: 211/255, blue: 179/255) // #7BD3B3
    private let profoundAccent = Color(red: 32/255, green: 32/255, blue: 34/255) // Deep, profound dark color
    
    @State private var taskToEdit: DailyTaskItem?
    
    // Date Helpers
    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var list: [Date] = []
        for offset in -15...15 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                list.append(date)
            }
        }
        return list
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Vertical Date Strip
            dateStrip
            
            // Right: Event List
            eventList
        }
        .frame(height: 340)
        .background(
            Color.white.opacity(0.72)
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 36, x: 0, y: 16)
        .sheet(item: $taskToEdit) { task in
            EditTaskTimeView(pet: viewModel.pet, task: task, date: viewModel.selectedDate, modelContext: modelContext)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.refreshActivities()
            }
        }
    }
    
    @ViewBuilder
    private var dateStrip: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CALENDAR")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .kerning(0.6)
                    .foregroundColor(profoundAccent)
                    .textCase(.uppercase)
                
                Text(viewModel.monthYearString)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(tangerine)
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(days, id: \.self) { date in
                            DateButton(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate), isToday: Calendar.current.isDateInToday(date)) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectDate(date)
                                }
                            }
                            .id(date)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                .onAppear {
                    // Delay slightly to ensure layout is ready before scrolling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
                        }
                    }
                }
            }
            
            // Completion Stats
            HStack(spacing: 4) {
                Circle()
                    .fill(mint)
                    .frame(width: 6, height: 6)
                Text("\(viewModel.completedCount(for: viewModel.selectedDate))/\(viewModel.dailyTasks.count)")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(6)
            .background(Color.white.opacity(0.7))
            .clipShape(Capsule())
            .padding(.bottom, 12)
        }
        .frame(width: 112)
        .background(
            LinearGradient(
                stops: [
                    .init(color: tangerine.opacity(0.10), location: 0),
                    .init(color: tangerine.opacity(0.02), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        )
    }
    
    @ViewBuilder
    private var eventList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Calendar.current.isDateInToday(viewModel.selectedDate) ? "Today's Queue" : viewModel.longDateString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .kerning(-0.2)
                
                Spacer()
                
                Text("\(viewModel.dailyTasks.count) items")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(viewModel.dailyTasks) { task in
                        QueueRow(viewModel: viewModel, task: task) {
                            taskToEdit = task
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let profoundAccent = Color(red: 32/255, green: 32/255, blue: 34/255)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(weekdayString(for: date))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .kerning(0.4)
                    .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary.opacity(0.8))
                    .frame(width: 24, alignment: .leading)
                    .textCase(.uppercase)
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 17, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .kerning(-0.3)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                // Dot indicator for tasks
                Circle()
                    .fill(isSelected ? .white.opacity(0.9) : tangerine)
                    .frame(width: 6, height: 6)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? profoundAccent : isToday ? tangerine.opacity(0.12) : Color.white.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : isToday ? tangerine.opacity(0.35) : Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }
    
    private func weekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct QueueRow: View {
    @Bindable var viewModel: RoutineViewModel
    let task: DailyTaskItem
    var onEdit: () -> Void
    
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let mint = Color(red: 123/255, green: 211/255, blue: 179/255)
    
    var isLogged: Bool {
        viewModel.isTaskCompleted(task, on: viewModel.selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isLogged ? mint.opacity(0.18) : tangerine.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: task.icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isLogged ? mint : tangerine)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 1) {
                Text(task.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .strikethrough(isLogged)
                    .opacity(isLogged ? 0.55 : 1)
                
                Text("\(task.timeRecommendation) · \(task.detail)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
                    .opacity(isLogged ? 0.55 : 1)
            }
            
            Spacer()
            
            // Checkmark Visual (Not a button anymore)
            ZStack {
                Circle()
                    .stroke(isLogged ? Color.clear : Color.black.opacity(0.28), lineWidth: 1.5)
                    .frame(width: 26, height: 26)
                
                if isLogged {
                    Circle()
                        .fill(mint)
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(8)
        .contentShape(Rectangle()) // Make the whole row tappable
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isLogged ? mint.opacity(0.12) : Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                viewModel.toggleTask(task, on: viewModel.selectedDate)
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onEdit()
        }
    }
}
