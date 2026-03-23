// ProcessingResult.swift
// EchoStudy
// Result of AI processing pipeline

import Foundation

struct ProcessingResult {
    var extractedText: String
    var visualDescription: String?
    var detectedTopics: [DetectedTopic]
    var overallConfidence: Float
    
    struct DetectedTopic: Identifiable {
        let id = UUID()
        var title: String
        var shortSummary: String
        var fullSummary: String
        var subtopics: [DetectedSubtopic]
        var confidence: Float
    }
    
    struct DetectedSubtopic: Identifiable {
        let id = UUID()
        var title: String
        var content: String
    }
}
