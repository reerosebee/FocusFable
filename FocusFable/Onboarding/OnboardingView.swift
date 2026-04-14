//
//  OnboardingView.swift
//  FocusFable
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context

    @State private var step          = 0
    @State private var heroName      = ""
    @State private var selectedGenre = StoryGenre.mystery

    var body: some View {
        ZStack {
            Color.brandMint.ignoresSafeArea()

            TabView(selection: $step) {

                // MARK: Screen 1 — Welcome
                VStack(spacing: 28) {
                    Spacer()
                    Image("FocusFableIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    Text("Study hard.\nUnlock your story.")
                        .font(.brandBody)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.brandGreen.opacity(0.7))
                    Spacer()
                    Button("Get Started") { withAnimation { step = 1 } }
                        .buttonStyle(GreenButtonStyle())
                }
                .padding(32)
                .tag(0)

                // MARK: Screen 2 — Hero name
                VStack(spacing: 24) {
                    Spacer()
                    Text("What's your hero's name?")
                        .font(.brandHeading)
                        .foregroundStyle(Color.brandGreen)
                    TextField("Enter your name", text: $heroName)
                        .textFieldStyle(GreenTextFieldStyle())
                        .autocorrectionDisabled()
                    Spacer()
                    Button("Next") { withAnimation { step = 2 } }
                        .buttonStyle(GreenButtonStyle())
                        .disabled(heroName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(32)
                .tag(1)

                // MARK: Screen 3 — Genre
                VStack(spacing: 16) {
                    Spacer()
                    Text("Choose your story world")
                        .font(.brandHeading)
                        .foregroundStyle(Color.brandGreen)

                    ForEach(StoryGenre.allCases, id: \.self) { genre in
                        GenreCard(
                            genre: genre,
                            isSelected: selectedGenre == genre,
                            onTap: {
                                if genre.isAvailable {
                                    selectedGenre = genre
                                }
                            }
                        )
                    }

                    Spacer()
                    Button("Start My Journey") {
                        let progress = UserProgress(heroName: heroName, genre: selectedGenre)
                        context.insert(progress)
                    }
                    .buttonStyle(GreenButtonStyle())
                }
                .padding(32)
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.brandGreen)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.brandGreenSoft)
            }
        }
    }
}

// MARK: - Genre Card

struct GenreCard: View {
    let genre: StoryGenre
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(genre.emoji)
                    .font(.title)
                    .opacity(genre.isAvailable ? 1 : 0.4)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(genre.rawValue)
                            .font(.brandBody.bold())
                            .foregroundStyle(genre.isAvailable ? Color.brandGreen : Color.brandGreen.opacity(0.35))
                        if !genre.isAvailable {
                            Text("Soon")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color.brandGreen.opacity(0.5))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.brandGreenSoft, in: Capsule())
                        }
                    }
                    Text(genre.description)
                        .font(.brandCaption)
                        .foregroundStyle(Color.brandGreen.opacity(genre.isAvailable ? 0.6 : 0.3))
                }

                Spacer()

                if genre.isAvailable {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.brandGreen)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brandGreen.opacity(0.3))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(genre.isAvailable
                          ? (isSelected ? Color.brandGreenSoft : Color.white.opacity(0.6))
                          : Color.white.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected && genre.isAvailable ? Color.brandGreen : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!genre.isAvailable)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Shared styles

struct GreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.brandBody.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.brandGreen)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
    }
}

struct GreenTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandGreen.opacity(0.3), lineWidth: 1)
            )
    }
}

typealias PrimaryButtonStyle = GreenButtonStyle
