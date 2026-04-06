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
    let leftSprite: String?      // full asset name including pose e.g. "iris_surprised"
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
//
// Naming convention: charactername_pose
// Each string must exactly match an image set name in Assets.xcassets
//
// HOW TO ADD YOUR SPRITES:
// 1. Export each pose from your slides as a PNG with transparent background
// 2. In Xcode, open Assets.xcassets
// 3. Create a New Image Set for each pose
// 4. Name it exactly as listed below (e.g. "iris_neutral")
// 5. Drag your PNG into the 1x, 2x, or 3x slot
//
// You can add as many poses per character as you have art for.
// If a pose asset isn't added yet, the code falls back to a colored circle placeholder.

private enum Iris {
    static let neutral    = "iris_neutral"     // default standing pose
    static let surprised  = "iris_surprised"
    static let concerned  = "iris_concerned"   // worried expression
    static let talking    = "iris_talking"     // mid-sentence, slight smile
    static let laughing   = "iris_laughing"
}

private enum Marigold {
    static let neutral    = "marigold_neutral"
    static let sad        = "marigold_sad"     // delivering bad news
    static let serious    = "marigold_serious" // firm/determined
    static let concerned  = "marigold_concerned" // concerned
    static let talking    = "marigold_talking"
}

private enum Del {
    // Del is the player — use poses that match internal monologue / reactions
    static let neutral    = "del_neutral"
    static let confused   = "del_confused"     // memory loss moments
    static let sarcastic  = "del_sarcastic"    // dry humor lines
    static let shocked    = "del_shocked"      // bad news reaction
}

