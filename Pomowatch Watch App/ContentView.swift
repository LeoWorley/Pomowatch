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
            VStack(spacing: 12) {
                Text(timeString(from: timeRemaining))
                    .font(.title2)
                    .fontWeight(.bold)
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
                
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimerIfNeeded()
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
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
                    Text("Status: \(status.description)")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
                
                NavigationLink("", destination: SettingsView(times: times), isActive: $isShowingSettings)
                    .opacity(0)
                    .buttonStyle(PlainButtonStyle()) // This makes the link not look like a button

                HStack(spacing: 8) {
                    Button(action: {
                        isShowingSettings = true // Show settings screen when button is tapped
                    }) {
                        Text("Settings")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    
                    Button(action: {
                        resetTimer()
                    }) {
                        Text("Reset")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SettingsView: View {
    @ObservedObject var times: Times

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Focus Time Section
                VStack(spacing: 4) {
                    Text("Focus")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Stepper("\(times.focus / 60) min", value: $times.focus, in: 60...3600, step: 60)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                // Short Break Section
                VStack(spacing: 4) {
                    Text("Short Break")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Stepper("\(times.shortBreak / 60) min", value: $times.shortBreak, in: 60...3600, step: 60)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                // Long Break Section
                VStack(spacing: 4) {
                    Text("Long Break")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Stepper("\(times.longBreak / 60) min", value: $times.longBreak, in: 60...3600, step: 60)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .navigationTitle("Settings")
    }
}

class Times: ObservableObject {
    @Published var focus = 25 * 60
    @Published var shortBreak = 5 * 60
    @Published var longBreak = 15 * 60
}





