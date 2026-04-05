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
    @Query private var chapters: [StoryChapter]
    @Environment(\.modelContext) private var context
 
    @State private var editedName   = ""
    @State private var editedGenre  = StoryGenre.fantasy
    @State private var showGenrePicker = false
    @State private var showResetAlert  = false
 
    let focusOptions = [10, 15, 20, 25, 30, 45]
    let breakOptions = [5, 10, 15]
 
    var user: UserProgress? { progressList.first }
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandMint.ignoresSafeArea()
 
                Form {
 
                    // MARK: Profile
                    Section {
                        // Editable name
                        HStack {
                            Text("Hero name")
                                .foregroundStyle(Color.brandGreen)
                            Spacer()
                            TextField("Your name", text: $editedName)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(Color.brandGreen)
                                .onSubmit { saveName() }
                        }
 
                        // Genre picker — shows alert when changing
                        HStack {
                            Text("Story world")
                                .foregroundStyle(Color.brandGreen)
                            Spacer()
                            Menu {
                                ForEach(StoryGenre.allCases, id: \.self) { genre in
                                    Button {
                                        if genre != editedGenre {
                                            editedGenre   = genre
                                            showResetAlert = true
                                        }
                                    } label: {
                                        Label(genre.rawValue, systemImage: genreIcon(genre))
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(editedGenre.emoji)
                                    Text(editedGenre.rawValue)
                                        .foregroundStyle(Color.brandGreen)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption2)
                                        .foregroundStyle(Color.brandGreen.opacity(0.5))
                                }
                            }
                        }
                    } header: {
                        Text("Profile").foregroundStyle(Color.brandGreen.opacity(0.7))
                    }
 
                    // MARK: Timer
                    Section {
                        if let user {
                            Picker("Focus duration", selection: Binding(
                                get: { user.focusDurationMinutes },
                                set: { user.focusDurationMinutes = $0 }
                            )) {
                                ForEach(focusOptions, id: \.self) { Text("\($0) min").tag($0) }
                            }
                            .foregroundStyle(Color.brandGreen)
 
                            Picker("Break duration", selection: Binding(
                                get: { user.breakDurationMinutes },
                                set: { user.breakDurationMinutes = $0 }
                            )) {
                                ForEach(breakOptions, id: \.self) { Text("\($0) min").tag($0) }
                            }
                            .foregroundStyle(Color.brandGreen)
                        }
                    } header: {
                        Text("Session defaults").foregroundStyle(Color.brandGreen.opacity(0.7))
                    }
 
                    // MARK: Stats
                    Section {
                        if let user {
                            LabeledContent("Total points", value: "\(user.totalPoints)")
                            LabeledContent("Current streak", value: "\(user.currentStreak) days")
                            LabeledContent("Chapters unlocked", value: "\(user.unlockedChapterCount)")
                        }
                    } header: {
                        Text("Stats").foregroundStyle(Color.brandGreen.opacity(0.7))
                    }
 
                    // MARK: About
                    Section {
                        LabeledContent("Version", value: "1.0.0") 
                    } header: {
                        Text("About").foregroundStyle(Color.brandGreen.opacity(0.7))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { loadCurrentValues() }
            // Save name whenever user leaves the screen
            .onDisappear { saveName() }
            .alert("Change story world?", isPresented: $showResetAlert) {
                Button("Change & reset chapters", role: .destructive) {
                    saveGenreAndResetChapters()
                }
                Button("Keep current world", role: .cancel) {
                    // revert the menu selection
                    editedGenre = user?.genre ?? .fantasy
                }
            } message: {
                Text("Switching to \(editedGenre.rawValue) will reset your chapter progress for this world. Your points and streak are kept.")
            }
        }
    }
 
    // MARK: - Helpers
 
    private func loadCurrentValues() {
        editedName  = user?.heroName ?? ""
        editedGenre = user?.genre    ?? .fantasy
    }
 
    private func saveName() {
        guard let user,
              !editedName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        user.heroName = editedName.trimmingCharacters(in: .whitespaces)
    }
 
    private func saveGenreAndResetChapters() {
        guard let user else { return }
        user.genre                = editedGenre
        user.unlockedChapterCount = 0
 
        // Delete all existing chapters so new ones generate fresh
        for chapter in chapters {
            context.delete(chapter)
        }
    }
 
    private func genreIcon(_ genre: StoryGenre) -> String {
        switch genre {
        case .fantasy: return "wand.and.stars"
        case .mystery: return "magnifyingglass"
        case .sciFi:   return "airplane"
        }
    }
}
 
#Preview {
    SettingsView()
}
