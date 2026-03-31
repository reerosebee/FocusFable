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
    var body: some Scene {
        WindowGroup {
            RootView()
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
