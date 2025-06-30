import SwiftUI

// MARK: - Setting Card Component
struct SettingCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with icon and title
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(value / 60) min")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            // Custom stepper
            HStack(spacing: 16) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 60
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(value > range.lowerBound ? color : .textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value <= range.lowerBound)
                
                Spacer()
                
                Button(action: {
                    if value < range.upperBound {
                        value += 60
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(value < range.upperBound ? color : .textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value >= range.upperBound)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}