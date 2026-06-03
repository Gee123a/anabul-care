import Foundation
import WeatherKit
import UserNotifications
import SwiftData
import BackgroundTasks

class ClimateManager {
    static let shared = ClimateManager()
    static let backgroundTaskId = "com.anabulcare.climateCheck"
    private let weatherService = WeatherService.shared
    
    private init() {}
    
    func registerBackgroundTask(modelContainer: ModelContainer) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundTaskId, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask, modelContainer: modelContainer)
        }
    }
    
    func scheduleNextCheck() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Check every 15 mins
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func handleBackgroundTask(task: BGAppRefreshTask, modelContainer: ModelContainer) {
        scheduleNextCheck()
        
        let descriptor = FetchDescriptor<PetProfile>()
        
        task.expirationHandler = {
            // Cleanup logic if needed
        }
        
        Task.detached(priority: .background) {
            let taskContext = ModelContext(modelContainer)
            let pets = (try? taskContext.fetch(descriptor)) ?? []
            await self.checkClimate(for: pets)
            task.setTaskCompleted(success: true)
        }
    }
    
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
        
        switch pet.petSpecies {
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
        
        if pet.petSpecies == .hamster {
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
