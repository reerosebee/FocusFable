//
//  SplashView.swift
//  FocusFable
//
//  Created by Riya  on 4/4/26.
//

import SwiftUI

struct SplashView: View {
    @State private var scale   = 0.7
    @State private var opacity = 0.0
 
    var body: some View {
        ZStack {
            Color.brandMint.ignoresSafeArea()
 
            VStack(spacing: 20) {
                // Use your actual logo image if you have it in Assets,
                // otherwise this quill SF Symbol approximates it
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.brandGreen)
 
                Text("FocusFable")
                    .font(.brandTitle)
                    .foregroundStyle(Color.brandGreen)
 
                Text("Study hard. Unlock your story.")
                    .font(.brandCaption)
                    .foregroundStyle(Color.brandGreen.opacity(0.6))
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(duration: 0.7)) {
                    scale   = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
