import SwiftUI

struct PreRaceSetupView: View {
    @Environment(GameState.self) private var gameState
    @Environment(\.dismiss) private var dismiss
    
    let track: RaceTrack
    
    @State private var weather: WeatherCondition = .sunny
    @State private var aeroSetup: Double = 50.0
    @State private var qualyTire: TireCompound = .soft
    
    @State private var raceTire: TireCompound = .medium
    @State private var drivingStyle: DrivingStyle = .neutral // FIX: Era .balanced, ora è .neutral
    
    @State private var hasQualified: Bool = false
    @State private var isShowingLiveRace = false // Il trigger per la nuova telemetria
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    trackHeaderView()
                    setupView()
                }
            }
            .navigationTitle(hasQualified ? "Griglia e Setup Gara" : "Qualifiche")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Generazione meteo locale provvisoria
                let roll = Int.random(in: 1...100)
                if roll > 80 { weather = .heavyRain }
                else if roll > 60 { weather = .lightRain }
                else if roll > 40 { weather = .cloudy }
                else { weather = .sunny }
                
                if weather == .heavyRain || weather == .lightRain { qualyTire = .wet; raceTire = .wet }
            }
        }
    }
    
    @ViewBuilder
    private func trackHeaderView() -> some View {
        VStack(spacing: 8) {
            Text(track.name).font(.title3).bold()
            HStack {
                Text(track.isHighSpeed ? "Pista Veloce ⚡️" : "Pista Tecnica 🛣️")
                    .font(.caption).bold().padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.primary.opacity(0.1)).cornerRadius(6)
                
                HStack(spacing: 4) {
                    Image(systemName: weatherIcon(for: weather)).foregroundColor(weatherColor(for: weather))
                    Text(weather.rawValue).font(.caption).bold()
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.primary.opacity(0.1)).cornerRadius(6)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
        .zIndex(1)
    }
    
    @ViewBuilder
    private func setupView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Usura Meccanica Sempre Visibile
                VStack(alignment: .leading, spacing: 12) {
                    Text("STATO COMPONENTI").font(.caption).bold().foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text("MOTORE").font(.caption2).bold(); Spacer(); Text("\(Int(gameState.engineWear))%").font(.caption2).bold() }
                        ProgressView(value: gameState.engineWear, total: 100.0).tint(gameState.engineWear > 70 ? .red : (gameState.engineWear > 40 ? .orange : .green))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text("CAMBIO").font(.caption2).bold(); Spacer(); Text("\(Int(gameState.gearboxWear))%").font(.caption2).bold() }
                        ProgressView(value: gameState.gearboxWear, total: 100.0).tint(gameState.gearboxWear > 70 ? .red : (gameState.gearboxWear > 40 ? .orange : .green))
                    }
                    
                    if (gameState.engineWear > 50 || gameState.gearboxWear > 50) && !hasQualified {
                        Button(action: {
                            if gameState.funds >= 15000 {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                gameState.funds -= 15000
                                gameState.engineWear = 0.0
                                gameState.gearboxWear = 0.0
                            }
                        }) {
                            Text("Sostituisci Pezzi (€15.000)").font(.caption).bold().frame(maxWidth: .infinity).padding(8)
                                .background(gameState.funds >= 15000 ? Color.orange : Color.gray).foregroundColor(.white).cornerRadius(6)
                        }
                        .disabled(gameState.funds < 15000)
                    }
                }
                .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                
                if !hasQualified {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SETUP AERODINAMICO").font(.caption).bold().foregroundColor(.secondary)
                        Text(aeroSetup < 33 ? "Basso Carico (Velocità Max)" : (aeroSetup > 66 ? "Alto Carico (Curva)" : "Bilanciato"))
                            .font(.headline).foregroundColor(.blue)
                        Slider(value: $aeroSetup, in: 0...100, step: 5).tint(.blue)
                    }
                    .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GOMME DA QUALIFICA").font(.caption).bold().foregroundColor(.secondary)
                        Picker("Gomme Qualifica", selection: $qualyTire) { ForEach(TireCompound.allCases, id: \.self) { tire in Text(tire.rawValue).tag(tire) } }.pickerStyle(WheelPickerStyle()).frame(height: 100)
                    }
                    .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        // FIX: Usa il nuovo sistema del motore di gara per generare la griglia basata sulla performance pura
                        gameState.raceEngine.setupGrid(
                            drivers: gameState.seasonManager.globalDrivers.filter { $0.category == track.category },
                            teams: gameState.seasonManager.globalTeams,
                            track: track
                        )
                        hasQualified = true
                    }) {
                        Text("VAI IN QUALIFICA").font(.headline).bold().padding().frame(maxWidth: .infinity).background(Color.blue).foregroundColor(.white).cornerRadius(12)
                    }
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        Text("LA TUA POSIZIONE IN GRIGLIA").font(.caption).bold().foregroundColor(.secondary)
                        // Legge la tua posizione direttamente dal nuovo State Machine del motore
                        if let playerCar = gameState.raceEngine.liveCars.first(where: { $0.id == gameState.playerDriver!.id }) {
                            Text("Partirai in P\(playerCar.currentPosition)").font(.largeTitle).bold().foregroundColor(.blue)
                        }
                    }
                    .padding().frame(maxWidth: .infinity).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GOMME E STRATEGIA GARA").font(.caption).bold().foregroundColor(.secondary)
                        
                        Picker("Gomme Gara", selection: $raceTire) { ForEach(TireCompound.allCases, id: \.self) { tire in Text(tire.rawValue).tag(tire) } }.pickerStyle(SegmentedPickerStyle())
                        
                        Text("Stile di Guida Iniziale").font(.caption).bold().padding(.top, 8)
                        Picker("Stile", selection: $drivingStyle) { ForEach(DrivingStyle.allCases, id: \.self) { style in Text(style.rawValue).tag(style) } }.pickerStyle(WheelPickerStyle()).frame(height: 100)
                    }
                    .padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        // FIX: Invece di calcolare la gara istantaneamente, aprirà il Live Timing
                        isShowingLiveRace = true
                    }) {
                        Text("SCENDI IN PISTA E CORRI").font(.headline).bold().padding().frame(maxWidth: .infinity).background(Color.red).foregroundColor(.white).cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        // Quando premi "Corri", si apre il foglio della nuova Diretta Live
        // Nota: Per ora ti darà errore su LiveRaceView perché la dobbiamo ancora creare!
        .fullScreenCover(isPresented: $isShowingLiveRace, onDismiss: {
            // Quando chiudi la gara, chiudiamo anche questo setup e torniamo all'HQ
            dismiss()
        }) {
            LiveRaceView(track: track, weather: weather, initialTire: raceTire, initialStyle: drivingStyle)
        }
    }
    
    private func weatherIcon(for weather: WeatherCondition) -> String { switch weather { case .sunny: return "sun.max.fill"; case .cloudy: return "cloud.fill"; case .lightRain: return "cloud.drizzle.fill"; case .heavyRain: return "cloud.heavyrain.fill" } }
    private func weatherColor(for weather: WeatherCondition) -> Color { switch weather { case .sunny: return .orange; case .cloudy: return .gray; case .lightRain: return .cyan; case .heavyRain: return .blue } }
}
