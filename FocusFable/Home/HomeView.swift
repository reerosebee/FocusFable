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
            ZStack {
               
                Color.brandMint.ignoresSafeArea()
 
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
                                .font(.brandHeading)
                                .foregroundStyle(Color.brandGreen)
 
                            TextField("e.g. study for bio test, finish math hw...",
                                      text: $vm.taskInput,
                                      axis: .vertical)
                                .lineLimit(2...4)
                                .textFieldStyle(GreenTextFieldStyle())
 
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
                            .buttonStyle(GreenButtonStyle())
                            .disabled(!vm.canBreakdown || vm.isLoading)
                        }
                        .padding()
                        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
 
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
                                    .font(.brandCaption)
                                    .foregroundStyle(Color.brandGreen.opacity(0.7))
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
                                    .font(.brandCaption)
                                    .foregroundStyle(Color.brandGreen.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
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
                        .buttonStyle(GreenButtonStyle())
 
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("FocusFable")
            .toolbar {
                if case .loaded = vm.breakdownState {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") { vm.reset() }
                            .foregroundStyle(Color.brandGreen)
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
                ProgressView().tint(Color.brandGreen)
                Text("Planning your session...")
                    .font(.brandBody)
                    .foregroundStyle(Color.brandGreen.opacity(0.7))
            }
            .padding()
 
        case .loaded(let tasks):
            SubTaskListView(tasks: tasks) { tappedTask in
                selectedTask = tappedTask
            }
 
        case .unsupported:
            VStack(alignment: .leading, spacing: 8) {
                Label("Apple Intelligence not available", systemImage: "exclamationmark.circle")
                    .font(.brandBody.bold())
                    .foregroundStyle(Color.brandGreen)
                Text("Requires iOS 18.1+ on iPhone 15 Pro or iPhone 16. Start a session manually below.")
                    .font(.brandCaption)
                    .foregroundStyle(Color.brandGreen.opacity(0.6))
            }
            .padding()
            .background(Color.brandGreenSoft, in: RoundedRectangle(cornerRadius: 12))
 
        case .error(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen)
                .padding()
                .background(Color.brandGreenSoft, in: RoundedRectangle(cornerRadius: 10))
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
                .font(.brandHeading)
                .foregroundStyle(Color.brandGreen)
 
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                Button { onSelect(task) } label: {
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.brandCaption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.brandGreen, in: Circle())
 
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.brandBody.weight(.medium))
                                .foregroundStyle(Color.brandGreen)
                                .multilineTextAlignment(.leading)
                            Text("\(task.durationMinutes) min · tap to start")
                                .font(.brandCaption)
                                .foregroundStyle(Color.brandGreen.opacity(0.6))
                        }
 
                        Spacer()
 
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(Color.brandGreenMid)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
 
            Text("Tap a step to begin that session")
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen.opacity(0.4))
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
            .background(Color.orange.opacity(0.25), in: Capsule())
    }
}


#Preview {
    HomeView()
}
