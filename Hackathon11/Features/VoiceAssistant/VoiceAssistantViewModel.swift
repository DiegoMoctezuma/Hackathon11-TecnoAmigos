// VoiceAssistantViewModel.swift
// EchoStudy

import Foundation
import SwiftUI

@Observable
@MainActor
final class VoiceAssistantViewModel {
    var messages: [AssistantMessage] = []
    var isProcessing: Bool = false
    var currentContext: String = "General"
    
    struct AssistantMessage: Identifiable {
        let id = UUID()
        let role: MessageRole
        let content: String
        let timestamp: Date
        let wasSpoken: Bool
        let isGenerated: Bool
        
        init(role: MessageRole, content: String, timestamp: Date = Date(), wasSpoken: Bool = false, isGenerated: Bool = false) {
            self.role = role
            self.content = content
            self.timestamp = timestamp
            self.wasSpoken = wasSpoken
            self.isGenerated = isGenerated
        }
    }
    
    func sendMessage(_ text: String, wasSpoken: Bool = false) async {
        let userMessage = AssistantMessage(
            role: .user,
            content: text,
            wasSpoken: wasSpoken
        )
        messages.append(userMessage)
        isProcessing = true
        
        let response = await MockLLMProvider.shared.generate(prompt: text)
        
        // Detect if this is "generated content" (summaries, relations, maps)
        let isGenerated = detectGeneratedContent(in: text)
        
        let assistantMessage = AssistantMessage(
            role: .assistant,
            content: response,
            isGenerated: isGenerated
        )
        messages.append(assistantMessage)
        isProcessing = false
    }
    
    private func detectGeneratedContent(in text: String) -> Bool {
        let generatedKeywords = ["resumen", "mapa conceptual", "relación", "genera", "crea"]
        let lowered = text.lowercased()
        return generatedKeywords.contains { lowered.contains($0) }
    }
}
