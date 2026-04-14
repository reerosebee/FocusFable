//
//  TaskBreakdownService.swift
//  FocusFable
//

import Foundation
import FoundationModels

// MARK: - Structured output types

@Generable
struct StudyPlan {
    @Guide(description: "Between 3 and 5 specific, actionable study steps")
    var steps: [StudyStep]
}

@Generable
struct StudyStep {
    @Guide(description: "A specific, actionable task under 50 characters. Not vague — e.g. 'Review pages 40-55' not 'Study chapter'")
    var title: String

    @Guide(description: "Duration in minutes. Must match the session length the user chose.")
    var durationMinutes: Int
}

// MARK: - Service

struct TaskBreakdownService {

    func breakdown(task: String, sessionMinutes: Int) async throws -> [SubTask] {

        let model = SystemLanguageModel.default

        // Log exactly what availability returns
        print("🤖 FoundationModels availability: \(model.availability)")

        switch model.availability {
        case .available:
            print("✅ Model is available — calling LanguageModelSession")
            return try await runModel(task: task, sessionMinutes: sessionMinutes)

        case .unavailable(let reason):
            print("❌ Model unavailable — reason: \(reason)")
            return fallbackBreakdown(task: task, sessionMinutes: sessionMinutes)
        }
    }

    private func runModel(task: String, sessionMinutes: Int) async throws -> [SubTask] {
        let session = LanguageModelSession()

        let prompt = """
        You are a study coach helping a high school student with ADHD.
        Break down this study task into \(sessionMinutes)-minute Pomodoro steps: "\(task)"
        Each step must be specific and actionable. Maximum 5 steps.
        Every step's durationMinutes must be \(sessionMinutes).
        """

        print("📝 Sending prompt: \(prompt)")

        let response = try await session.respond(
            to: prompt,
            generating: StudyPlan.self
        )

        print("📦 Raw response: \(response)")
        print("📋 Steps count: \(response.content.steps.count)")

        let tasks = response.content.steps.map {
            SubTask(title: $0.title, durationMinutes: $0.durationMinutes)
        }

        print("✅ Returning \(tasks.count) tasks")
        return tasks
    }

    private func fallbackBreakdown(task: String, sessionMinutes: Int) -> [SubTask] {
        print("⚠️ Using fallback breakdown")
        return [
            SubTask(title: "Review your notes on: \(task)", durationMinutes: sessionMinutes),
            SubTask(title: "Practice or work through problems", durationMinutes: sessionMinutes),
            SubTask(title: "Summarize what you learned", durationMinutes: sessionMinutes)
        ]
    }
}
