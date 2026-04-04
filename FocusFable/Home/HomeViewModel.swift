//
//  HomeViewModel.swift
//  FocusFable
//
//  Created by Riya  on 3/30/26.
//

import Foundation
import SwiftUI

// All possible states the breakdown UI can be in
enum BreakdownState {
    case idle
    case loading
    case loaded([SubTask])
    case unsupported          // device doesn't support Foundation Models
    case error(String)
}

@Observable
class HomeViewModel {

    var taskInput: String      = ""
    var breakdownState: BreakdownState = .idle

    private let service = TaskBreakdownService()

    var canBreakdown: Bool {
        taskInput.trimmingCharacters(in: .whitespaces).count > 3
    }

    var isLoading: Bool {
        if case .loading = breakdownState { return true }
        return false
    }

    func breakdownTask(sessionMinutes: Int) async {
        guard canBreakdown else { return }
        breakdownState = .loading

        do {
            let tasks = try await service.breakdown(
                task: taskInput,
                sessionMinutes: sessionMinutes
            )
            breakdownState = tasks.isEmpty
                ? .error("Couldn't generate steps. Try describing your task differently.")
                : .loaded(tasks)
        } catch {
            // Surface a readable message, not a raw Swift error
            breakdownState = .error(readableError(error))
        }
    }

    func reset() {
        taskInput      = ""
        breakdownState = .idle
    }

    private func readableError(_ error: Error) -> String {
        // Foundation Models throws specific error types you can check here
        // For now, a friendly generic message covers most cases
        return "Something went wrong. Make sure your device supports Apple Intelligence."
    }
}
