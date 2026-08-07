import Foundation

class SeasonManager {
    var globalDrivers: [Driver] = []
    var globalTeams: [Team] = []
    
    func inizializzaCampionati() {
        if !globalTeams.isEmpty { return }
        
        globalTeams.removeAll()
        
        // 1. Formula 1 Teams (Griglia 2026 Reale con 11 Team)
        globalTeams.append(contentsOf: [
            Team(name: "Red Bull Racing", category: .f1, basePerformance: 99.0, budget: 140_000_000),
            Team(name: "Ferrari", category: .f1, basePerformance: 98.5, budget: 140_000_000),
            Team(name: "McLaren", category: .f1, basePerformance: 98.0, budget: 135_000_000),
            Team(name: "Mercedes", category: .f1, basePerformance: 97.0, budget: 140_000_000),
            Team(name: "Aston Martin", category: .f1, basePerformance: 89.0, budget: 120_000_000),
            Team(name: "Williams", category: .f1, basePerformance: 84.0, budget: 85_000_000),
            Team(name: "Alpine", category: .f1, basePerformance: 83.0, budget: 100_000_000),
            Team(name: "RB F1 Team", category: .f1, basePerformance: 82.5, budget: 90_000_000),
            Team(name: "Haas F1 Team", category: .f1, basePerformance: 81.0, budget: 85_000_000),
            Team(name: "Audi F1 Team", category: .f1, basePerformance: 80.0, budget: 110_000_000),
            Team(name: "Cadillac F1 Team", category: .f1, basePerformance: 77.0, budget: 100_000_000)
        ])
        
        // 2. Formula 2 Teams
        globalTeams.append(contentsOf: [
            Team(name: "Prema Racing", category: .f2, basePerformance: 92.0, budget: 6_000_000),
            Team(name: "ART Grand Prix", category: .f2, basePerformance: 90.0, budget: 5_500_000),
            Team(name: "Rodin Motorsport", category: .f2, basePerformance: 88.0, budget: 5_000_000),
            Team(name: "DAMS", category: .f2, basePerformance: 87.0, budget: 5_000_000),
            Team(name: "Invicta Racing", category: .f2, basePerformance: 89.0, budget: 5_200_000),
            Team(name: "MP Motorsport", category: .f2, basePerformance: 86.0, budget: 4_800_000),
            Team(name: "Campos Racing", category: .f2, basePerformance: 85.0, budget: 4_500_000),
            Team(name: "Hitech Pulse-Eight", category: .f2, basePerformance: 86.5, budget: 4_800_000),
            Team(name: "Trident", category: .f2, basePerformance: 83.0, budget: 4_000_000),
            Team(name: "Van Amersfoort Racing", category: .f2, basePerformance: 82.0, budget: 4_000_000)
        ])
        
        // 3. Formula 3 Teams
        globalTeams.append(contentsOf: [
            Team(name: "Prema Racing F3", category: .f3, basePerformance: 90.0, budget: 3_000_000),
            Team(name: "Trident F3", category: .f3, basePerformance: 88.0, budget: 2_800_000),
            Team(name: "ART Grand Prix F3", category: .f3, basePerformance: 87.0, budget: 2_700_000),
            Team(name: "Hitech F3", category: .f3, basePerformance: 85.0, budget: 2_500_000),
            Team(name: "MP Motorsport F3", category: .f3, basePerformance: 84.0, budget: 2_400_000),
            Team(name: "Campos F3", category: .f3, basePerformance: 83.0, budget: 2_300_000),
            Team(name: "Van Amersfoort F3", category: .f3, basePerformance: 81.0, budget: 2_100_000)
        ])
        
        // 4. Formula 4 Teams
        globalTeams.append(contentsOf: [
            Team(name: "Prema Racing F4", category: .f4, basePerformance: 78.0, budget: 1_200_000),
            Team(name: "US Racing", category: .f4, basePerformance: 76.0, budget: 1_100_000),
            Team(name: "Van Amersfoort F4", category: .f4, basePerformance: 75.0, budget: 1_050_000),
            Team(name: "R-ace GP", category: .f4, basePerformance: 74.0, budget: 950_000),
            Team(name: "PHM Racing", category: .f4, basePerformance: 72.0, budget: 900_000),
            Team(name: "Jenzer Motorsport", category: .f4, basePerformance: 70.0, budget: 850_000)
        ])
        
        // 5. Karting Teams
        globalTeams.append(contentsOf: [
            Team(name: "Tony Kart Racing Team", category: .karting, basePerformance: 88.0, budget: 600_000),
            Team(name: "CRG Racing Team", category: .karting, basePerformance: 86.0, budget: 550_000),
            Team(name: "Birel ART Racing", category: .karting, basePerformance: 85.0, budget: 520_000),
            Team(name: "Sodi Kart Official", category: .karting, basePerformance: 84.0, budget: 500_000),
            Team(name: "Parolin Racing Kart", category: .karting, basePerformance: 83.0, budget: 480_000),
            Team(name: "Energy Corse", category: .karting, basePerformance: 80.0, budget: 400_000),
            Team(name: "KR Motorsport", category: .karting, basePerformance: 55.0, budget: 200_000),
            Team(name: "Kosmic Racing Department", category: .karting, basePerformance: 48.0, budget: 150_000),
            Team(name: "Exprit Racing Team", category: .karting, basePerformance: 40.0, budget: 100_000)
        ])
    }
    
