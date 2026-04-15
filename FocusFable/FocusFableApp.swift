//
//  FocusFableApp.swift
//  FocusFable
//

import SwiftUI
import SwiftData

@main
struct FocusFableApp: App {
    // Wire in AppDelegate for orientation control
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
            // Force light mode — the mint/green theme only works in light mode
            .preferredColorScheme(.light)
        }
        .modelContainer(for: [
            UserProgress.self,
            SessionRecord.self
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

import UIKit
 
class AppDelegate: NSObject, UIApplicationDelegate {
 
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // Let OrientationManager decide — portrait normally, landscape in story reader
        return OrientationManager.shared.current
    }
}
 





