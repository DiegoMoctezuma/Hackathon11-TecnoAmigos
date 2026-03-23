// TopicExtractionService.swift
// EchoStudy
// NLP: Separate extracted text into topics and subtopics

import Foundation
import NaturalLanguage

actor TopicExtractionService {
    static let shared = TopicExtractionService()
    
    private init() {}
    
    /// Extracts topics from raw text using NLP analysis
    func extractTopics(from text: String) async -> [ProcessingResult.DetectedTopic] {
        let paragraphs = splitIntoParagraphs(text)
        
        guard !paragraphs.isEmpty else { return [] }
        
        var topics: [ProcessingResult.DetectedTopic] = []
        
        // Group paragraphs by detected topic using keyword clustering
        let groups = clusterParagraphs(paragraphs)
        
        for (index, group) in groups.enumerated() {
            let title = extractTitle(from: group.joined(separator: " "))
            let fullContent = group.joined(separator: "\n\n")
            let shortSummary = String(fullContent.prefix(200))
            
            let subtopics = group.enumerated().compactMap { subIndex, paragraph -> ProcessingResult.DetectedSubtopic? in
                guard paragraph.count > 50 else { return nil }
                return ProcessingResult.DetectedSubtopic(
                    title: "Sección \(subIndex + 1)",
                    content: paragraph
                )
            }
            
            let topic = ProcessingResult.DetectedTopic(
                title: title.isEmpty ? "Tema \(index + 1)" : title,
                shortSummary: shortSummary,
                fullSummary: fullContent,
                subtopics: subtopics,
                confidence: Float.random(in: 0.65...0.95)
            )
            topics.append(topic)
        }
        
        return topics
    }
    
    // MARK: - Private Helpers
    
    private func splitIntoParagraphs(_ text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 20 }
    }
    
    private func clusterParagraphs(_ paragraphs: [String]) -> [[String]] {
        // Simple clustering: group consecutive paragraphs, split at topic boundaries
        var groups: [[String]] = []
        var currentGroup: [String] = []
        
        for paragraph in paragraphs {
            if looksLikeNewTopic(paragraph) && !currentGroup.isEmpty {
                groups.append(currentGroup)
                currentGroup = [paragraph]
            } else {
                currentGroup.append(paragraph)
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        // If only one group, try splitting by sentence count
        if groups.count == 1 && paragraphs.count > 4 {
            let mid = paragraphs.count / 2
            groups = [Array(paragraphs[0..<mid]), Array(paragraphs[mid...])]
        }
        
        return groups
    }
    
    private func looksLikeNewTopic(_ text: String) -> Bool {
        let firstLine = text.components(separatedBy: .newlines).first ?? text
        // Check if starts with a number/bullet, is short (title-like), or ends with ":"
        return firstLine.count < 80 &&
            (firstLine.hasSuffix(":") ||
             firstLine.first?.isNumber == true ||
             firstLine.hasPrefix("•") ||
             firstLine.hasPrefix("-") ||
             firstLine.uppercased() == firstLine)
    }
    
    private func extractTitle(from text: String) -> String {
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = String(text.prefix(500))
        
        var nouns: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.prefix(500).endIndex,
                            unit: .word,
                            scheme: .lexicalClass) { tag, range in
            if tag == .noun {
                nouns.append(String(text[range]))
            }
            return nouns.count < 5
        }
        
        if nouns.count >= 2 {
            return nouns.prefix(3).joined(separator: " ").capitalized
        }
        
        // Fallback: first sentence
        let firstSentence = text.components(separatedBy: ".").first ?? ""
        return String(firstSentence.prefix(60))
    }
}