    func generaPilotiIniziali() {
            globalDrivers.removeAll()
            var newDrivers: [Driver] = []
            
            // Funzione universale per assegnare un pilota a qualsiasi categoria e team
            func assignDriver(fname: String, lname: String, nat: String, age: Int, stat: Double, category: RaceCategory, teamName: String) -> Driver {
                let stats = DriverStats(
                    reflexes: stat,
                    braking: stat,
                    consistency: stat,
                    wetWeather: stat * 0.9,
                    tireManagement: stat * 0.9,
                    stamina: category == .f1 ? 85 : 75,
                    potential: min(99.0, stat + Double.random(in: 3.0...15.0)) // I giovani hanno più margine di crescita
                )
                let driver = Driver(firstName: fname, lastName: lname, nationality: nat, age: age, category: category, stats: stats)
                driver.currentTeamID = globalTeams.first(where: { $0.name == teamName && $0.category == category })?.id
                return driver
            }
            
            // MARK: - FORMULA 1 (22 Piloti)
            newDrivers.append(contentsOf: [
                assignDriver(fname: "Max", lname: "Verstappen", nat: "NLD", age: 28, stat: 99.0, category: .f1, teamName: "Red Bull Racing"),
                assignDriver(fname: "Liam", lname: "Lawson", nat: "NZL", age: 24, stat: 85.0, category: .f1, teamName: "Red Bull Racing"),
                assignDriver(fname: "Charles", lname: "Leclerc", nat: "MCO", age: 28, stat: 97.0, category: .f1, teamName: "Ferrari"),
                assignDriver(fname: "Lewis", lname: "Hamilton", nat: "GBR", age: 41, stat: 96.5, category: .f1, teamName: "Ferrari"),
                assignDriver(fname: "Lando", lname: "Norris", nat: "GBR", age: 26, stat: 97.0, category: .f1, teamName: "McLaren"),
                assignDriver(fname: "Oscar", lname: "Piastri", nat: "AUS", age: 25, stat: 94.0, category: .f1, teamName: "McLaren"),
                assignDriver(fname: "George", lname: "Russell", nat: "GBR", age: 28, stat: 95.0, category: .f1, teamName: "Mercedes"),
                assignDriver(fname: "Andrea Kimi", lname: "Antonelli", nat: "ITA", age: 19, stat: 89.0, category: .f1, teamName: "Mercedes"),
                assignDriver(fname: "Fernando", lname: "Alonso", nat: "ESP", age: 44, stat: 93.0, category: .f1, teamName: "Aston Martin"),
                assignDriver(fname: "Lance", lname: "Stroll", nat: "CAN", age: 27, stat: 82.0, category: .f1, teamName: "Aston Martin"),
                assignDriver(fname: "Carlos", lname: "Sainz", nat: "ESP", age: 31, stat: 94.5, category: .f1, teamName: "Williams"),
                assignDriver(fname: "Alex", lname: "Albon", nat: "THA", age: 30, stat: 88.0, category: .f1, teamName: "Williams"),
                assignDriver(fname: "Pierre", lname: "Gasly", nat: "FRA", age: 30, stat: 87.0, category: .f1, teamName: "Alpine"),
                assignDriver(fname: "Jack", lname: "Doohan", nat: "AUS", age: 23, stat: 83.0, category: .f1, teamName: "Alpine"),
                assignDriver(fname: "Yuki", lname: "Tsunoda", nat: "JPN", age: 25, stat: 87.5, category: .f1, teamName: "RB F1 Team"),
                assignDriver(fname: "Isack", lname: "Hadjar", nat: "FRA", age: 21, stat: 84.5, category: .f1, teamName: "RB F1 Team"),
                assignDriver(fname: "Esteban", lname: "Ocon", nat: "FRA", age: 29, stat: 86.0, category: .f1, teamName: "Haas F1 Team"),
                assignDriver(fname: "Oliver", lname: "Bearman", nat: "GBR", age: 20, stat: 85.5, category: .f1, teamName: "Haas F1 Team"),
                assignDriver(fname: "Nico", lname: "Hülkenberg", nat: "DEU", age: 38, stat: 86.5, category: .f1, teamName: "Audi F1 Team"),
                assignDriver(fname: "Gabriel", lname: "Bortoleto", nat: "BRA", age: 21, stat: 85.0, category: .f1, teamName: "Audi F1 Team"),
                assignDriver(fname: "Valtteri", lname: "Bottas", nat: "FIN", age: 36, stat: 84.0, category: .f1, teamName: "Cadillac F1 Team"),
                assignDriver(fname: "Franco", lname: "Colapinto", nat: "ARG", age: 22, stat: 85.0, category: .f1, teamName: "Cadillac F1 Team")
            ])
            
            // MARK: - FORMULA 2 (20 Piloti - 2 per i 10 Team definiti)
            newDrivers.append(contentsOf: [
                assignDriver(fname: "Paul", lname: "Aron", nat: "EST", age: 22, stat: 83.0, category: .f2, teamName: "Prema Racing"),
                assignDriver(fname: "Dino", lname: "Beganovic", nat: "SWE", age: 22, stat: 81.0, category: .f2, teamName: "Prema Racing"),
                assignDriver(fname: "Victor", lname: "Martins", nat: "FRA", age: 24, stat: 82.5, category: .f2, teamName: "ART Grand Prix"),
                assignDriver(fname: "Luke", lname: "Browning", nat: "GBR", age: 21, stat: 80.0, category: .f2, teamName: "ART Grand Prix"),
                assignDriver(fname: "Zane", lname: "Maloney", nat: "BRB", age: 22, stat: 83.5, category: .f2, teamName: "Rodin Motorsport"),
                assignDriver(fname: "Ritomo", lname: "Miyata", nat: "JPN", age: 26, stat: 80.5, category: .f2, teamName: "Rodin Motorsport"),
                assignDriver(fname: "Jak", lname: "Crawford", nat: "USA", age: 20, stat: 81.0, category: .f2, teamName: "DAMS"),
                assignDriver(fname: "Juan Manuel", lname: "Correa", nat: "USA", age: 26, stat: 78.0, category: .f2, teamName: "DAMS"),
                assignDriver(fname: "Kush", lname: "Maini", nat: "IND", age: 25, stat: 80.0, category: .f2, teamName: "Invicta Racing"),
                assignDriver(fname: "Enzo", lname: "Fittipaldi", nat: "BRA", age: 24, stat: 79.5, category: .f2, teamName: "Invicta Racing"),
                assignDriver(fname: "Dennis", lname: "Hauger", nat: "NOR", age: 23, stat: 82.0, category: .f2, teamName: "MP Motorsport"),
                assignDriver(fname: "Richard", lname: "Verschoor", nat: "NLD", age: 25, stat: 80.0, category: .f2, teamName: "MP Motorsport"),
                assignDriver(fname: "Pepe", lname: "Martí", nat: "ESP", age: 20, stat: 79.0, category: .f2, teamName: "Campos Racing"),
                assignDriver(fname: "Oliver", lname: "Goethe", nat: "DEU", age: 21, stat: 78.5, category: .f2, teamName: "Campos Racing"),
                assignDriver(fname: "Taylor", lname: "Barnard", nat: "GBR", age: 21, stat: 79.0, category: .f2, teamName: "Hitech Pulse-Eight"),
                assignDriver(fname: "Amaury", lname: "Cordeel", nat: "BEL", age: 23, stat: 75.0, category: .f2, teamName: "Hitech Pulse-Eight"),
                assignDriver(fname: "Roman", lname: "Stanek", nat: "CZE", age: 22, stat: 77.0, category: .f2, teamName: "Trident"),
                assignDriver(fname: "Leonardo", lname: "Fornaroli", nat: "ITA", age: 21, stat: 81.5, category: .f2, teamName: "Trident"),
                assignDriver(fname: "Rafael", lname: "Villagómez", nat: "MEX", age: 24, stat: 74.0, category: .f2, teamName: "Van Amersfoort Racing"),
                assignDriver(fname: "Joshua", lname: "Duerksen", nat: "PRY", age: 22, stat: 78.0, category: .f2, teamName: "Van Amersfoort Racing")
            ])
            
            // MARK: - FORMULA 3 (14 Piloti - 2 per i 7 Team definiti)
            newDrivers.append(contentsOf: [
                assignDriver(fname: "Arvid", lname: "Lindblad", nat: "GBR", age: 18, stat: 77.0, category: .f3, teamName: "Prema Racing F3"),
                assignDriver(fname: "Gabriele", lname: "Minì", nat: "ITA", age: 21, stat: 79.0, category: .f3, teamName: "Prema Racing F3"),
                assignDriver(fname: "Sami", lname: "Meguetounif", nat: "FRA", age: 21, stat: 76.0, category: .f3, teamName: "Trident F3"),
                assignDriver(fname: "Santiago", lname: "Ramos", nat: "MEX", age: 22, stat: 74.0, category: .f3, teamName: "Trident F3"),
                assignDriver(fname: "Laurens", lname: "van Hoepen", nat: "NLD", age: 19, stat: 75.5, category: .f3, teamName: "ART Grand Prix F3"),
                assignDriver(fname: "Christian", lname: "Mansell", nat: "AUS", age: 21, stat: 76.5, category: .f3, teamName: "ART Grand Prix F3"),
                assignDriver(fname: "Cian", lname: "Shields", nat: "GBR", age: 19, stat: 72.0, category: .f3, teamName: "Hitech F3"),
                assignDriver(fname: "Martinius", lname: "Stenshorne", nat: "NOR", age: 19, stat: 75.0, category: .f3, teamName: "Hitech F3"),
                assignDriver(fname: "Tim", lname: "Tramnitz", nat: "DEU", age: 21, stat: 76.0, category: .f3, teamName: "MP Motorsport F3"),
                assignDriver(fname: "Kacper", lname: "Sztuka", nat: "POL", age: 19, stat: 73.0, category: .f3, teamName: "MP Motorsport F3"),
                assignDriver(fname: "Mari", lname: "Boya", nat: "ESP", age: 21, stat: 75.5, category: .f3, teamName: "Campos F3"),
                assignDriver(fname: "Sebastian", lname: "Montoya", nat: "COL", age: 20, stat: 74.5, category: .f3, teamName: "Campos F3"),
                assignDriver(fname: "Noel", lname: "León", nat: "MEX", age: 21, stat: 73.5, category: .f3, teamName: "Van Amersfoort F3"),
                assignDriver(fname: "Tommy", lname: "Smith", nat: "AUS", age: 23, stat: 70.0, category: .f3, teamName: "Van Amersfoort F3")
            ])
            
            // MARK: - FORMULA 4 (12 Piloti - 2 per i 6 Team definiti)
            newDrivers.append(contentsOf: [
                assignDriver(fname: "Freddie", lname: "Slater", nat: "GBR", age: 17, stat: 71.0, category: .f4, teamName: "Prema Racing F4"),
                assignDriver(fname: "Kean", lname: "Nakamura-Berta", nat: "JPN", age: 18, stat: 69.5, category: .f4, teamName: "Prema Racing F4"),
                assignDriver(fname: "Jack", lname: "Beeton", nat: "AUS", age: 17, stat: 68.0, category: .f4, teamName: "US Racing"),
                assignDriver(fname: "Akshay", lname: "Bohra", nat: "SGP", age: 18, stat: 67.5, category: .f4, teamName: "US Racing"),
                assignDriver(fname: "Hiyu", lname: "Yamakoshi", nat: "JPN", age: 18, stat: 68.5, category: .f4, teamName: "Van Amersfoort F4"),
                assignDriver(fname: "Lin", lname: "Hanhui", nat: "CHN", age: 17, stat: 64.0, category: .f4, teamName: "Van Amersfoort F4"),
                assignDriver(fname: "Enzo", lname: "Tarnvanichkul", nat: "THA", age: 17, stat: 67.0, category: .f4, teamName: "R-ace GP"),
                assignDriver(fname: "Luka", lname: "Sammalisto", nat: "FIN", age: 18, stat: 65.5, category: .f4, teamName: "R-ace GP"),
                assignDriver(fname: "Rashid", lname: "Al Dhaheri", nat: "ARE", age: 17, stat: 66.0, category: .f4, teamName: "PHM Racing"),
                assignDriver(fname: "Maksimilian", lname: "Popov", nat: "ITA", age: 18, stat: 63.5, category: .f4, teamName: "PHM Racing"),
                assignDriver(fname: "Reno", lname: "Francot", nat: "NLD", age: 17, stat: 65.0, category: .f4, teamName: "Jenzer Motorsport"),
                assignDriver(fname: "Enea", lname: "Frey", nat: "CHE", age: 18, stat: 64.5, category: .f4, teamName: "Jenzer Motorsport")
            ])
            
            // MARK: - KARTING (18 Piloti - 2 per i 9 Team definiti)
            newDrivers.append(contentsOf: [
                assignDriver(fname: "Joe", lname: "Turney", nat: "GBR", age: 22, stat: 62.0, category: .karting, teamName: "Tony Kart Racing Team"),
                assignDriver(fname: "Scott", lname: "Lindblom", nat: "SWE", age: 16, stat: 58.5, category: .karting, teamName: "Tony Kart Racing Team"),
                assignDriver(fname: "Gabriel", lname: "Gomez", nat: "BRA", age: 17, stat: 60.0, category: .karting, teamName: "CRG Racing Team"),
                assignDriver(fname: "Louis", lname: "Iglesias", nat: "FRA", age: 16, stat: 57.0, category: .karting, teamName: "CRG Racing Team"),
                assignDriver(fname: "Matheus", lname: "Morgatto", nat: "BRA", age: 20, stat: 61.0, category: .karting, teamName: "Birel ART Racing"),
                assignDriver(fname: "Ean", lname: "Eyckmans", nat: "BEL", age: 16, stat: 56.5, category: .karting, teamName: "Birel ART Racing"),
                assignDriver(fname: "Noah", lname: "Wolfe", nat: "GBR", age: 15, stat: 55.0, category: .karting, teamName: "Sodi Kart Official"),
                assignDriver(fname: "Iacopo", lname: "Martino", nat: "ITA", age: 15, stat: 54.5, category: .karting, teamName: "Sodi Kart Official"),
                assignDriver(fname: "Christian", lname: "Costoya", nat: "ESP", age: 15, stat: 57.5, category: .karting, teamName: "Parolin Racing Kart"),
                assignDriver(fname: "Filippo", lname: "Sala", nat: "ITA", age: 15, stat: 53.0, category: .karting, teamName: "Parolin Racing Kart"),
                assignDriver(fname: "Tomass", lname: "Stolcermanis", nat: "LVA", age: 17, stat: 58.0, category: .karting, teamName: "Energy Corse"),
                assignDriver(fname: "Dries", lname: "van Langendonck", nat: "BEL", age: 14, stat: 56.0, category: .karting, teamName: "Energy Corse"),
                assignDriver(fname: "Vladimir", lname: "Ivannikov", nat: "ITA", age: 15, stat: 52.0, category: .karting, teamName: "KR Motorsport"),
                assignDriver(fname: "Thibaut", lname: "Ramaekers", nat: "BEL", age: 15, stat: 53.5, category: .karting, teamName: "KR Motorsport"),
                assignDriver(fname: "David", lname: "Walther", nat: "DNK", age: 16, stat: 55.5, category: .karting, teamName: "Kosmic Racing Department"),
                assignDriver(fname: "Noah", lname: "Monteiro", nat: "PRT", age: 15, stat: 51.0, category: .karting, teamName: "Kosmic Racing Department"),
                assignDriver(fname: "Oscar", lname: "Wurz", nat: "AUT", age: 16, stat: 54.0, category: .karting, teamName: "Exprit Racing Team"),
                assignDriver(fname: "Augusto", lname: "Toniolo", nat: "BRA", age: 15, stat: 50.5, category: .karting, teamName: "Exprit Racing Team")
            ])
            
            self.globalDrivers.append(contentsOf: newDrivers)
        }
    
