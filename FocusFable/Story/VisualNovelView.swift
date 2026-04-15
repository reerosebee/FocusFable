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
    @State private var typingTimer: Timer? = nil

    private var currentScene: StoryScene {
        if let branch = branchScenes { return branch[branchIndex] }
        return scenes[mainIndex]
    }

    private var isChoiceScene: Bool { currentScene.choices != nil && !isTyping }
    private var isLastScene: Bool   { branchScenes == nil && mainIndex >= scenes.count - 1 }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                backgroundLayer

                spriteLayer(geo: geo)

                // Box sits 80pt from the bottom — simple, no dynamic padding needed
                VStack(spacing: 0) {
                    Spacer()
                    if isChoiceScene {
                        choiceBox
                    } else {
                        dialogueBox
                    }
                    Spacer().frame(height: 105)
                }
            }
            .onTapGesture { if !isChoiceScene { handleTap() } }
        }
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

    private func spriteLayer(geo: GeometryProxy) -> some View {
        let spriteHeight = geo.size.height * 1.25

        return HStack(alignment: .bottom, spacing: 0) {
            if let left = currentScene.leftSprite {
                spriteImage(named: left, isActive: isLeftSpeaking, height: spriteHeight)
                    .padding(.leading, geo.size.width * 0.01)
            } else {
                Spacer()
            }
            Spacer()
            if let right = currentScene.rightSprite {
                spriteImage(named: right, isActive: isRightSpeaking, height: spriteHeight)
                    .padding(.trailing, geo.size.width * 0.01)
            } else {
                Spacer()
            }
        }
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        .animation(.easeInOut(duration: 0.25), value: currentScene.leftSprite)
        .animation(.easeInOut(duration: 0.25), value: currentScene.rightSprite)
        .animation(.easeInOut(duration: 0.25), value: currentScene.speakerName)
    }

    // MARK: - Speaker detection

    private func isSpeaking(_ spriteName: String) -> Bool {
        let speaker = currentScene.speakerName.lowercased()
        let delNames = ["you", "del", "delphinium"]
        let firstName = speaker.components(separatedBy: " ").first ?? speaker
        if speaker.isEmpty || speaker == "narrator" { return false }
        if delNames.contains(firstName) { return false }
        return spriteName.lowercased().hasPrefix(firstName)
    }

    private var isLeftSpeaking: Bool {
        guard let left = currentScene.leftSprite else { return false }
        return isSpeaking(left)
    }

    private var isRightSpeaking: Bool {
        guard let right = currentScene.rightSprite else { return false }
        return isSpeaking(right)
    }

    // MARK: - Sprite image

    private func spriteImage(named: String, isActive: Bool, height: CGFloat) -> some View {
        Group {
            if UIImage(named: named) != nil {
                Image(named)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
                    .brightness(isActive ? 0 : -0.25)
                    .saturation(isActive ? 1.0 : 0.55)
            } else {
                Circle()
                    .fill(Color.brandGreenSoft)
                    .frame(width: height * 0.4, height: height * 0.4)
                    .overlay(
                        Text(String(named.prefix(1)).uppercased())
                            .font(.brandHeading)
                            .foregroundStyle(Color.brandGreen)
                    )
                    .brightness(isActive ? 0 : -0.25)
                    .saturation(isActive ? 1.0 : 0.55)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }

    // MARK: - Dialogue box

    private var dialogueBox: some View {
        HStack(alignment: .center, spacing: 12) {
            if !currentScene.speakerName.isEmpty {
                Text(currentScene.speakerName)
                    .font(.brandCaption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.brandGreen, in: RoundedRectangle(cornerRadius: 8))
                    .fixedSize()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayedText)
                    .font(.brandBody)
                    .foregroundStyle(Color.brandGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if !isTyping {
                    HStack {
                        Spacer()
                        Image(systemName: isLastScene ? "checkmark.circle" : "chevron.right.2")
                            .font(.caption)
                            .foregroundStyle(Color.brandGreen.opacity(0.5))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandGreenSoft, lineWidth: 1.5))
        .padding(.horizontal, 24)
    }

    // MARK: - Choice box

    private var choiceBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What do you ask?")
                .font(.brandCaption.bold())
                .foregroundStyle(Color.brandGreen.opacity(0.7))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                if let choices = currentScene.choices {
                    ForEach(choices) { choice in
                        Button { selectChoice(choice) } label: {
                            Text(choice.label)
                                .font(.brandBody)
                                .foregroundStyle(Color.brandGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.brandMint, in: RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.brandGreen.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandGreenSoft, lineWidth: 1.5))
        .padding(.horizontal, 24)
    }

    // MARK: - Typewriter

    private func startTyping() {
        // Cancel any existing timer before starting fresh
        typingTimer?.invalidate()
        typingTimer = nil

        displayedText = ""
        isTyping      = true
        let full      = currentScene.dialogue

        if currentScene.choices != nil {
            displayedText = full
            isTyping = false
            return
        }

        var i = full.startIndex
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [self] t in
            guard i < full.endIndex else {
                t.invalidate()
                typingTimer = nil
                isTyping = false
                return
            }
            displayedText.append(full[i])
            i = full.index(after: i)
        }
    }

    // MARK: - Navigation

    private func handleTap() {
        if isTyping {
            typingTimer?.invalidate()
            typingTimer = nil
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
