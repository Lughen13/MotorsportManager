import SwiftUI
import Combine

struct LiveRaceView: View {
    @Environment(GameState.self) private var gameState
    @Environment(\.dismiss) private var dismiss
    
    let track: RaceTrack
    let weather: WeatherCondition
    let initialTire: TireCompound
    let initialStyle: DrivingStyle
    
    // Il timer che scandisce il ritmo della diretta
    @State private var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @State private var currentStyle: DrivingStyle
    @State private var isExiting = false
    
    init(track: RaceTrack, weather: WeatherCondition, initialTire: TireCompound, initialStyle: DrivingStyle) {
        self.track = track
        self.weather = weather
        self.initialTire = initialTire
        self.initialStyle = initialStyle
        _currentStyle = State(initialValue: initialStyle)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. HEADER (Info Pista e Giri)
            HStack {
                VStack(alignment: .leading) {
                    Text(track.name).font(.headline).foregroundColor(.primary)
                    Text("Giro \(gameState.raceEngine.currentLap) di \(gameState.raceEngine.totalLaps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                }
                Spacer()
                
                if gameState.raceEngine.isRaceFinished {
                    Button(action: saveAndExit) {
                        Text("Termina Gara")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
            .zIndex(1)
            
            // 2. CONTENUTO CENTRALE (RADAR DINAMICO + CRONACA)
            GeometryReader { geo in
                VStack(spacing: 0) {
                    
                    // RADAR DI PISTA
                    ScrollView {
                        VStack(spacing: 8) {
                            let leaderTime = gameState.raceEngine.liveCars.first(where: { $0.status == .racing || $0.status == .finished })?.totalRaceTime ?? 0
                            
                            ForEach(gameState.raceEngine.liveCars) { car in
                                let isPlayer = car.id == gameState.playerDriver?.id
                                let gap = (car.status == .racing || car.status == .finished) ? max(0, car.totalRaceTime - leaderTime) : 999
                                
                                HStack(spacing: 12) {
                                    Text("\(car.currentPosition)")
                                        .font(.caption).bold()
                                        .frame(width: 25, alignment: .leading)
                                        .foregroundColor((car.status == .racing || car.status == .finished) ? .primary : .gray)
                                    
                                    GeometryReader { barGeo in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 24)
                                                .cornerRadius(4)
                                            
                                            if car.status == .racing || car.status == .finished {
                                                let maxGapVisual = 20.0
                                                let offsetRatio = min(gap / maxGapVisual, 1.0)
                                                let xOffset = (barGeo.size.width - 100) * offsetRatio
                                                
                                                HStack(spacing: 4) {
                                                    Text(car.driverName)
                                                        .font(.caption).bold()
                                                        .foregroundColor(isPlayer ? .white : .primary)
                                                        .lineLimit(1)
                                                        .frame(width: 90, alignment: .leading)
                                                    
                                                    if gap > 0 {
                                                        Text("+\(String(format: "%.1f", gap))s")
                                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 4)
                                                .background(isPlayer ? Color.blue : Color(UIColor.systemBackground))
                                                .cornerRadius(4)
                                                .shadow(color: .black.opacity(isPlayer ? 0.3 : 0.1), radius: 2, y: 1)
                                                .offset(x: xOffset)
                                                .animation(.easeInOut(duration: 1.0), value: gap)
                                            } else {
                                                Text("\(car.driverName) - \(car.status.rawValue)")
                                                    .font(.caption).bold().foregroundColor(.red)
                                                    .padding(.horizontal, 6).padding(.vertical, 4)
                                            }
                                        }
                                    }
                                    .frame(height: 24)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: geo.size.height * 0.55)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    
                    Divider()
                    
                    // RADIO BOX (Cronaca Testuale)
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(gameState.raceEngine.raceLog.enumerated()), id: \.offset) { index, log in
                                    Text(log)
                                        .font(.caption)
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(8)
                                        .id(index)
                                }
                            }
                            .padding()
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                        .onChange(of: gameState.raceEngine.raceLog.count) { _, _ in
                            withAnimation { proxy.scrollTo(0, anchor: .top) }
                        }
                    }
                }
            }
            
            // 3. MURETTO BOX (Controlli Pilota)
            VStack(spacing: 12) {
                if let playerCar = gameState.raceEngine.liveCars.first(where: { $0.id == gameState.playerDriver?.id }) {
                    HStack {
                        Text("Gomme: \(Int(playerCar.tiresCondition))%").font(.caption).bold()
                            .foregroundColor(playerCar.tiresCondition < 30 ? .red : (playerCar.tiresCondition < 60 ? .orange : .primary))
                        Spacer()
                        Text("Motore: \(Int(gameState.engineWear))%").font(.caption).bold()
                            .foregroundColor(gameState.engineWear > 70 ? .red : .primary)
                    }
                }
                
                HStack(spacing: 12) {
                    controlButton(title: "Conserva", style: .conservative, color: .green)
                    controlButton(title: "Neutrale", style: .neutral, color: .blue)
                    controlButton(title: "Spingi", style: .aggressive, color: .red)
                }
                .disabled(gameState.raceEngine.isRaceFinished)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.1), radius: 5, y: -5)
        }
        // IL CICLO VITALE DELLA GARA
                .onReceive(timer) { _ in
                    if !gameState.raceEngine.isRaceFinished {
                        gameState.raceEngine.simulateLap(
                            playerStyle: currentStyle,
                            track: track,
                            playerID: gameState.playerDriver!.id,
                            playerEngineWear: gameState.engineWear,
                            activeDrivers: gameState.seasonManager.globalDrivers // Ecco il parametro obbligatorio aggiunto
                        )
                    } else {
                        timer.upstream.connect().cancel()
                    }
                }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func controlButton(title: String, style: DrivingStyle, color: Color) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            currentStyle = style
        }) {
            Text(title)
                .font(.caption).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(currentStyle == style ? color : Color.gray.opacity(0.2))
                .foregroundColor(currentStyle == style ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    private func colorForStatus(_ status: LiveRaceStatus) -> Color {
        switch status {
        case .racing: return .green
        case .finished: return .primary
        case .retired, .crashed: return .red
        }
    }
    
    private func saveAndExit() {
        guard !isExiting else { return }
        isExiting = true
        
        var finalResults: [RaceResult] = []
        for car in gameState.raceEngine.liveCars {
            let finalStatus: RaceStatus = (car.status == .racing || car.status == .finished) ? .finished : .dnf
            let result = RaceResult(
                driverID: car.id,
                position: car.currentPosition,
                status: finalStatus,
                gridPosition: car.currentPosition,
                totalTime: car.totalRaceTime
            )
            finalResults.append(result)
        }
        
        gameState.completaGaraSettimanale(results: finalResults, style: currentStyle)
        dismiss()
    }
}
