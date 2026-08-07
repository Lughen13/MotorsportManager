import Foundation

struct DriverStandingEntry: Codable, Identifiable {
    let id: UUID
    let driverID: UUID
    let driverName: String
    let points: Int
    let position: Int
    
    init(id: UUID = UUID(), driverID: UUID, driverName: String, points: Int, position: Int) {
        self.id = id
        self.driverID = driverID
        self.driverName = driverName
        self.points = points
        self.position = position
    }
}



struct TeamStandingEntry: Codable, Identifiable {
    let id: UUID
    let teamID: UUID
    let teamName: String
    let points: Int
    let position: Int
    
    init(id: UUID = UUID(), teamID: UUID, teamName: String, points: Int, position: Int) {
        self.id = id
        self.teamID = teamID
        self.teamName = teamName
        self.points = points
        self.position = position
    }
}

struct HistoricalSeason: Codable, Identifiable {
    let id: UUID
    let year: Int
    let categoryName: String
    let driverStandings: [DriverStandingEntry]
    let teamStandings: [TeamStandingEntry]
    
    init(id: UUID = UUID(), year: Int, categoryName: String, driverStandings: [DriverStandingEntry], teamStandings: [TeamStandingEntry]) {
        self.id = id
        self.year = year
        self.categoryName = categoryName
        self.driverStandings = driverStandings
        self.teamStandings = teamStandings
    }
}

struct StatSnapshot: Codable, Identifiable {
    let id: UUID
    let year: Int
    let reflexes: Double
    let stamina: Double
    let consistency: Double
    
    init(id: UUID = UUID(), year: Int, reflexes: Double, stamina: Double, consistency: Double) {
        self.id = id
        self.year = year
        self.reflexes = reflexes
        self.stamina = stamina
        self.consistency = consistency
    }
}
