//
//  Anabul_careWidget.swift
//  Anabul-careWidget
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

@MainActor
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            petName: "Luna",
            completedCount: 3,
            totalCount: 6,
            species: "cat",
            nextTaskName: "Morning Feeding",
            nextTaskType: "feeding",
            nextTaskIcon: "fork.knife"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchLatestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchLatestEntry()
        // Refresh every 15 minutes to stay updated
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchLatestEntry() -> SimpleEntry {
        let context = ModelContext(Anabul_careWidget.sharedModelContainer)
        let petDescriptor = FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)])
        
        do {
            let pets = try context.fetch(petDescriptor)
            if let pet = pets.first {
                let today = Date()
                let petID = pet.id
                
                // Fetch preferences
                let prefDescriptor = FetchDescriptor<TaskPreference>(
                    predicate: #Predicate<TaskPreference> { $0.petID == petID }
                )
                let preferences = (try? context.fetch(prefDescriptor)) ?? []
                
                // Fetch deactivations
                let deactDescriptor = FetchDescriptor<TaskDeactivation>(
                    predicate: #Predicate<TaskDeactivation> { $0.petID == petID }
                )
                let deactivations = (try? context.fetch(deactDescriptor)) ?? []
                
                // Generate today's tasks
                let tasks = DailyRoutineGenerator.generate(
                    for: pet,
                    on: today,
                    preferences: preferences,
                    deactivations: deactivations
                )
                
                let totalCount = tasks.count
                let completedCount = tasks.filter { task in
                    pet.activities.contains { activity in
                        activity.type == task.type.rawValue && Calendar.current.isDate(activity.timestamp, inSameDayAs: today)
                    }
                }.count
                
                let uncompletedTasks = tasks.filter { task in
                    !pet.activities.contains { activity in
                        activity.type == task.type.rawValue && Calendar.current.isDate(activity.timestamp, inSameDayAs: today)
                    }
                }
                
                let nextTaskName = uncompletedTasks.first?.title
                let nextTaskType = uncompletedTasks.first?.type.rawValue
                let nextTaskIcon = uncompletedTasks.first?.icon
                
                return SimpleEntry(
                    date: today,
                    petName: pet.name,
                    completedCount: completedCount,
                    totalCount: totalCount,
                    species: pet.species,
                    nextTaskName: nextTaskName,
                    nextTaskType: nextTaskType,
                    nextTaskIcon: nextTaskIcon
                )
            }
        } catch {
            print("Widget failed to fetch pets: \(error)")
        }
        
        // Default fallback placeholder if no pets exist in the database yet
        return SimpleEntry(
            date: Date(),
            petName: "Luna",
            completedCount: 3,
            totalCount: 6,
            species: "cat",
            nextTaskName: "Morning Feeding",
            nextTaskType: "feeding",
            nextTaskIcon: "fork.knife"
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let petName: String
    let completedCount: Int
    let totalCount: Int
    let species: String
    let nextTaskName: String?
    let nextTaskType: String?
    let nextTaskIcon: String?
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
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(tangerine)
                            .frame(width: geometry.size.width * CGFloat(progressFraction), height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            Spacer()
            
            if let taskName = entry.nextTaskName, let taskType = entry.nextTaskType {
                Button(intent: LogActivityIntent(petName: entry.petName, activityType: taskType)) {
                    HStack(spacing: 4) {
                        if let icon = entry.nextTaskIcon {
                            Image(systemName: icon)
                                .font(.system(size: 10))
                        }
                        Text("Log \(taskName)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(tangerine)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Text("All Done! 🐾")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.secondary)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var progressFraction: Double {
        guard entry.totalCount > 0 else { return 0.0 }
        return Double(entry.completedCount) / Double(entry.totalCount)
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
    
    // Shared container configuration to read data from the main app
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
            TaskPreference.self,
            TaskDeactivation.self,
        ])
        
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare") {
            let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
            let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                print("Failed to initialize shared ModelContainer: \(error)")
            }
        } else {
            print("App Group container URL not available")
        }

        // Fallback to in-memory store so that the widget does not crash during gallery discovery
        do {
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [fallbackConfig])
        } catch {
            fatalError("Could not create fallback ModelContainer: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Anabul_careWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.98, green: 0.98, blue: 0.97), for: .widget)
                .modelContainer(Self.sharedModelContainer) // Inject the container
        }
        .configurationDisplayName("Anabul Status")
        .description("Track your pet's daily progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
