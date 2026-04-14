//
//  VisualNovelView.swift
//  FocusFable
//

import SwiftUI

struct VisualNovelView: View {
    let scenes: [StoryScene]
    let chapterIndex: Int
    let onComplete: () -> Void

    @State private var mainIndex     = 0
    @State private var branchScenes: [StoryScene]? = nil
    @State private var branchIndex   = 0
    @State private var displayedText = ""
    @State private var isTyping      = false

    private var currentScene: StoryScene {
        if let branch = branchScenes { return branch[branchIndex] }
        return scenes[mainIndex]
    }

    private var isChoiceScene: Bool { currentScene.choices != nil && !isTyping }
    private var isLastScene: Bool   { branchScenes == nil && mainIndex >= scenes.count - 1 }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundLayer
            spriteLayer

            // Pinned to bottom — works correctly in landscape
            if isChoiceScene { choiceBox } else { dialogueBox }
        }
        .onTapGesture { if !isChoiceScene { handleTap() } }
        .onAppear {
            OrientationManager.shared.lock(.landscape)
            startTyping()
        }
        .onDisappear {
            OrientationManager.shared.lock(.portrait)
        }
        .statusBarHidden(true)
        .ignoresSafeArea()
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        Group {
            if UIImage(named: currentScene.background) != nil {
                Image(currentScene.background)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color.brandMint, Color.brandGreenSoft],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.4), value: currentScene.background)
    }

    // MARK: - Sprites

    private var spriteLayer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if let left = currentScene.leftSprite {
                spriteImage(named: left, isActive: isLeftSpeaking)
                    .padding(.leading, 16)
            } else {
                Spacer().frame(width: 100)
            }
            Spacer()
            if let right = currentScene.rightSprite {
                spriteImage(named: right, isActive: isRightSpeaking)
                    .padding(.trailing, 16)
            } else {
                Spacer().frame(width: 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 80)   // sits above dialogue box
        .animation(.easeInOut(duration: 0.25), value: currentScene.leftSprite)
        .animation(.easeInOut(duration: 0.25), value: currentScene.rightSprite)
        .animation(.easeInOut(duration: 0.25), value: currentScene.speakerName)
    }

    // MARK: - Active speaker detection

    private var isLeftSpeaking: Bool {
        guard let left = currentScene.leftSprite else { return true }
        let speaker = currentScene.speakerName.lowercased()
        // If no speaker or narrator, both are fully lit
        if speaker.isEmpty || speaker == "narrator" { return true }
        // Both sprites shown, neither is clearly matched → both lit
        let firstName = speaker.components(separatedBy: " ").first ?? speaker
        let youNames = ["you", "del", "delphinium"]
        if youNames.contains(firstName) {
            return left.lowercased().hasPrefix("del")
        }
        return left.lowercased().hasPrefix(firstName)
    }

    private var isRightSpeaking: Bool {
        guard let right = currentScene.rightSprite else { return true }
        let speaker = currentScene.speakerName.lowercased()
        if speaker.isEmpty || speaker == "narrator" { return true }
        let firstName = speaker.components(separatedBy: " ").first ?? speaker
        let youNames = ["you", "del", "delphinium"]
        if youNames.contains(firstName) {
            return right.lowercased().hasPrefix("del")
        }
        return right.lowercased().hasPrefix(firstName)
    }

    private func spriteImage(named: String, isActive: Bool) -> some View {
        Group {
            if UIImage(named: named) != nil {
                Image(named)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 370)
            } else {
                Circle()
                    .fill(Color.brandGreenSoft)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(named.prefix(1)).uppercased())
                            .font(.brandHeading)
                            .foregroundStyle(Color.brandGreen)
                    )
            }
        }
        // Shade inactive sprite — colorMultiply respects transparency
        .colorMultiply(isActive ? .white : Color(white: 0.6))
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }

    // MARK: - Dialogue box

    private var dialogueBox: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if !currentScene.speakerName.isEmpty {
                Text(currentScene.speakerName)
                    .font(.brandCaption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.brandGreen, in: RoundedRectangle(cornerRadius: 8))
                    .fixedSize()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(displayedText)
                    .font(.brandBody)
                    .foregroundStyle(Color.brandGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    if !isTyping {
                        Image(systemName: isLastScene ? "checkmark.circle" : "chevron.right.2")
                            .font(.caption)
                            .foregroundStyle(Color.brandGreen.opacity(0.5))
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandGreenSoft, lineWidth: 1))
        .padding(.horizontal, 40)
        .padding(.bottom, 80)
    }

    // MARK: - Choice box

    private var choiceBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What do you ask?")
                .font(.brandCaption.bold())
                .foregroundStyle(Color.brandGreen.opacity(0.7))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                if let choices = currentScene.choices {
                    ForEach(choices) { choice in
                        Button { selectChoice(choice) } label: {
                            Text(choice.label)
                                .font(.brandBody)
                                .foregroundStyle(Color.brandGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.85),
                                            in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brandGreenSoft, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandGreenSoft, lineWidth: 1))
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }

    // MARK: - Typewriter

    private func startTyping() {
        displayedText = ""
        isTyping      = true
        let full      = currentScene.dialogue

        if currentScene.choices != nil {
            displayedText = full
            isTyping = false
            return
        }

        var i = full.startIndex
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { t in
            guard i < full.endIndex else { t.invalidate(); isTyping = false; return }
            displayedText.append(full[i])
            i = full.index(after: i)
        }
    }

    // MARK: - Navigation

    private func handleTap() {
        if isTyping {
            displayedText = currentScene.dialogue
            isTyping = false
            return
        }
        if let branch = branchScenes {
            if branchIndex < branch.count - 1 {
                branchIndex += 1
                startTyping()
            } else {
                branchScenes = nil
                mainIndex   += 1
                startTyping()
            }
        } else {
            if isLastScene { onComplete() }
            else { mainIndex += 1; startTyping() }
        }
    }

    private func selectChoice(_ choice: StoryChoice) {
        branchScenes = choice.scenes
        branchIndex  = 0
        startTyping()
    }
}
