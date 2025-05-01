import Foundation
import SwiftData

enum AchievementCategory: String, Codable, CaseIterable, Identifiable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case learning = "Learning"
    case relationships = "Relationships"
    case other = "Other"
    
    var id: String { self.rawValue }
}

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case happy = "Happy"
    case proud = "Proud"
    case grateful = "Grateful"
    case excited = "Excited"
    case peaceful = "Peaceful"
    case accomplished = "Accomplished"
    
    var id: String { self.rawValue }
}

@Model
final class Achievement {
    var id: UUID
    var text: String
    var timestamp: Date
    var category: String?
    var mood: String?
    var isRetrieved: Bool
    var lastRetrievedDate: Date?

    init(id: UUID = UUID(), 
         text: String = "", 
         timestamp: Date = Date(),
         category: String? = nil,
         mood: String? = nil,
         isRetrieved: Bool = false,
         lastRetrievedDate: Date? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.category = category
        self.mood = mood
        self.isRetrieved = isRetrieved
        self.lastRetrievedDate = lastRetrievedDate
    }
} 