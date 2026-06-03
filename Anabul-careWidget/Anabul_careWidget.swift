//
//  Anabul_careWidget.swift
//  Anabul-careWidget
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), petName: "Luna", completedCount: 3, totalCount: 6, species: "cat")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), petName: "Luna", completedCount: 3, totalCount: 6, species: "cat")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), petName: "Luna", completedCount: 3, totalCount: 6, species: "cat")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let petName: String
    let completedCount: Int
    let totalCount: Int
    let species: String
}

struct Anabul_careWidgetEntryView : View {
    var entry: Provider.Entry
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(tangerine.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: speciesIcon)
                        .font(.system(size: 14))
                        .foregroundColor(tangerine)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.petName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("Today's Progress")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.completedCount)/\(entry.totalCount) tasks")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(tangerine)
                        .frame(width: 80, height: 80) // Mock fixed width for test
                        .frame(width: 100, height: 8)
                }
                .frame(height: 8)
            }
            
            Spacer()
            
            Text("Log activity in app")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(tangerine)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
    
    private var speciesIcon: String {
        switch entry.species.lowercased() {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "hamster": return "hare.fill"
        default: return "pawprint.fill"
        }
    }
}

struct Anabul_careWidget: Widget {
    let kind: String = "Anabul_careWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Anabul_careWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.98, green: 0.98, blue: 0.97), for: .widget)
        }
        .configurationDisplayName("Anabul Status")
        .description("Track your pet's daily progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
