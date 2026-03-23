// QuizSession.swift
// EchoStudy
// @Model: Oral quiz session with questions and results

import Foundation
import SwiftData

@Model
class QuizSession {
    var id: UUID
    var subject: Subject?
    @Relationship(deleteRule: .nullify) var topics: [Topic]
    @Relationship(deleteRule: .cascade) var questions: [QuizQuestion]
    var score: Int
    var totalQuestions: Int
    var completedAt: Date
    
    init(
        id: UUID = UUID(),
        subject: Subject? = nil,
        topics: [Topic] = [],
        questions: [QuizQuestion] = [],
        score: Int = 0,
        totalQuestions: Int = 0,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.subject = subject
        self.topics = topics
        self.questions = questions
        self.score = score
        self.totalQuestions = totalQuestions
        self.completedAt = completedAt
    }
}
