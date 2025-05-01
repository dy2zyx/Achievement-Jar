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
    var content: String
    var category: String
    var moods: Set<String>
    var date: Date
    var isArchived: Bool
    
    init(content: String, category: String, moods: Set<String>, date: Date = Date(), isArchived: Bool = false) {
        self.content = content
        self.category = category
        self.moods = moods
        self.date = date
        self.isArchived = isArchived
    }
} 