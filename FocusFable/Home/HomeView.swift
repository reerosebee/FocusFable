//
//  HomeView.swift
//  FocusFable
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
            ZStack {
                Color.brandMint.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        // MARK: Greeting + badges
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hi, \(user?.heroName ?? "Hero")")
                                    .font(.brandHeading)
                                    .foregroundStyle(Color.brandGreen)
                                Text("Ready to focus?")
                                    .font(.brandCaption)
                                    .foregroundStyle(Color.brandGreen.opacity(0.6))
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                StreakBadge(streak: user?.currentStreak ?? 0)
                                PointsBadge(points: user?.totalPoints ?? 0)
                            }
                        }
                        .padding(.top, 40)

                        // MARK: Task input
                        BrandTextField(
                            placeholder: "What are you studying today?",
                            text: $vm.taskInput,
                            axis: .vertical,
                            lineLimit: 2...3
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
                                }
                                .foregroundStyle(Color.brandGreen)
                                .fontWeight(.semibold)
                            }
                        }

                        // MARK: Timer row — compact dropdowns
                        if let user {
                            timerRow(user: user)
                        }

                        // MARK: AI breakdown button
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
                                Text(vm.isLoading ? "Thinking..." : "Break it down with AI")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GreenButtonStyle())
                        .disabled(!vm.canBreakdown || vm.isLoading)

                        // MARK: AI breakdown results
                        breakdownResultView

                        // MARK: Start button
                        Button {
                            selectedTask = SubTask(
                                title: vm.taskInput.isEmpty ? "Study session" : vm.taskInput,
                                durationMinutes: user?.focusDurationMinutes ?? 25
                            )
                        } label: {
                            Text("Start Session")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OutlineButtonStyle())

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .loaded = vm.breakdownState {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") { vm.reset() }
                            .font(.brandCaption)
                            .foregroundStyle(Color.brandGreen.opacity(0.6))
                    }
                }
            }
            .fullScreenCover(item: $selectedTask) { task in
                SessionView(taskLabel: task.title,
                            durationMinutes: task.durationMinutes)
            }
        }
    }

    // MARK: - Compact timer row

    private func timerRow(user: UserProgress) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
                .foregroundStyle(Color.brandGreen.opacity(0.5))
                .font(.subheadline)

            // Focus duration dropdown
            Menu {
                ForEach(focusOptions, id: \.self) { min in
                    Button("\(min) min") { user.focusDurationMinutes = min }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Focus: \(user.focusDurationMinutes) min")
                        .font(.brandCaption.weight(.medium))
                        .foregroundStyle(Color.brandGreen)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.brandGreen.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.7), in: Capsule())
            }

            // Break duration dropdown
            Menu {
                ForEach(breakOptions, id: \.self) { min in
                    Button("\(min) min") { user.breakDurationMinutes = min }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Break: \(user.breakDurationMinutes) min")
                        .font(.brandCaption.weight(.medium))
                        .foregroundStyle(Color.brandGreen)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.brandGreen.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.7), in: Capsule())
            }

            Spacer()
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
                ProgressView().tint(Color.brandGreen)
                Text("Planning your session...")
                    .font(.brandCaption)
                    .foregroundStyle(Color.brandGreen.opacity(0.7))
            }

        case .loaded(let tasks):
            SubTaskListView(tasks: tasks) { tappedTask in
                selectedTask = tappedTask
            }

        case .unsupported:
            Text("AI breakdown requires iOS 18.1+ on iPhone 15 Pro or iPhone 16.")
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .multilineTextAlignment(.center)

        case .error(let message):
            Text(message)
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - SubTaskListView

struct SubTaskListView: View {
    let tasks: [SubTask]
    let onSelect: (SubTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your plan")
                .font(.brandCaption.bold())
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .textCase(.uppercase)

            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                Button { onSelect(task) } label: {
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.brandCaption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.brandGreen, in: Circle())

                        VStack(alignment: .leading, spacing: 1) {
                            Text(task.title)
                                .font(.brandCaption.weight(.medium))
                                .foregroundStyle(Color.brandGreen)
                                .multilineTextAlignment(.leading)
                            Text("\(task.durationMinutes) min")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.brandGreen.opacity(0.5))
                        }

                        Spacer()

                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(Color.brandGreenMid)
                            .font(.title3)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Outline button style (secondary action)

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.brandBody.weight(.medium))
            .foregroundStyle(Color.brandGreen)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.brandGreen.opacity(0.4), lineWidth: 1.5)
                    .background(Color.white.opacity(configuration.isPressed ? 0.5 : 0.3),
                                in: RoundedRectangle(cornerRadius: 14))
            )
    }
}

// MARK: - Badges

struct PointsBadge: View {
    let points: Int
    var body: some View {
        Label("\(points)", systemImage: "star.fill")
            .font(.brandCaption.bold())
            .foregroundStyle(Color.brandGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.brandGreenSoft, in: Capsule())
    }
}

struct StreakBadge: View {
    let streak: Int
    var body: some View {
        Label("\(streak)", systemImage: "flame.fill")
            .font(.brandCaption.bold())
            .foregroundStyle(Color.brandGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.brandGreenSoft, in: Capsule())
    }
}

#Preview {
    HomeView()
}
