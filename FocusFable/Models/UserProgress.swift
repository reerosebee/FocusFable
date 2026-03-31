//
//  UserProgress.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation
import SwiftData

@Model
class UserProgress {
    var heroName: String
    var genre: StoryGenre
    var totalPoints: Int
    var currentStreak: Int
    var lastStudyDate: Date?
    var unlockedChapterCount: Int
    var focusDurationMinutes: Int   // user's preferred session length (from Settings)
    var breakDurationMinutes: Int

    init(
        heroName: String,
        genre: StoryGenre,
        focusDurationMinutes: Int = Constants.Timer.defaultFocusMinutes,
        breakDurationMinutes: Int = Constants.Timer.defaultBreakMinutes
    ) {
        self.heroName             = heroName
        self.genre                = genre
        self.totalPoints          = 0
        self.currentStreak        = 0
        self.lastStudyDate        = nil
        self.unlockedChapterCount = 0
        self.focusDurationMinutes = focusDurationMinutes
        self.breakDurationMinutes = breakDurationMinutes
    }

    /// Adds points and updates the streak based on today's date.
    func addPoints(_ amount: Int) {
        totalPoints += amount

        let today = Calendar.current.startOfDay(for: .now)

        if let last = lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1           // studied yesterday → extend streak
            } else if daysBetween > 1 {
                currentStreak = 1            // gap → reset streak
            }
            // daysBetween == 0 means already studied today, streak unchanged
        } else {
            currentStreak = 1                // first ever session
        }

        lastStudyDate = .now
    }

    /// Returns true if the user has enough points to unlock the next chapter.
    var canUnlockNextChapter: Bool {
        totalPoints >= Constants.Points.chapterUnlockCost * (unlockedChapterCount + 1)
    }

    /// How many points until the next chapter unlocks.
    var pointsUntilNextChapter: Int {
        let threshold = Constants.Points.chapterUnlockCost * (unlockedChapterCount + 1)
        return max(0, threshold - totalPoints)
    }
}
