//
//  Anabul_careWidget.swift
//  Anabul-careWidget
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: AppIntentTimelineProvider {
    
    // Shared container configuration (exactly same as main app)
    private var container: ModelContainer? {
        let schema = Schema([PetProfile.self, ActivityLog.self, SpeciesRuleModel.self, ToxicityModel.self, TidbitModel.self])
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare")!
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        
        return try? ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), petName: "Luna", completedCount: 2, totalCount: 6, species: "cat")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let petData = await fetchCurrentPetData()
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            petName: petData.name,
            completedCount: petData.completed,
            totalCount: petData.total,
            species: petData.species
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let petData = await fetchCurrentPetData()
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            petName: petData.name,
            completedCount: petData.completed,
            totalCount: petData.total,
            species: petData.species
        )
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    @MainActor
    private func fetchCurrentPetData() async -> (name: String, completed: Int, total: Int, species: String) {
        guard let container = container else { return ("No Pet", 0, 0, "cat") }
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<PetProfile>()
        let pets = (try? context.fetch(descriptor)) ?? []
        
        guard let pet = pets.first else { return ("Add Pet", 0, 0, "cat") }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Use a basic mock logic if DailyRoutineGenerator isn't available to the widget target
        // (Usually you'd add the service file to the target membership)
        let total = 6 
        let completed = pet.activities.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }.count
        
        return (pet.name, completed, total, pet.species)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
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
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(tangerine)
                            .frame(width: geo.size.width * CGFloat(Double(entry.completedCount) / Double(max(entry.totalCount, 1))), height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            Spacer()
            
            // Interactive Button
            Button(
                intent: LogActivityIntent(
                    petName: IntentParameter(
                        title: .init(stringLiteral: entry.petName)
                    ),
                    activityType: IntentParameter(title: .init("feeding"))
                )
            ) {
                Label("Log Feed", systemImage: "fork.knife")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(tangerine)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding()
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
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Anabul_careWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.98, green: 0.98, blue: 0.97), for: .widget)
        }
        .configurationDisplayName("Anabul Status")
        .description("Track your pet's daily progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    Anabul_careWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), petName: "Luna", completedCount: 3, totalCount: 6, species: "cat")
}

