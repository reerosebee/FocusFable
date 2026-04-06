//
//  Extensions.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI

// MARK: Converts seconds to minutes and seconds "MM:SS"
extension TimeInterval {
    var timerFormatted: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: All brand colors
extension Color {
        /// Mint green — the app background (matches logo background)
        static let brandMint      = Color(hex: "#e7ffea")
     
        /// Deep forest green — primary text, buttons, icons
        static let brandGreen     = Color(hex: "#2E7D32")
     
        /// Medium green — secondary elements
        static let brandGreenMid  = Color(hex: "#4CAF50")
     
        /// Soft green — subtle backgrounds, badges
        static let brandGreenSoft = Color(hex: "#C8E6C9")
     
        /// Warm focus background — soft amber tint for session screen
        static let focusBackground = Color(hex: "#FFFDE7")
     
        /// Calm break background — mint for break screen
        static let breakBackground = Color(hex: "#E8F5E9")
     
        /// Alias so existing .appAccent references keep working
        static let appAccent = Color.brandGreen
     
        /// Init from a hex string
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

    // MARK: Brand Typography
    extension Font {
        /// Serif display to match the logo
        static let brandTitle   = Font.custom("Georgia", size: 32).weight(.bold)
        static let brandHeading = Font.custom("Georgia", size: 20).weight(.semibold)
        static let brandBody    = Font.system(size: 16, weight: .regular, design: .rounded)
        static let brandCaption = Font.system(size: 13, weight: .regular, design: .rounded)
    }
     
