import Foundation

enum WeeklyActivity: CaseIterable, Identifiable {
    case gym
    case simulator
    case sponsorEvent
    case circuitStudy
    case rest
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .gym: return "Allenamento Fisico"
        case .simulator: return "Simulatore"
        case .sponsorEvent: return "Evento Sponsor"
        case .circuitStudy: return "Studio Circuito"
        case .rest: return "Riposo"
        }
    }
    
    var icon: String {
        switch self {
        case .gym: return "figure.strengthtraining.traditional"
        case .simulator: return "gamecontroller.fill"
        case .sponsorEvent: return "camera.macro"
        case .circuitStudy: return "map.fill"
        case .rest: return "bed.double.fill"
        }
    }
    
    var energyCost: Int {
        switch self {
        case .gym: return 30
        case .simulator: return 40
        case .sponsorEvent: return 35
        case .circuitStudy: return 20
        case .rest: return 0
        }
    }
    
    var financialCost: Double {
        switch self {
        case .gym: return 500.0
        case .simulator: return 1000.0
        case .sponsorEvent, .circuitStudy, .rest: return 0.0
        }
    }
    
    func financialReward(basePopularity: Double = 1.0) -> Double {
        if self == .sponsorEvent { return 2500.0 * basePopularity }
        return 0.0
    }
}
