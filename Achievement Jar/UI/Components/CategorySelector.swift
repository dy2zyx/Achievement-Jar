import SwiftUI

struct CategorySelector: View {
    @Binding var selectedCategory: String
    
    // Background colors for each category button
    private let categoryColors: [String: Color] = [
        AchievementCategory.personal.rawValue: .blue.opacity(0.2),
        AchievementCategory.work.rawValue: .green.opacity(0.2),
        AchievementCategory.health.rawValue: .red.opacity(0.2),
        AchievementCategory.learning.rawValue: .purple.opacity(0.2),
        AchievementCategory.relationships.rawValue: .pink.opacity(0.2),
        AchievementCategory.other.rawValue: .gray.opacity(0.2)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("categorySelector_title_category", comment: "Title for the category selector section"))
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AchievementCategory.allCases) { category in
                        categoryButton(for: category)
                    }
                }
                .padding(.bottom, 5)
            }
        }
    }
    
    @ViewBuilder
    private func categoryButton(for category: AchievementCategory) -> some View {
        Button {
            selectedCategory = category.rawValue
        } label: {
            Text(category.localizedName)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selectedCategory == category.rawValue ? 
                              categoryColors[category.rawValue, default: .gray.opacity(0.2)] : 
                              Color.gray.opacity(0.1))
                )
                .foregroundColor(selectedCategory == category.rawValue ? .primary : .secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedCategory == category.rawValue ? .primary : Color.clear, 
                                lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CategorySelectorPreview()
        .environment(\.locale, .init(identifier: "zh-Hans"))
}

// Preview container struct
struct CategorySelectorPreview: View {
    @State private var selectedCategory: String = AchievementCategory.personal.rawValue
    
    private var localizedSelectionText: String {
        let prefix = NSLocalizedString("categorySelector_preview_selectedPrefix", comment: "Prefix for selected category in preview")
        let currentCategoryDisplayName: String
        if let catEnum = AchievementCategory(rawValue: selectedCategory) {
            currentCategoryDisplayName = catEnum.localizedName
        } else {
            currentCategoryDisplayName = selectedCategory
        }
        return prefix + currentCategoryDisplayName
    }
    
    var body: some View {
        VStack {
            CategorySelector(selectedCategory: $selectedCategory)
            Text(localizedSelectionText)
        }
        .padding()
    }
} 