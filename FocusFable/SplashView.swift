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
                Image("FocusFableIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
 
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
