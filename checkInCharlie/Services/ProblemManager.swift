//
//  ProblemManager.swift
//  checkInCharlie
//
//  Created by Robert Lester on 11/13/24.
//

import Foundation

class ProblemManager: ObservableObject {
    static let shared = ProblemManager()

    @Published var hasPendingProblem: Bool = false
    var pendingProblem: Problem?

    struct Problem {
        let question: String
        let answer: Int
    }

    private init() {}
}
