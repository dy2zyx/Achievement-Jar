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
    
    // Determine bottle state based on fill percentage
    private var bottleState: BottleImageView.BottleState {
        if fillPercentage <= 0.33 {
            return .empty
        } else if fillPercentage <= 0.66 {
            return .half
        } else {
            return .full
        }
    }
    
    @State private var isRetrieving: Bool = false // State for animation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // --- Jar Tab ---
            NavigationView {
                VStack {
                    Text("Achievements: \(achievements.count)")
                        .font(.headline)
                        .padding(.top)
                    
                    Spacer()
                    
                    // Updated to use the new BottleImageView
                    BottleImageView(fillPercentage: fillPercentage, bottleState: bottleState)
                        .frame(height: 350)
                        .padding(.bottom, 30)
                    
                    Spacer()
                    
                    // Manual Retrieval Button with feedback
                    Button {
                        // Prevent rapid clicks
                        guard !isRetrieving else { return }
                        retrieveAchievement()
                    } label: {
                        Label(isRetrieving ? "Remembering..." : "Retrieve Memory", 
                              systemImage: isRetrieving ? "hourglass" : "sparkles.rectangle.stack")
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                    .disabled(isRetrieving) // Disable while retrieving
                    .opacity(isRetrieving ? 0.7 : 1.0) // Dim slightly
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
                Label("Jar", systemImage: "circle.grid.cross")
            }
            .tag(Tab.jar)

            // --- List Tab ---
            NavigationView { 
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
