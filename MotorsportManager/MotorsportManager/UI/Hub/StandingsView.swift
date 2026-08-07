import SwiftUI

enum StandingType {
    case drivers
    case teams
}

struct StandingsView: View {
    @Environment(GameState.self) private var gameState
    @State private var selectedStandingType: StandingType = .drivers
    @State private var viewingCategory: RaceCategory = .karting
    
    var body: some View {
        VStack(spacing: 0) {
            // Selettore Categoria (Karting, F4, F3, F2, F1)
            categoryPickerBar()
            
            // Selettore Tipo Classifica (Piloti vs Costruttori)
            Picker("Tipo di Classifica", selection: $selectedStandingType) {
                Text("Piloti").tag(StandingType.drivers)
                Text("Costruttori").tag(StandingType.teams)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Lista dei Risultati
            List {
                if selectedStandingType == .drivers {
                    let standings = gameState.getCurrentDriverStandings(for: viewingCategory)
                    if standings.isEmpty {
                        Text("Nessun pilota registrato in questa categoria.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(standings) { entry in
                            let isPlayer = entry.driverID == gameState.playerDriver?.id
                            driverRow(entry: entry, isPlayer: isPlayer)
                                .listRowBackground(isPlayer ? Color.blue.opacity(0.15) : Color(UIColor.secondarySystemGroupedBackground))
                        }
                    }
                } else {
                    let standings = gameState.getCurrentTeamStandings(for: viewingCategory)
                    if standings.isEmpty {
                        Text("Nessun team registrato in questa categoria.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(standings) { entry in
                            let isPlayerTeam = gameState.playerDriver?.currentTeamID == entry.teamID
                            teamRow(entry: entry, isPlayerTeam: isPlayerTeam)
                                .listRowBackground(isPlayerTeam ? Color.blue.opacity(0.15) : Color(UIColor.secondarySystemGroupedBackground))
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Classifiche Campionato")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if let driver = gameState.playerDriver {
                viewingCategory = driver.category
            }
        }
    }
    
    @ViewBuilder
    private func categoryPickerBar() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([RaceCategory.karting, .f4, .f3, .f2, .f1], id: \.self) { cat in
                    Button(action: {
                        viewingCategory = cat
                    }) {
                        Text(cat.rawValue.uppercased())
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewingCategory == cat ? Color.accentColor : Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundColor(viewingCategory == cat ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    @ViewBuilder
    private func driverRow(entry: DriverStandingEntry, isPlayer: Bool) -> some View {
        let driverObj = gameState.seasonManager.globalDrivers.first(where: { $0.id == entry.driverID })
        let teamName = gameState.seasonManager.globalTeams.first(where: { $0.id == driverObj?.currentTeamID })?.name ?? "Svincolato"
        
        HStack {
            Text("P\(entry.position)")
                .font(.headline)
                .frame(width: 35, alignment: .leading)
                .foregroundColor(entry.position <= 3 ? .accentColor : .primary)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.driverName)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(isPlayer ? .blue : .primary)
                    
                    if let nat = driverObj?.nationality {
                        Text("(\(nat))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(teamName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(entry.points) pt")
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func teamRow(entry: TeamStandingEntry, isPlayerTeam: Bool) -> some View {
        HStack {
            Text("P\(entry.position)")
                .font(.headline)
                .frame(width: 35, alignment: .leading)
                .foregroundColor(entry.position <= 3 ? .accentColor : .primary)
            
            Text(entry.teamName)
                .font(.subheadline)
                .bold()
                .foregroundColor(isPlayerTeam ? .blue : .primary)
            
            Spacer()
            
            Text("\(entry.points) pt")
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 4)
    }
}
