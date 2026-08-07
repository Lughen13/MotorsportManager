import Foundation

struct RaceTrack: Codable, Identifiable {
    let id: UUID
    let name: String
    let country: String
    let lengthKM: Double
    let isHighSpeed: Bool
    let baseTireWear: Double
    let category: RaceCategory
    let baseLapTime: Double // Tempo medio reale sul giro in secondi
    let totalLaps: Int      // Formato di gara reale (numero di giri)
    
    init(id: UUID = UUID(), name: String, country: String, lengthKM: Double, isHighSpeed: Bool, baseTireWear: Double, category: RaceCategory, baseLapTime: Double, totalLaps: Int) {
        self.id = id
        self.name = name
        self.country = country
        self.lengthKM = lengthKM
        self.isHighSpeed = isHighSpeed
        self.baseTireWear = baseTireWear
        self.category = category
        self.baseLapTime = baseLapTime
        self.totalLaps = totalLaps
    }
}
