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
    @Query private var achievements: [Achievement]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(achievements) { achievement in
                    NavigationLink {
                        Text("Achievement at \(achievement.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(achievement.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteAchievements)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addAchievement) {
                        Label("Add Achievement", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an achievement")
        }
    }

    private func addAchievement() {
        withAnimation {
            let newAchievement = Achievement(text: "New Achievement", timestamp: Date())
            modelContext.insert(newAchievement)
        }
    }

    private func deleteAchievements(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(achievements[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Achievement.self, inMemory: true)
}
