import SwiftUI

struct MoodSelector: View {
    @Binding var selectedMoods: Set<String>
    
    // Emojis for each mood
    private let moodEmojis: [String: String] = [
        MoodTag.happy.rawValue: "😊",
        MoodTag.proud.rawValue: "🏆",
        MoodTag.grateful.rawValue: "🙏",
        MoodTag.excited.rawValue: "🎉",
        MoodTag.peaceful.rawValue: "✨",
        MoodTag.accomplished.rawValue: "💪"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("moodSelector_title_feelingsQuestion", comment: "Title asking how the user feels about their achievement"))
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MoodTag.allCases) { mood in
                        moodButton(for: mood)
                    }
                }
                .padding(.bottom, 5)
            }
        }
    }
    
    @ViewBuilder
    private func moodButton(for mood: MoodTag) -> some View {
        VStack {
            Button {
                // Toggle selection
                if selectedMoods.contains(mood.rawValue) {
                    selectedMoods.remove(mood.rawValue)
                } else {
                    selectedMoods.insert(mood.rawValue)
                }
            } label: {
                VStack {
                    Text(moodEmojis[mood.rawValue, default: "😊"])
                        .font(.system(size: 30))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(selectedMoods.contains(mood.rawValue) ? 
                                      Color.yellow.opacity(0.3) : 
                                      Color.gray.opacity(0.1))
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedMoods.contains(mood.rawValue) ? .yellow : Color.clear, 
                                        lineWidth: 2)
                        )
                    
                    Text(mood.localizedName)
                        .font(.caption)
                        .foregroundColor(selectedMoods.contains(mood.rawValue) ? .primary : .secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    MoodSelectorPreview()
        .environment(\.locale, .init(identifier: "zh-Hans"))
}

// Preview container struct
struct MoodSelectorPreview: View {
    @State private var selectedMoods: Set<String> = []
    
    private var localizedSelectionText: String {
        let prefix = NSLocalizedString("moodSelector_preview_selectedPrefix", comment: "Prefix for selected moods in preview")
        let moodsText = selectedMoods.isEmpty ? 
                      NSLocalizedString("moodSelector_preview_noMoodsSelected", comment: "Text when no moods are selected") : 
                      selectedMoods.map { rawValue in
                          MoodTag(rawValue: rawValue)?.localizedName ?? rawValue
                      }.joined(separator: ", ")
        return prefix + moodsText
    }
    
    var body: some View {
        VStack {
            MoodSelector(selectedMoods: $selectedMoods)
            Text(localizedSelectionText)
        }
        .padding()
    }
} 