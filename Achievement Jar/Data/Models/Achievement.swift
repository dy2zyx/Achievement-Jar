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

    // Computed property for localized display name
    var localizedName: String {
        switch self {
        case .personal:
            return NSLocalizedString("achievementCategory_personal", comment: "Category name: Personal")
        case .work:
            return NSLocalizedString("achievementCategory_work", comment: "Category name: Work")
        case .health:
            return NSLocalizedString("achievementCategory_health", comment: "Category name: Health")
        case .learning:
            return NSLocalizedString("achievementCategory_learning", comment: "Category name: Learning")
        case .relationships:
            return NSLocalizedString("achievementCategory_relationships", comment: "Category name: Relationships")
        case .other:
            return NSLocalizedString("achievementCategory_other", comment: "Category name: Other")
        }
    }
}

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case happy = "Happy"
    case proud = "Proud"
    case grateful = "Grateful"
    case excited = "Excited"
    case peaceful = "Peaceful"
    case accomplished = "Accomplished"
    
    var id: String { self.rawValue }
    
    // Computed property for localized display name
    var localizedName: String {
        switch self {
        case .happy:
            return NSLocalizedString("moodTag_happy", comment: "Mood: Happy")
        case .proud:
            return NSLocalizedString("moodTag_proud", comment: "Mood: Proud")
        case .grateful:
            return NSLocalizedString("moodTag_grateful", comment: "Mood: Grateful")
        case .excited:
            return NSLocalizedString("moodTag_excited", comment: "Mood: Excited")
        case .peaceful:
            return NSLocalizedString("moodTag_peaceful", comment: "Mood: Peaceful")
        case .accomplished:
            return NSLocalizedString("moodTag_accomplished", comment: "Mood: Accomplished")
        }
    }
}

@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var content: String
    var category: String
    var moods: Set<String>
    var date: Date
    var lastRetrievedDate: Date?
    var isArchived: Bool
    
    init(id: UUID = UUID(), content: String, category: String, moods: Set<String>, date: Date = Date(), lastRetrievedDate: Date? = nil, isArchived: Bool = false) {
        self.id = id
        self.content = content
        self.category = category
        self.moods = moods
        self.date = date
        self.lastRetrievedDate = lastRetrievedDate
        self.isArchived = isArchived
    }
} 