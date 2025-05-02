//
//  ContentView.swift
//  Achievement Jar
//
//  Created by Yu Du on 01/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Achievement.date, order: .reverse) private var achievements: [Achievement]
    @State private var showingAddSheet = false
    @State private var selectedTab: Tab = .jar // Default tab

    // Enum for tab identification
    enum Tab {
        case jar
        case list
    }
    
    // Calculate fill percentage using the @Query result
    private var fillPercentage: Double {
        let count = achievements.count // Use count from @Query
        let maxCapacity = 100.0 // Arbitrary max for fill calculation
        return min(1.0, Double(count) / maxCapacity)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // --- Jar Tab ---
            NavigationView {
                VStack {
                    // Achievement Count Display - Use count from @Query
                    Text("Achievements: \(achievements.count)")
                        .font(.headline)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Display the Jar View with dynamic fill
                    FilledJarView(fillPercentage: fillPercentage)
                        .frame(width: 250, height: 350)
                        .padding(.bottom, 30)
                    
                    Spacer()
                }
                .navigationTitle("Achievement Jar")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Add Achievement", systemImage: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Label("Jar", systemImage: "circle.grid.cross") // Example icon
            }
            .tag(Tab.jar)

            // --- List Tab ---
            NavigationView { // Embed list in its own NavigationView for title/toolbar
                AchievementListView()
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(Tab.list)
        }
        .sheet(isPresented: $showingAddSheet) {
            AchievementEntryView()
                .environment(\.modelContext, modelContext)
        }
    }
}

#Preview {
    // Setup in-memory container for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    // Add sample data for preview
    let sampleAchievements = [
        Achievement(content: "Preview 1", category: "Personal", moods: ["Happy"]),
        Achievement(content: "Preview 2", category: "Work", moods: ["Proud"])
    ]
    sampleAchievements.forEach { container.mainContext.insert($0) }
    
    return ContentView()
        .modelContainer(container)
}
