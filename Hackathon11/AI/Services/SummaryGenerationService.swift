// SummaryGenerationService.swift
// EchoStudy
// Generates summaries via MockLLMProvider (mock) or LLM (future)

import Foundation

// MARK: - Summary Types

enum SummaryLength: String, CaseIterable {
    case short = "Corto"
    case medium = "Medio"
    case long = "Largo"
    case alternative = "Alternativo"
}

enum SummaryStyle {
    case standard
    case simplified
    case analogy
}

// MARK: - Service

actor SummaryGenerationService {
    static let shared = SummaryGenerationService()
    
    private init() {}
    
    /// Generates a summary with mock delay and pre-written content
    func generateSummary(for text: String, length: SummaryLength = .medium) async throws -> String {
        // Realistic delay
        try await Task.sleep(for: .seconds(3))
        
        return await MockLLMProvider.shared.generateSummary(
            topicTitle: extractFirstLine(from: text),
            length: length,
            style: .standard
        )
    }
    
    /// Generates an alternative explanation with analogies
    func generateAlternativeExplanation(for topicTitle: String) async throws -> String {
        try await Task.sleep(for: .seconds(2.5))
        
        return await MockLLMProvider.shared.generateSummary(
            topicTitle: topicTitle,
            length: .alternative,
            style: .analogy
        )
    }
    
    /// Simplifies text for easier understanding
    func simplify(_ text: String) async -> String {
        try? await Task.sleep(for: .seconds(2))
        
        let sentences = splitIntoSentences(text)
        return sentences.map { sentence in
            if sentence.count > 100 {
                let midpoint = sentence.index(sentence.startIndex, offsetBy: sentence.count / 2)
                if let breakPoint = sentence[midpoint...].firstIndex(of: ",") {
                    return String(sentence[...breakPoint]) + "."
                }
            }
            return sentence
        }.joined(separator: " ")
    }
    
    /// Generates a summary without delay (for non-mock local NLP fallback)
    func generateLocalSummary(from text: String, length: SummaryLength = .medium) -> String {
        let sentences = splitIntoSentences(text)
        guard !sentences.isEmpty else { return text }
        
        switch length {
        case .short:
            return sentences.prefix(2).joined(separator: " ")
        case .medium:
            let count = min(sentences.count, max(3, sentences.count / 3))
            return sentences.prefix(count).joined(separator: " ")
        case .long:
            return text
        case .alternative:
            return sentences.reversed().prefix(3).joined(separator: " ")
        }
    }
    
    // MARK: - Private
    
    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences.isEmpty ? [text] : sentences
    }
    
    private func extractFirstLine(from text: String) -> String {
        text.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespaces) ?? text
    }
}
