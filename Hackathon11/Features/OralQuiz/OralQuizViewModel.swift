// OralQuizViewModel.swift
// EchoStudy

import Foundation
import SwiftUI
import SwiftData

// MARK: - Quiz Difficulty

enum QuizDifficulty: String, CaseIterable, Identifiable {
    case basic = "Básico"
    case intermediate = "Intermedio"
    case advanced = "Avanzado"
    
    var id: String { rawValue }
    
    var accessibilityLabel: String {
        switch self {
        case .basic: return "Básico. Preguntas sencillas de comprensión."
        case .intermediate: return "Intermedio. Preguntas que requieren análisis."
        case .advanced: return "Avanzado. Preguntas de aplicación y síntesis."
        }
    }
}

// MARK: - Quiz Setup Step

enum QuizSetupStep: Int, CaseIterable {
    case selectSubject = 0
    case selectTopics = 1
    case questionCount = 2
    case difficulty = 3
    
    var title: String {
        switch self {
        case .selectSubject: return "Selecciona una materia"
        case .selectTopics: return "Selecciona los temas"
        case .questionCount: return "Número de preguntas"
        case .difficulty: return "Nivel de dificultad"
        }
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class OralQuizViewModel {
    // Setup
    var currentStep: QuizSetupStep = .selectSubject
    var selectedSubject: Subject?
    var selectedTopics: Set<Topic> = []
    var allTopicsSelected: Bool = true
    var questionCount: Int = 10
    var difficulty: QuizDifficulty = .intermediate
    
    // Session
    var currentQuestionIndex: Int = 0
    var questions: [QuizQuestion] = []
    var isQuizActive: Bool = false
    var showResults: Bool = false
    var currentSession: QuizSession?
    var userAnswer: String = ""
    var showFeedback: Bool = false
    var currentFeedbackCorrect: Bool = false
    
    // Timer
    var timerEnabled: Bool = false
    var timerSeconds: Int = 60
    var timerRemaining: Int = 60
    var timerTask: Task<Void, Never>?
    
    // Computed
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .selectSubject: return selectedSubject != nil
        case .selectTopics: return !selectedTopics.isEmpty
        case .questionCount: return true
        case .difficulty: return true
        }
    }
    
    var isLastSetupStep: Bool {
        currentStep == .difficulty
    }
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var topicsToReinforce: [Topic] {
        let incorrectQuestions = questions.filter { $0.isCorrect == false }
        var topicSet = Set<Topic>()
        for question in incorrectQuestions {
            if let session = currentSession {
                for topic in session.topics where !topicSet.contains(topic) {
                    topicSet.insert(topic)
                }
            }
        }
        return Array(topicSet)
    }
    
    var masteredTopics: [Topic] {
        guard let session = currentSession else { return [] }
        let reinforceSet = Set(topicsToReinforce.map(\.id))
        return session.topics.filter { !reinforceSet.contains($0.id) }
    }
    
    // MARK: - Setup Navigation
    
    func selectSubject(_ subject: Subject) {
        selectedSubject = subject
        selectedTopics = Set(subject.topics)
        allTopicsSelected = true
    }
    
    func toggleTopic(_ topic: Topic) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
        allTopicsSelected = selectedTopics.count == (selectedSubject?.topics.count ?? 0)
    }
    
    func toggleAllTopics() {
        guard let subject = selectedSubject else { return }
        if allTopicsSelected {
            selectedTopics.removeAll()
            allTopicsSelected = false
        } else {
            selectedTopics = Set(subject.topics)
            allTopicsSelected = true
        }
    }
    
    func nextStep() {
        guard let nextRaw = QuizSetupStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextRaw
    }
    
    func previousStep() {
        guard let prevRaw = QuizSetupStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prevRaw
    }
    
    // MARK: - Quiz Session
    
    func startQuiz() async {
        guard !selectedTopics.isEmpty else { return }
        
        let topicsArray = Array(selectedTopics)
        
        // Generate all questions at once instead of per-topic to avoid stacked delays
        let allQuestions = await QuizGenerationService.shared.generateQuestions(
            from: topicsArray.first!,
            count: questionCount
        )
        
        questions = Array(allQuestions.shuffled().prefix(questionCount))
        currentQuestionIndex = 0
        isQuizActive = true
        showResults = false
        showFeedback = false
        
        if timerEnabled {
            startTimer()
        }
    }
    
    func submitAnswer(_ answer: String) {
        guard currentQuestionIndex < questions.count else { return }
        stopTimer()
        
        let question = questions[currentQuestionIndex]
        question.userAnswer = answer
        
        let normalizedAnswer = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedCorrect = question.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let isCorrect = normalizedAnswer.contains(normalizedCorrect) ||
                         normalizedCorrect.contains(normalizedAnswer)
        question.isCorrect = isCorrect
        currentFeedbackCorrect = isCorrect
        showFeedback = true
        userAnswer = ""
    }
    
    func skipQuestion() {
        guard currentQuestionIndex < questions.count else { return }
        stopTimer()
        let question = questions[currentQuestionIndex]
        question.userAnswer = nil
        question.isCorrect = false
        nextQuestion()
    }
    
    func nextQuestion() {
        showFeedback = false
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questions.count {
            finishQuiz()
        } else if timerEnabled {
            startTimer()
        }
    }
    
    func finishQuiz() {
        stopTimer()
        let correctCount = questions.filter { $0.isCorrect == true }.count
        let session = QuizSession(
            subject: selectedSubject,
            topics: Array(selectedTopics),
            questions: questions,
            score: correctCount,
            totalQuestions: questions.count,
            completedAt: Date()
        )
        currentSession = session
        isQuizActive = false
        showResults = true
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timerRemaining = timerSeconds
        timerTask?.cancel()
        timerTask = Task {
            while timerRemaining > 0, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                timerRemaining -= 1
            }
            if timerRemaining <= 0, !Task.isCancelled {
                skipQuestion()
            }
        }
    }
    
    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    // MARK: - Reset
    
    func resetForNewQuiz() {
        currentStep = .selectSubject
        selectedSubject = nil
        selectedTopics = []
        allTopicsSelected = true
        questionCount = 10
        difficulty = .intermediate
        currentQuestionIndex = 0
        questions = []
        isQuizActive = false
        showResults = false
        currentSession = nil
        userAnswer = ""
        showFeedback = false
        currentFeedbackCorrect = false
        stopTimer()
    }
    
    func resetForRepeatQuiz() {
        currentQuestionIndex = 0
        questions = []
        isQuizActive = false
        showResults = false
        currentSession = nil
        userAnswer = ""
        showFeedback = false
        currentFeedbackCorrect = false
        stopTimer()
    }
}
