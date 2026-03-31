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
    @Query(sort: \StoryChapter.index) private var chapters: [StoryChapter]

    var user: UserProgress? { progressList.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Points progress toward next chapter
                if let user {
                    VStack(spacing: 6) {
                        let needed = Constants.Points.chapterUnlockCost
                        let progress = Double(user.totalPoints % needed) / Double(needed)
                        ProgressView(value: progress)
                            .tint(Color.appAccent)
                        Text("\(user.pointsUntilNextChapter) points until next chapter")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }

                if chapters.isEmpty {
                    Spacer()
                    Text("📖")
                        .font(.system(size: 48))
                    Text("Complete a study session to unlock your first chapter.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                } else {
                    List(chapters) { chapter in
                        ChapterRow(chapter: chapter)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Your Story")
        }
    }
}

struct ChapterRow: View {
    let chapter: StoryChapter

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: chapter.isUnlocked ? "book.open.fill" : "lock.fill")
                .foregroundStyle(chapter.isUnlocked ? Color.appAccent : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Chapter \(chapter.index + 1)")
                    .font(.headline)
                    .foregroundStyle(chapter.isUnlocked ? .primary : .secondary)
                Text(chapter.isUnlocked ? chapter.preview : "Earn more points to unlock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .opacity(chapter.isUnlocked ? 1 : 0.5)
    }
}

#Preview {
    StoryView()
}
