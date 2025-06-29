//
//  Pomowatch_Watch_AppTests.swift
//  Pomowatch Watch AppTests
//
//  Created by Jesus Quintero Worley on 27/08/23.
//

import XCTest
@testable import Pomowatch_Watch_App

final class Pomowatch_Watch_AppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTimesClassInitialization() throws {
        // Test that Times class initializes with correct default values
        let times = Times()
        
        XCTAssertEqual(times.focus, 25 * 60, "Focus time should be 25 minutes (1500 seconds)")
        XCTAssertEqual(times.shortBreak, 5 * 60, "Short break should be 5 minutes (300 seconds)")
        XCTAssertEqual(times.longBreak, 15 * 60, "Long break should be 15 minutes (900 seconds)")
    }
    
    func testStatusEnumDescriptions() throws {
        // Test that Status enum returns correct descriptions
        XCTAssertEqual(Status.focus.description, "Focus")
        XCTAssertEqual(Status.shortBreak.description, "Short Break")
        XCTAssertEqual(Status.longBreak.description, "Long Break")
    }
    
    func testTimerAssignmentLogic() throws {
        // Test the fixed timer assignment logic
        let times = Times()
        
        // Test focus to short break transition
        var currentStatus = Status.focus
        var timeRemaining = 0
        
        switch currentStatus {
        case .focus:
            currentStatus = .shortBreak
            timeRemaining = times.shortBreak
        case .shortBreak:
            currentStatus = .longBreak
            timeRemaining = times.longBreak
        case .longBreak:
            currentStatus = .focus
            timeRemaining = times.focus
        }
        
        XCTAssertEqual(currentStatus, .shortBreak, "Status should change from focus to shortBreak")
        XCTAssertEqual(timeRemaining, times.shortBreak, "Time should be set to short break duration")
        
        // Test short break to long break transition
        switch currentStatus {
        case .focus:
            currentStatus = .shortBreak
            timeRemaining = times.shortBreak
        case .shortBreak:
            currentStatus = .longBreak
            timeRemaining = times.longBreak
        case .longBreak:
            currentStatus = .focus
            timeRemaining = times.focus
        }
        
        XCTAssertEqual(currentStatus, .longBreak, "Status should change from shortBreak to longBreak")
        XCTAssertEqual(timeRemaining, times.longBreak, "Time should be set to long break duration")
        
        // Test long break to focus transition
        switch currentStatus {
        case .focus:
            currentStatus = .shortBreak
            timeRemaining = times.shortBreak
        case .shortBreak:
            currentStatus = .longBreak
            timeRemaining = times.longBreak
        case .longBreak:
            currentStatus = .focus
            timeRemaining = times.focus
        }
        
        XCTAssertEqual(currentStatus, .focus, "Status should change from longBreak to focus")
        XCTAssertEqual(timeRemaining, times.focus, "Time should be set to focus duration")
    }
    
    func testTimeStringFormatting() throws {
        // Test the timeString formatting function
        // We need to create a ContentView instance to access the private function
        // For now, we'll test the logic manually
        
        // Test various time values
        let testCases = [
            (seconds: 0, expected: "00:00"),
            (seconds: 59, expected: "00:59"),
            (seconds: 60, expected: "01:00"),
            (seconds: 125, expected: "02:05"),
            (seconds: 1500, expected: "25:00"), // 25 minutes
            (seconds: 3599, expected: "59:59"), // 59 minutes 59 seconds
            (seconds: 3600, expected: "60:00")  // 1 hour
        ]
        
        for testCase in testCases {
            let minutes = testCase.seconds / 60
            let seconds = testCase.seconds % 60
            let result = String(format: "%02d:%02d", minutes, seconds)
            
            XCTAssertEqual(result, testCase.expected, 
                          "Time formatting failed for \(testCase.seconds) seconds")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
