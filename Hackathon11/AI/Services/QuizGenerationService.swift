// QuizGenerationService.swift
// EchoStudy
// Generates quiz questions from topics

import Foundation

actor QuizGenerationService {
    static let shared = QuizGenerationService()
    
    private init() {}
    
    /// Generates quiz questions from a topic's content
    func generateQuestions(from topic: Topic, count: Int = 5) async -> [QuizQuestion] {
        let sentences = splitIntoSentences(topic.fullSummary)
        
        guard !sentences.isEmpty else { return [] }
        
        var questions: [QuizQuestion] = []
        let maxQuestions = min(count, sentences.count)
        
        for i in 0..<maxQuestions {
            let sentence = sentences[i]
            let question = createQuestion(from: sentence, topicTitle: topic.title, index: i)
            questions.append(question)
        }
        
        return questions
    }
    
    private func createQuestion(from sentence: String, topicTitle: String, index: Int) -> QuizQuestion {
        // Generate fill-in-the-blank style questions
        let words = sentence.components(separatedBy: " ")
        let significantWords = words.filter { $0.count > 4 }
        
        if let keyword = significantWords.randomElement() {
            let questionText = "En el tema de \(topicTitle): \(sentence.replacingOccurrences(of: keyword, with: "________"))"
            return QuizQuestion(
                questionText: questionText,
                correctAnswer: keyword,
                explanation: "La respuesta correcta es '\(keyword)'. \(sentence)"
            )
        }
        
        // Fallback: comprehension question
        return QuizQuestion(
            questionText: "¿Puedes explicar el siguiente concepto de \(topicTitle)? \(sentence)",
            correctAnswer: sentence,
            explanation: sentence
        )
    }
    
    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines),
               !sentence.isEmpty, sentence.count > 30 {
                sentences.append(sentence)
            }
        }
        return sentences
    }
}
