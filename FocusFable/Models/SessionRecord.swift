//
//  SessionRecord.swift
//  FocusFable
//

import Foundation
import SwiftData

@Model
class SessionRecord {
    var date: Date
    var focusDuration: TimeInterval   // actual seconds focused (not counting pauses)
    var pauseCount: Int
    var pointsEarned: Int
    var taskLabel: String

    init(
        date: Date = .now,
        focusDuration: TimeInterval,
        pauseCount: Int,
        pointsEarned: Int,
        taskLabel: String
    ) {
        self.date          = date
        self.focusDuration = focusDuration
        self.pauseCount    = pauseCount
        self.pointsEarned  = pointsEarned
        self.taskLabel     = taskLabel
    }

    var durationLabel: String {
        let minutes = Int(focusDuration / 60)
        return "\(minutes) min"
    }
}
