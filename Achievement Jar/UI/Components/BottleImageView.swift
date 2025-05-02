import SwiftUI

/// A view component that displays the bottle image with appropriate scaling and fill
struct BottleImageView: View {
    var fillPercentage: Double // How full the bottle is (0.0 to 1.0)
    var bottleState: BottleState = .empty
    
    // Different states of the bottle
    enum BottleState {
        case empty
        case half
        case full
    }
    
    // Get the correct image based on state
    private var bottleImage: String {
        switch bottleState {
        case .empty:
            return "bottle_empty"
        case .half:
            // Once we add the half-full bottle image, use "bottle_half_full"
            return "bottle_empty" 
        case .full:
            // Once we add the full bottle image, use "bottle_full"
            return "bottle_empty"
        }
    }
    
    // Fill color with adjustable opacity based on bottle state
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
                // Only show if there's something in the bottle
                if fillPercentage > 0 {
                    // A semi-transparent overlay at the bottom of the bottle
                    // with height determined by fill percentage
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
                
                // Add subtle water bubbles in a future update
            }
        }
        .aspectRatio(1/2.5, contentMode: .fit) // Match the aspect ratio from assets
    }
}

// To show different bottle states and fill levels
#Preview {
    VStack(spacing: 20) {
        HStack {
            BottleImageView(fillPercentage: 0.1, bottleState: .empty)
                .frame(height: 300)
                .padding()
            
            BottleImageView(fillPercentage: 0.5, bottleState: .half)
                .frame(height: 300)
                .padding()
            
            BottleImageView(fillPercentage: 0.9, bottleState: .full)
                .frame(height: 300)
                .padding()
        }
        
        Text("Bottle Fill Visualization")
            .font(.headline)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 