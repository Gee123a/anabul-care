import Foundation


public enum PetSpecies: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case hamster = "hamster"
}


public enum LogType: String, Codable, CaseIterable {
    case feeding = "feeding"
    case grooming = "grooming"
    case walk = "walk"
    case play = "play"
    case hydration = "hydration"
}


public enum LifeStage: String, Codable {
    case puppyKitten = "puppyKitten"
    case adult = "adult"
    case senior = "senior"
}
