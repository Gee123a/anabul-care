import XCTest
@testable import anabul_care

final class RoutineGenerationTests: XCTestCase {

    func test_HuskyPuppy_Routine() {
        // Arrange: A 3-month-old Husky (High Energy, Working, Puppy)
        let dob = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let pet = PetProfile(name: "Ghost", species: "dog", breed: "Husky", dateOfBirth: dob, weightKg: 10.0)
        
        // Act
        let tasks = DailyRoutineGenerator.generate(for: pet)
        
        // Assert
        // Should have Lunch Feeding (Puppy modifier)
        XCTAssertTrue(tasks.contains { $0.title == "Lunch Feeding" })
        
        // Should have Vigorous Training instead of Play Time (High Energy modifier)
        XCTAssertTrue(tasks.contains { $0.title == "Vigorous Training" })
        XCTAssertFalse(tasks.contains { $0.title == "Play Time" })
        
        print("Husky Puppy Tasks: \(tasks.map { $0.title })")
    }
    
    func test_PugAdult_Routine() {
        // Arrange: A 4-year-old Pug (Brachycephalic, Low Energy, Adult)
        let dob = Calendar.current.date(byAdding: .year, value: -4, to: Date())!
        let pet = PetProfile(name: "Pudge", species: "dog", breed: "Pug", dateOfBirth: dob, weightKg: 8.0)
        
        // Act
        let tasks = DailyRoutineGenerator.generate(for: pet)
        
        // Assert
        // Should have Light Stroll instead of Morning Walk (Brachycephalic modifier)
        XCTAssertTrue(tasks.contains { $0.title == "Light Stroll" })
        XCTAssertFalse(tasks.contains { $0.title == "Morning Walk" })
        
        // Should NOT have Lunch Feeding (Not a puppy)
        XCTAssertFalse(tasks.contains { $0.title == "Lunch Feeding" })
        
        print("Pug Adult Tasks: \(tasks.map { $0.title })")
    }
    
    func test_SeniorCat_Routine() {
        // Arrange: An 8-year-old Cat (Senior)
        let dob = Calendar.current.date(byAdding: .year, value: -8, to: Date())!
        let pet = PetProfile(name: "Luna", species: "cat", breed: "Persian", dateOfBirth: dob, weightKg: 4.0)
        
        // Act
        let tasks = DailyRoutineGenerator.generate(for: pet)
        
        // Assert
        // Should have Joint Supplement (Senior modifier)
        XCTAssertTrue(tasks.contains { $0.title == "Joint Supplement" })
        
        // Should have Intensive Brushing instead of Coat Brushing (High Grooming/Brachycephalic modifier)
        XCTAssertTrue(tasks.contains { $0.title == "Intensive Brushing" })
        
        print("Senior Cat Tasks: \(tasks.map { $0.title })")
    }

    func test_WeeklyDeepClean_Routine() {
        // Arrange: A Sunday (weekday 1)
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 9 // June 9, 2024 is a Sunday
        let sunday = Calendar.current.date(from: components)!
        
        let pet = PetProfile(name: "Kitty", species: "cat", breed: "Siamese", dateOfBirth: Date(), weightKg: 3.0)
        
        // Act
        let tasks = DailyRoutineGenerator.generate(for: pet, on: sunday)
        
        // Assert
        // Should have Deep Litter Clean instead of regular Litter Scoop
        XCTAssertTrue(tasks.contains { $0.title == "Deep Litter Clean" })
        XCTAssertFalse(tasks.contains { $0.title == "Litter Scoop" })
        
        print("Sunday Cat Tasks: \(tasks.map { $0.title })")
    }
}
