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
                            Text(achievement.content)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            HStack {
                                Text("Date: ")
                                    .fontWeight(.bold)
                                Text(achievement.date.formatted(date: .numeric, time: .standard))
                            }
                            
                            HStack {
                                Text("Category: ")
                                    .fontWeight(.bold)
                                Text(achievement.category)
                            }
                            
                            if !achievement.moods.isEmpty {
                                HStack {
                                    Text("Moods: ")
                                        .fontWeight(.bold)
                                    Text(achievement.moods.joined(separator: ", "))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Achievement Details")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(achievement.content)
                                .lineLimit(1)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text(achievement.date.formatted(.dateTime.day().month()))
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
