import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {


    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self
        ])
        

        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare")!
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Widget: Could not create ModelContainer: \(error)")

            return try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
        }
    }()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), petName: "Luna", completedCount: 3, totalCount: 5, species: "cat")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {

        Task { @MainActor in
            let entry = fetchRealData(for: Date()) ?? SimpleEntry(date: Date(), petName: "No Pet", completedCount: 0, totalCount: 0, species: "cat")
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            let date = Date()
            let entry = fetchRealData(for: date) ?? SimpleEntry(date: date, petName: "No Pet", completedCount: 0, totalCount: 0, species: "cat")
            

            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    // This function bridges the SwiftData database into Widget data
    @MainActor
    private func fetchRealData(for date: Date) -> SimpleEntry? {
        let context = ModelContext(sharedModelContainer)
        let descriptor = FetchDescriptor<PetProfile>(sortBy: [SortDescriptor(\.name)])
        
        do {
            let pets = try context.fetch(descriptor)
            
            // If no pets found, return nil to trigger the "No Pet" state
            guard let firstPet = pets.first else {
                print("Widget: No pets found in database.")
                return nil
            }
            
            // Use the same generator as the Dashboard View
            let routine = DailyRoutineGenerator.generate(for: firstPet)
            let totalCount = routine.count
            
            // Count matching activities logged today
            // FETCH DIRECTLY from ActivityLog to ensure we catch the latest saves
            let startOfDay = Calendar.current.startOfDay(for: date)
            let activityDescriptor = FetchDescriptor<ActivityLog>(
                predicate: #Predicate<ActivityLog> { log in
                    log.timestamp >= startOfDay
                }
            )
            let allTodayLogs = (try? context.fetch(activityDescriptor)) ?? []
            
            // Filter logs for this specific pet and routine types
            let completedCount = routine.filter { task in
                allTodayLogs.contains { log in 
                    log.pet?.id == firstPet.id && log.type == task.type.rawValue
                }
            }.count
            
            print("Widget: Fetched data for \(firstPet.name) - \(completedCount)/\(totalCount)")
            
            return SimpleEntry(
                date: date,
                petName: firstPet.name,
                completedCount: completedCount,
                totalCount: totalCount,
                species: firstPet.species
            )
        } catch {
            print("Widget: Fetch error: \(error)")
            return nil
        }
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
            // Header: Pet Info
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tangerine.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: speciesIcon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(tangerine)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.petName)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Text("DAILY PROGRESS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .kerning(0.5)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Progress Section
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .bottom) {
                    Text("\(entry.completedCount)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        + Text("/\(entry.totalCount)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(entry.totalCount > 0 ? "\(Int(Double(entry.completedCount)/Double(entry.totalCount)*100))%" : "0%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(tangerine)
                }
                
                // Real Dynamic Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(tangerine)
                            .frame(width: progressWidth(in: geometry.size.width), height: 10)
                    }
                }
                .frame(height: 10)
            }
            
            Spacer()
            
            // Visual Prompt
            Text("Log Activity")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(tangerine)
                .clipShape(Capsule())
                .shadow(color: tangerine.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        guard entry.totalCount > 0 else { return 0 }
        let percentage = CGFloat(entry.completedCount) / CGFloat(entry.totalCount)
        return totalWidth * min(percentage, 1.0)
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
        .configurationDisplayName("Pet Status")
        .description("Monitor your companion's daily routine.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
