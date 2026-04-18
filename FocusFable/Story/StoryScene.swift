//
//  StoryScene.swift
//  FocusFable
//
//  Story: "The Forgetful Bloom" by Riya and Mahati
//

import Foundation

// MARK: - Scene types

struct StoryScene: Identifiable {
    let id = UUID()
    let background: String
    let leftSprite: String?
    let rightSprite: String?
    let speakerName: String
    let dialogue: String
    var choices: [StoryChoice]?
}

struct StoryChoice: Identifiable {
    let id = UUID()
    let label: String
    let scenes: [StoryScene]
}

// MARK: - Sprite pose constants

private enum Iris {
    static let neutral    = "iris_neutral"
    static let surprised  = "iris_surprised"
    static let talking    = "iris_talking"
}

private enum Marigold {
    static let neutral    = "marigold_neutral"
    static let concerned  = "marigold_concerned"
    static let talking    = "marigold_talking"
}

private enum Zinn {
    static let neutral    = "zinn_neutral"
    static let talking   = "zinn_talking"
}

// MARK: - Background constants

private enum BG {
    static let hospital         = "bg_hospital"
    static let transition       = "bg_transition"
    static let university       = "bg_university"
    static let dorm             = "bg_dorm"
    static let universityCampus = "bg_campus"
}

// MARK: - Chapter library
 
struct ChapterLibrary {
 
    static func scenes(for chapterIndex: Int, genre: StoryGenre) -> [StoryScene] {
        switch chapterIndex {
        case 0:  return chapter0
        case 1:  return chapter1
        default: return placeholderScenes(chapterIndex: chapterIndex)
        }
    }
 
    // MARK: Chapter 0 — The Hospital
    // Waking up, meeting Iris and Marigold, choosing what to ask, learning about university.
 
    static let chapter0: [StoryScene] = [
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.surprised,
                   rightSprite: Marigold.concerned,
                   speakerName: "Unknown Girl 1",
                   dialogue: "“Oh! You're finally awake!”"),
        
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.surprised,
                   rightSprite: Marigold.concerned,
                   speakerName: "Unknown Girl 2",
                   dialogue: "”We thought you wouldn't wake up ever again.”"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.talking,
                   rightSprite: Marigold.concerned,
                   speakerName: "Iris",
                   dialogue: "“I'm not sure if you remember... But I'm Iris and here's Marigold.”"),
 
        // Choice screen
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.neutral,
                   rightSprite: Marigold.neutral,
                   speakerName: "", dialogue: "Choose a question to ask:",
                   choices: [
                    StoryChoice(label: "“Where am I?”", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.talking,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "Iris",
                                   dialogue: "“You're in Flower Valley Hospital in Echelon City.”"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "You",
                                   dialogue: "“Echelon City... I think I remember... Nope, I got nothing.”"),
                    ]),
 
                    StoryChoice(label: "“Who am I?", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.talking,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "Iris",
                                   dialogue: "“Your name is Del, short for Delphinium. Do you not remember us? We're your close friends!”"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "You",
                                   dialogue: "“Are you sure that's my name? It sounds like a drug! Strange... I don't remember a single thing...”"),
                    ]),
 
                    StoryChoice(label: "“What happened to me?”", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.concerned,
                                   speakerName: "Marigold",
                                   dialogue: "“You were in a terrible car accident. I'm sorry... your parents didn't make it.”"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.concerned,
                                   speakerName: "You",
                                   dialogue: "“So you're saying I'm an orphan now?”"),
                    ]),
 
                    StoryChoice(label: "“What do I do now?”", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.concerned,
                                   speakerName: "Marigold",
                                   dialogue: "“You can stay with us in our college dorm once you feel better. We have a lot to tell you... time is ticking and we'll need your help.”"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.neutral,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "You",
                                   dialogue: "“College? I'm not sure if I'd like to stay with you both...”"),
                    ]),
                   ]),
 
        // All branches converge here
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.talking,
                   rightSprite: Marigold.neutral,
                   speakerName: "Iris",
                   dialogue: "“Are you sure you lost your memories? You still have the same sense of humor.”"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.talking,
                   rightSprite: Marigold.neutral,
                   speakerName: "Iris",
                   dialogue: "“Anyway, let us fill you in on a few things. We all go to J. Cipher University.”"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.neutral,
                   rightSprite: Marigold.neutral,
                   speakerName: "Marigold",
                   dialogue: "“We have another friend there that you'll meet. All four of us have been sponsored to go to university because of our talents.”"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.neutral,
                   rightSprite: Marigold.neutral,
                   speakerName: "Marigold",
                   dialogue: "“We'll explain more once you feel better! Bye for now!”"),
    ]
 
    // MARK: Chapter 1 — J. Cipher University
    // Time skip, arriving at university, meeting Zinn.
    static let chapter1: [StoryScene] = [
 
        StoryScene(background: BG.transition,
                   leftSprite: nil,
                   rightSprite: nil,
                   speakerName: "Narrator",
                   dialogue: "A few weeks later..."),
 
        StoryScene(background: BG.university,
                   leftSprite: nil,
                   rightSprite: nil,
                   speakerName: "You",
                   dialogue: "So this is J. Cipher University? I wonder what's so special about this school that I was sponsored to come here."),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.neutral,
                   rightSprite: nil,
                   speakerName: "You",
                   dialogue: "Who is that weirdo with a cabbage on their head?"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.talking,
                   rightSprite: nil,
                   speakerName: "Zinn",
                   dialogue: "“Heya Del remember me? Or should I say del-usional!”"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.neutral,
                   rightSprite: nil,
                   speakerName: "You",
                   dialogue: "“So it seems my name is actually Delphinium... I was hoping that was a joke. Who are you?”"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.talking,
                   rightSprite: nil,
                   speakerName: "Zinn",
                   dialogue: "“I'm Zinn, the best locksmith in Echelon, of course... well also your bestie ;).”"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.neutral,
                   rightSprite: nil,
                   speakerName: "You",
                   dialogue: "“Good to know. I'll keep you in mind if I ever lose my keys.”"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.talking,
                   rightSprite: nil,
                   speakerName: "Zinn",
                   dialogue: "“Haha good one Del. Iris was right, your personality hasn't changed one bit.”"),
 
        StoryScene(background: BG.university,
                   leftSprite: Zinn.talking,
                   rightSprite: nil,
                   speakerName: "Zinn",
                   dialogue: "“Alright Del. Come with me, I'll bring you to the dorm Goldy told you about.”"),
    ]
 
    // MARK: Fallback
    static func placeholderScenes(chapterIndex: Int) -> [StoryScene] {
        [StoryScene(background: BG.university,
                    leftSprite: nil,
                    rightSprite: nil,
                    speakerName: "Narrator",
                    dialogue: "Chapter \(chapterIndex + 1) is coming soon. Keep studying to unlock more!")]
    }
}
