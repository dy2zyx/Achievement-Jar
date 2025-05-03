import SwiftUI

/// A view component that displays the bottle image with appropriate scaling and fill
struct BottleImageView: View {
    var fillPercentage: Double // How full the bottle is (0.0 to 1.0)
    var isEmpty: Bool // Whether the achievements list is empty
    var withStopper: Bool = true // Whether the bottle should have a stopper
    
    // Get the correct image based on state
    private var bottleImage: String {
        if withStopper {
            // For main display (with stopper)
            return isEmpty ? "bottle_empty" : "bottle_filled"
        } else {
            // For animation (without stopper)
            return isEmpty ? "bottle_empty_without_stopper" : "bottle_filled_without_stopper"
        }
    }
    
    // Fill color with adjustable opacity
    private var fillColor: Color {
        Color.blue.opacity(0.2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The bottle image
                Image(bottleImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity)
                
                // The fill visualization 
                // Only show if bottle is not already a filled bottle image
                if fillPercentage > 0 && isEmpty {
                    // A semi-transparent overlay for empty bottles
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(fillColor)
                            .frame(
                                width: geometry.size.width * 0.7, // Slightly narrower than the bottle
                                height: geometry.size.height * fillPercentage
                            )
                            // Add subtle animations to the water
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 1.0), value: fillPercentage)
                    }
                    .mask(
                        // Mask the fill to the bottle shape
                        Image(bottleImage)
                            .resizable()
                            .scaledToFit()
                    )
                }
                
                // Add the achievement note for filled bottles
                if !isEmpty {
                    // Show notes inside the bottle for filled bottles
                    Image("achievement_note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4)
                        .offset(y: geometry.size.height * 0.1) // Position inside bottle
                        .opacity(0.9)
                }
            }
        }
        .aspectRatio(1/2.5, contentMode: .fit) // Match the aspect ratio from assets
    }
}

// To show different bottle states and fill levels
#Preview {
    VStack(spacing: 20) {
        HStack {
            // Empty bottle with stopper
            BottleImageView(fillPercentage: 0.0, isEmpty: true, withStopper: true)
                .frame(height: 300)
                .padding()
            
            // Filled bottle with stopper
            BottleImageView(fillPercentage: 0.5, isEmpty: false, withStopper: true)
                .frame(height: 300)
                .padding()
        }
        
        HStack {
            // Empty bottle without stopper
            BottleImageView(fillPercentage: 0.0, isEmpty: true, withStopper: false)
                .frame(height: 300)
                .padding()
            
            // Filled bottle without stopper
            BottleImageView(fillPercentage: 0.5, isEmpty: false, withStopper: false)
                .frame(height: 300)
                .padding()
        }
        
        Text("Bottle Visualization")
            .font(.headline)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 