import SwiftUI
import SwiftData

struct AchievementEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Parameter that indicates if this is the first achievement being added
    var isFirstAchievement: Bool = true
    
    @State private var content: String = ""
    @State private var selectedCategory: String = "Personal"
    @State private var selectedMoods: Set<String> = []
    @State private var selectedDate: Date = Date()
    @State private var isCustomDate: Bool = false
    @State private var showingAnimation: Bool = false
    
    // Character limit constants
    private let characterLimit = 600
    private let warningThreshold = 540 // Start showing warning color when approaching limit
    
    // Computed property for current character count
    private var characterCount: Int {
        content.count
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
    
    // Date formatter for display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Achievement text entry section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Record your achievement:")
                                .font(.headline)
                                .padding(.bottom, 2)

                            // Character count display
                            Text("\(characterCount)/\(characterLimit)")
                                .foregroundColor(countColor)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.bottom, 2)
                                .accessibilityIdentifier("characterCountText")

                            TextEditor(text: $content)
                                .frame(height: 150)
                                .border(Color.gray.opacity(0.5), width: 1)
                                .cornerRadius(5)
                                .accessibilityIdentifier("achievementContentTextEditor")
                                .onChange(of: content) { oldValue, newValue in
                                    // Enforce character limit
                                    if newValue.count > characterLimit {
                                        content = String(newValue.prefix(characterLimit))
                                    }
                                }
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Date selection section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Date")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            // Toggle between "Today" and custom date
                            Toggle("Use custom date", isOn: $isCustomDate)
                                .padding(.bottom, isCustomDate ? 10 : 0)
                            
                            if isCustomDate {
                                DatePicker(
                                    "Achievement date",
                                    selection: $selectedDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                .padding(.horizontal)
                            } else {
                                Text("Today: \(Date(), formatter: dateFormatter)")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                            
                        // Category selector
                        CategorySelector(selectedCategory: $selectedCategory)
                            
                        Divider()
                            .padding(.vertical, 5)
                            
                        // Mood selector
                        MoodSelector(selectedMoods: $selectedMoods)
                        
                        // No Spacer here, as the button is in safeAreaInset

                    }
                    .padding()
                    .padding(.bottom, 70)
                    .frame(maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    // Add to Jar Button placed outside ScrollView
                    Button("Add to Jar") {
                        triggerSaveAnimation()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.bar) // Use background material for floating effect
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(showingAnimation ? 0 : 1) // Hide button during animation
                    .accessibilityIdentifier("addToJarButton")
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .navigationTitle("New Achievement")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .disabled(showingAnimation) // Disable UI during animation
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Overlay the animation when active
            JarAdditionAnimation(
                isAnimating: $showingAnimation,
                isFirstAchievement: isFirstAchievement,
                onComplete: {
                    // Animation completed callback
                    saveAchievementAndDismiss() // Save and dismiss after animation
                }
            )
            .opacity(showingAnimation ? 1 : 0)
            .allowsHitTesting(showingAnimation)
        }
    }
    
    private func triggerSaveAnimation() {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Achievement text cannot be empty.")
            return
        }
        showingAnimation = true
    }

    private func saveAchievementAndDismiss() {
        let achievement = Achievement(
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            moods: selectedMoods,
            date: isCustomDate ? selectedDate : Date()
        )
        
        modelContext.insert(achievement)
        
        // Dismiss is now called after animation completes via the callback
        dismiss()
    }
}

#Preview {
    // Preview with both states
    VStack {
        Text("First Achievement")
            .font(.headline)
        AchievementEntryView(isFirstAchievement: true)
            .frame(height: 300)
            
        Text("Subsequent Achievement")
            .font(.headline)
        AchievementEntryView(isFirstAchievement: false)
            .frame(height: 300)
    }
    .modelContainer(for: Achievement.self, inMemory: true)
} 