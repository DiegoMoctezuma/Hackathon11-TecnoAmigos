// ChatMessage.swift
// EchoStudy
// @Model: Individual message in a conversation

import Foundation
import SwiftData

enum MessageRole: String, Codable {
    case user
    case assistant
}

@Model
class ChatMessage {
    var id: UUID
    var role: MessageRole
    var content: String
    var timestamp: Date
    var wasSpoken: Bool
    var conversation: Conversation?
    
    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        wasSpoken: Bool = false,
        conversation: Conversation? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.wasSpoken = wasSpoken
        self.conversation = conversation
    }
}
