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
            backgroundColor.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: vm.phase)
 
            switch vm.phase {
            case .focusing, .idle:
                focusView
            case .onBreak:
                breakView
            case .complete:
                completeView
            }
        }
        .onAppear {
            vm.taskLabel     = taskLabel
            vm.focusDuration = TimeInterval(durationMinutes * 60)
            vm.startSession()
        }
    }
 
    // MARK: - Focus view
 
    private var focusView: some View {
        VStack(spacing: 36) {
            Spacer()
 
            Text(taskLabel)
                .font(.brandHeading)
                .foregroundStyle(Color.brandGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
 
            Text("FOCUS")
                .font(.brandCaption.uppercaseSmallCaps())
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.brandGreenSoft, in: Capsule())
 
            Text(vm.timeRemaining.timerFormatted)
                .font(.system(size: 80, weight: .thin, design: .serif))
                .foregroundStyle(Color.brandGreen)
                .monospacedDigit()
 
            Label("\(projectedPoints) pts so far", systemImage: "star.fill")
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreenMid)
 
            Spacer()
 
            VStack(spacing: 14) {
                Button {
                    vm.isPaused ? vm.resume() : vm.pause()
                } label: {
                    Label(
                        vm.isPaused ? "Resume" : "Pause",
                        systemImage: vm.isPaused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(GreenButtonStyle())
 
                Button("End session early") {
                    let record = vm.endSession()
                    saveSession(record)
                    dismiss()
                }
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen.opacity(0.5))
            }
            .padding(.horizontal, 32)
 
            Spacer()
        }
    }
 
    // MARK: - Break view
 
    private var breakView: some View {
        VStack(spacing: 36) {
            Spacer()
 
            Text("☕")
                .font(.system(size: 64))
 
            Text("Break time!")
                .font(.brandTitle)
                .foregroundStyle(Color.brandGreen)
 
            Text("Step away, stretch, breathe.")
                .font(.brandBody)
                .foregroundStyle(Color.brandGreen.opacity(0.7))
 
            Text("BREAK")
                .font(.brandCaption.uppercaseSmallCaps())
                .foregroundStyle(Color.brandGreen.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.brandGreenSoft, in: Capsule())
 
            Text(vm.timeRemaining.timerFormatted)
                .font(.system(size: 80, weight: .thin, design: .serif))
                .foregroundStyle(Color.brandGreen)
                .monospacedDigit()
 
            Spacer()
 
            VStack(spacing: 14) {
                Button {
                    vm.isPaused ? vm.resume() : vm.pause()
                } label: {
                    Label(
                        vm.isPaused ? "Resume break" : "Pause break",
                        systemImage: vm.isPaused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(GreenButtonStyle())
 
                Button("Skip break") {
                    vm.skipBreak()
                }
                .font(.brandCaption)
                .foregroundStyle(Color.brandGreen.opacity(0.5))
            }
            .padding(.horizontal, 32)
 
            Spacer()
        }
    }
 
    // MARK: - Complete view
 
    private var completeView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandGreenMid)
            Text("Session complete!")
                .font(.brandTitle)
                .foregroundStyle(Color.brandGreen)
            Text("You earned \(vm.pointsEarned) points")
                .font(.brandBody)
                .foregroundStyle(Color.brandGreen.opacity(0.7))
            Spacer()
            Button("Done") {
                let record = vm.endSession()
                saveSession(record)
                dismiss()
            }
            .buttonStyle(GreenButtonStyle())
            .padding(.horizontal, 32)
            Spacer()
        }
    }
 
    // MARK: - Helpers
 
    private var backgroundColor: Color {
        switch vm.phase {
        case .onBreak:  return .breakBackground
        case .complete: return .brandMint
        default:        return .focusBackground
        }
    }
 
    private var projectedPoints: Int {
        let mins = Int(vm.totalFocused / 60)
        return max(0, mins * Constants.Points.perMinuteFocused
                        - vm.pauseCount * Constants.Points.penaltyPerPause)
    }
 
    private func saveSession(_ record: SessionRecord) {
        context.insert(record)
        user?.addPoints(record.pointsEarned)
    }
}

#Preview {
    SessionView(taskLabel: "Math", durationMinutes: 20)
}
