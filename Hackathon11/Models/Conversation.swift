// Conversation.swift
// EchoStudy
// @Model: Conversation with AI assistant

import Foundation
import SwiftData

@Model
class Conversation {
    var id: UUID
    var title: String
    @Relationship(deleteRule: .cascade) var messages: [ChatMessage]
    var subject: Subject?
    var topic: Topic?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "Nueva conversación",
        messages: [ChatMessage] = [],
        subject: Subject? = nil,
        topic: Topic? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.subject = subject
        self.topic = topic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
