//
//  ContentView.swift
//  FocusFable
//

import SwiftUI
import SwiftData

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            StoryView()
                .tabItem {
                    Label("Story", systemImage: "book.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.brandGreen)
        .background(Color.brandMint)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
