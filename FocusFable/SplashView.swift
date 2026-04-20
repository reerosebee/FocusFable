//
//  SplashView.swift
//  FocusFable
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
 
                Text("Once Upon a Study Time...")
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
