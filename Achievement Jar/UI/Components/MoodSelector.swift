import SwiftUI

struct MoodSelector: View {
    @Binding var selectedMoods: Set<String>
    
    // Emojis for each mood
    private let moodEmojis: [String: String] = [
        "Happy": "😊",
        "Proud": "🏆",
        "Grateful": "🙏",
        "Excited": "🎉",
        "Peaceful": "✨",
        "Accomplished": "💪"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("How do you feel about it?")
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
                    
                    Text(mood.rawValue)
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
}

// Preview container struct
struct MoodSelectorPreview: View {
    @State private var selectedMoods: Set<String> = []
    
    var body: some View {
        VStack {
            MoodSelector(selectedMoods: $selectedMoods)
            Text("Selected: \(selectedMoods.joined(separator: ", "))")
        }
        .padding()
    }
} 