    // MARK: - MOTORE GENERAZIONALE E MERCATO PILOTI
    func processEndSeason(playerID: UUID?) {
        var retiringDrivers: [UUID] = []
        
        // 1. Invecchiamento e Sviluppo Statistiche
        for driver in globalDrivers {
            driver.age += 1
            
            // Escludiamo il giocatore dalla progressione passiva (si allena attivamente tramite il QG)
            if driver.id != playerID {
                if driver.age < 28 {
                    // I giovani crescono verso il loro potenziale
                    let growthRoom = driver.stats.potential - driver.stats.reflexes
                    if growthRoom > 0 {
                        driver.stats.reflexes += growthRoom * Double.random(in: 0.05...0.12)
                        driver.stats.consistency += growthRoom * Double.random(in: 0.05...0.12)
                        driver.stats.stamina = min(99.0, driver.stats.stamina + 1.0)
                    }
                } else if driver.age > 34 {
                    // Declino inesorabile dei veterani
                    let decay = Double.random(in: 0.5...2.5)
                    driver.stats.reflexes = max(20.0, driver.stats.reflexes - decay)
                    driver.stats.stamina = max(20.0, driver.stats.stamina - decay)
                }
                
                // Logica Ritiro: Troppo vecchi o troppo scarsi
                if driver.age >= 40 || (driver.age > 35 && driver.stats.reflexes < 70.0) {
                    retiringDrivers.append(driver.id)
                }
            }
        }
        
        // 2. Esecuzione Ritiri
        globalDrivers.removeAll { retiringDrivers.contains($0.id) }
        
        // 3. Mercato Piloti (L'Effetto Domino)
        eseguiMercatoPiloti(playerID: playerID)
    }
    
