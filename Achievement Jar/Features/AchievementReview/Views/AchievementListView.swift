import SwiftUI
import SwiftData

// Enum for predefined filter periods
enum TimePeriod: String, CaseIterable, Identifiable {
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case lastYear = "Last Year"
    case allTime = "All Time"
    
    var id: String { self.rawValue }
    
    // Calculate the start date based on the period
    var startDate: Date {
        let calendar = Calendar.current
        switch self {
        case .last7Days:
            return calendar.date(byAdding: .day, value: -7, to: Date())!
        case .last30Days:
            return calendar.date(byAdding: .day, value: -30, to: Date())!
        case .last90Days:
            return calendar.date(byAdding: .month, value: -3, to: Date())! // Approx 90 days
        case .lastYear:
            return calendar.date(byAdding: .year, value: -1, to: Date())!
        case .allTime:
            return Date.distantPast // Effectively no start date limit
        }
    }
}

struct AchievementListView: View {
    @Environment(\.modelContext) private var modelContext
    // @Query will be modified to use filters
    // @Query(sort: \Achievement.date, order: .reverse) private var achievements: [Achievement]
    
    // State for filtering
    @State private var selectedPeriod: TimePeriod = .last30Days
    @State private var selectedCategory: String? = nil // Optional String to represent category, nil means "All"
    
    // Computed property for Picker display
    private var categoryOptions: [String?] {
        [nil] + AchievementCategory.allCases.map { $0.rawValue }
    }
    
    private func categoryDisplayName(for category: String?) -> String {
        category ?? "All Categories"
    }
    
    var body: some View {
        // Pass both period and category to the content view
        AchievementListContentView(selectedPeriod: selectedPeriod, selectedCategory: selectedCategory)
            .navigationTitle("All Achievements")
            .toolbar {
                // Keep Edit button
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                // Category Picker
                ToolbarItem(placement: .topBarLeading) { // Move to top leading for space
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categoryOptions, id: \.self) { category in
                            Text(categoryDisplayName(for: category)).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Period Picker
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
    }
}

// Separate struct to hold the filtered Query
struct AchievementListContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var achievements: [Achievement]
    
    init(selectedPeriod: TimePeriod, selectedCategory: String?) {
        let startDate = selectedPeriod.startDate
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        
        // Capture the optional category filter
        let categoryFilter = selectedCategory
        
        // Create the predicate conditionally
        let predicate: Predicate<Achievement>
        if let category = categoryFilter {
            // If category is selected, filter by date AND category
            predicate = #Predicate<Achievement> { achievement in
                (achievement.date >= startDate && achievement.date <= endOfDay) &&
                (achievement.category == category) // Compare non-optional String
            }
        } else {
            // If category is nil (All Categories), filter only by date
            predicate = #Predicate<Achievement> { achievement in
                achievement.date >= startDate && achievement.date <= endOfDay
            }
        }
        
        // Initialize the query with the appropriate predicate and sorting
        _achievements = Query(filter: predicate, sort: [SortDescriptor(\Achievement.date, order: .reverse)])
    }
    
    var body: some View {
        // The .navigationDestination modifier works with NavigationStack
        // If AchievementListView is used within a NavigationView from ContentView's TabView,
        // we need NavigationLink here instead.
        List {
            if achievements.isEmpty {
                ContentUnavailableView {
                    Label("No Achievements Found", systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text("Try adjusting the filters or add some new achievements.")
                }
            } else {
                ForEach(achievements) { achievement in
                    NavigationLink { 
                        // Destination: The detail view
                        AchievementDetailView(achievement: achievement)
                    } label: { 
                        // Label: The existing row content
                        VStack(alignment: .leading) {
                            Text(achievement.content)
                                .lineLimit(3)
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
                                Spacer() 
                            }
                        }
                    } // End Label
                } // End ForEach
                .onDelete(perform: deleteAchievements)
            } // End else
        } // End List
        // No need for .navigationDestination here if using NavigationLink
    }
    
    private func deleteAchievements(offsets: IndexSet) {
        withAnimation {
            offsets.map { achievements[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    // Setup in-memory container for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    // Add sample data for preview
    let sampleAchievements = [
        Achievement(content: "Preview 1 - Today", category: "Personal", moods: ["Happy"], date: Date()),
        Achievement(content: "Preview 2 - Yesterday", category: "Work", moods: ["Proud"], date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        Achievement(content: "Preview 3 - Last Week", category: "Learning", moods: ["Excited"], date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!),
        Achievement(content: "Preview 4 - Last Year", category: "Health", moods: ["Accomplished"], date: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    ]
    sampleAchievements.forEach { container.mainContext.insert($0) }
    
    // Wrap in NavigationView for preview toolbar
    return NavigationView {
        AchievementListView()
    }
    .modelContainer(container)
} 