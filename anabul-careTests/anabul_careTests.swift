import XCTest
import SwiftData
@testable import anabul_care

final class anabul_careTests: XCTestCase {
    
    // MARK: - MetabolismEngine Tests
    
    func testRERCalculation() {
        // Dog/Cat: 70 * (weight)^0.75
        let dogRER = MetabolismEngine.calculateRER(weightKg: 10, species: .dog)
        XCTAssertEqual(dogRER, 70 * pow(10, 0.75), accuracy: 0.01)
        
        // Hamster: 145 * (weight)^0.75
        let hamsterRER = MetabolismEngine.calculateRER(weightKg: 0.1, species: .hamster)
        XCTAssertEqual(hamsterRER, 145 * pow(0.1, 0.75), accuracy: 0.01)
    }
    
    func testMERCalculationForDog() {
        let dob = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let pet = PetProfile(name: "Rex", species: .dog, breed: "Lab", dateOfBirth: dob, weightKg: 20, isNeutered: true)
        
        let rer = pet.rer
        let mer = pet.dailyTargetCalories
        
        // Neutered Adult Dog: RER * 1.6
        XCTAssertEqual(mer, rer * 1.6, accuracy: 0.01)
    }
    
    func testMERCalculationForPuppy() {
        let dob = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let pet = PetProfile(name: "Puppy", species: .dog, breed: "Golden", dateOfBirth: dob, weightKg: 10, isNeutered: false)
        
        let rer = pet.rer
        let mer = pet.dailyTargetCalories
        
        // Puppy < 12 Months: RER * 3.0
        XCTAssertEqual(mer, rer * 3.0, accuracy: 0.01)
    }
    
    func testMERCalculationForHamster() {
        let dob = Calendar.current.date(byAdding: .month, value: -8, to: Date())!
        let pet = PetProfile(name: "Hamtaro", species: .hamster, breed: "Syrian", dateOfBirth: dob, weightKg: 0.1, isNeutered: false)
        
        let rer = pet.rer
        let mer = pet.dailyTargetCalories
        
        // Standard Maintenance Hamster (> 6 Months): RER * 1.0
        XCTAssertEqual(mer, rer * 1.0, accuracy: 0.01)
    }

    // MARK: - ToxicityViewModel Tests
    
    @MainActor
    func testToxicityFiltering() {
        let viewModel = ToxicityViewModel()
        let hazard1 = ToxicityModel(keyword: "Bawang", dangerLevel: "High", alternative: "None")
        let hazard2 = ToxicityModel(keyword: "Cokelat", dangerLevel: "Critical", alternative: "None")
        let hazards = [hazard1, hazard2]
        
        viewModel.searchText = "Baw"
        let filtered = viewModel.filterHazards(hazards)
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.keyword, "Bawang")
    }
    
    @MainActor
    func testToxicityEmptySearch() {
        let viewModel = ToxicityViewModel()
        let hazards = [ToxicityModel(keyword: "Bawang", dangerLevel: "High", alternative: "None")]
        
        viewModel.searchText = ""
        let filtered = viewModel.filterHazards(hazards)
        
        XCTAssertEqual(filtered.count, 1)
    }

    // MARK: - PetViewModel Tests (SwiftData)
    
    @MainActor
    func testAddPet() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PetProfile.self, ActivityLog.self, configurations: config)
        let context = container.mainContext
        let viewModel = PetViewModel()
        
        viewModel.addPet(
            name: "Test Pet",
            species: .dog,
            breed: "Test Breed",
            dateOfBirth: Date(),
            weightKg: 5.0,
            isNeutered: false,
            in: context
        )
        
        let descriptor = FetchDescriptor<PetProfile>()
        let pets = try context.fetch(descriptor)
        
        XCTAssertEqual(pets.count, 1)
        XCTAssertEqual(pets.first?.name, "Test Pet")
    }
    
    @MainActor
    func testAddActivity() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PetProfile.self, ActivityLog.self, configurations: config)
        let context = container.mainContext
        let viewModel = PetViewModel()
        
        let pet = PetProfile(name: "Test", species: .cat, breed: "Mixed", dateOfBirth: Date(), weightKg: 4.0)
        context.insert(pet)
        
        viewModel.addActivity(
            to: pet,
            type: .feeding,
            duration: 0,
            details: "Lunch",
            in: context
        )
        
        XCTAssertEqual(pet.activityLogs.count, 1)
        XCTAssertEqual(pet.activityLogs.first?.logType, .feeding)
    }
}
