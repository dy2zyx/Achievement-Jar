import SwiftUI

struct CategorySelector: View {
    @Binding var selectedCategory: String?
    
    // Background colors for each category button
    private let categoryColors: [String: Color] = [
        "Personal": .blue.opacity(0.2),
        "Work": .green.opacity(0.2),
        "Health": .red.opacity(0.2),
        "Learning": .purple.opacity(0.2),
        "Relationships": .pink.opacity(0.2),
        "Other": .gray.opacity(0.2)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category")
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
            // Toggle selection - if already selected, deselect it
            if selectedCategory == category.rawValue {
                selectedCategory = nil
            } else {
                selectedCategory = category.rawValue
            }
        } label: {
            Text(category.rawValue)
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
    @State var selectedCategory: String? = nil
    
    return VStack {
        CategorySelector(selectedCategory: $selectedCategory)
        Text("Selected: \(selectedCategory ?? "None")")
    }
    .padding()
} 