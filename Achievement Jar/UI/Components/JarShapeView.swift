import SwiftUI

struct JarShapeView: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Jar dimensions (proportional to rect)
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.6 // Slightly narrower neck
        let neckHeight = height * 0.15
        let shoulderHeight = height * 0.1 // Height of the curve from neck to body
        let bodyWidth = width
        let bottomCurveHeight = height * 0.1
        
        // Control points for curves
        let shoulderControlXOffset = width * 0.05
        let shoulderControlYOffset = shoulderHeight * 0.5
        
        // Start at top left of neck
        let neckLeftX = (width - neckWidth) / 2
        path.move(to: CGPoint(x: neckLeftX, y: 0))
        
        // Top of jar (neck)
        let neckRightX = neckLeftX + neckWidth
        path.addLine(to: CGPoint(x: neckRightX, y: 0))
        
        // Right side of neck
        path.addLine(to: CGPoint(x: neckRightX, y: neckHeight))
        
        // Right shoulder curve (neck to body)
        let shoulderTopRight = CGPoint(x: neckRightX, y: neckHeight)
        let shoulderBottomRight = CGPoint(x: width, y: neckHeight + shoulderHeight)
        path.addCurve(
            to: shoulderBottomRight,
            control1: CGPoint(x: shoulderTopRight.x + shoulderControlXOffset, y: shoulderTopRight.y + shoulderControlYOffset),
            control2: CGPoint(x: shoulderBottomRight.x - shoulderControlXOffset, y: shoulderBottomRight.y - shoulderControlYOffset)
        )
        
        // Right side of body
        let bodyBottomRightY = height - bottomCurveHeight
        path.addLine(to: CGPoint(x: width, y: bodyBottomRightY))
        
        // Bottom curve of jar
        path.addQuadCurve(
            to: CGPoint(x: 0, y: bodyBottomRightY),
            control: CGPoint(x: width / 2, y: height + bottomCurveHeight * 0.5) // Control point below base for curve
        )
        
        // Left side of body
        path.addLine(to: CGPoint(x: 0, y: neckHeight + shoulderHeight))
        
        // Left shoulder curve (body to neck)
        let shoulderBottomLeft = CGPoint(x: 0, y: neckHeight + shoulderHeight)
        let shoulderTopLeft = CGPoint(x: neckLeftX, y: neckHeight)
        path.addCurve(
            to: shoulderTopLeft,
            control1: CGPoint(x: shoulderBottomLeft.x + shoulderControlXOffset, y: shoulderBottomLeft.y - shoulderControlYOffset),
            control2: CGPoint(x: shoulderTopLeft.x - shoulderControlXOffset, y: shoulderTopLeft.y + shoulderControlYOffset)
        )
        
        // Left side of neck
        path.addLine(to: CGPoint(x: neckLeftX, y: 0))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

// View that uses the JarShape to draw a filled and outlined jar
struct FilledJarView: View {
    var fillPercentage: Double // How full the jar is (0.0 to 1.0)
    var fillColor: Color = Color.blue.opacity(0.2) // Temporary default color
    var outlineColor: Color = Color.blue // Temporary default color
    var lineWidth: CGFloat = 3
    
    var body: some View {
        ZStack {
            // Jar outline
            JarShapeView()
                .stroke(outlineColor, lineWidth: lineWidth)
            
            // Fill - Using GeometryReader to draw the fill correctly
            GeometryReader { geometry in
                let fillHeight = geometry.size.height * fillPercentage
                if fillHeight > 0 {
                    JarShapeView() // Clip the fill to the jar shape
                        .fill(fillColor)
                        .frame(height: fillHeight)
                        .offset(y: geometry.size.height - fillHeight) // Align fill to bottom
                        .clipped() // Ensure fill doesn't go outside shape bounds
                }
            }
            .clipShape(JarShapeView()) // Clip the GeometryReader content itself
        }
    }
}

// Updated preview to show different fill levels
#Preview {
    HStack(spacing: 20) {
        FilledJarView(fillPercentage: 0.1)
            .frame(width: 100, height: 150)
        FilledJarView(fillPercentage: 0.5)
            .frame(width: 100, height: 150)
        FilledJarView(fillPercentage: 0.9)
            .frame(width: 100, height: 150)
    }
    .padding()
} 