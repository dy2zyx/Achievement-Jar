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
    @State private var selectedTab: Tab = .jar
    
    // State for retrieval
    @State private var retrievedAchievement: Achievement? = nil
    @State private var showingRetrievedSheet: Bool = false
    
    // Instance of the retrieval algorithm
    private let retrievalAlgorithm = RetrievalAlgorithm()

    // Enum for tab identification
    enum Tab {
        case jar
        case list
    }
    
    // Calculate fill percentage using the @Query result
    private var fillPercentage: Double {
        let count = achievements.count
        let maxCapacity = 100.0
        return min(1.0, Double(count) / maxCapacity)
    }
    
    // Check if achievements list is empty
    private var isAchievementsEmpty: Bool {
        achievements.isEmpty
    }
    
    @State private var isRetrieving: Bool = false // State for animation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // --- Jar Tab ---
            NavigationView {
                VStack {
                    Text(String(format: NSLocalizedString("contentView_label_achievements", comment: "Label showing the count of achievements"), achievements.count))
                        .font(.headline)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Updated to use the new BottleImageView parameters
                    BottleImageView(
                        fillPercentage: fillPercentage,
                        isEmpty: isAchievementsEmpty,
                        withStopper: true // Always show with stopper in main view
                    )
                    .frame(height: 350)
                    
                    Spacer() // Pushes buttons towards the bottom
                    
                    // HStack for Add and Retrieve buttons
                    HStack {
                        // Add Button
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image("add_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        
                        Spacer() // Pushes buttons apart
                        
                        // Retrieve Button
                        Button {
                            guard !isRetrieving else { return }
                            retrieveAchievement()
                        } label: {
                            Image("retrieve_button") 
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        .disabled(isRetrieving || isAchievementsEmpty)
                        .opacity(isRetrieving ? 0.6 : (isAchievementsEmpty ? 0.4 : 1.0))
                        
                    } // End HStack for buttons
                    .padding(.horizontal, 40) // Add horizontal padding to keep buttons away from edges
                    .padding(.bottom) // Add some padding below buttons
                }
                .ignoresSafeArea(.keyboard) // Ignore keyboard safe area changes
                .edgesIgnoringSafeArea([]) // Reset any ignored edges to default
                .navigationTitle(NSLocalizedString("contentView_title_achievementJar", comment: "Title for the main achievement jar view"))
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label(NSLocalizedString("contentView_tab_jar", comment: "Tab title for the jar view"), systemImage: "circle.grid.cross")
            }
            .tag(Tab.jar)
            
            // --- List Tab ---
            NavigationView { 
                AchievementListView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label(NSLocalizedString("contentView_tab_list", comment: "Tab title for the achievements list"), systemImage: "list.bullet")
            }
            .tag(Tab.list)
        }
        // Replace .sheet with .fullScreenCover
        .fullScreenCover(isPresented: $showingAddSheet) {
            AchievementEntryView(isFirstAchievement: isAchievementsEmpty)
                .environment(\.modelContext, modelContext)
        }
        
        // Sheet to display the retrieved achievement
        .sheet(item: $retrievedAchievement) { achievement in
            // The sheet is presented when retrievedAchievement is not nil
            RetrievedAchievementView(achievement: achievement)
        }
    }
    
    // Updated retrieval function with animation state
    private func retrieveAchievement() {
        guard !achievements.isEmpty else {
            print("No achievements to retrieve.")
            return
        }
        
        // Start animation state
        isRetrieving = true
        
        // Add a small delay for visual effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let achievementToView = retrievalAlgorithm.retrieveRandomAchievement(from: achievements) {
                achievementToView.lastRetrievedDate = Date()
                self.retrievedAchievement = achievementToView
            } else {
                print("Failed to retrieve an achievement.")
                // Handle error, maybe show an alert
            }
            // End animation state
            isRetrieving = false
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    let sampleAchievements = [
        Achievement(content: "Preview 1", category: "Personal", moods: ["Happy"]),
        Achievement(content: "Preview 2", category: "Work", moods: ["Proud"])
    ]
    sampleAchievements.forEach { container.mainContext.insert($0) }
    
    return ContentView()
        .modelContainer(container)
}
