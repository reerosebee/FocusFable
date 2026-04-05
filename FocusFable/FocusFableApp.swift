//
//  FocusFableApp.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

@main
struct FocusFableApp: App {
    @State private var showSplash = true
 
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showSplash = false
                }
            }
        }
        .modelContainer(for: [
            UserProgress.self,
            SessionRecord.self,
            StoryChapter.self
        ])
    }
}
 

struct RootView: View {
    @Query private var progressList: [UserProgress]
 
    var body: some View {
        if progressList.isEmpty {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
 #Preview {
    
}
