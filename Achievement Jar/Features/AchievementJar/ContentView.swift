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
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(achievements) { achievement in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(achievement.text)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            HStack {
                                Text("Date: ")
                                    .fontWeight(.bold)
                                Text("\(achievement.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            }
                            
                            if let category = achievement.category {
                                HStack {
                                    Text("Category: ")
                                        .fontWeight(.bold)
                                    Text(category)
                                }
                            }
                            
                            if let mood = achievement.mood {
                                HStack {
                                    Text("Mood: ")
                                        .fontWeight(.bold)
                                    Text(mood)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Achievement Details")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(achievement.text)
                                .lineLimit(1)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("\(achievement.timestamp, format: .dateTime.day().month())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let category = achievement.category {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let mood = achievement.mood {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(mood)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteAchievements)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Achievement", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AchievementEntryView()
            }
        } detail: {
            Text("Select an achievement")
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
