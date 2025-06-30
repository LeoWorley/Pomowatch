import SwiftUI
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
    
    // MARK: - Timer Functions
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





