import Foundation

/// Enumeration defining the strictly supported companion species.
public enum PetSpecies: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case hamster = "hamster"
}

/// Enumeration defining the specific operational classes of user activity logging.
public enum LogType: String, Codable, CaseIterable {
    case feeding = "feeding"
    case grooming = "grooming"
    case walk = "walk"
    case play = "play"
    case hydration = "hydration"
}

public enum LifeStage: String, Codable, CaseIterable {
    case puppyKitten = "puppyKitten"
    case adult = "adult"
    case senior = "senior"
}
