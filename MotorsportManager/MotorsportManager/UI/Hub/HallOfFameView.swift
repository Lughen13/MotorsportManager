import SwiftUI

struct HallOfFameView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                if gameState.historyDatabase.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill").font(.system(size: 50)).foregroundColor(.secondary)
                        Text("Nessuna Eredità").font(.title2).bold()
                        Text("Il database storico è vuoto. Completa la tua prima stagione per inaugurare l'Albo d'Oro.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        // Raggruppa storicamente per anno decrescente
                        let groupedSeasons = Dictionary(grouping: gameState.historyDatabase, by: { $0.year })
                        let sortedYears = groupedSeasons.keys.sorted(by: >)
                        
                        ForEach(sortedYears, id: \.self) { year in
                            Section(header: Text("Stagione \(String(year))").font(.headline)) {
                                let seasons = groupedSeasons[year] ?? []
                                // Ordina per importanza della categoria
                                let sortedSeasons = seasons.sorted { rank(category: $0.categoryName) < rank(category: $1.categoryName) }
                                
                                ForEach(sortedSeasons) { season in
                                    if let champ = season.driverStandings.first {
                                        HStack {
                                            Text(season.categoryName.uppercased())
                                                .font(.caption).bold()
                                                .foregroundColor(.white)
                                                .frame(width: 60)
                                                .padding(.vertical, 4)
                                                .background(color(for: season.categoryName))
                                                .cornerRadius(6)
                                            
                                            VStack(alignment: .leading) {
                                                Text(champ.driverName).font(.subheadline).bold()
                                                if let teamChamp = season.teamStandings.first {
                                                    Text(teamChamp.teamName).font(.caption2).foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // La Stella del Giocatore
                                            if champ.driverID == gameState.playerDriver?.id {
                                                Image(systemName: "star.fill").foregroundColor(.orange)
                                            }
                                            Image(systemName: "trophy.fill").foregroundColor(.yellow)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Albo d'Oro")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Assegna un peso alle categorie per l'ordinamento visivo
    private func rank(category: String) -> Int {
        switch category.lowercased() {
        case "f1": return 1
        case "f2": return 2
        case "f3": return 3
        case "f4": return 4
        default: return 5
        }
    }
    
    // Colori distintivi per l'interfaccia
    private func color(for category: String) -> Color {
        switch category.lowercased() {
        case "f1": return .red
        case "f2": return .blue
        case "f3": return .purple
        case "f4": return .orange
        default: return .green
        }
    }
}
