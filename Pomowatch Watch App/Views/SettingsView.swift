import SwiftUI

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