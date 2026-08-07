import Foundation

enum WeatherCondition: String, Codable, CaseIterable {
    case sunny = "Soleggiato"
    case cloudy = "Nuvoloso"
    case lightRain = "Pioggia Leggera"
    case heavyRain = "Pioggia Battente"
    
    var isRaining: Bool {
        return self == .lightRain || self == .heavyRain
    }
}

enum TireCompound: String, Codable, CaseIterable {
    case soft = "Soft (Rosse)"
    case medium = "Medium (Gialle)"
    case hard = "Hard (Bianche)"
    case intermediate = "Intermedie (Verdi)"
    case wet = "Full Wet (Blu)"
}

enum RaceStatus: String, Codable {
    case finished
    case dnf
}

struct RaceResult: Codable, Identifiable {
    var id = UUID()
    let driverID: UUID
    var position: Int
    let status: RaceStatus
    let gridPosition: Int
    let totalTime: Double
}

struct RaceSimulationData {
    let results: [RaceResult]
    let commentaryFeed: [String]
}
