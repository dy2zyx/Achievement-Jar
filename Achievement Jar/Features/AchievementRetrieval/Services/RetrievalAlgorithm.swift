import Foundation
import SwiftData

class RetrievalAlgorithm {
    // Weights for different time periods (days) to balance recency with diversity
    private let ageWeights: [Range<Int>: Double] = [
        0..<8: 0.5,      // Last week: 50% lower chance
        8..<31: 0.8,     // Last month: 20% lower chance
        31..<91: 1.0,    // 1-3 months: Normal chance
        91..<181: 1.2,   // 3-6 months: 20% higher chance
        181..<366: 1.5,  // 6-12 months: 50% higher chance
        366..<Int.max: 2.0 // Older than a year: Double chance
    ]
    
    // Key for UserDefaults
    private let userDefaultsKey = "recentlyRetrievedAchievementIDs"
    
    private var recentlyRetrievedIDs: [UUID] = []
    private let maxRecentIDsToAvoid = 10

    init() {
        // Load previously saved IDs on initialization
        loadRecentlyRetrievedIDs()
    }

    /**
     Selects a random achievement, favoring older and less recently retrieved items.
     */
    func retrieveRandomAchievement(from achievements: [Achievement]) -> Achievement? {
        guard !achievements.isEmpty else { return nil }
        
        // Filter out recently retrieved achievements if possible and if there are enough alternatives
        var eligibleAchievements = achievements
        if eligibleAchievements.count > maxRecentIDsToAvoid {
            // Load fresh list in case it changed elsewhere (though unlikely in current setup)
            loadRecentlyRetrievedIDs()
            
            eligibleAchievements = eligibleAchievements.filter { 
                !recentlyRetrievedIDs.contains($0.id)
            }
            if eligibleAchievements.isEmpty {
                eligibleAchievements = achievements
            }
        }
        
        // Calculate weights for each eligible achievement
        let weightedAchievements = eligibleAchievements.map { achievement -> (Achievement, Double) in
            let daysOld = Calendar.current.dateComponents([.day], from: achievement.date, to: Date()).day ?? 0
            let ageWeight = getWeight(forDays: daysOld, in: ageWeights, defaultWeight: 1.0)
            
            let recencyWeight: Double
            if let lastRetrieved = achievement.lastRetrievedDate {
                let daysSinceLastRetrieved = Calendar.current.dateComponents([.day], from: lastRetrieved, to: Date()).day ?? 0
                recencyWeight = min(3.0, 1.0 + (Double(daysSinceLastRetrieved) / 30.0))
            } else {
                recencyWeight = 1.5 // Bonus for never retrieved
            }
            
            let combinedWeight = ageWeight * recencyWeight
            return (achievement, combinedWeight)
        }
        
        // Perform weighted random selection
        let totalWeight = weightedAchievements.reduce(0) { $0 + $1.1 }
        guard totalWeight > 0 else {
             // If filtering removed all possibilities OR all weights are 0, return simple random from eligible
             if let fallback = eligibleAchievements.randomElement() {
                 updateRecentlyRetrievedList(fallback.id) // Still track it
                 return fallback
             }
             return nil // Only if eligibleAchievements is truly empty
        }
        
        let randomValue = Double.random(in: 0..<totalWeight)
        var cumulativeWeight = 0.0
        
        for (achievement, weight) in weightedAchievements {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                updateRecentlyRetrievedList(achievement.id)
                return achievement
            }
        }
        
        // Fallback: Should theoretically not be reached if totalWeight > 0
        if let fallback = eligibleAchievements.randomElement() {
            updateRecentlyRetrievedList(fallback.id)
            return fallback
        }
        
        return nil
    }
    
    // Helper to get weight from a dictionary of ranges
    private func getWeight(forDays days: Int, in weightMap: [Range<Int>: Double], defaultWeight: Double) -> Double {
        for (range, weight) in weightMap {
            if range.contains(days) {
                return weight
            }
        }
        return defaultWeight
    }
    
    // Updates the list of recently retrieved IDs and saves to UserDefaults
    private func updateRecentlyRetrievedList(_ id: UUID) {
        recentlyRetrievedIDs.removeAll { $0 == id }
        recentlyRetrievedIDs.append(id)
        
        if recentlyRetrievedIDs.count > maxRecentIDsToAvoid {
            recentlyRetrievedIDs.removeFirst()
        }
        
        saveRecentlyRetrievedIDs()
    }
    
    // Load IDs from UserDefaults
    private func loadRecentlyRetrievedIDs() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                recentlyRetrievedIDs = try decoder.decode([UUID].self, from: data)
            } catch {
                print("Error decoding recently retrieved IDs: \(error)")
                recentlyRetrievedIDs = [] // Reset if decoding fails
            }
        } else {
            recentlyRetrievedIDs = [] // Initialize if not found
        }
    }
    
    // Save IDs to UserDefaults
    private func saveRecentlyRetrievedIDs() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentlyRetrievedIDs)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding recently retrieved IDs: \(error)")
        }
    }
} 