//
//  Extensions.swift
//  FocusFable
//

import SwiftUI

// MARK: - TimeInterval
extension TimeInterval {
    var timerFormatted: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Brand Colors (all hardcoded — no system/dark mode dependencies)
extension Color {
    /// Mint green — main app background
    static let brandMint      = Color(hex: "#E8F5E9")

    /// Deep forest green — primary text, buttons, icons
    static let brandGreen     = Color(hex: "#2E7D32")

    /// Medium green — secondary elements, play buttons
    static let brandGreenMid  = Color(hex: "#4CAF50")

    /// Soft green — badge backgrounds, card tints
    static let brandGreenSoft = Color(hex: "#C8E6C9")

    /// Warm amber — focus session background
    static let focusBackground = Color(hex: "#FFFDE7")

    /// Cool mint — break session background
    static let breakBackground = Color(hex: "#E8F5E9")

    /// White with slight transparency — card backgrounds
    static let cardBackground  = Color(hex: "#FFFFFF").opacity(0.75)

    /// Alias so .appAccent references keep working
    static let appAccent = Color.brandGreen

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Brand Typography
extension Font {
    static let brandTitle   = Font.custom("Georgia", size: 32).weight(.bold)
    static let brandHeading = Font.custom("Georgia", size: 20).weight(.semibold)
    static let brandBody    = Font.system(size: 16, weight: .regular, design: .rounded)
    static let brandCaption = Font.system(size: 13, weight: .regular, design: .rounded)
}
