//
//  HomeViewModel.swift
//  FocusFable
//

import SwiftUI

enum BreakdownState {
    case idle
    case loading
    case loaded([SubTask])
    case unsupported  // kept for compatibility but no longer shown
    case error(String)
}

@Observable
class HomeViewModel {

    var taskInput: String              = ""
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
            // Service always returns tasks now — never empty
            breakdownState = .loaded(tasks)
        } catch {
            // Shouldn't reach here but just in case
            breakdownState = .error("Try again.")
        }
    }

    func reset() {
        taskInput      = ""
        breakdownState = .idle
    }
}
