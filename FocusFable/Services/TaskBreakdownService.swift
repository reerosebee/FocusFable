//
//  TaskBreakdownService.swift
//  FocusFable
//

import Foundation
import FoundationModels

@Generable
struct StudyPlan {
    @Guide(description: "Between 3 and 5 specific, actionable study steps for this exact task")
    var steps: [StudyStep]
}

@Generable
struct StudyStep {
    @Guide(description: "One specific action the student should do — e.g. 'Memorize sine and cosine values for 0, 30, 45, 60, 90 degrees'. Do NOT include generic steps like 'set up workspace', 'reflect', or 'organize notes'. Every step must be directly about the topic given.")
    var title: String

    @Guide(description: "Duration in minutes. Must exactly equal the session length the user chose.")
    var durationMinutes: Int
}

// MARK: - Service

struct TaskBreakdownService {

    func breakdown(task: String, sessionMinutes: Int) async throws -> [SubTask] {
        let model = SystemLanguageModel.default
        print("🤖 availability: \(model.availability)")

        if case .available = model.availability {
            print("✅ Model available — calling AI")
            do {
                let result = try await runModel(task: task, sessionMinutes: sessionMinutes)
                print("✅ AI returned \(result.count) steps")
                return result
            } catch {
                print("⚠️ AI error, using smart fallback: \(error)")
                return smartFallback(task: task, sessionMinutes: sessionMinutes)
            }
        } else {
            print("❌ Model not available — using smart fallback")
            return smartFallback(task: task, sessionMinutes: sessionMinutes)
        }
    }

    // MARK: - Apple Intelligence

    private func runModel(task: String, sessionMinutes: Int) async throws -> [SubTask] {
        let session = LanguageModelSession()

        let prompt = """
        A high school student with ADHD needs to study: "\(task)"

        Create \(sessionMinutes)-minute focused Pomodoro steps for THIS specific topic.

        Rules:
        - Every step must be directly about "\(task)" — nothing generic
        - No "set up workspace", "organize notes", "reflect", "review your plan", or similar filler steps
        - Steps should be concrete actions: memorize, solve, draw, practice, summarize THIS topic
        - Maximum 4 steps
        - Each step's durationMinutes must be exactly \(sessionMinutes)

        Example for "unit circle trig":
        - "Label all angles (0°, 30°, 45°, 60°, 90°) on a blank circle"
        - "Memorize sine and cosine values for each angle"
        - "Practice finding tan, sec, csc, cot from the values"
        - "Do 10 practice problems using the unit circle"
        """

        let response = try await session.respond(to: prompt, generating: StudyPlan.self)
        return response.content.steps.map {
            SubTask(title: $0.title, durationMinutes: $0.durationMinutes)
        }
    }

    // MARK: - Smart rule-based fallback
    // Used when Apple Intelligence isn't available.
    // Detects subject from keywords and returns topic-specific steps.

