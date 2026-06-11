//
//  WatchLogActivityView.swift
//  anabul-care
//
//  Created by Nicholas Gerwin Mawardji on 11/06/26.
//

import SwiftUI
import WatchKit

struct WatchLogActivityView: View {

    @State private var viewModel: WatchLogViewModel

    // Activity definitions are UI data — correctly live in the View
    private let activities: [(type: String, icon: String, color: Color)] = [
        (type: "feeding",    icon: "fork.knife",  color: .orange),
        (type: "hydration",  icon: "drop.fill",      color: .blue),
        (type: "walk",       icon: "figure.walk",    color: .green),
        (type: "medication", icon: "pills.fill",     color: .red)
    ]

    init(pet: PetProfile) {
        _viewModel = State(initialValue: WatchLogViewModel(pet: pet))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(activities, id: \.type) { activity in
                    Button {
                        // Business logic lives in ViewModel; haptic is UI-layer
                        viewModel.logActivity(type: activity.type)
                        WKInterfaceDevice.current().play(.success)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: activity.icon)
                                .font(.title3)
                                .foregroundColor(activity.color)
                                .frame(width: 24)

                            Text(activity.type.capitalized)
                                .font(.system(.body, design: .rounded, weight: .medium))

                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Log Action")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
