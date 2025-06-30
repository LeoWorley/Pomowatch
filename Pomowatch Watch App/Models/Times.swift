import Foundation

class Times: ObservableObject {
    @Published var focus = 1500 // 25 minutes in seconds
    @Published var shortBreak = 300 // 5 minutes in seconds
    @Published var longBreak = 900 // 15 minutes in seconds
}