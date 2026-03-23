// Subject.swift
// EchoStudy
// @Model: Academic subject (e.g., "Biología Celular")

import Foundation
import SwiftData

@Model
class Subject {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    @Relationship(deleteRule: .cascade) var topics: [Topic]
    @Relationship(deleteRule: .cascade) var conversations: [Conversation]
    var createdAt: Date
    var lastAccessedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "book.fill",
        colorHex: String = "#1B4965",
        topics: [Topic] = [],
        conversations: [Conversation] = [],
        createdAt: Date = Date(),
        lastAccessedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.topics = topics
        self.conversations = conversations
        self.createdAt = createdAt
        self.lastAccessedAt = lastAccessedAt
    }
}
