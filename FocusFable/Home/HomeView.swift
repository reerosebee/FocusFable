//
//  HomeView.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var progressList: [UserProgress]
    @State private var taskInput    = ""
    @State private var showSession  = false
    @State private var selectedTask: SubTask?

    var user: UserProgress? { progressList.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Header — points + streak
                    HStack {
                        StreakBadge(streak: user?.currentStreak ?? 0)
                        Spacer()
                        PointsBadge(points: user?.totalPoints ?? 0)
                    }

                    // MARK: Task input card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What do you need to study?")
                            .font(.headline)
                        TextField("e.g. study for bio test, finish math hw...",
                                  text: $taskInput,
                                  axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            // TODO: hook up TaskBreakdownService here
                        } label: {
                            Label("Break it down", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(taskInput.trimmingCharacters(in: .whitespaces).count < 3)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                    // MARK: Quick-start (before AI is wired up)
                    Button {
                        selectedTask = SubTask(title: taskInput.isEmpty ? "Study session" : taskInput,
                                               durationMinutes: user?.focusDurationMinutes ?? 25)
                        showSession  = true
                    } label: {
                        Label("Start Session Now", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Focus Fable")
            .fullScreenCover(isPresented: $showSession) {
                if let task = selectedTask {
                    SessionView(taskLabel: task.title,
                                durationMinutes: task.durationMinutes)
                }
            }
        }
    }
}

// MARK: - Badges (defined here for now, can move to Components/ later)

struct PointsBadge: View {
    let points: Int
    var body: some View {
        Label("\(points)", systemImage: "star.fill")
            .font(.subheadline.bold())
            .foregroundStyle(Color.appAccent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.appAccent.opacity(0.12), in: Capsule())
    }
}

struct StreakBadge: View {
    let streak: Int
    var body: some View {
        Label("\(streak)", systemImage: "flame.fill")
            .font(.subheadline.bold())
            .foregroundStyle(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12), in: Capsule())
    }
}

#Preview {
    HomeView()
}
