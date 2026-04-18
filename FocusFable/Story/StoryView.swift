//
//  StoryView.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

struct StoryView: View {
    @Query private var progressList: [UserProgress]
    @State private var selectedChapterIndex: Int? = nil
 
    var user: UserProgress? { progressList.first }
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandMint.ignoresSafeArea()
                VStack(spacing: 0) {
                    Text("Your Story")
                        .font(.brandTitle)
                        .foregroundStyle(Color.brandGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 45)
                        .background(Color.brandMint)
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            if let user {
                                progressCard(user: user)
                            }
                            
                            if (user?.unlockedChapterCount ?? 0) == 0 {
                                emptyState
                            } else {
                                chapterList
                            }
                        }
                        .padding()
                    }
                }
            }
            .fullScreenCover(item: $selectedChapterIndex) { index in
                if let user {
                    let scenes = ChapterLibrary.scenes(for: index, genre: user.genre)
                    VisualNovelView(
                        scenes: scenes,
                        chapterIndex: index,
                        onComplete: { selectedChapterIndex = nil }
                    )
                }
            }
        }
    }
 
    // MARK: - Progress card
 
    private func progressCard(user: UserProgress) -> some View {
        let cost     = Constants.Points.chapterUnlockCost
        let earned   = user.totalPoints
        let nextCost = cost * (user.unlockedChapterCount + 1)
        let progress = min(1.0, Double(earned % cost) / Double(cost))
 
        return VStack(spacing: 8) {
            HStack {
                Text("Next chapter")
                    .font(.brandCaption.bold())
                    .foregroundStyle(Color.brandGreen)
                Spacer()
                Text("\(user.pointsUntilNextChapter) pts to go")
                    .font(.brandCaption)
                    .foregroundStyle(Color.brandGreen.opacity(0.6))
            }
            ProgressView(value: progress)
                .tint(Color.brandGreen)
        }
        .padding()
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
    }
 
    // MARK: - Chapter list
 
    private var chapterList: some View {
        VStack(spacing: 12) {
            // Unlocked chapters
            ForEach(0..<(user?.unlockedChapterCount ?? 0), id: \.self) { index in
                ChapterCard(index: index, isUnlocked: true) {
                    selectedChapterIndex = index
                }
            }
            // Next locked chapter as a teaser
            if let user, user.unlockedChapterCount < Constants.Story.maxChapters {
                ChapterCard(index: user.unlockedChapterCount, isUnlocked: false, onTap: {})
            }
        }
    }
 
    // MARK: - Empty state
 
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandGreenMid)
            Text("Your story awaits")
                .font(.brandHeading)
                .foregroundStyle(Color.brandGreen)
            Text("Complete a study session to unlock Chapter 1.")
                .font(.brandBody)
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
 
// MARK: - Chapter card
 
struct ChapterCard: View {
    let index: Int
    let isUnlocked: Bool
    let onTap: () -> Void
 
    var chapterTitle: String {
        switch index {
        case 0: return "The Hospital"
        case 1: return "J. Cipher University"
        default: return "Chapter \(index + 1)"
        }
    }
 
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.brandGreen : Color.brandGreenSoft)
                        .frame(width: 44, height: 44)
                    if isUnlocked {
                        Text("\(index + 1)")
                            .font(.brandBody.bold())
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(Color.brandGreen.opacity(0.4))
                    }
                }
 
                VStack(alignment: .leading, spacing: 3) {
                    Text("Chapter \(index + 1): \(chapterTitle)")
                        .font(.brandBody.weight(.semibold))
                        .foregroundStyle(isUnlocked ? Color.brandGreen : Color.brandGreen.opacity(0.4))
                    Text(isUnlocked ? "Tap to read" : "Earn \(Constants.Points.chapterUnlockCost) points to unlock")
                        .font(.brandCaption)
                        .foregroundStyle(Color.brandGreen.opacity(0.5))
                }
 
                Spacer()
 
                if isUnlocked {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.brandGreenMid)
                }
            }
            .padding()
            .background(
                Color.white.opacity(isUnlocked ? 0.8 : 0.4),
                in: RoundedRectangle(cornerRadius: 14)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}
 
// MARK: - Int: Identifiable for fullScreenCover(item:)
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    StoryView()
}
