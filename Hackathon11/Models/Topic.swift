// Topic.swift
// EchoStudy
// @Model: Topic within a subject (e.g., "Mitosis")

import Foundation
import SwiftData

@Model
class Topic {
    var id: UUID
    var title: String
    var shortSummary: String
    var fullSummary: String
    @Relationship(deleteRule: .cascade) var subtopics: [Subtopic]
    @Relationship(deleteRule: .nullify) var sourceMaterials: [StudyMaterial]
    var confidence: Float
    var isUserVerified: Bool
    var subject: Subject?
    var createdAt: Date
    var orderIndex: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        shortSummary: String = "",
        fullSummary: String = "",
        subtopics: [Subtopic] = [],
        sourceMaterials: [StudyMaterial] = [],
        confidence: Float = 0.0,
        isUserVerified: Bool = false,
        subject: Subject? = nil,
        createdAt: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.shortSummary = shortSummary
        self.fullSummary = fullSummary
        self.subtopics = subtopics
        self.sourceMaterials = sourceMaterials
        self.confidence = confidence
        self.isUserVerified = isUserVerified
        self.subject = subject
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }
}
