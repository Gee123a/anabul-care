import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class PetViewModel: ObservableObject {
    @Published var pets: [PetProfile] = []
    
    func addPet(name: String, species: PetSpecies, breed: String, dateOfBirth: Date, weightKg: Double, isNeutered: Bool, in context: ModelContext) {
        let newPet = PetProfile(
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            weightKg: weightKg,
            isNeutered: isNeutered
        )
        context.insert(newPet)
    }
    
    func deletePet(_ pet: PetProfile, in context: ModelContext) {
        context.delete(pet)
    }
    
    func addActivity(to pet: PetProfile, type: LogType, duration: Int, details: String, in context: ModelContext) {
        let newLog = ActivityLog(
            logType: type,
            durationMinutes: duration,
            details: details
        )
        newLog.pet = pet
        pet.activityLogs.append(newLog)
    }
}
