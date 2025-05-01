import SwiftUI

struct JarAdditionAnimation: View {
    @Binding var isAnimating: Bool
    var onComplete: () -> Void = {}
    
    @State private var noteOffset: CGSize = CGSize(width: 0, height: -300)
    @State private var noteRotation: Double = 0
    @State private var noteOpacity: Double = 0
    @State private var jarScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isAnimating)
                
                VStack {
                    Spacer()
                    
                    // The jar image
                    Image(systemName: "archivebox.fill") // Temporary system icon as placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue.opacity(0.7))
                        .scaleEffect(jarScale)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: jarScale)
                        .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity)
                
                // The achievement note
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 60, height: 40)
                    .shadow(radius: 3)
                    .rotationEffect(.degrees(noteRotation))
                    .offset(noteOffset)
                    .opacity(noteOpacity)
            }
            .onChange(of: isAnimating) { oldValue, newValue in
                if newValue {
                    // Start the animation sequence
                    withAnimation(.easeOut(duration: 0.3)) {
                        noteOpacity = 1
                    }
                    
                    // Reset position if needed
                    noteOffset = CGSize(width: 0, height: -geometry.size.height / 3)
                    
                    // Animate note going into the jar
                    withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                        noteOffset = CGSize(width: 0, height: geometry.size.height / 3 - 50)
                        noteRotation = Double.random(in: -30...30)
                    }
                    
                    // Jar reaction
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        jarScale = 1.15
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            jarScale = 1.0
                            
                            // Fade out and complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    noteOpacity = 0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }
                        }
                    }
                } else {
                    // Reset animation state
                    noteOffset = CGSize(width: 0, height: -300)
                    noteRotation = 0
                    noteOpacity = 0
                    jarScale = 1.0
                }
            }
        }
    }
}

#Preview {
    JarAdditionAnimationPreview()
}

// Preview container struct
struct JarAdditionAnimationPreview: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            VStack {
                Button("Start Animation") {
                    isAnimating = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            JarAdditionAnimation(isAnimating: $isAnimating) {
                print("Animation completed")
                isAnimating = false
            }
        }
    }
} 