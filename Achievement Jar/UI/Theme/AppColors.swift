import SwiftUI

extension Color {
    // Primary Colors
    static let primaryBlue = Color(hex: "#A8D8EA")
    static let primaryPurple = Color(hex: "#AA96DA")

    // Secondary Colors
    static let secondaryPink = Color(hex: "#FCBAD3")
    static let secondaryYellow = Color(hex: "#FFFFD2")

    // Accent Colors
    static let accentBrown = Color(hex: "#D5A6BD") // Using D5A6BD as a brownish-pink accent
    static let accentOrange = Color(hex: "#FFEAA5") // Using FFEAA5 as a gentle orange/yellow accent

    // Utility for Hex Colors (from https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to clear
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 