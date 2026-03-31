//
//  Constants.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation

enum Constants {

    enum Points {
        static let perMinuteFocused  = 10
        static let penaltyPerPause   = 5
        static let chapterUnlockCost = 100
    }

    enum Timer {
        static let defaultFocusMinutes = 25
        static let defaultBreakMinutes = 5
        static let minimumFocusMinutes = 10
        static let pausePenaltyAfter   = 30.0  // seconds before a pause counts against you
    }

    enum API {
        static var claudeKey: String {
            Bundle.main.infoDictionary?["CLAUDE_API_KEY"] as? String ?? ""
        }
        static let endpoint = "https://api.anthropic.com/v1/messages"
        static let model    = "claude-sonnet-4-20250514"
    }

    enum Story {
        static let wordsPerChapter = 200
        static let maxChapters     = 20
    }
}