    private func eseguiMercatoPiloti(playerID: UUID?) {
        let categories: [RaceCategory] = [.f1, .f2, .f3, .f4, .karting]
        
        // Promozioni dall'alto verso il basso
        for i in 0..<(categories.count - 1) {
            let currentCat = categories[i]
            let lowerCat = categories[i+1]
            let currentTeams = globalTeams.filter { $0.category == currentCat }
            
            for team in currentTeams {
                let driversInTeam = globalDrivers.filter { $0.currentTeamID == team.id }
                let emptySeats = 2 - driversInTeam.count
                
                if emptySeats > 0 {
                    // Peschiamo i migliori talenti della categoria inferiore per riempire il vuoto
                    let candidates = globalDrivers.filter { $0.category == lowerCat && $0.currentTeamID != nil && $0.id != playerID }
                        .sorted { ($0.stats.reflexes + $0.stats.consistency) > ($1.stats.reflexes + $1.stats.consistency) }
                    
                    for j in 0..<min(emptySeats, candidates.count) {
                        let promotedDriver = candidates[j]
                        promotedDriver.category = currentCat
                        promotedDriver.currentTeamID = team.id
                    }
                }
            }
        }
        
        // 4. Ripopolamento Karting (Generazione vivaio)
        let kartingTeams = globalTeams.filter { $0.category == .karting }
        for team in kartingTeams {
            let driversInTeam = globalDrivers.filter { $0.currentTeamID == team.id }
            let emptySeats = 2 - driversInTeam.count
            
            if emptySeats > 0 {
                for _ in 0..<emptySeats {
                    globalDrivers.append(generateSingleRookie(for: team))
                }
            }
        }
    }
    
    private func generateSingleRookie(for team: Team) -> Driver {
        let fNames = ["Leo", "Oscar", "Jules", "Diego", "Kimi", "Mick", "Arthur", "Enzo", "Liam"]
        let lNames = ["Bianchi", "Russo", "Browning", "Lindblad", "Camara", "Antonelli", "Bearman", "Marti", "O'Ward"]
        let nations = ["ITA", "GBR", "FRA", "ESP", "DEU", "BRA", "USA"]
        
        let baseStat = Double.random(in: 25.0...40.0)
        let stats = DriverStats(reflexes: baseStat, braking: baseStat, consistency: baseStat, wetWeather: baseStat, tireManagement: baseStat, stamina: 70, potential: Double.random(in: 75.0...96.0))
        
        let rookie = Driver(firstName: fNames.randomElement()!, lastName: lNames.randomElement()!, nationality: nations.randomElement()!, age: Int.random(in: 14...16), category: .karting, stats: stats)
        rookie.currentTeamID = team.id
        return rookie
    }
}
