import SwiftUI

// MARK: - Progress Ring Component
struct ProgressRing: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.cardBackground, lineWidth: 3)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}