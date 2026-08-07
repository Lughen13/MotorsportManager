import SwiftUI

struct CalendarHubView: View {
    @Environment(GameState.self) private var gameState
    
    var body: some View {
        List {
            Section(header: Text("Calendario Anno \(gameState.currentYear)")) {
                // Mostra le settimane con gare pianificate
                ForEach(Array(gameState.seasonCalendar.keys.sorted()), id: \.self) { week in
                    if let track = gameState.seasonCalendar[week] {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Week \(week)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.red)
                                Text(track.name)
                                    .font(.subheadline)
                                    .bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(track.country)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", track.lengthKM)) km")
                                    .font(.caption2)
                                    .fontDesign(.monospaced)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Calendario & Piste")
        .navigationBarTitleDisplayMode(.inline)
    }
}
