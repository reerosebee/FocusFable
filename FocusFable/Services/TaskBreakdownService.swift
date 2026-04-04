//
//  TaskBreakdownSwift.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation
import FoundationModels

// MARK: - Structured output types
// @Generable tells the Foundation Models framework exactly what shape to return.
// No JSON parsing needed — Apple enforces the structure for you.

@Generable
struct StudyPlan {
    @Guide(description: "Between 3 and 5 specific, actionable study steps")
    var steps: [StudyStep]
}

@Generable
struct StudyStep {
    @Guide(description: "A specific, actionable task under 50 characters. Not vague — e.g. 'Review pages 40–55' not 'Study chapter'")
    var title: String

    @Guide(description: "Duration in minutes. Must be exactly the session length the user chose.")
    var durationMinutes: Int
}

// MARK: - Service

struct TaskBreakdownService {

    /// Breaks a study task into Pomodoro-sized steps using the on-device model.
    /// Falls back to a hardcoded plan if the device doesn't support Foundation Models.
    func breakdown(task: String, sessionMinutes: Int) async throws -> [SubTask] {

        // Check device support before trying
        let model = SystemLanguageModel.default
        print("🔍 Model availability: \(model.availability)")
        guard case .available = model.availability else {
            return fallbackBreakdown(task: task, sessionMinutes: sessionMinutes)
        }

        let session = LanguageModelSession()

        let prompt = """
        You are a study coach helping a high school student with ADHD.
        Break down this study task into \(sessionMinutes)-minute Pomodoro steps: "\(task)"
        Each step must be specific and actionable. Maximum 5 steps.
        Every step's durationMinutes must be \(sessionMinutes).
        """

        let response = try await session.respond(
            to: prompt,
            generating: StudyPlan.self
        )

        return response.content.steps.map {
            SubTask(title: $0.title, durationMinutes: $0.durationMinutes)
        }
    }

    // MARK: - Fallback for unsupported devices

    /// Returns a generic 3-step plan when on-device AI isn't available.
    private func fallbackBreakdown(task: String, sessionMinutes: Int) -> [SubTask] {
        return [
            SubTask(title: "Review your notes on: \(task)", durationMinutes: sessionMinutes),
            SubTask(title: "Practice or work through problems", durationMinutes: sessionMinutes),
            SubTask(title: "Summarize what you learned", durationMinutes: sessionMinutes)
        ]
    }
}
