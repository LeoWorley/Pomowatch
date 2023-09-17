import SwiftUI

struct ContentView: View {
    @State private var timer: Timer?
    @State private var timeRemaining = 1500 // 25 minutes in seconds
    @State private var isRunning = false
    @State private var isShowingSettings = false // State to track if settings screen is visible
    @State private var isRestTime = false // State to track if it's rest time
    
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
                                } else {
                                    if isRestTime {
                                        // Handle rest time logic here
                                        timeRemaining = 300 // 5 minutes rest time
                                        isRestTime = false
                                    } else {
                                        // Start rest time when the timer reaches 0
                                        timeRemaining = 1500 // 25 minutes work time
                                        isRestTime = true
                                    }
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
                
                NavigationLink("", destination: SettingsView(timeRemaining: $timeRemaining), isActive: $isShowingSettings)
                    .opacity(0) // Hide the link, but still use it to control navigation
                
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
            .padding()
            .navigationBarTitle("Pomowatch")
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
