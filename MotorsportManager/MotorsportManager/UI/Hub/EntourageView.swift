import SwiftUI

struct EntourageView: View {
    @Environment(GameState.self) private var gameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // HEADER ECONOMICO
                    VStack(spacing: 8) {
                        Text("Finanze Personali").font(.headline).foregroundColor(.secondary)
                        Text("€\(gameState.funds, specifier: "%.0f")").font(.system(size: 40, weight: .bold, design: .monospaced))
                        
                        HStack {
                            Text("Costi Settimanali Entourage:")
                            Text("-€\(gameState.driverStaff.weeklyCost, specifier: "%.0f")").foregroundColor(.red).bold()
                        }.font(.subheadline)
                        
                        if gameState.funds < 0 {
                            Text("⚠️ Rischio Bancarotta: Sotto i -€50.000 lo staff si licenzierà!")
                                .font(.caption).bold().foregroundColor(.red)
                        }
                    }
                    .padding().frame(maxWidth: .infinity).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    
                    // FISIOTERAPISTA
                    staffCard(
                        title: "Fisioterapista & Medico",
                        icon: "cross.case.fill",
                        color: .green,
                        currentLevel: gameState.driverStaff.physioLevel,
                        maxLevel: 3,
                        description: "Riduce lo stress accumulato e aumenta il recupero energetico.",
                        levelCosts: [1: 20_000, 2: 75_000, 3: 200_000],
                        weeklyCosts: [1: 500, 2: 2000, 3: 5000],
                        type: .physio
                    )
                    
                    // PR MANAGER
                    staffCard(
                        title: "PR & Talent Manager",
                        icon: "megaphone.fill",
                        color: .blue,
                        currentLevel: gameState.driverStaff.prLevel,
                        maxLevel: 3,
                        description: "Aumenta la reputazione guadagnata e massimizza i bonus sponsor.",
                        levelCosts: [1: 25_000, 2: 100_000, 3: 300_000],
                        weeklyCosts: [1: 1000, 2: 3000, 3: 10000],
                        type: .pr
                    )
                    
                    // SIMULATORE
                    staffCard(
                        title: "Simulatore Privato",
                        icon: "gamecontroller.fill",
                        color: .purple,
                        currentLevel: gameState.driverStaff.simLevel,
                        maxLevel: 3,
                        description: "Aumenta i riflessi e la costanza allenandoti da casa.",
                        levelCosts: [1: 50_000, 2: 150_000, 3: 500_000],
                        weeklyCosts: [1: 0, 2: 0, 3: 0], // Si paga una volta sola
                        type: .sim
                    )
                    
                    // JET PRIVATO (L'Endgame)
                    staffCard(
                        title: "Jet Privato",
                        icon: "airplane",
                        color: .orange,
                        currentLevel: gameState.driverStaff.jetLevel,
                        maxLevel: 1,
                        description: "Annulla quasi totalmente lo stress da viaggio tra le gare.",
                        levelCosts: [1: 3_000_000],
                        weeklyCosts: [1: 25_000],
                        type: .jet
                    )
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Gestione Entourage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }
    
    // Generatore dinamico di Card per lo Staff
    @ViewBuilder
    private func staffCard(title: String, icon: String, color: Color, currentLevel: Int, maxLevel: Int, description: String, levelCosts: [Int: Double], weeklyCosts: [Int: Double], type: StaffType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).font(.title2).foregroundColor(color)
                Text(title).font(.headline)
                Spacer()
                Text(currentLevel > 0 ? "Lvl \(currentLevel)" : "Inattivo")
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(currentLevel > 0 ? color.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(currentLevel > 0 ? color : .gray)
                    .cornerRadius(8)
            }
            
            Text(description).font(.caption).foregroundColor(.secondary)
            
            if currentLevel < maxLevel {
                let nextLevel = currentLevel + 1
                let upgCost = levelCosts[nextLevel] ?? 0
                let weekCost = weeklyCosts[nextLevel] ?? 0
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Upgrade a Lvl \(nextLevel)").font(.subheadline).bold()
                        Text("Costo: €\(upgCost, specifier: "%.0f") | Mant: €\(weekCost, specifier: "%.0f")/sett").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        gameState.upgradeStaff(type: type, cost: upgCost, level: nextLevel)
                    }) {
                        Text("Assumi").font(.caption).bold().padding(.horizontal, 16).padding(.vertical, 8)
                            .background(gameState.funds >= upgCost ? Color.accentColor : Color.gray)
                            .foregroundColor(.white).cornerRadius(8)
                    }
                    .disabled(gameState.funds < upgCost)
                }
            } else {
                Divider()
                Text("Livello Massimo Raggiunto").font(.caption).bold().foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
}
