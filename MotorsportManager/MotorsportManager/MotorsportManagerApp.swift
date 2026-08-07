//
//  MotorsportManagerApp.swift
//  MotorsportManager
//
//  Created by Luca Loi on 04/08/2026.
//

import SwiftUI

@main
struct MotorsportManagerApp: App {
    // Istanziamo il nostro stato globale UNA sola volta
    @State private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView() // Questa sarà la tua prima schermata
                .environment(gameState) // Iniettiamo il cervello nell'ecosistema SwiftUI
        }
    }
}
