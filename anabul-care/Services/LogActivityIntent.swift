//
//  LogActivityIntent.swift
//  anabul-care
//

import AppIntents
import SwiftData
import Foundation
import WidgetKit

public struct LogActivityIntent: AppIntent {
    public static var title: LocalizedStringResource = "Log Pet Activity"
    public static var description = IntentDescription("Log an activity like feeding, walking, or playing for your pet.")

    @Parameter(title: "Pet Name")
    public var petName: String

    @Parameter(title: "Activity Type")
    public var activityType: String // matches LogType raw values

    public init() {}

    public init(petName: String, activityType: String) {
        self.petName = petName
        self.activityType = activityType
    }

    public static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$activityType) for \(\.$petName)")
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // 1. Get the shared model container
        let schema = Schema([
            PetProfile.self,
            ActivityLog.self,
            SpeciesRuleModel.self,
            ToxicityModel.self,
            TidbitModel.self,
            TaskPreference.self,
            TaskDeactivation.self
        ])
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Gee.anabulcare") else {
            return .result(dialog: "Sorry, I couldn't access your pet data right now.")
        }
        let sharedStoreURL = groupURL.appendingPathComponent("anabulcare.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        
        guard let container = try? ModelContainer(for: schema, configurations: [modelConfiguration]) else {
            return .result(dialog: "Sorry, I couldn't access your pet data right now.")
        }
        
        let context = ModelContext(container)
        
        // 2. Find the pet
        let petNameLower = petName.lowercased()
        let descriptor = FetchDescriptor<PetProfile>()
        let allPets = (try? context.fetch(descriptor)) ?? []
        
        guard let pet = allPets.first(where: { $0.name.lowercased() == petNameLower }) else {
            return .result(dialog: "I couldn't find a pet named \(petName).")
        }
        
        // 3. Create and save the log
        let log = ActivityLog(
            timestamp: Date(),
            type: activityType,
            durationMinutes: 0,
            detail: "Logged via Widget/Siri"
        )
        log.pet = pet
        context.insert(log)
        
        do {
            try context.save()
            // Ensure widget reflects the new activity immediately
            WidgetCenter.shared.reloadAllTimelines()
            return .result(dialog: "Successfully logged \(activityType) for \(pet.name)!")
        } catch {
            return .result(dialog: "Failed to save the activity.")
        }
    }
}

// Helper to provide options for the intent
struct PetEntity: AppEntity {
    let id: UUID
    let name: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Pet"
    static var defaultQuery = PetQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct PetQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [PetEntity] {
        // In a real app, you'd fetch from SwiftData here
        return []
    }
    
    func suggestedEntities() async throws -> [PetEntity] {
        // Return recent or all pets
        return []
    }
}
