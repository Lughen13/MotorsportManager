import SwiftUI

struct DriverDashboardView: View {
    @Environment(GameState.self) private var gameState
    @State private var selectedHistoricalYear: Int?
    @State private var viewingCategory: RaceCategory = .karting
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let driver = gameState.playerDriver {
                    
                    // SEZIONE 1: SCHEDA BIOGRAFICA & TROFEI
                    biographyHeaderSection(driver: driver)
                    
                    // SEZIONE 2: CLASSIFICA CAMPIONATO CORRENTE (CON SELETTORE CATEGORIA)
                    currentChampionshipSection()
                    
                    // SEZIONE 3: EVOLUZIONE COMPETENZE
                    skillsEvolutionSection(driver: driver)
                    
                    // SEZIONE 4: ALBO D'ORO (STORICO CAMPIONATI)
                    historicalArchiveSection()
                    
                } else {
                    Text("Nessun pilota attivo.")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard Pilota")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if let driver = gameState.playerDriver {
                viewingCategory = driver.category
            }
            if selectedHistoricalYear == nil {
                selectedHistoricalYear = gameState.historyDatabase.last?.year
            }
        }
    }
    
    // MARK: - 1. Scheda Biografica e Bacheca Trofei
    @ViewBuilder
    private func biographyHeaderSection(driver: Driver) -> some View {
        let stats = CareerSummary(races: gameState.careerRaces, wins: gameState.careerWins, podiums: gameState.careerPodiums, poles: gameState.careerPoles, championships: gameState.championshipsWon)
        let currentTeamName = gameState.seasonManager.globalTeams.first(where: { $0.id == driver.currentTeamID })?.name ?? "Svincolato"
        
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 65, height: 65)
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(driver.name)
                        .font(.title3)
                        .bold()
                    Text("\(driver.nationality) • \(driver.age) anni")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Team: \(currentTeamName)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(title: "Mondiali", value: "\(stats.championships)", icon: "trophy.fill", color: .yellow)
                statCard(title: "Vittorie", value: "\(stats.wins)", icon: "flag.checkered", color: .green)
                statCard(title: "Podi", value: "\(stats.podiums)", icon: "medal.fill", color: .orange)
                statCard(title: "Pole Position", value: "\(stats.poles)", icon: "timer", color: .purple)
                statCard(title: "Gare", value: "\(stats.races)", icon: "car.fill", color: .blue)
                statCard(title: "Reputazione", value: "\(Int(driver.reputation))%", icon: "star.fill", color: .pink)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
            Text(value)
                .font(.headline)
                .bold()
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    // MARK: - 2. Classifica Campionato Corrente con Filtro Categoria
    @ViewBuilder
    private func currentChampionshipSection() -> some View {
        let driverStandings = gameState.getCurrentDriverStandings(for: viewingCategory)
        let teamStandings = gameState.getCurrentTeamStandings(for: viewingCategory)
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Classifiche Stagione (\(gameState.currentYear))")
                    .font(.headline)
                Spacer()
                Picker("Categoria", selection: $viewingCategory) {
                    Text("Karting").tag(RaceCategory.karting)
                    Text("F4").tag(RaceCategory.f4)
                    Text("F3").tag(RaceCategory.f3)
                    Text("F2").tag(RaceCategory.f2)
                    Text("F1").tag(RaceCategory.f1)
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Tab Piloti
            VStack(alignment: .leading, spacing: 8) {
                Text("Campionato Piloti - \(viewingCategory.rawValue)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                
                ForEach(driverStandings.prefix(10)) { entry in
                    HStack {
                        Text("P\(entry.position)")
                            .font(.caption)
                            .bold()
                            .frame(width: 30, alignment: .leading)
                        Text(entry.driverName)
                            .font(.caption)
                            .fontWeight(entry.driverID == gameState.playerDriver?.id ? .bold : .regular)
                            .foregroundColor(entry.driverID == gameState.playerDriver?.id ? .blue : .primary)
                        Spacer()
                        Text("\(entry.points) pt")
                            .font(.caption)
                            .bold()
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Tab Costruttori
            VStack(alignment: .leading, spacing: 8) {
                Text("Campionato Costruttori - \(viewingCategory.rawValue)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                
                ForEach(teamStandings) { entry in
                    HStack {
                        Text("P\(entry.position)")
                            .font(.caption)
                            .bold()
                            .frame(width: 30, alignment: .leading)
                        Text(entry.teamName)
                            .font(.caption)
                        Spacer()
                        Text("\(entry.points) pt")
                            .font(.caption)
                            .bold()
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    // MARK: - 3. Evoluzione Competenze
    @ViewBuilder
    private func skillsEvolutionSection(driver: Driver) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evoluzione Competenze e Potenziale")
                .font(.headline)
            
            VStack(spacing: 12) {
                skillBar(title: "Riflessi", current: driver.stats.reflexes, potential: driver.stats.potential)
                skillBar(title: "Staccata", current: driver.stats.braking, potential: driver.stats.potential)
                skillBar(title: "Costanza", current: driver.stats.consistency, potential: driver.stats.potential)
                skillBar(title: "Guida sul Bagnato", current: driver.stats.wetWeather, potential: driver.stats.potential)
                skillBar(title: "Gestione Gomme", current: driver.stats.tireManagement, potential: driver.stats.potential)
                skillBar(title: "Stamina", current: driver.stats.stamina, potential: driver.stats.potential)
            }
            
            let history = gameState.statHistory
            if !history.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                Text("Crescita Storica per Anno")
                    .font(.subheadline)
                    .bold()
                
                ForEach(history) { snapshot in
                    HStack {
                        Text("Anno \(snapshot.year)")
                            .font(.caption)
                            .bold()
                        Spacer()
                        Text("Riflessi: \(Int(snapshot.reflexes))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Costanza: \(Int(snapshot.consistency))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    @ViewBuilder
    private func skillBar(title: String, current: Double, potential: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(current)) / \(Int(potential))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: current, total: potential)
                .tint(.blue)
        }
    }
    
    // MARK: - 4. Albo d'Oro (Storico Campionati)
    @ViewBuilder
    private func historicalArchiveSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Albo d'Oro e Storico Campionati")
                .font(.headline)
            
            if gameState.historyDatabase.isEmpty {
                Text("Nessuna stagione archiviata. Completa almeno un anno di gare per sbloccare l'albo d'oro.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                Picker("Seleziona Stagione", selection: $selectedHistoricalYear) {
                    ForEach(gameState.historyDatabase) { season in
                        Text("Stagione \(season.year) (\(season.categoryName))").tag(Optional(season.year))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if let year = selectedHistoricalYear,
                   let season = gameState.historyDatabase.first(where: { $0.year == year }) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Classifica Piloti (\(season.year))")
                            .font(.subheadline)
                            .bold()
                        
                        ForEach(season.driverStandings.prefix(5)) { entry in
                            HStack {
                                Text("P\(entry.position)")
                                    .font(.caption)
                                    .bold()
                                    .frame(width: 30, alignment: .leading)
                                Text(entry.driverName)
                                    .font(.caption)
                                Spacer()
                                Text("\(entry.points) pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 2)
                        
                        Text("Classifica Costruttori (\(season.year))")
                            .font(.subheadline)
                            .bold()
                        
                        ForEach(season.teamStandings.prefix(3)) { entry in
                            HStack {
                                Text("P\(entry.position)")
                                    .font(.caption)
                                    .bold()
                                    .frame(width: 30, alignment: .leading)
                                Text(entry.teamName)
                                    .font(.caption)
                                Spacer()
                                Text("\(entry.points) pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
