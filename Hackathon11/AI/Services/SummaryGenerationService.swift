// SummaryGenerationService.swift
// EchoStudy
// Generates summaries of different lengths from topics

import Foundation

actor SummaryGenerationService {
    static let shared = SummaryGenerationService()
    
    private init() {}
    
    enum SummaryLength {
        case short    // 1-2 sentences
        case medium   // 1 paragraph
        case full     // Complete summary
    }
    
    /// Generates a summary from text content
    /// Uses local NLP for basic summarization, can be extended with LLM
    func generateSummary(from text: String, length: SummaryLength = .medium) async -> String {
        let sentences = splitIntoSentences(text)
        
        guard !sentences.isEmpty else { return text }
        
        switch length {
        case .short:
            return sentences.prefix(2).joined(separator: " ")
        case .medium:
            let count = min(sentences.count, max(3, sentences.count / 3))
            return sentences.prefix(count).joined(separator: " ")
        case .full:
            return text
        }
    }
    
    /// Generates an alternative explanation (simpler language)
    func simplify(_ text: String) async -> String {
        // Placeholder: in production, this would use an LLM
        let sentences = splitIntoSentences(text)
        return sentences.map { sentence in
            // Simple heuristic: shorter sentences are simpler
            if sentence.count > 100 {
                let midpoint = sentence.index(sentence.startIndex, offsetBy: sentence.count / 2)
                if let breakPoint = sentence[midpoint...].firstIndex(of: ",") {
                    return String(sentence[...breakPoint]) + "."
                }
            }
            return sentence
        }.joined(separator: " ")
    }
    
    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences.isEmpty ? [text] : sentences
    }
}
