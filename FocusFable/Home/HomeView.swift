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
    @State private var vm           = HomeViewModel()
    @State private var selectedTask: SubTask?

    let focusOptions = [10, 15, 20, 25, 30, 45]
    let breakOptions = [5, 10, 15]

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
                                  text: $vm.taskInput,
                                  axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            Task {
                                await vm.breakdownTask(
                                    sessionMinutes: user?.focusDurationMinutes ?? Constants.Timer.defaultFocusMinutes
                                )
                            }
                        } label: {
                            HStack {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(vm.isLoading ? "Thinking..." : "Break it down")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!vm.canBreakdown || vm.isLoading)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                    // MARK: AI breakdown results
                    breakdownResultView

                    // MARK: Timer pickers
                    if let user {
                        VStack(spacing: 0) {
                            Picker("Focus", selection: Binding(
                                get: { user.focusDurationMinutes },
                                set: { user.focusDurationMinutes = $0 }
                            )) {
                                ForEach(focusOptions, id: \.self) { min in
                                    Text("\(min) min").tag(min)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Focus duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)

                            Divider().padding(.vertical, 10)

                            Picker("Break", selection: Binding(
                                get: { user.breakDurationMinutes },
                                set: { user.breakDurationMinutes = $0 }
                            )) {
                                ForEach(breakOptions, id: \.self) { min in
                                    Text("\(min) min").tag(min)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Break duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }

                    // MARK: Quick-start
                    Button {
                        selectedTask = SubTask(
                            title: vm.taskInput.isEmpty ? "Study session" : vm.taskInput,
                            durationMinutes: user?.focusDurationMinutes ?? 25
                        )
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
            .toolbar {
                if case .loaded = vm.breakdownState {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") { vm.reset() }
                    }
                }
            }
            .fullScreenCover(item: $selectedTask) { task in
                SessionView(taskLabel: task.title,
                            durationMinutes: task.durationMinutes)
            }
        }
    }

    // MARK: - Breakdown result view

    @ViewBuilder
    private var breakdownResultView: some View {
        switch vm.breakdownState {

        case .idle:
            EmptyView()

        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text("Planning your session...")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            .padding()

        case .loaded(let tasks):
            SubTaskListView(tasks: tasks) { tappedTask in
                selectedTask = tappedTask
            }

        case .unsupported:
            VStack(alignment: .leading, spacing: 8) {
                Label("Apple Intelligence not available", systemImage: "exclamationmark.circle")
                    .font(.subheadline.bold())
                    .foregroundStyle(.orange)
                Text("Requires iOS 18.1+ on iPhone 15 Pro or iPhone 16. Start a session manually below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .error(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.red)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - SubTaskListView

struct SubTaskListView: View {
    let tasks: [SubTask]
    let onSelect: (SubTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your study plan")
                .font(.headline)

            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                Button { onSelect(task) } label: {
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.appAccent, in: Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Text("\(task.durationMinutes) min · tap to start")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(Color.appAccent)
                            .font(.title2)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Text("Tap a step to begin that session")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
        }
    }
}

// MARK: - Badges

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
