//
//  OnboardingView.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context

    @State private var step            = 0
    @State private var heroName        = ""
    @State private var selectedGenre   = StoryGenre.fantasy

    var body: some View {
        TabView(selection: $step) {

            // MARK: Screen 1 — Welcome
            VStack(spacing: 28) {
                Spacer()
                Text("📖")
                    .font(.system(size: 64))
                Text("Focus Fable")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appAccent)
                Text("Study hard.\nUnlock your story.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Get Started") { withAnimation { step = 1 } }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(32)
            .tag(0)

            // MARK: Screen 2 — Hero name
            VStack(spacing: 24) {
                Spacer()
                Text("What's your hero's name?")
                    .font(.title2.bold())
                TextField("Enter your name", text: $heroName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                Spacer()
                Button("Next") { withAnimation { step = 2 } }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(heroName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(32)
            .tag(1)

            // MARK: Screen 3 — Genre
            VStack(spacing: 20) {
                Spacer()
                Text("Choose your story world")
                    .font(.title2.bold())

                ForEach(StoryGenre.allCases, id: \.self) { genre in
                    GenreCard(genre: genre, isSelected: selectedGenre == genre) {
                        selectedGenre = genre
                    }
                }

                Spacer()
                Button("Start My Journey") {
                    let progress = UserProgress(heroName: heroName, genre: selectedGenre)
                    context.insert(progress)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(32)
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .animation(.easeInOut, value: step)
    }
}

// MARK: - Genre selection card
struct GenreCard: View {
    let genre: StoryGenre
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(genre.emoji)
                    .font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(genre.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(genre.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appAccent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appAccent.opacity(0.1) : Color(.systemGray6))
                    .stroke(isSelected ? Color.appAccent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Reusable primary button style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appAccent)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
    }
}
#Preview {
    OnboardingView()
}
