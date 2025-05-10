import SwiftUI
import SwiftData

struct RetrievedAchievementView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    // 获取类别的本地化显示名称
    private func localizedCategoryName(for categoryRawValue: String) -> String {
        if let category = AchievementCategory(rawValue: categoryRawValue) {
            return category.localizedName
        }
        return categoryRawValue
    }
    
    // 获取心情的本地化显示名称
    private func localizedMoodName(for moodRawValue: String) -> String {
        if let mood = MoodTag(rawValue: moodRawValue) {
            return mood.localizedName
        }
        return moodRawValue
    }
    
    // 对心情数组进行本地化处理
    private func localizedMoods() -> String {
        achievement.moods.map { localizedMoodName(for: $0) }.joined(separator: ", ")
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for title and dismiss button
            ScrollView { // Use ScrollView for potentially long content
                VStack(alignment: .leading, spacing: 20) {
                    Text(NSLocalizedString("retrievedAchievement_question", comment: "Question asking if the user remembers the achievement"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    // Content Section
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("retrievedAchievement_label_achievement", comment: "Label for the achievement content"))
                            .font(.headline)
                        Text(achievement.content)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Details Section
                    HStack {
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("retrievedAchievement_label_date", comment: "Label for the achievement date"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(achievement.date, style: .date)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("retrievedAchievement_label_category", comment: "Label for the achievement category"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(localizedCategoryName(for: achievement.category))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Moods Section (if any)
                    if !achievement.moods.isEmpty {
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("retrievedAchievement_label_moods", comment: "Label for the achievement moods"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            // Display moods as tags - requires a simple FlowLayout or similar
                            // For now, just join them
                            Text(localizedMoods())
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer() // Pushes content up
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
            .navigationTitle(NSLocalizedString("retrievedAchievement_title", comment: "Title for the retrieved achievement screen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("retrievedAchievement_button_done", comment: "Button to close the retrieved achievement view")) {
                        dismiss()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview requires a sample Achievement
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    let sampleAchievement = Achievement(
        content: "Successfully debugged a tricky issue after hours of effort. Felt a huge sense of relief and accomplishment!",
        category: "Work",
        moods: ["Proud", "Relieved", "Accomplished"],
        date: Calendar.current.date(byAdding: .day, value: -30, to: Date())! // 30 days ago
    )
    // Note: No need to insert into container for preview if just passing the object
    
    return RetrievedAchievementView(achievement: sampleAchievement)
        // .modelContainer(container) // Not strictly needed if not using @Query inside
} 