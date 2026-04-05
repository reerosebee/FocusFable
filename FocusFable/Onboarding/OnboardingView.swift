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
 
    @State private var step          = 0
    @State private var heroName      = ""
    @State private var selectedGenre = StoryGenre.fantasy
 
    var body: some View {
        ZStack {
            Color.brandMint.ignoresSafeArea()
 
            TabView(selection: $step) {
 
                // Welcome Screen
                VStack(spacing: 28) {
                    Spacer()
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.brandGreen)
                    Text("FocusFable")
                        .font(.brandTitle)
                        .foregroundStyle(Color.brandGreen)
                    Text("Study hard.\nUnlock your story.")
                        .font(.brandBody)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.brandGreen.opacity(0.7))
                    Spacer()
                    Button("Get Started") { withAnimation { step = 1 } }
                        .buttonStyle(GreenButtonStyle())
                        .padding(.bottom)
                }
                .padding(32)
                .tag(0)
 
                // Hero name Screen
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
                        .padding(.bottom)
                }
                .padding(32)
                .tag(1)
 
                // Genre Screen
                VStack(spacing: 16) {
                    Spacer()
                    Text("Choose your story world")
                        .font(.brandHeading)
                        .foregroundStyle(Color.brandGreen)
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
                    .buttonStyle(GreenButtonStyle())
                    .padding(.bottom)
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
                Text(genre.emoji).font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(genre.rawValue)
                        .font(.brandBody.bold())
                        .foregroundStyle(Color.brandGreen)
                    Text(genre.description)
                        .font(.brandCaption)
                        .foregroundStyle(Color.brandGreen.opacity(0.6))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.brandGreenSoft : Color.white.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.brandGreen : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
 
// MARK: - Shared button style
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
 
// MARK: - Shared text field style
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

#Preview {
    OnboardingView()
}
