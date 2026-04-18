//
//  StoryGenre.swift
//  FocusFable
//

import Foundation

enum StoryGenre: String, Codable, CaseIterable {
    case mystery = "Mystery"
    case fantasy = "Fantasy"
    case sciFi   = "Sci-Fi"

    var emoji: String {
        switch self {
        case .mystery: return "🔍"
        case .fantasy: return "🏰"
        case .sciFi:   return "🚀"
        }
    }

    var description: String {
        switch self {
        case .mystery: return "Clues, suspects, and twists"
        case .fantasy: return "Coming in a future update!"
        case .sciFi:   return "Coming in a future update!"
        }
    }

    //Only mystery is available right now
    var isAvailable: Bool {
        switch self {
        case .mystery: return true
        case .fantasy: return false
        case .sciFi:   return false
        }
    }
}
