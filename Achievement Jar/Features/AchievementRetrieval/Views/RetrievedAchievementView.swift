import SwiftUI
import SwiftData

struct RetrievedAchievementView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView { // Embed in NavigationView for title and dismiss button
            ScrollView { // Use ScrollView for potentially long content
                VStack(alignment: .leading, spacing: 20) {
                    Text("Remember this moment?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    // Content Section
                    VStack(alignment: .leading) {
                        Text("Achievement:")
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
                            Text("Date:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(achievement.date, style: .date)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Category:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(achievement.category)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Moods Section (if any)
                    if !achievement.moods.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Moods:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            // Display moods as tags - requires a simple FlowLayout or similar
                            // For now, just join them
                            Text(achievement.moods.joined(separator: ", "))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer() // Pushes content up
                }
                .padding()
            }
            .navigationTitle("A Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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