// TopicViewModel.swift
// EchoStudy

import Foundation
import SwiftUI

@Observable
@MainActor
final class TopicViewModel {
    var isReadingAloud: Bool = false
    var showAlternateExplanation: Bool = false
    var alternateExplanation: String = ""
    var isShowingShortSummary: Bool = false
    var displaySummary: String?
    var showRelatedTopics: Bool = false
    var relationExplanation: String = ""
    
    func requestAlternateExplanation(for topic: Topic) async {
        let response = await MockLLMProvider.shared.generate(
            prompt: "Explica de manera diferente: \(topic.fullSummary)"
        )
        alternateExplanation = response
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showAlternateExplanation = true
        }
    }
    
    func toggleSummaryLength(for topic: Topic) {
        HapticService.shared.light()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isShowingShortSummary.toggle()
            displaySummary = isShowingShortSummary ? topic.shortSummary : nil
        }
    }
    
    func requestRelation(between topicA: Topic, and topicB: Topic) async {
        let response = await MockLLMProvider.shared.generate(
            prompt: "Relaciona: \(topicA.title) con \(topicB.title)"
        )
        relationExplanation = response
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showRelatedTopics = true
        }
    }
}
