import SwiftUI
import SwiftData

struct PetProfileView: View {
    let pet: PetProfile
    
    // Design Tokens
    private let tangerine = Color(red: 255/255, green: 107/255, blue: 51/255)
    private let bgApp = Color(red: 0.98, green: 0.98, blue: 0.97)
    private let textGray = Color(red: 138/255, green: 138/255, blue: 133/255)
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                
                // 1. GLOWING HEADER
                VStack(spacing: 16) {
                    ZStack {
                        // Ambient Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [tangerine.opacity(0.15), .clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 20)
                            .offset(y: 20)
                        
                        // Avatar
                        Image(systemName: "pawprint.fill") // Placeholder for actual image
                            .resizable()
                            .scaledToFit()
                            .padding(32)
                            .frame(width: 140, height: 140)
                            .background(Color.gray.opacity(0.1)) // Placeholder background
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    VStack(spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(tangerine)
                            Text("\(pet.breed) · \(pet.species.capitalized)")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 24)
                
                // 2. STATS GRID
                HStack(spacing: 12) {
                    StatCard(icon: "birthday.cake", title: "AGE", value: calculateAge(), iconColor: tangerine)
                    StatCard(icon: "scalemass", title: "WEIGHT", value: String(format: "%.1f kg", pet.weightKg), iconColor: .blue)
                    StatCard(icon: "syringe", title: "VACCINES", value: "Up-to-date", iconColor: tangerine)
                }
                .padding(.horizontal, 24)
                
                // 3. HEALTH OVERVIEW
                VStack(alignment: .leading, spacing: 16) {
                    Text("HEALTH OVERVIEW")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(textGray)
                        .tracking(1.0)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        // Static Mock Data for Wellness/Vaccines
                        HealthRow(
                            icon: "heart.fill",
                            iconBg: tangerine,
                            iconColor: .white,
                            title: "Wellness check",
                            subtitle: "Last visit · Apr 12, 2026"
                        )
                        
                        HealthRow(
                            icon: "syringe",
                            iconBg: Color.gray.opacity(0.1),
                            iconColor: .primary,
                            title: "Rabies booster",
                            subtitle: "Due in 2 months"
                        )
                        
                        // Dynamic Birthday Data
                        HealthRow(
                            icon: "birthday.cake",
                            iconBg: Color.gray.opacity(0.1),
                            iconColor: .primary,
                            title: "Birthday",
                            subtitle: "\(formattedBirthday) · \(birthdaySubtext)"
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 40)
        }
        .background(bgApp.ignoresSafeArea())
        .navigationTitle("Pet Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func calculateAge() -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: pet.dateOfBirth, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yrs"
        } else if let months = components.month, months > 0 {
            return "\(months) mos"
        }
        return "Puppy/Kitten"
    }
    
    private var formattedBirthday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: pet.dateOfBirth)
    }
    
    private var birthdaySubtext: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let birthYear = Calendar.current.component(.year, from: pet.dateOfBirth)
        let ageThisYear = currentYear - birthYear
        if ageThisYear > 0 {
            return "Turns \(ageThisYear) this year"
        }
        return "Born this year"
    }
}

// MARK: - Components

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct HealthRow: View {
    let icon: String
    let iconBg: Color
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        PetProfileView(pet: PetProfile(name: "Luna", species: "cat", breed: "Persian", dateOfBirth: Date().addingTimeInterval(-86400 * 365 * 3), weightKg: 4.2))
    }
}
