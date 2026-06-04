import Foundation
import WeatherKit
import UserNotifications
import SwiftData
import BackgroundTasks
import CoreLocation


class ClimateManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ClimateManager()
    static let backgroundTaskId = "com.anabulcare.climateCheck"
    private let weatherService = WeatherService.shared
    
    private override init() {
        super.init()

        DispatchQueue.main.async {
            UNUserNotificationCenter.current().delegate = self
            print("ClimateManager: Notification delegate set.")
        }
    }
    
    // Allow notifications to show even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("ClimateManager: Notification will present in foreground: \(notification.request.content.title)")
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func registerBackgroundTask(modelContainer: ModelContainer) {
        print("ClimateManager: Registering background task: \(Self.backgroundTaskId)")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundTaskId, using: nil) { task in
            // Bridge to async handler
            Task {
                await self.handleBackgroundTask(task: task as! BGAppRefreshTask, modelContainer: modelContainer)
            }
        }
    }
    
    func scheduleNextCheck() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("ClimateManager: Successfully scheduled next background check.")
        } catch {
            print("ClimateManager: Could not schedule background task: \(error)")
        }
    }
    
    private func handleBackgroundTask(task: BGAppRefreshTask, modelContainer: ModelContainer) async {
        print("ClimateManager: Handling background task execution...")
        scheduleNextCheck()
        
        task.expirationHandler = {
            print("ClimateManager: Background task expired by system.")
        }
        
        let taskContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<PetProfile>()
        
        do {
            let pets = try taskContext.fetch(descriptor)
            let petData = pets.map { (id: $0.id, name: $0.name, species: $0.petSpecies) }
            await self.checkClimate(for: petData)
            task.setTaskCompleted(success: true)
        } catch {
            print("ClimateManager: Background fetch error: \(error)")
            task.setTaskCompleted(success: false)
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, error in
            if granted {
                print("ClimateManager: Notification permission granted.")
            } else if let error = error {
                print("ClimateManager: Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkClimate(for pets: [(id: UUID, name: String, species: PetSpecies)]) async {
        guard let location = await LocationManager.shared.getLocation() else {
            print("ClimateManager: Location not available, skipping weather check.")
            return
        }
        
        do {
            let weather = try await weatherService.weather(for: location)
            let currentTemp = weather.currentWeather.temperature.converted(to: .celsius).value
            print("ClimateManager: Weather fetched. Current temp: \(currentTemp)°C")
            
            for pet in pets {
                evaluateThreshold(name: pet.name, species: pet.species, id: pet.id, temperature: currentTemp)
            }
        } catch {
            print("ClimateManager: Weather fetch error: \(error.localizedDescription)")
        }
    }
    
    private func evaluateThreshold(name: String, species: PetSpecies, id: UUID, temperature: Double) {
        let threshold: Double
        switch species {
        case .dog, .cat: threshold = 34.0
        case .hamster: threshold = 26.0
        }
        
        if temperature >= threshold {
            print("ClimateManager: Threshold EXCEEDED for \(name) (\(temperature)°C >= \(threshold)°C)")
            sendAlert(name: name, species: species, id: id, temperature: temperature)
        } else {
            print("ClimateManager: Threshold safe for \(name) (\(temperature)°C < \(threshold)°C)")
        }
    }
    
    private func sendAlert(name: String, species: PetSpecies, id: UUID, temperature: Double) {
        print("ClimateManager: Preparing notification for \(name)...")
        let content = UNMutableNotificationContent()
        
        if species == .hamster {
            content.title = "Peringatan Stres Panas Hamster!"
            content.body = "Suhu ruangan terdeteksi kritis (\(Int(temperature))°C). Segera nyalakan pendingin atau pindahkan \(name) ke area sejuk."
            content.interruptionLevel = .critical
        } else {
            content.title = "Periksa Air Minum \(name)!"
            content.body = "Suhu sekitar mencapai \(Int(temperature))°C. Pastikan wadah air minum terisi penuh."
            content.interruptionLevel = .timeSensitive
        }
        
        content.sound = .defaultCritical
        
        // Use a unique identifier including timestamp to ensure delivery if triggered multiple times
        let request = UNNotificationRequest(
            identifier: "climate_alert_\(id.uuidString)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("ClimateManager: Notification error: \(error.localizedDescription)")
            } else {
                print("ClimateManager: Notification successfully delivered to system.")
            }
        }
    }
    
    func triggerTestNotification() {
        print("ClimateManager: Manually triggering test notification...")
        sendAlert(name: "Anabul (Test)", species: .dog, id: UUID(), temperature: 38.0)
    }
}

// Thread-safe Location Manager
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
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
    
    func getLocation() async -> CLLocation? {
        if let location = lastLocation { return location }
        
        return await withCheckedContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
        locationContinuation?.resume(returning: locations.first)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager: Location error: \(error.localizedDescription)")
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
}
