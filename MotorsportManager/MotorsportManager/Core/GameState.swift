import Foundation
import SwiftUI
import Observation

struct CareerSummary: Codable {
    let races: Int
    let wins: Int
    let podiums: Int
    let poles: Int
    let championships: Int
}

struct DriverStaff: Codable {
    var physioLevel: Int = 0 // 0 a 3
    var prLevel: Int = 0     // 0 a 3
    var simLevel: Int = 0    // 0 a 3
    var jetLevel: Int = 0    // 0 o 1
    
    // Il pozzo senza fondo: il mantenimento settimanale
    var weeklyCost: Double {
        let pCost = physioLevel == 1 ? 500.0 : (physioLevel == 2 ? 2000.0 : (physioLevel == 3 ? 5000.0 : 0.0))
        let prCost = prLevel == 1 ? 1000.0 : (prLevel == 2 ? 3000.0 : (prLevel == 3 ? 10000.0 : 0.0))
        let jCost = jetLevel == 1 ? 25000.0 : 0.0
        return pCost + prCost + jCost
    }
}

enum StaffType { case physio, pr, sim, jet }

struct SponsorOffer: Codable, Identifiable {
    let id: UUID
    let name: String
    let targetPosition: Int
    let signOnFee: Double
    let raceBonus: Double
    let failurePenalty: Double
    var racesRemaining: Int
}

struct SaveData: Codable {
    let playerDriver: Driver
    let currentWeek: Int
    let currentYear: Int
    let funds: Double
    let globalDrivers: [Driver]
    let globalTeams: [Team]
    let seasonCalendar: [Int: RaceTrack]
    let historyDatabase: [HistoricalSeason]
    let careerRaces: Int
    let careerWins: Int
    let careerPodiums: Int
    let careerPoles: Int
    let championshipsWon: Int
    let statHistory: [StatSnapshot]
    let driverPoints: [String: Int]
    let teamPoints: [String: Int]
    let driverStaff: DriverStaff
    let activeSponsor: SponsorOffer?
    let availableSponsors: [SponsorOffer]
    let engineWear: Double
    let gearboxWear: Double
}

@Observable
class GameState {
    var activeSlot: Int = 1
    var playerDriver: Driver?
    var currentWeek: Int = 1
    var currentYear: Int = 2026
    var funds: Double = 50_000.0
    var actionsRemaining: Int = 5
    var activeSponsor: SponsorOffer? = nil
    var availableSponsors: [SponsorOffer] = []
    var lastSponsorResult: String? = nil
    var engineWear: Double = 0.0
    var gearboxWear: Double = 0.0
    
    var seasonCalendar: [Int: RaceTrack] = [:]
    var historyDatabase: [HistoricalSeason] = []
    
    var careerRaces: Int = 0
    var careerWins: Int = 0
    var careerPodiums: Int = 0
    var careerPoles: Int = 0
    var championshipsWon: Int = 0
    var statHistory: [StatSnapshot] = []
    
    var driverPoints: [String: Int] = [:]
    var teamPoints: [String: Int] = [:]
    
    var driverStaff: DriverStaff = DriverStaff()
    var firingNotification: String? = nil
    
    @ObservationIgnored let seasonManager = SeasonManager()
    @ObservationIgnored let raceEngine = RaceSimulationEngine()
    
