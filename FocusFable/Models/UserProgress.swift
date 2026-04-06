//
//  UserProgress.swift
//  FocusFable
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
    var focusDurationMinutes: Int
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

    /// Adds points, updates streak, and automatically unlocks chapters if threshold is crossed.
    func addPoints(_ amount: Int) {
        totalPoints += amount

        // Update streak
        let today = Calendar.current.startOfDay(for: .now)
        if let last = lastStudyDate {
            let lastDay     = Calendar.current.startOfDay(for: last)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        lastStudyDate = .now

        // Unlock chapters automatically when threshold is crossed
        checkAndUnlockChapters()
    }

    /// Call this any time points change (e.g. from debug menu) to sync unlocks.
    func checkAndUnlockChapters() {
        let cost = Constants.Points.chapterUnlockCost
        // How many chapters the user has earned based on total points
        let earned = totalPoints / cost
        // Cap at max chapters and only ever go up, never down
        let newCount = min(earned, Constants.Story.maxChapters)
        if newCount > unlockedChapterCount {
            unlockedChapterCount = newCount
        }
    }

    var pointsUntilNextChapter: Int {
        let cost      = Constants.Points.chapterUnlockCost
        let threshold = cost * (unlockedChapterCount + 1)
        return max(0, threshold - totalPoints)
    }

    var canUnlockNextChapter: Bool {
        totalPoints >= Constants.Points.chapterUnlockCost * (unlockedChapterCount + 1)
    }
}
