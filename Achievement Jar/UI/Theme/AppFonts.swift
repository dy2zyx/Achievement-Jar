import SwiftUI

extension Font {
    // Using SF Pro Rounded requires adding it to the project if not system-available
    // For now, let's use the system rounded design as a placeholder.
    static func appPrimary(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // Placeholder for secondary handwritten font
    // static func appSecondary(size: CGFloat) -> Font {
    //     .custom("YourHandwrittenFontName", size: size)
    // }
} 