private enum Zinn {
    static let neutral    = "zinn_neutral"
    static let grinning   = "zinn_grinning"    // cocky intro
    static let laughing   = "zinn_laughing"    // reacting to Del's jokes
    static let beckoning  = "zinn_beckoning"   // "come with me" pose
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
                   dialogue: "\u{201c}Oh! You\u{2019}re finally awake!\u{201d}"),
        
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.surprised,
                   rightSprite: Marigold.concerned,
                   speakerName: "Unknown Girl 2",
                   dialogue: "\u{201c}We thought you wouldn\u{2019}t wake up ever again.\u{201d}"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.talking,
                   rightSprite: Marigold.neutral,
                   speakerName: "Iris",
                   dialogue: "\u{201c}I\u{2019}m not sure if you remember\u{2026} But I\u{2019}m Iris and here\u{2019}s Marigold.\u{201d}"),
 
        // Choice screen
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.neutral,
                   rightSprite: Marigold.neutral,
                   speakerName: "", dialogue: "Choose a question to ask:",
                   choices: [
 
                    StoryChoice(label: "\u{201c}Where am I?\u{201d}", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.talking,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "Iris",
                                   dialogue: "\u{201c}You\u{2019}re in Flower Valley Hospital in Echelon City.\u{201d}"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Del.confused,
                                   rightSprite: Iris.neutral,
                                   speakerName: "You",
                                   dialogue: "\u{201c}Echelon City\u{2026} I think I remember\u{2026} Nope, I got nothing.\u{201d}"),
                    ]),
 
                    StoryChoice(label: "\u{201c}Who am I?\u{201d}", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: Iris.talking,
                                   rightSprite: Marigold.neutral,
                                   speakerName: "Iris",
                                   dialogue: "\u{201c}Your name is Del, short for Delphinium. Do you not remember us? We\u{2019}re your close friends!\u{201d}"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Del.confused,
                                   rightSprite: Iris.concerned,
                                   speakerName: "You",
                                   dialogue: "\u{201c}Are you sure that\u{2019}s my name? It sounds like a drug! Strange\u{2026} I don\u{2019}t remember a single thing\u{2026}\u{201d}"),
                    ]),
 
                    StoryChoice(label: "\u{201c}What happened to me?\u{201d}", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: nil,
                                   rightSprite: Marigold.sad,
                                   speakerName: "Marigold",
                                   dialogue: "\u{201c}You were in a terrible car accident. I\u{2019}m sorry\u{2026} your parents didn\u{2019}t make it.\u{201d}"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Del.shocked,
                                   rightSprite: Iris.concerned,
                                   speakerName: "You",
                                   dialogue: "\u{201c}So you\u{2019}re saying I\u{2019}m an orphan now?\u{201d}"),
                    ]),
 
                    StoryChoice(label: "\u{201c}What do I do now?\u{201d}", scenes: [
                        StoryScene(background: BG.hospital,
                                   leftSprite: nil,
                                   rightSprite: Marigold.serious,
                                   speakerName: "Marigold",
                                   dialogue: "\u{201c}You can stay with us in our college dorm once you feel better. We have a lot to tell you\u{2026} time is ticking and we\u{2019}ll need your help.\u{201d}"),
                        StoryScene(background: BG.hospital,
                                   leftSprite: Del.confused,
                                   rightSprite: Iris.talking,
                                   speakerName: "You",
                                   dialogue: "\u{201c}College? I\u{2019}m not sure if I\u{2019}d like to stay with you both\u{2026}\u{201d}"),
                    ]),
                   ]),
 
        // All branches converge here
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.laughing,
                   rightSprite: nil,
                   speakerName: "Iris",
                   dialogue: "\u{201c}Are you sure you lost your memories? You still have the same sense of humor.\u{201d}"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: Iris.talking,
                   rightSprite: nil,
                   speakerName: "Iris",
                   dialogue: "\u{201c}Anyway, let us fill you in on a few things. We all go to J. Cipher University.\u{201d}"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: nil,
                   rightSprite: Marigold.talking,
                   speakerName: "Marigold",
                   dialogue: "\u{201c}We have another friend there that you\u{2019}ll meet. All four of us have been sponsored to go to university because of our talents.\u{201d}"),
 
        StoryScene(background: BG.hospital,
                   leftSprite: nil,
                   rightSprite: Marigold.neutral,
                   speakerName: "Marigold",
                   dialogue: "\u{201c}We\u{2019}ll explain more once you feel better! Bye for now!\u{201d}"),
    ]
 
    // MARK: Chapter 1 — J. Cipher University
    // Time skip, arriving at university, meeting Zinn.
 
    static let chapter1: [StoryScene] = [
 
        StoryScene(background: BG.transition,
                   leftSprite: nil,
                   rightSprite: nil,
                   speakerName: "Narrator",
                   dialogue: "A few weeks later\u{2026}"),
 
        StoryScene(background: BG.university,
                   leftSprite: Del.neutral,
                   rightSprite: nil,
                   speakerName: "You",
                   dialogue: "So this is J. Cipher University? I wonder what\u{2019}s so special about this school that I was sponsored to come here."),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.confused,
                   rightSprite: Zinn.neutral,
                   speakerName: "You",
                   dialogue: "Who is that weirdo with a cabbage on their head?"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.neutral,
                   rightSprite: Zinn.grinning,
                   speakerName: "Zinn",
                   dialogue: "\u{201c}Heya Del remember me? Or should I say del-usional!\u{201d}"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.confused,
                   rightSprite: Zinn.neutral,
                   speakerName: "You",
                   dialogue: "\u{201c}So it seems my name is actually Delphinium\u{2026} I was hoping that was a joke. Who are you?\u{201d}"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.neutral,
                   rightSprite: Zinn.grinning,
                   speakerName: "Zinn",
                   dialogue: "\u{201c}I\u{2019}m Zinn, the best locksmith in Echelon, of course\u{2026} well also your bestie ;).\u{201d}"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.sarcastic,
                   rightSprite: Zinn.neutral,
                   speakerName: "You",
                   dialogue: "\u{201c}Good to know. I\u{2019}ll keep you in mind if I ever lose my keys.\u{201d}"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.neutral,
                   rightSprite: Zinn.laughing,
                   speakerName: "Zinn",
                   dialogue: "\u{201c}Haha good one Del. Iris was right, your personality hasn\u{2019}t changed one bit.\u{201d}"),
 
        StoryScene(background: BG.universityCampus,
                   leftSprite: Del.neutral,
                   rightSprite: Zinn.beckoning,
                   speakerName: "Zinn",
                   dialogue: "\u{201c}Alright Del. Come with me, I\u{2019}ll bring you to the dorm Goldy told you about.\u{201d}"),
    ]
 
    // MARK: Fallback
 
    static func placeholderScenes(chapterIndex: Int) -> [StoryScene] {
        [StoryScene(background: BG.hospital,
                    leftSprite: nil,
                    rightSprite: nil,
                    speakerName: "Narrator",
                    dialogue: "Chapter \(chapterIndex + 1) is coming soon. Keep studying to unlock more!")]
    }
}
