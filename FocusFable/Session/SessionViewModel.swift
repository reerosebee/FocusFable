//
//  SessionViewModel.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation
import SwiftUI

enum SessionPhase {
    case idle, focusing, onBreak, complete
}

@Observable
class SessionViewModel {

    // MARK: - Public state (views read these)
    var phase: SessionPhase    = .idle
    var timeRemaining: TimeInterval = 0
    var totalFocused: TimeInterval  = 0
    var pauseCount: Int             = 0
    var pointsEarned: Int           = 0
    var taskLabel: String           = ""

    // MARK: - Config (set before calling startSession)
    var focusDuration: TimeInterval = TimeInterval(Constants.Timer.defaultFocusMinutes * 60)
    var breakDuration: TimeInterval = TimeInterval(Constants.Timer.defaultBreakMinutes * 60)

    // MARK: - Private
    private var timer: Timer?
    private var pauseStartTime: Date?

    // MARK: - Controls

    func startSession() {
        timeRemaining = focusDuration
        phase         = .focusing
        tick()
    }

    func pause() {
        guard phase == .focusing else { return }
        timer?.invalidate()
        pauseStartTime = .now
        pauseCount    += 1
    }

    func resume() {
        guard phase == .focusing else { return }
        pauseStartTime = nil
        tick()
    }

    /// Call this when the user taps "End Session".
    /// Returns a SessionRecord ready to be saved to SwiftData.
    @discardableResult
    func endSession() -> SessionRecord {
        timer?.invalidate()
        phase        = .complete
        pointsEarned = calculatePoints()
        return SessionRecord(
            focusDuration: totalFocused,
            pauseCount:    pauseCount,
            pointsEarned:  pointsEarned,
            taskLabel:     taskLabel
        )
    }

    var isPaused: Bool {
        pauseStartTime != nil
    }

    // MARK: - Private helpers

    private func tick() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                if self.phase == .focusing {
                    self.totalFocused += 1
                }
            } else {
                self.advancePhase()
            }
        }
    }

    private func advancePhase() {
        timer?.invalidate()
        switch phase {
        case .focusing:
            phase         = .onBreak
            timeRemaining = breakDuration
            tick()
        case .onBreak:
            phase = .complete
        default:
            break
        }
    }

    private func calculatePoints() -> Int {
        let minutesFocused = Int(totalFocused / 60)
        var pts = minutesFocused * Constants.Points.perMinuteFocused
        pts    -= pauseCount * Constants.Points.penaltyPerPause
        return max(0, pts)
    }
}
