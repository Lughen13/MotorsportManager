//
//  VehicleComponent.swift
//  MotorsportManager
//
//  Created by Luca Loi on 04/08/2026.
//
import Foundation

enum ComponentType {
    case engine, gearbox, chassis, aerodynamics
}

class VehicleComponent {
    let type: ComponentType
    var performanceBase: Double
    var wear: Double // da 0.0 (nuovo) a 1.0 (distrutto)
    var isBroken: Bool = false
    
    init(type: ComponentType, performanceBase: Double) {
        self.type = type
        self.performanceBase = performanceBase
        self.wear = 0.0
    }
    
    // Ritorna la performance attuale influenzata dall'usura
    var currentPerformance: Double {
        // La performance cala del 20% massimo quando l'usura è al 100% (prima di rompersi)
        return performanceBase * (1.0 - (wear * 0.20))
    }
    
    func addWear(amount: Double) {
        guard !isBroken else { return }
        wear = min(1.0, wear + amount)
    }
    
    func checkFailure(stressFactor: Double) -> Bool {
        guard !isBroken else { return true }
        
        // Calcolo esponenziale. Valori di esempio per la curva.
        let alpha = 0.001
        let beta = 6.5
        let baseProbability = alpha * exp(beta * wear) - alpha
        
        // Lo stressFactor (es. guida aggressiva o cordoli) moltiplica il rischio
        let finalProbability = baseProbability * stressFactor
        
        let roll = Double.random(in: 0...1)
        if roll < finalProbability {
            isBroken = true
            return true
        }
        return false
    }
}
