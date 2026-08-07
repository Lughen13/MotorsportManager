import Foundation
import Observation

// 1. Reintroduciamo DrivingStyle per tutto il progetto
enum DrivingStyle: String, Codable, CaseIterable {
    case aggressive = "Spingi"
    case neutral = "Neutrale"
    case conservative = "Conserva"
}

enum LiveRaceStatus: String {
    case racing = "In Pista"
    case finished = "Traguardo"
    case retired = "Motore Fuso"
    case crashed = "Incidente"
}

struct LiveCar: Identifiable {
    let id: UUID // Corrisponde all'ID del Pilota reale
    var driverName: String
    var basePace: Double
    var tiresCondition: Double
    var currentPosition: Int
    var status: LiveRaceStatus
    var lastLapTime: Double = 0.0
    var totalRaceTime: Double = 0.0
}

@Observable
class RaceSimulationEngine {
    var liveCars: [LiveCar] = []
    var currentLap: Int = 0
    var totalLaps: Int = 0
    var raceLog: [String] = []
    var isRaceFinished: Bool = false
    
    func setupGrid(drivers: [Driver], teams: [Team], track: RaceTrack) {
            var grid: [LiveCar] = []
            
            for (index, driver) in drivers.enumerated() {
                let team = teams.first(where: { $0.id == driver.currentTeamID })
                let teamPerf = team?.basePerformance ?? 40.0
                
                // PESI DINAMICI IN BASE ALLA CATEGORIA
                // Nel Karting il pilota vale l'80%, il team il 20%. In F1 è il contrario.
                let driverWeight: Double = (track.category == .karting) ? 0.8 : 0.3
                let carWeight: Double = 1.0 - driverWeight
                
                // Calcolo dell'abilità complessiva del pilota basata sulle sue vere stats
                let driverSkill = (driver.stats.reflexes + driver.stats.braking + driver.stats.consistency) / 3.0
                
                let driverImpact = driverSkill * driverWeight
                let carImpact = teamPerf * carWeight
                
                // Base pace calcolata dinamicamente in base alla sinergia pilota-auto
                let performanceMultiplier = 2.0 - ((driverImpact + carImpact) / 100.0)
                let basePace = track.baseLapTime * max(0.7, performanceMultiplier)
                
                let car = LiveCar(
                    id: driver.id,
                    driverName: driver.name,
                    basePace: basePace,
                    tiresCondition: 100.0,
                    currentPosition: 0,
                    status: .racing
                )
                grid.append(car)
            }
            
            // Qualifica fittizia basata sul passo teorico per ora
            grid.sort { $0.basePace < $1.basePace }
            for i in 0..<grid.count {
                grid[i].currentPosition = i + 1
            }
            
            self.liveCars = grid
            self.totalLaps = track.totalLaps
            self.currentLap = 0
            self.isRaceFinished = false
            self.raceLog = ["🟢 SEMAFORO VERDE! Inizia il GP di \(track.name)!"]
        }
    
