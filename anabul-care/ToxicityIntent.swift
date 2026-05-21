import AppIntents
import SwiftData

struct ToxicityIntent: AppIntent {
    static var title: LocalizedStringResource = "Cek Keamanan Makanan Anabul"
    static var description = IntentDescription("Cek apakah makanan aman untuk anabul Anda.")

    @Parameter(title: "Makanan", requestValueDialog: "Makanan apa yang ingin Anda cek?")
    var item: String

    @Parameter(title: "Spesies", requestValueDialog: "Untuk anjing, kucing, atau hamster?")
    var species: String

    static var parameterSummary: some ParameterSummary {
        Summary("Apakah \(\.$item) aman untuk \(\.$species)?")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let container = try ModelContainer(for: ToxicityModel.self, SpeciesRuleModel.self)
        let context = container.mainContext
        
        let searchText = item.lowercased()
        let searchSpecies = species.lowercased()
        
        let descriptor = FetchDescriptor<ToxicityModel>()
        let allHazards = (try? context.fetch(descriptor)) ?? []
        
        let match = allHazards.first { hazard in
            hazard.keyword.lowercased() == searchText &&
            hazard.speciesRule?.species.lowercased() == searchSpecies
        }
        
        if let match = match {
            let message = "Bahaya \(match.keyword) untuk \(searchSpecies) adalah \(match.dangerLevel). \(match.alternative != "none" ? "Coba berikan \(match.alternative) sebagai alternatif." : "")"
            return .result(value: match.dangerLevel, dialog: "\(message)")
        } else {
            return .result(value: "Aman", dialog: "Sepertinya \(item) aman untuk \(species), tapi tetap berhati-hatilah.")
        }
    }
}

struct ToxicityShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToxicityIntent(),
            phrases: [
                "Apakah \(\.$item) aman untuk \(\.$species) di \(.applicationName)?",
                "Cek keamanan \(\.$item) untuk \(\.$species)"
            ],
            shortTitle: "Keamanan Makanan",
            systemImageName: "exclamationmark.shield"
        )
    }
}
