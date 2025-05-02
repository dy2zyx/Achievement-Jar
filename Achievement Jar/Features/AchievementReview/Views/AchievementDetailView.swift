import SwiftUI
import SwiftData

struct AchievementDetailView: View {
    // Use @Bindable for potential future edits, though just `let` is fine for read-only
    @Bindable var achievement: Achievement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Content Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievement")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(achievement.content)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Divider()
                
                // Details Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Recorded On")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        // Display both date and time
                        Text(achievement.date, style: .date)
                        Text(achievement.date, style: .time)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(achievement.category)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Moods Section
                if !achievement.moods.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Moods")
                            .font(.headline)
                        // Simple horizontal layout for moods
                        // A FlowLayout would be better for many moods
                        HStack {
                            ForEach(achievement.moods.sorted(), id: \.self) { mood in
                                Text(mood)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Last Retrieved Section (if applicable)
                if let lastRetrieved = achievement.lastRetrievedDate {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Last Remembered")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastRetrieved, style: .date)
                        Text("(\(lastRetrieved, style: .relative) ago)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer() // Pushes content to top
            }
            .padding()
        }
        .navigationTitle("Details")
        // Consider adding Edit/Delete options to the toolbar later
    }
}

#Preview {
    // Setup in-memory container for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    let sampleAchievement = Achievement(
        content: "This is a longer achievement note to demonstrate how the detail view handles more text content. It should wrap appropriately within the view.",
        category: "Personal",
        moods: ["Happy", "Grateful", "Excited"],
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        lastRetrievedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    )
    // Insert into context if using @Query or relationships within the detail view
    // container.mainContext.insert(sampleAchievement)
    
    // Embed in NavigationView for Title
    return NavigationView {
        AchievementDetailView(achievement: sampleAchievement)
            .modelContainer(container)
    }
} 