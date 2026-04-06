//
//  SessionViewModel.swift
//  FocusFable
//

import SwiftUI

enum SessionPhase {
    case idle, focusing, onBreak, complete
}

@Observable
class SessionViewModel {

    var phase: SessionPhase         = .idle
    var timeRemaining: TimeInterval = 0
    var totalFocused: TimeInterval  = 0
    var pauseCount: Int             = 0
    var pointsEarned: Int           = 0
    var taskLabel: String           = ""

    var focusDuration: TimeInterval = TimeInterval(Constants.Timer.defaultFocusMinutes * 60)
    var breakDuration: TimeInterval = TimeInterval(Constants.Timer.defaultBreakMinutes * 60)

    // Track whether the user completed the full planned duration
    private var completedFullSession = false
    private var timer: Timer?
    private var pauseStartTime: Date?

    // MARK: - Controls

    func startSession() {
        timeRemaining        = focusDuration
        completedFullSession = false
        phase                = .focusing
        tick()
    }

    func pause() {
        timer?.invalidate()
        pauseStartTime = .now
        if phase == .focusing { pauseCount += 1 }
    }

    func resume() {
        pauseStartTime = nil
        tick()
    }

    func skipBreak() {
        timer?.invalidate()
        phase = .complete
    }

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

    var isPaused: Bool { pauseStartTime != nil }

    // MARK: - Point breakdown (shown in UI)

    var pointBreakdown: PointBreakdown {
        let base    = Int(totalFocused / 60) * Constants.Points.perMinuteFocused
        let penalty = pauseCount * Constants.Points.penaltyPerPause
        let noInterruptBonus = pauseCount == 0 ? Constants.Points.noInterruptionBonus : 0
        let completionBonus  = completedFullSession ? Constants.Points.completionBonus : 0
        return PointBreakdown(
            base: base,
            penalty: penalty,
            noInterruptBonus: noInterruptBonus,
            completionBonus: completionBonus,
            total: max(0, base - penalty + noInterruptBonus + completionBonus)
        )
    }

    // MARK: - Private

    private func tick() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                if self.phase == .focusing { self.totalFocused += 1 }
            } else {
                self.advancePhase()
            }
        }
    }

    private func advancePhase() {
        timer?.invalidate()
        switch phase {
        case .focusing:
            completedFullSession = true   // reached end naturally = full completion
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
        pointBreakdown.total
    }
}

// MARK: - Point breakdown model (for showing detail in UI)

struct PointBreakdown {
    let base: Int
    let penalty: Int
    let noInterruptBonus: Int
    let completionBonus: Int
    let total: Int
}
