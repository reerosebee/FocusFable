//
//  DebugMenuView.swift
//  FocusFable
//
//  DELETE THIS FILE before submitting / publishing.
//

import SwiftUI
import SwiftData

struct DebugMenuView: View {
    @Query private var progressList: [UserProgress]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var user: UserProgress? { progressList.first }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandMint.ignoresSafeArea()

                Form {

                    Section("Points") {
                        Button("Add 50 points")  { addPoints(50) }
                        Button("Add 100 points") { addPoints(100) }
                        Button("Add 500 points") { addPoints(500) }
                        Button("Reset points to 0", role: .destructive) {
                            user?.totalPoints = 0
                            user?.unlockedChapterCount = 0
                        }
                        if let user {
                            LabeledContent("Current points",     value: "\(user.totalPoints)")
                            LabeledContent("Chapters unlocked",  value: "\(user.unlockedChapterCount)")
                            LabeledContent("Points to next",     value: "\(user.pointsUntilNextChapter)")
                        }
                    }

                    Section("Chapters (direct)") {
                        Button("Unlock chapter 1") { user?.unlockedChapterCount = max(user?.unlockedChapterCount ?? 0, 1) }
                        Button("Unlock chapter 2") { user?.unlockedChapterCount = max(user?.unlockedChapterCount ?? 0, 2) }
                        Button("Reset chapter progress", role: .destructive) {
                            user?.unlockedChapterCount = 0
                        }
                    }

                    Section("Streak") {
                        Button("Set streak to 7") { user?.currentStreak = 7 }
                        Button("Reset streak", role: .destructive) { user?.currentStreak = 0 }
                    }

                    Section {
                        Button("💣 Wipe all data (restart onboarding)", role: .destructive) {
                            if let user { context.delete(user) }
                            dismiss()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(Color.brandGreen)
                }
            }
        }
    }

    private func addPoints(_ amount: Int) {
        user?.totalPoints += amount
        // Trigger chapter unlock check
        user?.checkAndUnlockChapters()
    }
}