    func simulateLap(playerStyle: DrivingStyle, track: RaceTrack, playerID: UUID, playerEngineWear: Double, activeDrivers: [Driver]) {
            guard currentLap < totalLaps && !isRaceFinished else { return }
            currentLap += 1
            
            let isKarting = track.category == .karting
            
            // 1. Ordina per tempo per sapere chi è davanti a chi fisicamente in questo istante
            liveCars.sort { $0.totalRaceTime < $1.totalRaceTime }
            
            for i in 0..<liveCars.count {
                guard liveCars[i].status == .racing else { continue }
                
                let isPlayer = liveCars[i].id == playerID
                let style = isPlayer ? playerStyle : .neutral
                
                // IL PONTE LOGICO: Recupera il VERO pilota dal database
                let realDriver = activeDrivers.first(where: { $0.id == liveCars[i].id })
                let brakingStat = realDriver?.stats.braking ?? 50.0
                let reflexStat = realDriver?.stats.reflexes ?? 50.0
                
                var lapTime = liveCars[i].basePace + Double.random(in: -0.1...0.3)
                
                // A. LOGICA USURA (I Kart non consumano gomme pesantemente)
                if !isKarting {
                    var tireDegradation = track.baseTireWear * Double.random(in: 0.8...1.2)
                    if style == .aggressive { tireDegradation *= 1.8 }
                    else if style == .conservative { tireDegradation *= 0.5 }
                    
                    liveCars[i].tiresCondition = max(0, liveCars[i].tiresCondition - tireDegradation)
                    
                    let tirePenalty = liveCars[i].tiresCondition < 30.0 ? ((30.0 - liveCars[i].tiresCondition) * 0.15) : 0.0
                    lapTime += tirePenalty
                } else {
                    if style == .aggressive { lapTime += Double.random(in: 0.0...0.2) } // Leggero drop di stamina simulato
                }
                
                // B. STILE DI GUIDA BASE
                if style == .aggressive { lapTime -= 0.6 }
                else if style == .conservative { lapTime += 0.8 }
                
                // C. EFFETTO SCIA E BATTAGLIE SULLE VERE STATS
                if i > 0 && liveCars[i-1].status == .racing {
                    let gapAhead = liveCars[i].totalRaceTime - liveCars[i-1].totalRaceTime
                    
                    if gapAhead < 1.2 {
                        lapTime -= 0.3 // Bonus scia
                        
                        if style == .aggressive || brakingStat > 70 {
                            // Il successo dipende da chi guida, non dal puro caso
                            let attackPower = Double(brakingStat + reflexStat) / 2.0
                            let successThreshold = 100.0 - attackPower
                            
                            let battleRoll = Double.random(in: 0...100)
                            
                            if battleRoll > successThreshold {
                                lapTime -= 0.6
                                raceLog.insert("⚔️ AFFONDO MAGISTRALE! \(liveCars[i].driverName) infila \(liveCars[i-1].driverName) in staccata!", at: 0)
                            } else if battleRoll > 20 {
                                lapTime += 0.3
                                raceLog.insert("🛡️ Duello duro: \(liveCars[i-1].driverName) difende la posizione.", at: 0)
                            } else {
                                liveCars[i].status = .crashed
                                raceLog.insert("💥 ERRORE CRITICO! \(liveCars[i].driverName) sbaglia i freni nel duello e finisce a muro!", at: 0)
                                continue
                            }
                        }
                    }
                }
                
                // D. ROTTURE MECCANICHE E FORATURE
                let riskRoll = Double.random(in: 0...100)
                
                if isPlayer && riskRoll > (100.0 - (playerEngineWear * 0.1)) && style == .aggressive {
                    liveCars[i].status = .retired
                    raceLog.insert("🔥 MOTORE IN FUMO! Il motore di \(liveCars[i].driverName) ha ceduto!", at: 0)
                    continue
                }
                
                if !isKarting && liveCars[i].tiresCondition < 15 && riskRoll > 85 {
                    raceLog.insert("⚠️ FORATURA per \(liveCars[i].driverName)! Costretto al pit-stop.", at: 0)
                    lapTime += 25.0
                    liveCars[i].tiresCondition = 100.0
                } else if style == .aggressive && riskRoll > 98 {
                    liveCars[i].status = .crashed
                    raceLog.insert("💥 INCIDENTE! \(liveCars[i].driverName) perde il controllo da solo!", at: 0)
                    continue
                }
                
                liveCars[i].lastLapTime = lapTime
                liveCars[i].totalRaceTime += lapTime
            }
            
            // 3. RIORDINA LA CLASSIFICA
            liveCars.sort {
                if $0.status != $1.status { return $0.status == .racing }
                return $0.totalRaceTime < $1.totalRaceTime
            }
            
            // 4. AGGIORNA LE POSIZIONI VISIVE
            var currentPos = 1
            for i in 0..<liveCars.count {
                if liveCars[i].status == .racing {
                    liveCars[i].currentPosition = currentPos
                    currentPos += 1
                }
            }
            
            if currentLap >= totalLaps {
                isRaceFinished = true
                raceLog.insert("🏁 BANDIERA A SCACCHI! Vince \(liveCars.first?.driverName ?? "Nessuno").", at: 0)
                for i in 0..<liveCars.count {
                    if liveCars[i].status == .racing { liveCars[i].status = .finished }
                }
            }
        }
}
