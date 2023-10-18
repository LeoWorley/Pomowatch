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

struct times {
    var focus = 25 * 60
    var shortBreak = 5 * 60
    var longBreak = 15 * 60
}

struct ContentView: View {
    @State private var timer: Timer?
    @State private var timeRemaining = 1500 // 25 minutes in seconds
    @State private var isRunning = false
    @State private var isShowingSettings = false // State to track if settings screen is visible
    @State private var status: Status = .focus
    @State private var count = 0
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text(timeString(from: timeRemaining))
                    .font(.largeTitle)
                    .onAppear(perform: {
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            if isRunning {
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }
                            }
                        }
                    })
                
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "Pause" : "Start")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if isRunning { stopTimer() }
                    // Toggle between the three status enums
                    switch status {
                    case .focus:
                        status = .shortBreak
                        timeRemaining = times().focus
                    case .shortBreak:
                        status = .longBreak
                        timeRemaining = times().shortBreak
                    case .longBreak:
                        status = .focus
                        timeRemaining = times().longBreak
                    }
                }) {
                    Text("Status: \(status.description)") // Display the current status
                }
                
                NavigationLink("", destination: SettingsView(timeRemaining: $timeRemaining), isActive: $isShowingSettings)
                    .opacity(0)
                    .buttonStyle(PlainButtonStyle()) // This makes the link not look like a button

                Button(action: {
                    isShowingSettings = true // Show settings screen when button is tapped
                }) {
                    Text("Settings")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
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
    @Binding var timeRemaining: Int
    
    var body: some View {
        VStack {
            Text("Focus time")
                .font(.largeTitle)
                .padding()
            
            Stepper("\(timeRemaining / 60)", value: $timeRemaining, in: 60...3600, step: 60)
                .padding()
        }
        .navigationBarTitle("Settings").fixedSize()
    }
}
