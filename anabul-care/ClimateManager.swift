import Foundation
import WeatherKit
import UserNotifications
import SwiftData

class ClimateManager {
    static let shared = ClimateManager()
    private let weatherService = WeatherService.shared
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkClimate(for pets: [PetProfile]) async {
        guard let location = LocationManager.shared.lastLocation else { return }
        
        do {
            let weather = try await weatherService.weather(for: location)
            let currentTemp = weather.currentWeather.temperature.converted(to: .celsius).value
            
            for pet in pets {
                evaluateThreshold(for: pet, temperature: currentTemp)
            }
        } catch {
            print("Weather fetch error: \(error.localizedDescription)")
        }
    }
    
    private func evaluateThreshold(for pet: PetProfile, temperature: Double) {
        let isCritical: Bool
        let threshold: Double
        
        switch pet.species {
        case .dog, .cat:
            threshold = 34.0
            isCritical = temperature >= threshold
        case .hamster:
            threshold = 26.0
            isCritical = temperature >= threshold
        }
        
        if isCritical {
            sendAlert(for: pet, temperature: temperature)
        }
    }
    
    private func sendAlert(for pet: PetProfile, temperature: Double) {
        let content = UNMutableNotificationContent()
        
        if pet.species == .hamster {
            content.title = "Peringatan Stres Panas Hamster!"
            content.body = "Suhu ruangan terdeteksi kritis (\(Int(temperature))°C). Segera nyalakan pendingin atau pindahkan \(pet.name) ke area sejuk."
            content.interruptionLevel = .critical
        } else {
            content.title = "Periksa Air Minum \(pet.name)!"
            content.body = "Suhu sekitar mencapai \(Int(temperature))°C. Pastikan wadah air minum terisi penuh."
            content.interruptionLevel = .timeSensitive
        }
        
        content.sound = .defaultCritical
        
        let request = UNNotificationRequest(
            identifier: "climate_alert_\(pet.id.uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// Simple Location Manager
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }
}
