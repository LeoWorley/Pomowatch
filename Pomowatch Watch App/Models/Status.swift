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