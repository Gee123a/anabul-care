//
//  ToxicityIntent.swift
//  anabul-care
//

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
        let results = SafetyService.shared.checkSafety(for: species, query: item)
        
        if let match = results.first {
            let message = "Bahaya \(match.name) untuk \(species) adalah \(match.severity). Gejalanya meliputi \(match.symptoms)."
            return .result(value: match.severity, dialog: "\(message)")
        } else {
            return .result(value: "Aman", dialog: "Sepertinya \(item) aman untuk \(species), tapi tetap berhati-hatilah.")
        }
    }
}
