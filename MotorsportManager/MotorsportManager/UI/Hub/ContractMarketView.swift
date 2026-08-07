import SwiftUI

struct ContractMarketView: View {
    @Environment(GameState.self) private var gameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let driver = gameState.playerDriver {
                    
                    // 1. Dettagli Contratto Attuale
                    currentContractSection(driver: driver)
                    
                    // 2. Sezione Offerte Ricevute
                    receivedOffersSection(driver: driver)
                    
                } else {
                    Text("Nessun pilota attivo.")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                }
            }
            .padding()
        }
        .navigationTitle("Ufficio Contratti")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    
    @ViewBuilder
    private func currentContractSection(driver: Driver) -> some View {
        let currentTeamName = gameState.seasonManager.globalTeams.first(where: { $0.id == driver.currentTeamID })?.name ?? "Svincolato"
        
        VStack(alignment: .leading, spacing: 14) {
            Text("CONTRATTO ATTUALE")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(currentTeamName)
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(driver.category.rawValue.uppercased())
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(6)
                }
                
                Divider()
                
                if let contract = driver.currentContract {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("STIPENDIO / SETTIMANA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("€\(contract.stipendioSettimanale, specifier: "%.0f")")
                                .font(.subheadline)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("SCADENZA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("Fine anno (\(contract.stagioniRimanenti) stagioni)")
                                .font(.subheadline)
                                .bold()
                        }
                    }
                    
                    Text("Obiettivo: \(contract.obiettiviTeam)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                } else {
                    Text("Nessun contratto formale registrato. Svincolato.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if gameState.currentWeek >= 45 {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        gameState.proponiRinnovoTeamAttuale()
                    }) {
                        Text("Negozia Rinnovo con Team Attuale")
                            .font(.caption)
                            .bold()
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.primary.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func receivedOffersSection(driver: Driver) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("OFFERTE DI MERCATO RICEVUTE")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.secondary)
            
            if driver.pendingOffers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "envelope.open")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Nessuna offerta attiva al momento. Aumenta la tua reputazione per attirare l'interesse dei top team.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(TextAlignment.center)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            } else {
                ForEach(driver.pendingOffers) { offer in
                    offerCard(offer: offer)
                }
            }
        }
    }
    
    @ViewBuilder
    private func offerCard(offer: ContractOffer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(offer.teamName)
                        .font(.headline)
                        .bold()
                    Text("Categoria: \(offer.category.rawValue.uppercased())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                statusBadge(status: offer.status)
            }
            
            Divider()
            
            HStack {
                if offer.offeredSalary > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STIPENDIO OFFERTO")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("€\(offer.offeredSalary, specifier: "%.0f") / wk")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.green)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BUY-IN RICHIESTO")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("€\(offer.requiredBuyIn, specifier: "%.0f")")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("DURATA")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Text("\(offer.durationYears) Anno/i")
                                        .font(.subheadline)
                                        .bold()
                                }
            }
            
            if offer.status == .pending {
                HStack(spacing: 10) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        gameState.accettaOffertaContratto(offer)
                    }) {
                        Text(gameState.currentWeek >= 48 ? "Firma Subito" : "Accetta per Futuro")
                            .font(.caption)
                            .bold()
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let idx = gameState.playerDriver?.pendingOffers.firstIndex(where: { $0.id == offer.id }) {
                            gameState.playerDriver?.pendingOffers[idx].status = .declined
                            gameState.saveGame()
                        }
                    }) {
                        Text("Rifiuta")
                            .font(.caption)
                            .bold()
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusBadge(status: ContractStatus) -> some View {
        switch status {
        case .pending:
            Text("IN ATTESA")
                .font(.system(size: 9, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(6)
        case .accepted:
            Text("FIRMATO")
                .font(.system(size: 9, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(6)
        case .declined:
            Text("RIFIUTATO")
                .font(.system(size: 9, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(6)
        }
    }
}
