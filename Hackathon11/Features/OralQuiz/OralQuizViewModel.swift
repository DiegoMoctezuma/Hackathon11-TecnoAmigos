// OralQuizViewModel.swift
// EchoStudy

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class OralQuizViewModel {
    var selectedSubject: Subject?
    var selectedTopics: [Topic] = []
    var questionCount: Int = 5
    var currentQuestionIndex: Int = 0
    var questions: [QuizQuestion] = []
    var isQuizActive: Bool = false
    var showResults: Bool = false
    var currentSession: QuizSession?
    var userAnswer: String = ""
    var showFeedback: Bool = false
    var currentFeedbackCorrect: Bool = false
    
    func startQuiz() async {
        guard !selectedTopics.isEmpty else { return }
        
        var allQuestions: [QuizQuestion] = []
        for topic in selectedTopics {
            let topicQuestions = await QuizGenerationService.shared.generateQuestions(
                from: topic,
                count: max(1, questionCount / selectedTopics.count)
            )
            allQuestions.append(contentsOf: topicQuestions)
        }
        
        questions = Array(allQuestions.prefix(questionCount))
        currentQuestionIndex = 0
        isQuizActive = true
        showResults = false
        showFeedback = false
    }
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    func submitAnswer(_ answer: String) {
        guard currentQuestionIndex < questions.count else { return }
        let question = questions[currentQuestionIndex]
        question.userAnswer = answer
        
        // Simple matching
        let isCorrect = answer.lowercased().contains(question.correctAnswer.lowercased()) ||
                         question.correctAnswer.lowercased().contains(answer.lowercased())
        question.isCorrect = isCorrect
        currentFeedbackCorrect = isCorrect
        showFeedback = true
        userAnswer = ""
    }
    
    func nextQuestion() {
        showFeedback = false
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questions.count {
            finishQuiz()
        }
    }
    
    private func finishQuiz() {
        let correctCount = questions.filter { $0.isCorrect == true }.count
        let session = QuizSession(
            subject: selectedSubject,
            topics: selectedTopics,
            questions: questions,
            score: correctCount,
            totalQuestions: questions.count,
            completedAt: Date()
        )
        currentSession = session
        isQuizActive = false
        showResults = true
    }
}
