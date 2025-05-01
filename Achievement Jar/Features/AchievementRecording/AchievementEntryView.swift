import SwiftUI
import SwiftData

struct AchievementEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss // To close the view after saving

    @State private var achievementText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedMood: String? = nil
    
    // Character limit constants
    private let characterLimit = 200
    private let warningThreshold = 180 // Start showing warning color when approaching limit
    
    // Computed property for current character count
    private var characterCount: Int {
        achievementText.count
    }
    
    // Computed property for character count color
    private var countColor: Color {
        if characterCount > characterLimit {
            return .red // Over limit
        } else if characterCount > warningThreshold {
            return .orange // Approaching limit
        } else {
            return .gray // Normal
        }
    }

    var body: some View {
        NavigationView { // Or embed in existing navigation
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Achievement text entry section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Record your achievement:")
                            // .font(Font.appPrimary(size: 18, weight: .medium)) // Temporarily removed
                            .padding(.bottom, 2)

                        // Character count display
                        Text("\(characterCount)/\(characterLimit)")
                            .foregroundColor(countColor)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, 2)

                        TextEditor(text: $achievementText)
                            .frame(height: 150) // Reduced height to fit other components
                            .border(Color.gray.opacity(0.5), width: 1)
                            .cornerRadius(5)
                            // .font(Font.appPrimary(size: 16)) // Temporarily removed
                            .onChange(of: achievementText) { oldValue, newValue in
                                // Enforce character limit
                                if newValue.count > characterLimit {
                                    achievementText = String(newValue.prefix(characterLimit))
                                }
                            }
                    }
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    // Category selector
                    CategorySelector(selectedCategory: $selectedCategory)
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    // Mood selector
                    MoodSelector(selectedMood: $selectedMood)
                    
                    Spacer(minLength: 30) // Push button to bottom with minimum space

                    Button("Add to Jar") {
                        saveAchievement()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .disabled(achievementText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("New Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveAchievement() {
        guard !achievementText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Maybe show an alert to the user?
            print("Achievement text cannot be empty.")
            return
        }

        let newAchievement = Achievement(
            text: achievementText, 
            timestamp: Date(),
            category: selectedCategory,
            mood: selectedMood,
            isRetrieved: false
        )
        
        modelContext.insert(newAchievement)

        // Optionally: Trigger animation if needed later

        dismiss() // Close the view
    }
}

#Preview {
    // Need a temporary model container for the preview
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Achievement.self, configurations: config)
        // Add sample data if needed for previewing interactions
        // let sampleAchievement = Achievement(text: "Preview Achievement", timestamp: Date())
        // container.mainContext.insert(sampleAchievement)

        return AchievementEntryView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
} 