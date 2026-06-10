import Foundation

/// Enumeration defining the strictly supported companion species.
/// Used for type-safe species-specific logic and data filtering.
public enum PetSpecies: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case hamster = "hamster"
}

/// Enumeration defining the specific operational classes of user activity logging.
/// Standardizes keys used across the database and routine engine.
public enum LogType: String, Codable, CaseIterable {
    case feeding = "feeding"
    case grooming = "grooming"
    case walk = "walk"
    case play = "play"
    case hydration = "hydration"
    case medication = "medication"
}

/// Defines the biological life stage of a pet.
/// Used by the routine engine to adjust task frequency and nutritional needs.
public enum LifeStage: String, Codable, CaseIterable {
    case puppyKitten = "puppyKitten"
    case adult = "adult"
    case senior = "senior"
}
