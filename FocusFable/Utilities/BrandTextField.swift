//
//  BrandTextField.swift
//  FocusFable
//

import SwiftUI

/// A styled text field with brand green text and placeholder.
struct BrandTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int> = 1...1

    var body: some View {
        TextField("", text: $text, axis: axis)
            .lineLimit(lineLimit)
            .foregroundStyle(Color.brandGreen)
            .tint(Color.brandGreen)
            .padding()
            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandGreen.opacity(0.3), lineWidth: 1)
            )
            // Overlay a custom placeholder since .placeholder modifier isn't available
            .overlay(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Color.brandGreen.opacity(0.4))
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
            }
    }
}
