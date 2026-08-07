import Foundation

struct Team: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: RaceCategory
    var basePerformance: Double
    var budget: Double
    
    init(id: UUID = UUID(), name: String, category: RaceCategory, basePerformance: Double, budget: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.basePerformance = basePerformance
        self.budget = budget
    }
}