    private func saveFileURL(for slot: Int) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("savegame_slot\(slot).json")
    }
    
    func hasSavedGame(slot: Int) -> Bool {
        return FileManager.default.fileExists(atPath: saveFileURL(for: slot).path)
    }
    
    func deleteGame(slot: Int) {
        let url = saveFileURL(for: slot)
        if FileManager.default.fileExists(atPath: url.path) {
            do { try FileManager.default.removeItem(at: url) }
            catch { print("Errore durante l'eliminazione dello slot \(slot): \(error)") }
        }
    }
    
    func getDriverPoints(for driverID: UUID) -> Int { return driverPoints[driverID.uuidString] ?? 0 }
    func getTeamPoints(for teamID: UUID) -> Int { return teamPoints[teamID.uuidString] ?? 0 }
    
    func getCurrentDriverStandings(for category: RaceCategory) -> [DriverStandingEntry] {
        let drivers = seasonManager.globalDrivers.filter { $0.category == category }
        var entries = drivers.map { DriverStandingEntry(driverID: $0.id, driverName: $0.name, points: getDriverPoints(for: $0.id), position: 0) }
        entries.sort { $0.points > $1.points }
        return entries.enumerated().map { DriverStandingEntry(id: $1.id, driverID: $1.driverID, driverName: $1.driverName, points: $1.points, position: $0 + 1) }
    }
    
    func getCurrentTeamStandings(for category: RaceCategory) -> [TeamStandingEntry] {
        let teams = seasonManager.globalTeams.filter { $0.category == category }
        var entries = teams.map { TeamStandingEntry(teamID: $0.id, teamName: $0.name, points: getTeamPoints(for: $0.id), position: 0) }
        entries.sort { $0.points > $1.points }
        return entries.enumerated().map { TeamStandingEntry(id: $1.id, teamID: $1.teamID, teamName: $1.teamName, points: $1.points, position: $0 + 1) }
    }
    
    func getCareerStats() -> CareerSummary {
        return CareerSummary(races: careerRaces, wins: careerWins, podiums: careerPodiums, poles: careerPoles, championships: championshipsWon)
    }
    
    func startNewGame(slot: Int, firstName: String, lastName: String, nationality: String, age: Int, selectedTeamID: UUID) {
        self.activeSlot = slot
        seasonManager.inizializzaCampionati()
        seasonManager.generaPilotiIniziali()
        
        let stats = DriverStats(reflexes: 50, braking: 50, consistency: 50, wetWeather: 40, tireManagement: 40, stamina: 60, potential: 90)
        let newDriver = Driver(firstName: firstName, lastName: lastName, nationality: nationality, age: age, category: .karting, stats: stats)
        newDriver.currentTeamID = selectedTeamID
        newDriver.currentContract = PlayerContract(teamID: selectedTeamID, stipendioSettimanale: 0, buyInPagato: 10_000, stagioniRimanenti: 1, obiettiviTeam: "Debutta e fai esperienza")
        
        self.playerDriver = newDriver
        self.seasonManager.globalDrivers.append(newDriver)
        self.currentWeek = 1
        self.currentYear = 2026
        self.actionsRemaining = 5
        self.driverPoints.removeAll()
        self.teamPoints.removeAll()
        self.historyDatabase.removeAll()
        self.statHistory.removeAll()
        self.driverStaff = DriverStaff()
        self.activeSponsor = nil
        self.availableSponsors = []
        self.lastSponsorResult = nil
        self.generateSponsorOffers()
        self.engineWear = 0.0
        self.gearboxWear = 0.0
        
        generateCalendar(for: .karting)
        saveGame()
    }
    
    func getAvailableStartingTeams() -> [Team] {
        Array(seasonManager.globalTeams.filter { $0.category == .karting }.sorted { $0.basePerformance < $1.basePerformance }.prefix(3))
    }
    
    func generateCalendar(for category: RaceCategory) {
            // 1. Salviamo le gare già disputate per non perdere la cronologia della stagione in corso
            var pastRaces: [Int: RaceTrack] = [:]
            if currentWeek > 1 {
                for (week, track) in seasonCalendar {
                    if week < currentWeek {
                        pastRaces[week] = track
                    }
                }
            }
            
            // 2. Puliamo il calendario
            seasonCalendar.removeAll()
            
            // 3. Ripristiniamo intatto il passato
            for (week, track) in pastRaces {
                seasonCalendar[week] = track
            }
            
            // 4. Popoliamo le gare in base alla categoria, inserendo solo quelle future se siamo a metà anno
            switch category {
                
            case .karting: // 6 Gare - Campionato Mondiale
                let tracks: [(Int, RaceTrack)] = [
                    (10, RaceTrack(name: "South Garda (Lonato)", country: "Italia", lengthKM: 1.2, isHighSpeed: false, baseTireWear: 0.12, category: .karting, baseLapTime: 47.5, totalLaps: 15)),
                    (18, RaceTrack(name: "Napoli (Sarno)", country: "Italia", lengthKM: 1.6, isHighSpeed: true, baseTireWear: 0.14, category: .karting, baseLapTime: 55.0, totalLaps: 15)),
                    (26, RaceTrack(name: "Franciacorta", country: "Italia", lengthKM: 1.3, isHighSpeed: true, baseTireWear: 0.11, category: .karting, baseLapTime: 49.2, totalLaps: 16)),
                    (34, RaceTrack(name: "Zuera", country: "Spagna", lengthKM: 1.7, isHighSpeed: true, baseTireWear: 0.15, category: .karting, baseLapTime: 58.2, totalLaps: 16)),
                    (42, RaceTrack(name: "Le Mans Karting", country: "Francia", lengthKM: 1.4, isHighSpeed: true, baseTireWear: 0.13, category: .karting, baseLapTime: 51.0, totalLaps: 16)),
                    (50, RaceTrack(name: "Wackersdorf", country: "Germania", lengthKM: 1.2, isHighSpeed: false, baseTireWear: 0.10, category: .karting, baseLapTime: 48.3, totalLaps: 15))
                ]
                for (week, track) in tracks {
                    if currentWeek <= 1 || week >= currentWeek { seasonCalendar[week] = track }
                }
                
            case .f4: // 7 Gare - Campionato Europeo/Italiano
                let tracks: [(Int, RaceTrack)] = [
                    (15, RaceTrack(name: "Misano", country: "Italia", lengthKM: 4.22, isHighSpeed: false, baseTireWear: 0.10, category: .f4, baseLapTime: 96.0, totalLaps: 18)),
                    (21, RaceTrack(name: "Imola", country: "Italia", lengthKM: 4.90, isHighSpeed: true, baseTireWear: 0.12, category: .f4, baseLapTime: 104.2, totalLaps: 16)),
                    (27, RaceTrack(name: "Vallelunga", country: "Italia", lengthKM: 4.08, isHighSpeed: false, baseTireWear: 0.08, category: .f4, baseLapTime: 94.5, totalLaps: 18)),
                    (33, RaceTrack(name: "Mugello", country: "Italia", lengthKM: 5.24, isHighSpeed: true, baseTireWear: 0.13, category: .f4, baseLapTime: 107.0, totalLaps: 16)),
                    (39, RaceTrack(name: "Paul Ricard", country: "Francia", lengthKM: 5.84, isHighSpeed: true, baseTireWear: 0.11, category: .f4, baseLapTime: 122.5, totalLaps: 15)),
                    (45, RaceTrack(name: "Monza", country: "Italia", lengthKM: 5.79, isHighSpeed: true, baseTireWear: 0.14, category: .f4, baseLapTime: 112.0, totalLaps: 16)),
                    (51, RaceTrack(name: "Barcelona", country: "Spagna", lengthKM: 4.65, isHighSpeed: false, baseTireWear: 0.15, category: .f4, baseLapTime: 102.5, totalLaps: 17))
                ]
                for (week, track) in tracks {
                    if currentWeek <= 1 || week >= currentWeek { seasonCalendar[week] = track }
                }
                
            case .f3: // 10 Gare - Piste internazionali a contorno della F1
                let tracks: [(Int, RaceTrack)] = [
                    (8, RaceTrack(name: "Bahrain", country: "Bahrein", lengthKM: 5.41, isHighSpeed: true, baseTireWear: 0.14, category: .f3, baseLapTime: 108.5, totalLaps: 20)),
                    (12, RaceTrack(name: "Melbourne", country: "Australia", lengthKM: 5.27, isHighSpeed: true, baseTireWear: 0.12, category: .f3, baseLapTime: 105.2, totalLaps: 20)),
                    (20, RaceTrack(name: "Imola", country: "Italia", lengthKM: 4.90, isHighSpeed: true, baseTireWear: 0.11, category: .f3, baseLapTime: 95.0, totalLaps: 22)),
                    (22, RaceTrack(name: "Monaco", country: "Monaco", lengthKM: 3.33, isHighSpeed: false, baseTireWear: 0.06, category: .f3, baseLapTime: 82.0, totalLaps: 24)),
                    (26, RaceTrack(name: "Barcelona", country: "Spagna", lengthKM: 4.65, isHighSpeed: false, baseTireWear: 0.16, category: .f3, baseLapTime: 92.5, totalLaps: 22)),
                    (28, RaceTrack(name: "Spielberg", country: "Austria", lengthKM: 4.31, isHighSpeed: true, baseTireWear: 0.10, category: .f3, baseLapTime: 78.4, totalLaps: 24)),
                    (30, RaceTrack(name: "Silverstone", country: "Regno Unito", lengthKM: 5.89, isHighSpeed: true, baseTireWear: 0.15, category: .f3, baseLapTime: 105.0, totalLaps: 18)),
                    (32, RaceTrack(name: "Hungaroring", country: "Ungheria", lengthKM: 4.38, isHighSpeed: false, baseTireWear: 0.14, category: .f3, baseLapTime: 93.2, totalLaps: 22)),
                    (34, RaceTrack(name: "Spa-Francorchamps", country: "Belgio", lengthKM: 7.00, isHighSpeed: true, baseTireWear: 0.13, category: .f3, baseLapTime: 125.1, totalLaps: 15)),
                    (38, RaceTrack(name: "Monza", country: "Italia", lengthKM: 5.79, isHighSpeed: true, baseTireWear: 0.15, category: .f3, baseLapTime: 102.1, totalLaps: 18))
                ]
                for (week, track) in tracks {
                    if currentWeek <= 1 || week >= currentWeek { seasonCalendar[week] = track }
                }
                
            case .f2: // 14 Gare
                let tracks: [(Int, RaceTrack)] = [
                    (8, RaceTrack(name: "Bahrain", country: "Bahrein", lengthKM: 5.41, isHighSpeed: true, baseTireWear: 0.15, category: .f2, baseLapTime: 103.0, totalLaps: 28)),
                    (10, RaceTrack(name: "Jeddah", country: "Arabia Saudita", lengthKM: 6.17, isHighSpeed: true, baseTireWear: 0.13, category: .f2, baseLapTime: 101.4, totalLaps: 26)),
                    (12, RaceTrack(name: "Melbourne", country: "Australia", lengthKM: 5.27, isHighSpeed: true, baseTireWear: 0.14, category: .f2, baseLapTime: 98.5, totalLaps: 28)),
                    (20, RaceTrack(name: "Imola", country: "Italia", lengthKM: 4.90, isHighSpeed: true, baseTireWear: 0.12, category: .f2, baseLapTime: 89.2, totalLaps: 32)),
                    (22, RaceTrack(name: "Monaco", country: "Monaco", lengthKM: 3.33, isHighSpeed: false, baseTireWear: 0.08, category: .f2, baseLapTime: 76.0, totalLaps: 35)),
                    (26, RaceTrack(name: "Barcelona", country: "Spagna", lengthKM: 4.65, isHighSpeed: false, baseTireWear: 0.17, category: .f2, baseLapTime: 85.5, totalLaps: 32)),
                    (28, RaceTrack(name: "Spielberg", country: "Austria", lengthKM: 4.31, isHighSpeed: true, baseTireWear: 0.11, category: .f2, baseLapTime: 75.0, totalLaps: 35)),
                    (30, RaceTrack(name: "Silverstone", country: "Regno Unito", lengthKM: 5.89, isHighSpeed: true, baseTireWear: 0.16, category: .f2, baseLapTime: 98.2, totalLaps: 27)),
                    (32, RaceTrack(name: "Hungaroring", country: "Ungheria", lengthKM: 4.38, isHighSpeed: false, baseTireWear: 0.15, category: .f2, baseLapTime: 88.6, totalLaps: 33)),
                    (34, RaceTrack(name: "Spa-Francorchamps", country: "Belgio", lengthKM: 7.00, isHighSpeed: true, baseTireWear: 0.14, category: .f2, baseLapTime: 112.5, totalLaps: 24)),
                    (38, RaceTrack(name: "Monza", country: "Italia", lengthKM: 5.79, isHighSpeed: true, baseTireWear: 0.16, category: .f2, baseLapTime: 89.8, totalLaps: 28)),
                    (40, RaceTrack(name: "Baku", country: "Azerbaigian", lengthKM: 6.00, isHighSpeed: true, baseTireWear: 0.13, category: .f2, baseLapTime: 113.4, totalLaps: 25)),
                    (48, RaceTrack(name: "Interlagos", country: "Brasile", lengthKM: 4.31, isHighSpeed: false, baseTireWear: 0.14, category: .f2, baseLapTime: 76.5, totalLaps: 34)),
                    (50, RaceTrack(name: "Yas Marina", country: "Emirati Arabi", lengthKM: 5.28, isHighSpeed: false, baseTireWear: 0.12, category: .f2, baseLapTime: 96.0, totalLaps: 30))
                ]
                for (week, track) in tracks {
                    if currentWeek <= 1 || week >= currentWeek { seasonCalendar[week] = track }
                }
                
            case .f1: // 22 Gare - Il Mondiale Assoluto
                let tracks: [(Int, RaceTrack)] = [
                    (8, RaceTrack(name: "Bahrain", country: "Bahrein", lengthKM: 5.41, isHighSpeed: true, baseTireWear: 0.16, category: .f1, baseLapTime: 91.2, totalLaps: 57)),
                    (10, RaceTrack(name: "Jeddah", country: "Arabia Saudita", lengthKM: 6.17, isHighSpeed: true, baseTireWear: 0.12, category: .f1, baseLapTime: 88.4, totalLaps: 50)),
                    (12, RaceTrack(name: "Melbourne", country: "Australia", lengthKM: 5.27, isHighSpeed: true, baseTireWear: 0.14, category: .f1, baseLapTime: 80.5, totalLaps: 58)),
                    (14, RaceTrack(name: "Suzuka", country: "Giappone", lengthKM: 5.81, isHighSpeed: true, baseTireWear: 0.17, category: .f1, baseLapTime: 89.0, totalLaps: 53)),
                    (16, RaceTrack(name: "Shanghai", country: "Cina", lengthKM: 5.45, isHighSpeed: false, baseTireWear: 0.15, category: .f1, baseLapTime: 95.2, totalLaps: 56)),
                    (18, RaceTrack(name: "Miami", country: "USA", lengthKM: 5.41, isHighSpeed: true, baseTireWear: 0.13, category: .f1, baseLapTime: 90.0, totalLaps: 57)),
                    (20, RaceTrack(name: "Imola", country: "Italia", lengthKM: 4.90, isHighSpeed: true, baseTireWear: 0.12, category: .f1, baseLapTime: 76.2, totalLaps: 63)),
                    (22, RaceTrack(name: "Monaco", country: "Monaco", lengthKM: 3.33, isHighSpeed: false, baseTireWear: 0.08, category: .f1, baseLapTime: 71.3, totalLaps: 78)),
                    (24, RaceTrack(name: "Montreal", country: "Canada", lengthKM: 4.36, isHighSpeed: true, baseTireWear: 0.11, category: .f1, baseLapTime: 73.0, totalLaps: 70)),
                    (26, RaceTrack(name: "Barcelona", country: "Spagna", lengthKM: 4.65, isHighSpeed: false, baseTireWear: 0.18, category: .f1, baseLapTime: 73.1, totalLaps: 66)),
                    (28, RaceTrack(name: "Spielberg", country: "Austria", lengthKM: 4.31, isHighSpeed: true, baseTireWear: 0.12, category: .f1, baseLapTime: 65.5, totalLaps: 71)),
                    (30, RaceTrack(name: "Silverstone", country: "Regno Unito", lengthKM: 5.89, isHighSpeed: true, baseTireWear: 0.16, category: .f1, baseLapTime: 86.7, totalLaps: 52)),
                    (32, RaceTrack(name: "Hungaroring", country: "Ungheria", lengthKM: 4.38, isHighSpeed: false, baseTireWear: 0.15, category: .f1, baseLapTime: 78.6, totalLaps: 70)),
                    (34, RaceTrack(name: "Spa-Francorchamps", country: "Belgio", lengthKM: 7.00, isHighSpeed: true, baseTireWear: 0.14, category: .f1, baseLapTime: 104.1, totalLaps: 44)),
                    (36, RaceTrack(name: "Zandvoort", country: "Olanda", lengthKM: 4.26, isHighSpeed: false, baseTireWear: 0.15, category: .f1, baseLapTime: 71.5, totalLaps: 72)),
                    (38, RaceTrack(name: "Monza", country: "Italia", lengthKM: 5.79, isHighSpeed: true, baseTireWear: 0.13, category: .f1, baseLapTime: 81.0, totalLaps: 53)),
                    (40, RaceTrack(name: "Baku", country: "Azerbaigian", lengthKM: 6.00, isHighSpeed: true, baseTireWear: 0.12, category: .f1, baseLapTime: 102.4, totalLaps: 51)),
                    (42, RaceTrack(name: "Singapore", country: "Singapore", lengthKM: 4.94, isHighSpeed: false, baseTireWear: 0.16, category: .f1, baseLapTime: 93.5, totalLaps: 62)),
                    (44, RaceTrack(name: "Austin", country: "USA", lengthKM: 5.51, isHighSpeed: true, baseTireWear: 0.15, category: .f1, baseLapTime: 96.0, totalLaps: 56)),
                    (46, RaceTrack(name: "Mexico City", country: "Messico", lengthKM: 4.30, isHighSpeed: true, baseTireWear: 0.12, category: .f1, baseLapTime: 78.5, totalLaps: 71)),
                    (48, RaceTrack(name: "Interlagos", country: "Brasile", lengthKM: 4.31, isHighSpeed: false, baseTireWear: 0.14, category: .f1, baseLapTime: 70.5, totalLaps: 71)),
                    (50, RaceTrack(name: "Abu Dhabi", country: "Emirati Arabi", lengthKM: 5.28, isHighSpeed: false, baseTireWear: 0.13, category: .f1, baseLapTime: 85.3, totalLaps: 58))
                ]
                for (week, track) in tracks {
                    if currentWeek <= 1 || week >= currentWeek { seasonCalendar[week] = track }
                }
            }
        }
    
    private func simulateTeamDevelopment() {
            for i in 0..<seasonManager.globalTeams.count {
                let team = seasonManager.globalTeams[i]
                
                // Recupera i piloti attualmente seduti in questa scuderia
                let driversInTeam = seasonManager.globalDrivers.filter { $0.currentTeamID == team.id }
                guard !driversInTeam.isEmpty else { continue }
                
                // Calcola la qualità media del feedback (Consistency)
                let avgConsistency = driversInTeam.map { $0.stats.consistency }.reduce(0, +) / Double(driversInTeam.count)
                
                // Il punto di rottura è 50. Sotto il 50, i piloti danno indicazioni sbagliate.
                // Sopra il 50, guidano gli ingegneri verso assetti e aggiornamenti migliori.
                let feedbackQuality = (avgConsistency - 50.0) / 100.0 // Genera un valore tra -0.5 e +0.5
                
                // Il moltiplicatore stabilisce quanto la macchina può cambiare in base alla categoria
                let categoryMultiplier: Double
                switch team.category {
                case .karting, .f4: categoryMultiplier = 0.05 // Monomarca rigidi: si lima il centesimo
                case .f3, .f2: categoryMultiplier = 0.15      // Lavoro massiccio di setup e simulatore
                case .f1: categoryMultiplier = 0.40           // Guerra aerodinamica: aggiornamenti pesanti
                }
                
                // Calcolo finale del boost settimanale (con un pizzico di varianza ingegneristica)
                let weeklyVariation = feedbackQuality * categoryMultiplier * Double.random(in: 0.8...1.2)
                
                // Applica la variazione, mantenendo la performance nei limiti logici (30.0 - 99.0)
                seasonManager.globalTeams[i].basePerformance = max(30.0, min(99.0, team.basePerformance + weeklyVariation))
            }
        }
    
    private func applyRegulationChanges() {
        for i in 0..<seasonManager.globalTeams.count {
            let jitter = Double.random(in: -5.0...5.0)
            seasonManager.globalTeams[i].basePerformance = max(30.0, min(95.0, seasonManager.globalTeams[i].basePerformance + jitter))
        }
    }
    
    private func simulateAllChampionshipsWeekly() {
        guard currentWeek % 3 == 0 else { return }
        let categories: [RaceCategory] = [.f1, .f2, .f3, .f4, .karting]
        let ptsTable = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1]
        
        for cat in categories {
            if let playerCat = playerDriver?.category, cat == playerCat { continue }
            let driversInCat = seasonManager.globalDrivers.filter { $0.category == cat }
            guard !driversInCat.isEmpty else { continue }
            
            let shuffled = driversInCat.shuffled()
            for (idx, drv) in shuffled.prefix(10).enumerated() {
                let pts = ptsTable[idx]
                driverPoints[drv.id.uuidString, default: 0] += pts
                if let tID = drv.currentTeamID {
                    teamPoints[tID.uuidString, default: 0] += pts
                }
            }
        }
    }
    
    func evaluateScoutingOffers(for driver: Driver) {
        driver.pendingOffers.removeAll()
        
        var eligible = seasonManager.globalTeams.filter { team in
            team.category == driver.category || driver.reputation >= (team.basePerformance * 0.5)
        }.shuffled()
        
        if eligible.isEmpty {
            // Paracadute: Se sei finito nel baratro, riparti dai Kart.
            eligible = seasonManager.globalTeams.filter { $0.category == .karting }
        }
        
        let count = Int.random(in: 1...3)
        for i in 0..<min(count, eligible.count) {
            let team = eligible[i] // Questa era la riga che avevi cancellato!
            var buyIn = 0.0
            var salary = 0.0
            
            switch team.category {
            case .karting: buyIn = 10_000.0
            case .f4: buyIn = 20_000.0; salary = 1_500.0
            case .f3: buyIn = 30_000.0; salary = 3_500.0
            case .f2: salary = 8_000.0
            case .f1: salary = 25_000.0
            }
            
            let offer = ContractOffer(teamID: team.id, teamName: team.name, category: team.category, offeredSalary: salary, requiredBuyIn: buyIn, status: .pending, durationYears: 1)
            driver.pendingOffers.append(offer)
        }
    }
    
    // MARK: - MERCATO PILOTI IA
        private func gestisciMercatoPilotiIA() {
            // Analizza ogni squadra nel database
            for team in seasonManager.globalTeams {
                // Conta quanti piloti sono attualmente assegnati a questa squadra
                let driversInTeam = seasonManager.globalDrivers.filter { $0.currentTeamID == team.id }
                let missingSeats = 2 - driversInTeam.count
                
                if missingSeats > 0 {
                    for _ in 0..<missingSeats {
                        // Cerca un pilota disoccupato nella stessa categoria
                        let availableFreeAgents = seasonManager.globalDrivers.filter { $0.currentTeamID == nil && $0.category == team.category }
                        
                        if let luckyDriver = availableFreeAgents.randomElement(), let idx = seasonManager.globalDrivers.firstIndex(where: { $0.id == luckyDriver.id }) {
                            // Assumi il disoccupato: il sistema ricicla i piloti licenziati
                            seasonManager.globalDrivers[idx].currentTeamID = team.id
                        } else {
                            // Se non ci sono disoccupati, il vivaio genera un nuovo talento (Rookie)
                            let nomi = ["Marco", "Lando", "Oscar", "Kimi", "Oliver", "Andrea", "Yuki", "Liam"]
                            let cognomi = ["Rossi", "Bianchi", "Smith", "Takahashi", "Müller", "Gomez", "Dupont", "Silva"]
                            let nazioni = ["ITA", "GBR", "AUS", "JPN", "GER", "ESP", "FRA", "BRA"]
                            
                            let rookieStats = DriverStats(
                                reflexes: Double.random(in: 40...55),
                                braking: Double.random(in: 40...55),
                                consistency: Double.random(in: 40...55),
                                wetWeather: Double.random(in: 40...55),
                                tireManagement: Double.random(in: 40...55),
                                stamina: Double.random(in: 40...60),
                                potential: Double.random(in: 70...95)
                            )
                            
                            let rookie = Driver(
                                firstName: nomi.randomElement()!,
                                lastName: cognomi.randomElement()!,
                                nationality: nazioni.randomElement()!,
                                age: Int.random(in: 16...19),
                                category: team.category,
                                stats: rookieStats
                            )
                            rookie.currentTeamID = team.id
                            seasonManager.globalDrivers.append(rookie)
                        }
                    }
                }
            }
        }
    
    // MARK: - INVECCHIAMENTO E RITIRI
        private func gestisciInvecchiamentoERitiri() {
            guard let playerID = playerDriver?.id else { return }
            var ritirati: [String] = []
            
            // Scorriamo al contrario per poter eliminare elementi in sicurezza senza far crashare gli indici
            for i in (0..<seasonManager.globalDrivers.count).reversed() {
                let driver = seasonManager.globalDrivers[i]
                
                // Il tempo passa per tutti
                driver.age += 1
                
                // Il declino fisico inizia a 35 anni
                if driver.age > 35 {
                    let decadimento = Double(driver.age - 35) * 1.5 // 1.5 punti persi per ogni anno oltre i 35
                    driver.stats.reflexes = max(10.0, driver.stats.reflexes - decadimento)
                    driver.stats.stamina = max(10.0, driver.stats.stamina - decadimento)
                    driver.stats.consistency = max(10.0, driver.stats.consistency - (decadimento * 0.5))
                }
                
                // Condizioni di Ritiro:
                // O l'IA compie 40 anni, o i suoi riflessi crollano sotto il 50 (inutilizzabile).
                // Il giocatore umano fa eccezione: subisce il calo delle stats, ma decide lui quando smettere.
                if driver.id != playerID && (driver.age >= 40 || driver.stats.reflexes < 50.0) {
                    ritirati.append("\(driver.firstName) \(driver.lastName) (\(driver.age) anni)")
                    seasonManager.globalDrivers.remove(at: i)
                }
            }
            
            // Se vuoi vedere chi si ritira, questo stampa i nomi nella console di Xcode
            if !ritirati.isEmpty {
                print("🚨 RITIRI A FINE STAGIONE \(currentYear): \(ritirati.joined(separator: ", "))")
            }
        }
    
    func accettaOffertaContratto(_ offer: ContractOffer) {
            guard let driver = playerDriver else { return }
            
            // 1. Aggiorna lo stato dell'offerta per coerenza dati
            if let idx = driver.pendingOffers.firstIndex(where: { $0.id == offer.id }) {
                driver.pendingOffers[idx].status = .accepted
            }
            
            // 2. Transazione Finanziaria
            funds -= offer.requiredBuyIn
            
            // 3. IL RESET MECCANICO STRUTTURALE
            // Cambi team? Ti danno un'auto nuova. L'usura torna a zero. Niente scuse.
            self.engineWear = 0.0
            self.gearboxWear = 0.0
            
            // 4. LOGICA DI CAMBIO SCUDERIA / CATEGORIA
            driver.currentTeamID = offer.teamID
            
            if driver.category != offer.category {
                driver.category = offer.category
                generateCalendar(for: offer.category)
                
                // Il salto di categoria invalida gli sponsor minori
                // Non puoi portare lo sponsor del Karting in F4. Il giocatore deve cercarne uno nuovo.
                self.activeSponsor = nil
                self.generateSponsorOffers()
                // Notifica obbligatoria per evitare che il giocatore pensi a un bug
                self.firingNotification = "Promozione in \(offer.category.rawValue)! L'auto e il calendario sono stati aggiornati. I vecchi punti non contano in questa categoria e dovrai cercare nuovi sponsor."
            }
            
            // 5. STESURA CONTRATTO (La tua logica originale mantenuta intatta)
            let duration = (currentWeek > 1 && currentWeek <= 52) ? 2 : 1
            
            driver.currentContract = PlayerContract(
                teamID: offer.teamID,
                stipendioSettimanale: offer.offeredSalary,
                buyInPagato: offer.requiredBuyIn,
                stagioniRimanenti: duration,
                obiettiviTeam: "Lotta per il vertice"
            )
            
            // 6. PULIZIA FINALE E SALVATAGGIO
            driver.pendingOffers.removeAll()
            saveGame()
        }
    
    // MARK: - SISTEMA SPONSOR
    func generateSponsorOffers() {
        guard let driver = playerDriver else { return }
        availableSponsors.removeAll()
        
        // I soldi scalano con la categoria: in F1 girano milioni, nei Kart spiccioli
        let mult = driver.category == .f1 ? 15.0 : (driver.category == .f2 ? 5.0 : (driver.category == .f3 ? 2.5 : (driver.category == .f4 ? 1.2 : 0.5)))
        let duration = Int.random(in: 3...6) // Il contratto dura da 3 a 6 gare
        
        availableSponsors.append(SponsorOffer(id: UUID(), name: "SafeDrive Insurance", targetPosition: 15, signOnFee: 5000 * mult, raceBonus: 1000 * mult, failurePenalty: 0, racesRemaining: duration))
        availableSponsors.append(SponsorOffer(id: UUID(), name: "Velocity Energy", targetPosition: 8, signOnFee: 10000 * mult, raceBonus: 3500 * mult, failurePenalty: 1500 * mult, racesRemaining: duration))
        availableSponsors.append(SponsorOffer(id: UUID(), name: "Apex Predator Capital", targetPosition: 3, signOnFee: 25000 * mult, raceBonus: 8000 * mult, failurePenalty: 6000 * mult, racesRemaining: duration))
    }
    
    func acceptSponsor(_ offer: SponsorOffer) {
        funds += offer.signOnFee
        activeSponsor = offer
        availableSponsors.removeAll()
        saveGame()
    }
    
    func upgradeStaff(type: StaffType, cost: Double, level: Int) {
            if funds >= cost {
                funds -= cost
                switch type {
                case .physio: driverStaff.physioLevel = level
                case .pr: driverStaff.prLevel = level
                case .sim: driverStaff.simLevel = level
                case .jet: driverStaff.jetLevel = level
                }
                saveGame()
            }
        }
    
    func proponiRinnovoTeamAttuale() {
        guard let driver = playerDriver, let teamID = driver.currentTeamID else { return }
        guard let team = seasonManager.globalTeams.first(where: { $0.id == teamID }) else { return }
        
        // I team non trattano rinnovi a inizio stagione. Vogliono prima vedere come guidi.
        guard currentWeek > 5 else {
            firingNotification = "❌ TROPPO PRESTO\nLa \(team.name) non vuole parlare di contratti ora. Porta risultati in pista, poi ne riparleremo."
            return
        }
        
        let standings = getCurrentDriverStandings(for: driver.category)
        guard let playerPos = standings.first(where: { $0.driverID == driver.id })?.position else { return }
        
        let totalDrivers = standings.count
        var expectedPos = totalDrivers
        
        // Stessa metrica del licenziamento
        if team.basePerformance >= 90 { expectedPos = max(1, Int(Double(totalDrivers) * 0.20)) }
        else if team.basePerformance >= 80 { expectedPos = max(1, Int(Double(totalDrivers) * 0.50)) }
        else if team.basePerformance >= 70 { expectedPos = max(1, Int(Double(totalDrivers) * 0.75)) }
        
        let currentSalary = driver.currentContract?.stipendioSettimanale ?? 0.0
        
        // VALUTAZIONE DELLE TUE PRESTAZIONI
        if playerPos <= max(1, expectedPos / 2) {
            // OVERPERFORMING: Sei la stella della squadra. Pretendi un rinnovo pluriennale e un aumento massiccio.
            let newSalary = currentSalary * 1.5 + (team.category == .f1 ? 15000.0 : 2000.0)
            driver.currentContract = PlayerContract(teamID: teamID, stipendioSettimanale: newSalary, buyInPagato: 0, stagioniRimanenti: 2, obiettiviTeam: "Lotta per il titolo")
            firingNotification = "📝 RINNOVO SUPERSTAR!\nStai trascinando la squadra. La \(team.name) ti ha blindato per 2 STAGIONI con un ingaggio stellare di €\(Int(newSalary))/sett."
            
        } else if playerPos <= expectedPos {
            // MEETING EXPECTATIONS: Stai facendo il tuo dovere. Rinnovo standard di 1 anno.
            let newSalary = currentSalary + (team.category == .f1 ? 5000.0 : 500.0)
            driver.currentContract = PlayerContract(teamID: teamID, stipendioSettimanale: newSalary, buyInPagato: 0, stagioniRimanenti: 1, obiettiviTeam: "Conferma i progressi")
            firingNotification = "📝 RINNOVO ACCETTATO\nLa dirigenza è soddisfatta del tuo P\(playerPos). Contratto esteso di 1 anno a €\(Int(newSalary))/sett."
            
        } else {
            // UNDERPERFORMING: Stai deludendo. Il team si rifiuta di trattare.
            firingNotification = "❌ RINNOVO RIFIUTATO\nLa dirigenza esige la posizione P\(expectedPos) ma tu sei in P\(playerPos). Il team si rifiuta di prolungarti il contratto. O migliori, o a fine anno sei fuori."
            return // Usciamo senza salvare e senza rinnovare
        }
        
        driver.pendingOffers.removeAll()
        saveGame()
    }
    
    func executeActivity(_ activity: WeeklyActivity) {
            guard let driver = playerDriver else { return }
            if actionsRemaining <= 0 || driver.energy < activity.energyCost { return }
            
            // FIX: Aggiornato al nuovo sistema a livelli del PR Manager
            var rewardMultiplier = 1.0
            if activity == .sponsorEvent && driverStaff.prLevel > 0 {
                rewardMultiplier = 1.0 + (Double(driverStaff.prLevel) * 0.5) // Lvl 1: 1.5x, Lvl 2: 2.0x, Lvl 3: 2.5x
            }
            
            let netCost = activity.financialCost - (activity.financialReward() * rewardMultiplier)
            
            if funds - netCost < -20_000 { return }
            
            funds -= netCost
            driver.energy -= activity.energyCost
            actionsRemaining -= 1
            
            switch activity {
            case .gym:
                let catCap: Double
                switch driver.category { case .karting: catCap = 55.0; case .f4: catCap = 65.0; case .f3: catCap = 75.0; case .f2: catCap = 85.0; case .f1: catCap = driver.stats.potential }
                if driver.stats.stamina < min(catCap, driver.stats.potential) { driver.stats.stamina += 0.2 }
                
                let stressRelief = driverStaff.physioLevel == 3 ? 25.0 : (driverStaff.physioLevel == 2 ? 15.0 : (driverStaff.physioLevel == 1 ? 10.0 : 5.0))
                driver.mental.stress = max(0, driver.mental.stress - stressRelief)
                
            case .simulator:
                let catCap: Double
                switch driver.category { case .karting: catCap = 55.0; case .f4: catCap = 65.0; case .f3: catCap = 75.0; case .f2: catCap = 85.0; case .f1: catCap = driver.stats.potential }
                
                let simMultiplier = driverStaff.simLevel == 3 ? 2.0 : (driverStaff.simLevel == 2 ? 1.5 : (driverStaff.simLevel == 1 ? 1.2 : 1.0))
                if driver.stats.reflexes < min(catCap, driver.stats.potential) { driver.stats.reflexes += (0.2 * simMultiplier) }
                if driver.stats.consistency < min(catCap, driver.stats.potential) { driver.stats.consistency += (0.1 * simMultiplier) }
                
            case .sponsorEvent:
                let stressCost = driverStaff.prLevel >= 2 ? 5.0 : 15.0
                driver.mental.stress += stressCost
                
            case .circuitStudy:
                driver.raceFocusModifier = 5.0
                
            case .rest:
                let stressRelief = driverStaff.physioLevel == 3 ? 70.0 : (driverStaff.physioLevel == 2 ? 50.0 : (driverStaff.physioLevel == 1 ? 35.0 : 20.0))
                let energyGain = driverStaff.physioLevel == 3 ? 80 : (driverStaff.physioLevel == 2 ? 60 : (driverStaff.physioLevel == 1 ? 50 : 40))
                driver.mental.stress = max(0, driver.mental.stress - stressRelief)
                driver.energy = min(driver.maxEnergy, driver.energy + energyGain)
            }
            saveGame()
        } 
    
    // MARK: - SISTEMA DI LICENZIAMENTO
    private func evaluatePlayerContract() {
        guard let driver = playerDriver, let teamID = driver.currentTeamID, let team = seasonManager.globalTeams.first(where: { $0.id == teamID }) else { return }
        
        // LO SCUDO DEL SUBENTRATO: Se hai più di 1 stagione rimanente, sei immune al licenziamento quest'anno.
        if let contract = driver.currentContract, contract.stagioniRimanenti > 1 {
            driver.currentContract = PlayerContract(teamID: contract.teamID, stipendioSettimanale: contract.stipendioSettimanale, buyInPagato: contract.buyInPagato, stagioniRimanenti: contract.stagioniRimanenti - 1, obiettiviTeam: contract.obiettiviTeam)
            return // Usciamo dalla funzione: niente verifiche di classifica
        }
        
        let standings = getCurrentDriverStandings(for: driver.category)
        guard let playerPos = standings.first(where: { $0.driverID == driver.id })?.position else { return }
        
        var expectedPos = standings.count
        if team.basePerformance >= 90 { expectedPos = max(1, Int(Double(standings.count) * 0.20)) }
        else if team.basePerformance >= 80 { expectedPos = max(1, Int(Double(standings.count) * 0.50)) }
        else if team.basePerformance >= 70 { expectedPos = max(1, Int(Double(standings.count) * 0.75)) }
        
        if playerPos > expectedPos {
            driver.currentTeamID = nil
            driver.currentContract = nil
            driver.reputation = max(0, driver.reputation - 25.0)
            driver.mental.stress = min(100.0, driver.mental.stress + 40.0)
            firingNotification = "🚨 LICENZIATO!\nLa dirigenza esigeva P\(expectedPos), hai chiuso in P\(playerPos)."
        } else if let contract = driver.currentContract, driver.pendingOffers.filter({ $0.status == .accepted }).isEmpty {
            driver.currentContract = PlayerContract(teamID: team.id, stipendioSettimanale: contract.stipendioSettimanale + (team.category == .f1 ? 5000.0 : 500.0), buyInPagato: 0, stagioniRimanenti: 1, obiettiviTeam: "Migliorare i risultati")
        }
    }
    
    
    func completaGaraSettimanale(results: [RaceResult] = [], style: DrivingStyle) {
        guard let driver = playerDriver else { return }
        careerRaces += 1
        
        if !results.isEmpty {
            let ptsTable = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1]
            for res in results {
                if res.position <= ptsTable.count && res.status == .finished {
                    let pts = ptsTable[res.position - 1]
                    driverPoints[res.driverID.uuidString, default: 0] += pts
                    if let d = seasonManager.globalDrivers.first(where: { $0.id == res.driverID }), let tID = d.currentTeamID {
                        teamPoints[tID.uuidString, default: 0] += pts
                    }
                }
            }
            if let p = results.first(where: { $0.driverID == driver.id }) {
                if p.position == 1 { careerWins += 1; careerPodiums += 1 } else if p.position <= 3 { careerPodiums += 1 }
                
                // VALUTAZIONE SPONSOR (Ora è dentro la parentesi di 'p'!)
                if activeSponsor != nil {
                    let prMultiplier = driverStaff.prLevel == 3 ? 2.0 : (driverStaff.prLevel == 2 ? 1.5 : (driverStaff.prLevel == 1 ? 1.2 : 1.0))
                    if p.position <= activeSponsor!.targetPosition {
                        let bonus = activeSponsor!.raceBonus * prMultiplier
                        funds += bonus
                        lastSponsorResult = "✅ Obiettivo P\(activeSponsor!.targetPosition) centrato! Bonus incassato: €\(Int(bonus))"
                    } else {
                        funds -= activeSponsor!.failurePenalty
                        lastSponsorResult = "❌ Obiettivo P\(activeSponsor!.targetPosition) fallito. Penale trattenuta: -€\(Int(activeSponsor!.failurePenalty))"
                    }
                    
                    activeSponsor!.racesRemaining -= 1
                    if activeSponsor!.racesRemaining <= 0 {
                        activeSponsor = nil
                        generateSponsorOffers()
                        lastSponsorResult = (lastSponsorResult ?? "") + "\n📝 Contratto sponsor concluso."
                    }
                }
            }
        }
            
        let repGain = driverStaff.prLevel == 3 ? 8.0 : (driverStaff.prLevel == 2 ? 5.0 : (driverStaff.prLevel == 1 ? 3.0 : 1.5))
        let baseStress = driverStaff.physioLevel == 3 ? 2.0 : (driverStaff.physioLevel == 2 ? 5.0 : (driverStaff.physioLevel == 1 ? 9.0 : 15.0))
        let stressGain = driverStaff.jetLevel == 1 ? 0.0 : baseStress
            driver.reputation = min(100.0, driver.reputation + repGain)
            driver.mental.stress = min(100.0, driver.mental.stress + stressGain)
        // --- SISTEMA DI CRESCITA SUL CAMPO ---
                    // Il limite in gara è leggermente più alto (+5) rispetto all'allenamento a casa
                    let raceCap: Double
                    switch driver.category { case .karting: raceCap = 60.0; case .f4: raceCap = 70.0; case .f3: raceCap = 80.0; case .f2: raceCap = 90.0; case .f1: raceCap = driver.stats.potential }
                    
                    var expGain = 0.5 // Esperienza base
                    
                    if style == .aggressive {
                        expGain = 1.2 // Guidare al limite insegna molto di più
                    } else if style == .conservative {
                        expGain = 0.2 // Guidare sicuri non ti fa migliorare
                    }
                    
                    // Migliora i riflessi (massimo fino al cap di gara o potenziale)
                    if driver.stats.reflexes < min(raceCap, driver.stats.potential) {
                        driver.stats.reflexes += expGain
                    }
                    // Migliora la gestione gomme
                    if driver.stats.tireManagement < min(raceCap, driver.stats.potential) {
                        driver.stats.tireManagement += (style == .conservative ? 0.8 : 0.1) // Chi salva le gomme impara a gestirle
                    }
                    // -------------------------------------
            var wearGain = 5.0
            if style == .aggressive { wearGain = 12.0 }
            else if style == .conservative { wearGain = 2.0 }
            
            engineWear = min(100.0, engineWear + wearGain + Double.random(in: 0...3))
            gearboxWear = min(100.0, gearboxWear + wearGain + Double.random(in: 0...2))
            
            seasonCalendar.removeValue(forKey: currentWeek)
            saveGame()
        }
        
        func advanceWeek() {
            guard let driver = playerDriver else { return }
            if seasonCalendar.keys.contains(currentWeek) { return }
            
            var weeklyCost = 500.0
            switch driver.category {
            case .karting: weeklyCost = 500.0
            case .f4: weeklyCost = 1500.0
            case .f3: weeklyCost = 3000.0
            case .f2: weeklyCost = 5000.0
            case .f1: weeklyCost = 15000.0
            }
            
            // INCOLLA QUESTO:
                        weeklyCost += driverStaff.weeklyCost
                        if let contract = driver.currentContract { funds += contract.stipendioSettimanale }
                        funds -= weeklyCost
                        
                        // LA BANCAROTTA: Se scendi sotto i -50.000€, l'entourage si dimette
                        if funds < -50_000.0 {
                            driverStaff = DriverStaff() // Reset totale dei livelli a 0
                            driver.mental.stress = 100.0
                            firingNotification = "📉 BANCAROTTA!\nSei sprofondato nei debiti. Il tuo Fisioterapista, il PR e i piloti del Jet si sono licenziati all'istante. Sei da solo e lo stress è al collasso."
                            funds = 0.0 // Ripartenza azzerata
                        }
            if let contract = driver.currentContract { funds += contract.stipendioSettimanale }
            funds -= weeklyCost
            
            driver.maxEnergy = driver.mental.stress > 70.0 ? max(50, 100 - Int(driver.mental.stress - 70.0)) : 100
            driver.energy = driver.maxEnergy
            actionsRemaining = 5
            currentWeek += 1
            
            simulateAllChampionshipsWeekly()
            simulateTeamDevelopment()
            
            if currentWeek == 26 || currentWeek == 45 {
                evaluateScoutingOffers(for: driver)
            }
            
            if currentWeek > 52 {
                // 1. Valutazione spietata della stagione appena conclusa
                evaluatePlayerContract()
                // IL TEAM REVISIONA L'AUTO A FINE ANNO
                engineWear = 0.0
                gearboxWear = 0.0
                // 2. Trasferimento o Disoccupazione
                if let accepted = driver.pendingOffers.first(where: { $0.status == .accepted }) {
                    funds -= accepted.requiredBuyIn
                    driver.currentTeamID = accepted.teamID
                    if driver.category != accepted.category {
                        driver.category = accepted.category
                    }
                    driver.currentContract = PlayerContract(teamID: accepted.teamID, stipendioSettimanale: accepted.offeredSalary, buyInPagato: accepted.requiredBuyIn, stagioniRimanenti: accepted.durationYears, obiettiviTeam: "Puntare al vertice")
                } else if driver.currentTeamID == nil {
                    evaluateScoutingOffers(for: driver)
                }
                
                archiviaStagioneCorrente()
                gestisciInvecchiamentoERitiri()
                gestisciMercatoPilotiIA()
                
                currentWeek = 1
                currentYear += 1
                if currentYear % 4 == 0 { applyRegulationChanges() }
                seasonManager.processEndSeason(playerID: driver.id)
                generateCalendar(for: driver.category)
                
                if driver.currentTeamID != nil {
                    driver.pendingOffers.removeAll()
                }
            }
            saveGame()
        }
        
        func archiviaStagioneCorrente() {
            guard let driver = playerDriver else { return }
            statHistory.append(StatSnapshot(year: currentYear, reflexes: driver.stats.reflexes, stamina: driver.stats.stamina, consistency: driver.stats.consistency))
            
            let driverStandings = getCurrentDriverStandings(for: driver.category)
            let teamStandings = getCurrentTeamStandings(for: driver.category)
            if let p = driverStandings.first(where: { $0.driverID == driver.id }), p.position == 1 { championshipsWon += 1 }
            historyDatabase.append(HistoricalSeason(year: currentYear, categoryName: driver.category.rawValue, driverStandings: driverStandings, teamStandings: teamStandings))
            
            driverPoints.removeAll()
            teamPoints.removeAll()
        }
        
        // ... qui finisce la tua ultima funzione precedente (es. completaGaraSettimanale o advanceWeek) ...

            // MARK: - SISTEMA DI SALVATAGGIO
            func saveGame() {
                guard let driver = playerDriver else { return }
                let snapshot = SaveData(playerDriver: driver, currentWeek: currentWeek, currentYear: currentYear, funds: funds, globalDrivers: seasonManager.globalDrivers, globalTeams: seasonManager.globalTeams, seasonCalendar: seasonCalendar, historyDatabase: historyDatabase, careerRaces: careerRaces, careerWins: careerWins, careerPodiums: careerPodiums, careerPoles: careerPoles, championshipsWon: championshipsWon, statHistory: statHistory, driverPoints: driverPoints, teamPoints: teamPoints, driverStaff: driverStaff, activeSponsor: activeSponsor, availableSponsors: availableSponsors, engineWear: engineWear, gearboxWear: gearboxWear)
                do {
                    let data = try JSONEncoder().encode(snapshot)
                    try data.write(to: saveFileURL(for: activeSlot))
                } catch { print("Errore salvataggio: \(error)") }
            }
            
            func loadGame(slot: Int) -> Bool {
                let url = saveFileURL(for: slot)
                guard FileManager.default.fileExists(atPath: url.path) else { return false }
                do {
                    let data = try Data(contentsOf: url)
                    let snapshot = try JSONDecoder().decode(SaveData.self, from: data)
                    self.activeSlot = slot
                    self.playerDriver = snapshot.playerDriver
                    self.currentWeek = snapshot.currentWeek
                    self.currentYear = snapshot.currentYear
                    self.funds = snapshot.funds
                    self.seasonCalendar = snapshot.seasonCalendar
                    self.historyDatabase = snapshot.historyDatabase
                    self.careerRaces = snapshot.careerRaces
                    self.careerWins = snapshot.careerWins
                    self.careerPodiums = snapshot.careerPodiums
                    self.careerPoles = snapshot.careerPoles
                    self.championshipsWon = snapshot.championshipsWon
                    self.statHistory = snapshot.statHistory
                    self.driverPoints = snapshot.driverPoints
                    self.teamPoints = snapshot.teamPoints
                    self.seasonManager.globalDrivers = snapshot.globalDrivers
                    self.seasonManager.globalTeams = snapshot.globalTeams
                    self.driverStaff = snapshot.driverStaff
                    
                    self.activeSponsor = snapshot.activeSponsor
                    self.availableSponsors = snapshot.availableSponsors
                    self.engineWear = snapshot.engineWear
                    self.gearboxWear = snapshot.gearboxWear
                    
                    if let p = self.playerDriver, let idx = self.seasonManager.globalDrivers.firstIndex(where: { $0.id == p.id }) {
                        self.seasonManager.globalDrivers[idx] = p
                    }
                    
                    return true
                } catch {
                    print("Errore caricamento: \(error)")
                    return false
                }
            }

        }
