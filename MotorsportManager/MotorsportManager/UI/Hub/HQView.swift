import SwiftUI

struct HQView: View {
    @Environment(GameState.self) private var gameState
    @State private var isShowingLiveRace: Bool = false
    @State private var isShowingHallOfFame = false
    @State private var isShowingEntourage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let driver = gameState.playerDriver {
                    actionsCounterCard()
                    driverTelemetryCard(driver: driver)
                    financeCard()
                    Button(action: { isShowingEntourage = true }) {
                        Label("Entourage", systemImage: "person.3.fill")
                    }
                    
                    // La nuova card dell'entourage al posto dello sviluppo auto
                    entourageCard(driver: driver)
                    
                    if let track = gameState.seasonCalendar[gameState.currentWeek] {
                        raceWeekendBanner(track: track)
                    } else {
                        activitiesGrid(driver: driver)
                    }
                    
                    advanceWeekButton()
                }
                    
            }
            .padding()
        }
        .navigationTitle("HQ • Settimana \(gameState.currentWeek)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { gameState.saveGame() }) {
                    Label("Salva", systemImage: "square.and.arrow.down.fill")
                }
            
            Button(action: { isShowingHallOfFame = true }) {
                                        Label("Albo d'Oro", systemImage: "trophy.fill")
                                    }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    gameState.saveGame()
                    gameState.playerDriver = nil
                }) {
                    Label("Esci", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .foregroundColor(.red)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $isShowingLiveRace) {
                    if let track = gameState.seasonCalendar[gameState.currentWeek] {
                        PreRaceSetupView(track: track)
                            .interactiveDismissDisabled()
                    }
                }
        .sheet(isPresented: $isShowingHallOfFame) {
                    HallOfFameView()
                }
                // INCOLLALO QUI:
                .alert("COMUNICAZIONE UFFICIALE", isPresented: Binding<Bool>(
                    get: { gameState.firingNotification != nil },
                    set: { if !$0 { gameState.firingNotification = nil } }
                )) {
                    Button("Fai i bagagli", role: .cancel) { }
                } message: {
                    Text(gameState.firingNotification ?? "")
                }
        .sheet(isPresented: $isShowingEntourage) {
                    EntourageView()
                }
    }
    
    @ViewBuilder
    private func actionsCounterCard() -> some View {
        HStack {
            Image(systemName: "bolt.fill").foregroundColor(.yellow)
            Text("Azioni Disponibili:").font(.headline)
            Spacer()
            Text("\(gameState.actionsRemaining) / 5").font(.title3).bold().foregroundColor(gameState.actionsRemaining > 0 ? .green : .red)
        }
        .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
    
    @ViewBuilder
        private func entourageCard(driver: Driver) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.3.sequence.fill").foregroundColor(.purple)
                    Text("IL TUO ENTOURAGE").font(.system(size: 11, weight: .black)).foregroundColor(.secondary)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Costo Mantenimento: -€\(gameState.driverStaff.weeklyCost, specifier: "%.0f") / sett")
                        .font(.subheadline)
                        .foregroundColor(gameState.driverStaff.weeklyCost > 0 ? .red : .secondary)
                        .bold()
                    
                    // Etichette dinamiche che mostrano lo staff attivo
                    HStack {
                        if gameState.driverStaff.physioLevel > 0 { Text("Fisio L\(gameState.driverStaff.physioLevel)").font(.caption2).padding(4).background(Color.green.opacity(0.2)).cornerRadius(4) }
                        if gameState.driverStaff.prLevel > 0 { Text("PR L\(gameState.driverStaff.prLevel)").font(.caption2).padding(4).background(Color.blue.opacity(0.2)).cornerRadius(4) }
                        if gameState.driverStaff.simLevel > 0 { Text("Sim L\(gameState.driverStaff.simLevel)").font(.caption2).padding(4).background(Color.purple.opacity(0.2)).cornerRadius(4) }
                        if gameState.driverStaff.jetLevel > 0 { Text("Jet").font(.caption2).padding(4).background(Color.orange.opacity(0.2)).cornerRadius(4) }
                        
                        if gameState.driverStaff.weeklyCost == 0 {
                            Text("Nessuno staff assunto").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    
                    // Questo è il bottone che apre la nuova visuale che abbiamo creato prima
                    Button(action: {
                        isShowingEntourage = true
                    }) {
                        Text("Gestisci Entourage")
                            .font(.caption).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    
    @ViewBuilder
    private func entourageRow(title: String, desc: String, isHired: Bool, cost: String, icon: String, action: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 20).foregroundColor(isHired ? .purple : .gray)
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).bold()
                Text(desc).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
                gameState.saveGame()
            }) {
                Text(isHired ? "Attivo" : "Acquista (\(cost))")
                    .font(.caption2).bold()
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(isHired ? Color.purple.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(isHired ? .purple : .primary)
                    .cornerRadius(6)
            }
        }
    }
    
    @ViewBuilder
    private func driverTelemetryCard(driver: Driver) -> some View {
        let teamName = gameState.seasonManager.globalTeams.first(where: { $0.id == driver.currentTeamID })?.name ?? "Svincolato"
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(driver.name.uppercased()).font(.headline).fontWeight(.black)
                    Text("\(driver.nationality) • \(driver.category.rawValue.uppercased()) • \(teamName)").font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
            }
            Divider()
            VStack(spacing: 10) {
                telemetryBar(title: "ENERGIA PILOTA", current: Double(driver.energy), max: Double(driver.maxEnergy), color: .blue)
                telemetryBar(title: "LIVELLO STRESS", current: driver.mental.stress, max: 100.0, color: driver.mental.stress > 70 ? .red : .orange)
            }
        }
        .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
    
    @ViewBuilder
    private func telemetryBar(title: String, current: Double, max: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                Spacer()
                Text("\(Int(current)) / \(Int(max))").font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            ProgressView(value: current, total: max).tint(color)
        }
    }
    
    @ViewBuilder
        private func financeCard() -> some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "eurosign.circle.fill").font(.title2).foregroundColor(gameState.funds < 0 ? .red : .green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FINANZE E SPONSOR").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                        Text("€\(gameState.funds, specifier: "%.0f")").font(.title3).bold().fontDesign(.monospaced)
                    }
                    Spacer()
                }
                
                if let result = gameState.lastSponsorResult {
                    Text(result).font(.caption2).bold().padding(8).frame(maxWidth: .infinity, alignment: .leading)
                        .background(result.contains("✅") ? Color.green.opacity(0.2) : Color.red.opacity(0.2)).cornerRadius(6)
                }
                
                Divider()
                
                if let sponsor = gameState.activeSponsor {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(sponsor.name).font(.subheadline).bold()
                            Spacer()
                            Text("\(sponsor.racesRemaining) Gare Rimanenti").font(.caption2).bold().foregroundColor(.secondary)
                        }
                        Text("Obiettivo: P\(sponsor.targetPosition) | Bonus: €\(Int(sponsor.raceBonus)) | Penale: -€\(Int(sponsor.failurePenalty))").font(.caption)
                    }
                } else {
                    Text("Nessuno Sponsor Attivo. Seleziona un'offerta:").font(.caption).bold().foregroundColor(.orange)
                    ForEach(gameState.availableSponsors) { offer in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            gameState.acceptSponsor(offer)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(offer.name).font(.caption).bold()
                                    Spacer()
                                    Text("Firma (+€\(Int(offer.signOnFee)))").font(.caption2).bold().foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(Color.blue).cornerRadius(4)
                                }
                                Text("P\(offer.targetPosition) o meglio -> Bonus €\(Int(offer.raceBonus)) | Penale -€\(Int(offer.failurePenalty))").font(.caption2).foregroundColor(.secondary)
                            }
                            .padding(8).background(Color(UIColor.systemBackground)).cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
        }
    
    @ViewBuilder
        private func activitiesGrid(driver: Driver) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("PIANIFICAZIONE SETTIMANALE").font(.system(size: 11, weight: .black)).foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    // Aggiunto id: \.self per garantire che SwiftUI non faccia confusione coi bottoni
                    ForEach(WeeklyActivity.allCases, id: \.self) { activity in
                        
                        // 1. IL CERVELLO DEL BLOCCO: Calcola in tempo reale se l'azione è inaccessibile
                        let isLocked = (activity == .simulator && gameState.driverStaff.simLevel == 0) ||
                                       (activity == .gym && gameState.driverStaff.physioLevel == 0)
                        
                        // 2. IL MESSAGGIO: Spiega al giocatore cosa deve fare
                        let unlockMsg = activity == .simulator ? "Compra Sim" : (activity == .gym ? "Assumi Fisio" : "")
                        
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            gameState.executeActivity(activity)
                        }) {
                            VStack(spacing: 6) {
                                // Se è bloccato mostra il lucchetto, altrimenti l'icona normale
                                Image(systemName: isLocked ? "lock.fill" : activity.icon)
                                    .font(.title3)
                                    .foregroundColor(isLocked ? .gray : .red)
                                
                                Text(activity.title)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(isLocked ? .gray : .primary)
                                    .lineLimit(1)
                                
                                // Mostra il testo rosso solo se l'attività è bloccata
                                if isLocked {
                                    Text(unlockMsg)
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.red)
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            // Aggiungiamo un bordo rosso opaco per far capire subito che c'è un requisito mancante
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isLocked ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        // 3. LA GHIGLIOTTINA: Disabilita il bottone se non hai l'Entourage OPPURE se hai finito le mosse
                        .disabled(isLocked || gameState.actionsRemaining <= 0)
                        .opacity((isLocked || gameState.actionsRemaining <= 0) ? 0.5 : 1.0)
                    }
                }
            }
        }
    
    @ViewBuilder
    private func raceWeekendBanner(track: RaceTrack) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flag.checkered").foregroundColor(.white)
                Text("WEEKEND DI GARA").font(.headline).fontWeight(.black).foregroundColor(.white)
                Spacer()
            }
            Text(track.name).font(.title3).bold().foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                isShowingLiveRace = true
            }) {
                Text("SCENDI IN PISTA").font(.subheadline).bold().padding().frame(maxWidth: .infinity).background(Color.white).foregroundColor(.black).cornerRadius(8)
            }
        }
        .padding().background(Color.red).cornerRadius(12)
    }
    
    @ViewBuilder
    private func advanceWeekButton() -> some View {
        let isRaceWeek = gameState.seasonCalendar.keys.contains(gameState.currentWeek)
        Button(action: {
            if !isRaceWeek {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                gameState.advanceWeek()
            }
        }) {
            Text(isRaceWeek ? "GARA OBBLIGATORIA IN CORSO" : "AVANZA SETTIMANA")
                .font(.subheadline).bold().padding().frame(maxWidth: .infinity)
                .background(isRaceWeek ? Color.gray.opacity(0.3) : Color.primary)
                .foregroundColor(isRaceWeek ? .secondary : Color(UIColor.systemBackground))
                .cornerRadius(12)
        }
        .disabled(isRaceWeek)
    }
    @ViewBuilder
        private func contractOffersEmergencyCard(driver: Driver) -> some View {
            if driver.currentTeamID == nil && !driver.pendingOffers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        Text("SEI SVINCOLATO - FIRMA UN CONTRATTO").font(.system(size: 11, weight: .black)).foregroundColor(.red)
                    }
                    Text("Non puoi scendere in pista senza una scuderia.").font(.caption).foregroundColor(.secondary)
                    
                    ForEach(driver.pendingOffers) { offer in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            gameState.accettaOffertaContratto(offer)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(offer.teamName).font(.subheadline).bold()
                                    Text("\(offer.category.rawValue) | Ingaggio: €\(Int(offer.requiredBuyIn))").font(.caption2)
                                }
                                Spacer()
                                Text("Firma").font(.caption).bold().padding(.horizontal, 12).padding(.vertical, 6).background(Color.blue).foregroundColor(.white).cornerRadius(6)
                            }
                            .padding().background(Color(UIColor.systemBackground)).cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
            }
        }
}
