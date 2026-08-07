import SwiftUI

struct MainTabView: View {
    @Environment(GameState.self) private var gameState
    
    var body: some View {
        TabView {
            NavigationStack { HQView() }
                .tabItem { Label("HQ", systemImage: "house.fill") }
            
            NavigationStack { CalendarHubView() }
                .tabItem { Label("Pista", systemImage: "flag.checkered.2.crossed") }
            
            NavigationStack { StandingsView() }
                .tabItem { Label("Classifiche", systemImage: "list.number") }
            
            NavigationStack { ContractMarketView() }
                .tabItem { Label("Contratti", systemImage: "doc.text.fill") }
                .badge(hasPendingOffers ? "!" : nil)
            
            NavigationStack { DriverDashboardView() }
                .tabItem { Label("Pilota", systemImage: "person.crop.circle.fill") }
        }
        .accentColor(Color(.systemRed))
    }
    
    private var hasPendingOffers: Bool {
        guard let driver = gameState.playerDriver else { return false }
        return driver.pendingOffers.contains(where: { $0.status == .pending })
    }
}
