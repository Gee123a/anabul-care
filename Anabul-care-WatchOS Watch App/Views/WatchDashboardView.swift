//
//  WatchDashboardView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//

import SwiftUI
import SwiftData

// MARK: - View 1: Today's Dashboard
struct WatchDashboardView: View {

    @State private var viewModel: WatchDashboardViewModel

    init(pet: PetProfile) {
        _viewModel = State(initialValue: WatchDashboardViewModel(pet: pet))
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.dailyTasks.isEmpty {
                    Text("No tasks scheduled for today!")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.dailyTasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.system(.body, design: .rounded, weight: .medium))

                                Text(task.timeRecommendation)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            Spacer()

                            if viewModel.isTaskCompleted(task) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Today's Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
