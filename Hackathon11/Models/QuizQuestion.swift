// QuizQuestion.swift
// EchoStudy
// @Model: Individual quiz question

import Foundation
import SwiftData

@Model
class QuizQuestion {
    var id: UUID
    var questionText: String
    var correctAnswer: String
    var userAnswer: String?
    var isCorrect: Bool?
    var explanation: String
    var session: QuizSession?
    
    init(
        id: UUID = UUID(),
        questionText: String,
        correctAnswer: String,
        userAnswer: String? = nil,
        isCorrect: Bool? = nil,
        explanation: String = "",
        session: QuizSession? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.explanation = explanation
        self.session = session
    }
}
