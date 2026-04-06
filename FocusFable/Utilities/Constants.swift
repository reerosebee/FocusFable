//
//  Constants.swift
//  FocusFable
//

import Foundation

enum Constants {

    enum Points {
        // Base: 10 pts/min focused
        // But points are also modified by pause behavior (see SessionViewModel)
        static let perMinuteFocused     = 10

        // Completing a full session without pausing gives a bonus
        static let noInterruptionBonus  = 20

        // Each pause over 30s costs 5 pts
        static let penaltyPerPause      = 5

        // Completing the full planned duration (not ending early) gives a bonus
        static let completionBonus      = 15

        static let chapterUnlockCost    = 100
    }

    enum Timer {
        static let defaultFocusMinutes  = 25
        static let defaultBreakMinutes  = 5
        static let minimumFocusMinutes  = 10
        static let pausePenaltyAfter    = 30.0
    }

    enum API {
        static var claudeKey: String {
            Bundle.main.infoDictionary?["CLAUDE_API_KEY"] as? String ?? ""
        }
        static let endpoint = "https://api.anthropic.com/v1/messages"
        static let model    = "claude-sonnet-4-20250514"
    }

    enum Story {
        static let wordsPerChapter  = 200
        static let maxChapters      = 20
    }
}
