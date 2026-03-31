//
//  StoryGenre.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation

enum StoryGenre: String, Codable, CaseIterable {
    case fantasy = "Fantasy"
    case mystery = "Mystery"
    case sciFi   = "Sci-Fi"

    var emoji: String {
        switch self {
        case .fantasy: return "🏰"
        case .mystery: return "🔍"
        case .sciFi:   return "🚀"
        }
    }

    var description: String {
        switch self {
        case .fantasy: return "Magic, heroes, and epic quests"
        case .mystery: return "Clues, suspects, and twists"
        case .sciFi:   return "Space, technology, and the future"
        }
    }
}
