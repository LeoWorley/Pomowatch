import SwiftUI

enum Status {
    case focus
    case shortBreak
    case longBreak
    
    var description: String {
        switch self {
        case .focus:
            return "Focus"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    var color: Color {
        switch self {
        case .focus:
            return .pomodoroRed
        case .shortBreak:
            return .pomodoroGreen
        case .longBreak:
            return .pomodoroBlue
        }
    }
    
    var icon: String {
        switch self {
        case .focus:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "bed.double"
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let pomodoroRed = Color(red: 0.95, green: 0.31, blue: 0.31)
    static let pomodoroGreen = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let pomodoroBlue = Color(red: 0.20, green: 0.60, blue: 0.86)
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
}


struct ContentView: View {
    @State private var timer: Timer?
    @State private var timeRemaining = 0 // Will be properly initialized based on current status
    @State private var isRunning = false
    @State private var isShowingSettings = false // State to track if settings screen is visible
    @State private var status: Status = .focus
    @State private var count = 0
    @ObservedObject var times = Times()
    
    // Computed property to get the correct time for current status
    private var currentStatusTime: Int {
        switch status {
        case .focus:
            return times.focus
        case .shortBreak:
            return times.shortBreak
        case .longBreak:
            return times.longBreak
        }
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.darkBackground, Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Status indicator with icon
                    VStack(spacing: 8) {
                        Image(systemName: status.icon)
                            .font(.title3)
                            .foregroundColor(status.color)
                        
                        Text(status.description)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    
                    // Main timer display
                    VStack(spacing: 4) {
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(.textPrimary)
                        
                        // Progress ring
                        ProgressRing(
                            progress: Double(currentStatusTime - timeRemaining) / Double(currentStatusTime),
                            color: status.color
                        )
                        .frame(width: 80, height: 80)
                    }
                    
                    // Control buttons
                    VStack(spacing: 12) {
                        // Main action button
                        Button(action: {
                            if isRunning {
                                stopTimer()
                            } else {
                                startTimerIfNeeded()
                                startTimer()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.caption)
                                Text(isRunning ? "Pause" : "Start")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [status.color, status.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Secondary actions
                        HStack(spacing: 12) {
                            // Status toggle button
                            Button(action: {
                                if isRunning { 
                                    stopTimer()
                                    invalidateTimer()
                                }
                                // Toggle between the three status enums
                                switch status {
                                case .focus:
                                    status = .shortBreak
                                case .shortBreak:
                                    status = .longBreak
                                case .longBreak:
                                    status = .focus
                                }
                                // Set time remaining to the new status time
                                timeRemaining = currentStatusTime
                                // Restart timer if it was running
                                startTimerIfNeeded()
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Reset button
                            Button(action: {
                                resetTimer()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Settings button
                            Button(action: {
                                isShowingSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    NavigationLink("", destination: SettingsView(times: times), isActive: $isShowingSettings)
                        .opacity(0)
                        .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear(perform: {
            // Initialize timeRemaining with the current status time if not already set
            if timeRemaining == 0 {
                timeRemaining = currentStatusTime
            }
            startTimerIfNeeded()
        })
        .onDisappear(perform: {
            // Clean up timer when view disappears to prevent memory leaks
            invalidateTimer()
        })
        .onChange(of: times.focus) { _ in
            // Update timer if currently on focus and not running
            if status == .focus && !isRunning {
                timeRemaining = currentStatusTime
            }
        }
        .onChange(of: times.shortBreak) { _ in
            // Update timer if currently on short break and not running
            if status == .shortBreak && !isRunning {
                timeRemaining = currentStatusTime
            }
        }
        .onChange(of: times.longBreak) { _ in
            // Update timer if currently on long break and not running
            if status == .longBreak && !isRunning {
                timeRemaining = currentStatusTime
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
    }
    
    private func stopTimer() {
        isRunning = false
    }
    
    private func startTimerIfNeeded() {
        // Only create a new timer if one doesn't already exist
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if isRunning {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        // Stop the timer if running
        if isRunning {
            stopTimer()
            invalidateTimer()
        }
        // Reset time to current status time
        timeRemaining = currentStatusTime
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SettingsView: View {
    @ObservedObject var times: Times
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.darkBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header with back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.cardBackground)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Settings content
                ScrollView {
                    VStack(spacing: 16) {
                        // Subtitle
                        Text("Customize your Pomodoro intervals")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, 8)
                        
                        // Focus Time Section
                        SettingCard(
                            title: "Focus Time",
                            icon: "brain.head.profile",
                            color: .pomodoroRed,
                            value: $times.focus,
                            range: 60...3600
                        )

                        // Short Break Section
                        SettingCard(
                            title: "Short Break",
                            icon: "cup.and.saucer",
                            color: .pomodoroGreen,
                            value: $times.shortBreak,
                            range: 60...3600
                        )

                        // Long Break Section
                        SettingCard(
                            title: "Long Break",
                            icon: "bed.double",
                            color: .pomodoroBlue,
                            value: $times.longBreak,
                            range: 60...3600
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

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

class Times: ObservableObject {
    @Published var focus = 25 * 60
    @Published var shortBreak = 5 * 60
    @Published var longBreak = 15 * 60
}