    private func smartFallback(task: String, sessionMinutes: Int) -> [SubTask] {
        let lower = task.lowercased()

        // Trig / unit circle
        if containsAny(lower, ["trig", "unit circle", "sine", "cosine", "tangent",
                                "sin", "cos", "tan", "radian", "degree", "angle",
                                "secant", "cosecant", "cotangent"]) {
            return steps([
                "Draw and label a blank unit circle from memory",
                "Fill in all angle values (0°, 30°, 45°, 60°, 90°)",
                "Memorize sine and cosine for each angle",
                "Practice finding tan, sec, csc, cot from those values",
            ], minutes: sessionMinutes)
        }

        // Calculus
        if containsAny(lower, ["calculus", "derivative", "integral", "limit",
                                "differentiat", "integrat", "chain rule", "product rule",
                                "quotient rule", "implicit"]) {
            return steps([
                "Write out all relevant formulas from memory",
                "Work through example problems step by step",
                "Identify which rule applies to each problem type",
                "Do practice problems without looking at notes",
            ], minutes: sessionMinutes)
        }

        // General math / algebra / geometry
        if containsAny(lower, ["math", "algebra", "geometry", "equation",
                                "problem set", "homework", "hw", "worksheet",
                                "polynomial", "quadratic", "linear", "graph"]) {
            return steps([
                "Review worked examples from notes",
                "Attempt first half of problems",
                "Check answers and fix mistakes",
                "Attempt remaining problems",
            ], minutes: sessionMinutes)
        }

        // Essay / writing
        if containsAny(lower, ["essay", "write", "writing", "paper", "draft",
                                "thesis", "outline", "paragraph", "report"]) {
            return steps([
                "Brainstorm and write a quick outline",
                "Write introduction and first body paragraph",
                "Write remaining body paragraphs",
                "Write conclusion and revise for clarity",
            ], minutes: sessionMinutes)
        }

        // Reading
        if containsAny(lower, ["read", "reading", "chapter", "book", "novel",
                                "article", "passage", "text", "lit", "literature"]) {
            return steps([
                "Read and annotate the first section",
                "Write a 3-sentence summary of what you read",
                "Read and annotate the second section",
                "Answer any comprehension questions",
            ], minutes: sessionMinutes)
        }

        // Biology
        if containsAny(lower, ["bio", "biology", "cell", "dna", "genetics",
                                "evolution", "organism", "photosynthesis", "mitosis"]) {
            return steps([
                "Draw and label key diagrams from memory",
                "Re-read notes and highlight main concepts",
                "Define all bold vocabulary without looking",
                "Answer practice questions on this topic",
            ], minutes: sessionMinutes)
        }

        // Chemistry
        if containsAny(lower, ["chem", "chemistry", "element", "compound", "reaction",
                                "periodic", "molecule", "atom", "bond", "stoich"]) {
            return steps([
                "Write out key formulas and equations",
                "Review reaction types and examples",
                "Balance practice equations",
                "Work through stoichiometry problems",
            ], minutes: sessionMinutes)
        }

        // Physics
        if containsAny(lower, ["physics", "force", "motion", "velocity", "acceleration",
                                "newton", "energy", "momentum", "wave", "circuit"]) {
            return steps([
                "Write out all relevant physics formulas",
                "Understand what each variable represents",
                "Work through example problems step by step",
                "Solve practice problems without formula sheet",
            ], minutes: sessionMinutes)
        }

        // History / social studies
        if containsAny(lower, ["history", "social", "geography", "civics",
                                "war", "revolution", "government", "politics", "wwi", "wwii"]) {
            return steps([
                "Review the key events and their dates",
                "Identify causes and effects for each event",
                "Summarize key people and their significance",
                "Write a brief overview without looking at notes",
            ], minutes: sessionMinutes)
        }

        // Languages / vocab
        if containsAny(lower, ["vocab", "vocabulary", "spanish", "french", "latin",
                                "language", "grammar", "conjugat", "verb", "flashcard"]) {
            return steps([
                "Go through vocabulary list once",
                "Cover definitions and test yourself",
                "Write each new word in a sentence",
                "Final self-quiz — flag anything still unsure",
            ], minutes: sessionMinutes)
        }

        // Test / exam prep
        if containsAny(lower, ["test", "exam", "quiz", "final", "midterm", "ap ", "sat", "act"]) {
            return steps([
                "List all topics that will be on the test",
                "Focus on the topic you're least confident in",
                "Work through practice problems on that topic",
                "Do a timed mixed practice run",
            ], minutes: sessionMinutes)
        }

        // Generic — keep it topic-specific by including the task name
        let shortTask = task.count > 30 ? String(task.prefix(30)) : task
        return steps([
            "Review your notes on \(shortTask)",
            "Identify the 3 most important concepts",
            "Test yourself without looking at notes",
            "Write a summary of what you know",
        ], minutes: sessionMinutes)
    }

    // MARK: - Helpers

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private func steps(_ titles: [String], minutes: Int) -> [SubTask] {
        titles.map { SubTask(title: $0, durationMinutes: minutes) }
    }
}
