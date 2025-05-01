import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var text: String
    var timestamp: Date
    // Add category later if needed
    // var category: String?

    init(id: UUID = UUID(), text: String = "", timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
} 