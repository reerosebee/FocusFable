//
//  SubTask.swift
//  FocusFable
//

import Foundation

// A single AI-generated study step. Lives in memory only — not persisted to disk.
struct SubTask: Identifiable {
    let id = UUID()
    let title: String
    let durationMinutes: Int
    var isCompleted: Bool = false

    // Full label shown in the session view, like "Review chapter 8 notes (25 min)"
    var sessionLabel: String {
        "\(title) · \(durationMinutes) min"
    }
}
