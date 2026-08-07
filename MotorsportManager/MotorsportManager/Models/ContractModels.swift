import Foundation

enum RaceCategory: String, Codable, CaseIterable {
    case karting = "Karting"
    case f4 = "F4"
    case f3 = "F3"
    case f2 = "F2"
    case f1 = "F1"
}

enum ContractStatus: String, Codable {
    case pending
    case accepted
    case declined
}

struct ContractOffer: Codable, Identifiable {
    let id: UUID
    let teamID: UUID
    let teamName: String
    let category: RaceCategory
    let offeredSalary: Double
    let requiredBuyIn: Double
    var status: ContractStatus
    let durationYears: Int
    
    init(id: UUID = UUID(), teamID: UUID, teamName: String, category: RaceCategory, offeredSalary: Double, requiredBuyIn: Double, status: ContractStatus = .pending, durationYears: Int = 1) {
        self.id = id
        self.teamID = teamID
        self.teamName = teamName
        self.category = category
        self.offeredSalary = offeredSalary
        self.requiredBuyIn = requiredBuyIn
        self.status = status
        self.durationYears = durationYears
    }
}

struct PlayerContract: Codable {
    let teamID: UUID
    let stipendioSettimanale: Double
    let buyInPagato: Double
    var stagioniRimanenti: Int
    let obiettiviTeam: String
    
    init(teamID: UUID, stipendioSettimanale: Double, buyInPagato: Double, stagioniRimanenti: Int, obiettiviTeam: String) {
        self.teamID = teamID
        self.stipendioSettimanale = stipendioSettimanale
        self.buyInPagato = buyInPagato
        self.stagioniRimanenti = stagioniRimanenti
        self.obiettiviTeam = obiettiviTeam
    }
}
