//
//  Extensions.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI

// MARK: - TimeInterval
extension TimeInterval {
    /// Converts a duration in seconds to a "MM:SS" string.
    /// e.g. 1500.0 → "25:00"
    var timerFormatted: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Color
extension Color {
    /// Background color during a focus session — warm amber tone
    static let focusBackground = Color(red: 1.0, green: 0.97, blue: 0.91)

    /// Background color during a break — calm blue tone
    static let breakBackground = Color(red: 0.91, green: 0.96, blue: 1.0)

    /// App's primary purple accent
    static let appAccent = Color(red: 0.42, green: 0.34, blue: 0.80)
}
