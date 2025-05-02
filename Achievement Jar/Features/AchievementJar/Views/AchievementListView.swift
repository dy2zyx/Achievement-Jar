import SwiftUI
import SwiftData

struct AchievementListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Achievement.date, order: .reverse) private var achievements: [Achievement]
    
    var body: some View {
        List {
            ForEach(achievements) { achievement in
                VStack(alignment: .leading) {
                    Text(achievement.content)
                        .lineLimit(3) // Allow slightly more lines
                        .fontWeight(.medium)
                    
                    HStack {
                        Text(achievement.date.formatted(.dateTime.day().month().year()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(achievement.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !achievement.moods.isEmpty {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(achievement.moods.first ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                // Add swipe to delete later if needed
            }
            .onDelete(perform: deleteAchievements)
        }
        .navigationTitle("All Achievements")
        .toolbar {
             EditButton() // Add standard edit button for deletion
        }
    }
    
    private func deleteAchievements(offsets: IndexSet) {
        withAnimation {
            offsets.map { achievements[$0] }.forEach(modelContext.delete)
            // Consider adding error handling for save
            // try? modelContext.save()
        }
    }
}

#Preview {
    // Setup in-memory container for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    // Add sample data for preview
    let sampleAchievements = [
        Achievement(content: "Preview 1 - List", category: "Personal", moods: ["Happy"]),
        Achievement(content: "Preview 2 - List", category: "Work", moods: ["Proud"]),
        Achievement(content: "Preview 3 - A slightly longer achievement note to test the line limit functionality.", category: "Learning", moods: ["Excited"])
    ]
    sampleAchievements.forEach { container.mainContext.insert($0) }
    
    // Wrap in NavigationView for preview toolbar
    return NavigationView {
        AchievementListView()
    }
    .modelContainer(container)
} 