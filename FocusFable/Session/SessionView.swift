//
//  SessionView.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    let taskLabel: String
    let durationMinutes: Int

    @State private var vm = SessionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var progressList: [UserProgress]

    var user: UserProgress? { progressList.first }

    var body: some View {
        ZStack {
            // Background shifts with phase
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: vm.phase)

            VStack(spacing: 40) {
                // MARK: Task label
                Text(taskLabel)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // MARK: Phase label
                Text(phaseLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.5)

                // MARK: Timer display
                Text(vm.timeRemaining.timerFormatted)
                    .font(.system(size: 72, weight: .thin, design: .monospaced))
                    .foregroundStyle(.primary)

                // MARK: Points preview
                if vm.phase == .focusing {
                    Text("⭐ +\(projectedPoints) pts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: Controls
                if vm.phase == .complete {
                    completeView
                } else {
                    controlButtons
                }
            }
            .padding(32)
        }
        .onAppear {
            vm.taskLabel     = taskLabel
            vm.focusDuration = TimeInterval(durationMinutes * 60)
            vm.startSession()
        }
    }

    // MARK: - Sub-views

    private var controlButtons: some View {
        VStack(spacing: 16) {
            // Pause / Resume
            Button {
                vm.isPaused ? vm.resume() : vm.pause()
            } label: {
                Label(vm.isPaused ? "Resume" : "Pause",
                      systemImage: vm.isPaused ? "play.fill" : "pause.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            // End early
            Button("End Session") {
                let record = vm.endSession()
                saveSession(record)
                dismiss()
            }
            .foregroundStyle(.red)
            .font(.subheadline)
        }
    }

    private var completeView: some View {
        VStack(spacing: 20) {
            Text("Session complete!")
                .font(.title2.bold())
            Text("You earned \(vm.pointsEarned) points")
                .foregroundStyle(.secondary)
            Button("Done") {
                let record = vm.endSession()
                saveSession(record)
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        switch vm.phase {
        case .onBreak:   return .breakBackground
        case .complete:  return Color(.systemBackground)
        default:         return .focusBackground
        }
    }

    private var phaseLabel: String {
        switch vm.phase {
        case .focusing:  return "Focus"
        case .onBreak:   return "Break"
        case .complete:  return "Done"
        case .idle:      return ""
        }
    }

    private var projectedPoints: Int {
        let minutesFocused = Int(vm.totalFocused / 60)
        let pts = minutesFocused * Constants.Points.perMinuteFocused
        return max(0, pts - vm.pauseCount * Constants.Points.penaltyPerPause)
    }

    private func saveSession(_ record: SessionRecord) {
        context.insert(record)
        user?.addPoints(record.pointsEarned)
    }
}

#Preview {
    SessionView(taskLabel: "Math", durationMinutes: 20)
}
