import Foundation

struct DriverStats: Codable {
    var reflexes: Double
    var braking: Double
    var consistency: Double
    var wetWeather: Double
    var tireManagement: Double
    var stamina: Double
    var potential: Double
}

struct DriverMentalState: Codable {
    var stress: Double = 0.0
    var morale: Double = 50.0
}

class Driver: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var nationality: String
    var age: Int
    var category: RaceCategory
    var stats: DriverStats
    var currentTeamID: UUID?
    var energy: Int
    var maxEnergy: Int
    var mental: DriverMentalState
    var reputation: Double
    var raceFocusModifier: Double
    var pendingOffers: [ContractOffer]
    var currentContract: PlayerContract?
    
    // 1. LE NUOVE VARIABILI SOCIAL (Devono essere qui)
    var followers: Int
    var popularityTrend: Double
    
    var name: String {
        return "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, nationality, age, category, stats, currentTeamID, energy, maxEnergy, mental, reputation, raceFocusModifier, pendingOffers, currentContract
        // 2. AGGIUNTE ALLE CHIAVI DI CODIFICA (Cruciale per i salvataggi)
        case followers, popularityTrend
    }
    
    // 3. INIZIALIZZATORE AGGIORNATO (Valori di default a 0 per non rompere i piloti già esistenti)
    init(id: UUID = UUID(), firstName: String, lastName: String, nationality: String, age: Int, category: RaceCategory, stats: DriverStats, currentTeamID: UUID? = nil, energy: Int = 100, maxEnergy: Int = 100, mental: DriverMentalState = DriverMentalState(), reputation: Double = 20.0, raceFocusModifier: Double = 0.0, pendingOffers: [ContractOffer] = [], currentContract: PlayerContract? = nil, followers: Int = 0, popularityTrend: Double = 0.0) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.nationality = nationality
        self.age = age
        self.category = category
        self.stats = stats
        self.currentTeamID = currentTeamID
        self.energy = energy
        self.maxEnergy = maxEnergy
        self.mental = mental
        self.reputation = reputation
        self.raceFocusModifier = raceFocusModifier
        self.pendingOffers = pendingOffers
        self.currentContract = currentContract
        
        self.followers = followers
        self.popularityTrend = popularityTrend
    }
}
