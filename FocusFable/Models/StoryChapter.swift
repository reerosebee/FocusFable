//
//  StoryChapter.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation
import SwiftData

@Model
class StoryChapter {
    var index: Int
    var text: String
    var isUnlocked: Bool
    var genre: StoryGenre
    var unlockedAt: Date?

    init(index: Int, genre: StoryGenre) {
        self.index      = index
        self.text       = ""
        self.isUnlocked = false
        self.genre      = genre
        self.unlockedAt = nil
    }

    /// A short preview of the chapter text for list display.
    var preview: String {
        let words = text.split(separator: " ").prefix(12).joined(separator: " ")
        return words.isEmpty ? "Generating..." : words + "..."
    }
}
