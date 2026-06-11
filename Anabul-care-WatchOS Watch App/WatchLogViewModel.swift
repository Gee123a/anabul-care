import Foundation

/// ViewModel for WatchLogActivityView.
/// Owns the decision to call WatchConnectivityManager so the View
/// holds no knowledge of the connectivity layer.
/// Haptic feedback (WKInterfaceDevice) stays in the View — it is a
/// presentation-layer concern, not business logic.
@Observable
final class WatchLogViewModel {

    // MARK: - Private State
    private let pet: PetProfile

    // MARK: - Init
    init(pet: PetProfile) {
        self.pet = pet
    }

    // MARK: - Logging

    /// Sends an activity log request to the iPhone via WCSession.
    /// The View calls this when the user taps an activity button.
    func logActivity(type: String) {
        WatchConnectivityManager.shared.sendActivityLogToPhone(
            activityType: type.lowercased(),
            petName: pet.name
        )
        print("WatchLogViewModel: Sent '\(type)' log request to iPhone for \(pet.name).")
    }
}
