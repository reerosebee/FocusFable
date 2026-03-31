//
//  SettingsView.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var progressList: [UserProgress]

    var user: UserProgress? { progressList.first }

    let focusOptions = [10, 15, 20, 25, 30, 45]
    let breakOptions = [5, 10, 15]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Profile
                Section("Profile") {
                    if let user {
                        LabeledContent("Hero name", value: user.heroName)
                        LabeledContent("Story world", value: user.genre.rawValue)
                        LabeledContent("Total points", value: "\(user.totalPoints)")
                        LabeledContent("Current streak", value: "\(user.currentStreak) days")
                    }
                }

                // MARK: Timer
                Section("Session defaults") {
                    if let user {
                        Picker("Focus duration", selection: Binding(
                            get: { user.focusDurationMinutes },
                            set: { user.focusDurationMinutes = $0 }
                        )) {
                            ForEach(focusOptions, id: \.self) { min in
                                Text("\(min) min").tag(min)
                            }
                        }

                        Picker("Break duration", selection: Binding(
                            get: { user.breakDurationMinutes },
                            set: { user.breakDurationMinutes = $0 }
                        )) {
                            ForEach(breakOptions, id: \.self) { min in
                                Text("\(min) min").tag(min)
                            }
                        }
                    }
                }

                // MARK: About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Built for", value: "Technovation Girls 2025")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
