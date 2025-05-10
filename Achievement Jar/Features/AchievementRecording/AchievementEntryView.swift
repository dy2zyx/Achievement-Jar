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
    
    // 确保日期不超过今天
    private func validateSelectedDate() {
        let currentDate = Date()
        if selectedDate > currentDate {
            selectedDate = currentDate
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Achievement text entry section
                        VStack(alignment: .leading, spacing: 5) {
                            Text(NSLocalizedString("achievementEntry_textField_title", comment: "Title for the achievement text input field"))
                                .font(.headline)
                                .padding(.bottom, 2)

                            // Character count display
                            Text(String(format: NSLocalizedString("achievementEntry_characterCount_format", comment: "Format for displaying character count and limit"), characterCount, characterLimit))
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
                            Text(NSLocalizedString("achievementEntry_date_title", comment: "Title for the date selection section"))
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            // Toggle between "Today" and custom date
                            Toggle(NSLocalizedString("achievementEntry_date_useCustomDate", comment: "Toggle label for using a custom date"), isOn: $isCustomDate)
                                .padding(.bottom, isCustomDate ? 10 : 0)
                                .onChange(of: isCustomDate) { oldValue, newValue in
                                    if newValue {
                                        validateSelectedDate()
                                    }
                                }
                            
                            if isCustomDate {
                                DatePicker(
                                    NSLocalizedString("achievementEntry_date_datePicker", comment: "Label for the date picker when custom date is selected"),
                                    selection: $selectedDate,
                                    in: ...Date(), // 限制日期范围至今天及以前
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                .padding(.horizontal)
                            } else {
                                let todayLabel = NSLocalizedString("achievementEntry_date_today", comment: "Label showing today's date")
                                Text("\(todayLabel): \(Date(), formatter: dateFormatter)")
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
                    Button(NSLocalizedString("achievementEntry_button_addToJar", comment: "Button to save the achievement")) {
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
                .navigationTitle(NSLocalizedString("achievementEntry_screen_title", comment: "Title for new achievement screen"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(NSLocalizedString("achievementEntry_button_cancel", comment: "Button to cancel adding a new achievement")) {
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
        .onAppear {
            validateSelectedDate()
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
        Text(NSLocalizedString("preview_firstAchievement", comment: "Label for first achievement preview"))
            .font(.headline)
        AchievementEntryView(isFirstAchievement: true)
            .frame(height: 300)
            
        Text(NSLocalizedString("preview_subsequentAchievement", comment: "Label for subsequent achievement preview"))
            .font(.headline)
        AchievementEntryView(isFirstAchievement: false)
            .frame(height: 300)
    }
    .modelContainer(for: Achievement.self, inMemory: true)
    .environment(\.locale, .init(identifier: "zh-Hans")) // 强制预览使用简体中文
} 