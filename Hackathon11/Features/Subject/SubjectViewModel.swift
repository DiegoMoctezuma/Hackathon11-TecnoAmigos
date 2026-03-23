// SubjectViewModel.swift
// EchoStudy

import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class SubjectViewModel {
    var searchText: String = ""
    var showNewTopicSheet: Bool = false
    var selectedSortOption: SortOption = .dateNewest
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Más reciente"
        case dateOldest = "Más antiguo"
        case alphabetical = "Alfabético"
        case confidence = "Confianza"
    }
    
    func sortedTopics(_ topics: [Topic]) -> [Topic] {
        let filtered = searchText.isEmpty ? topics : topics.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.shortSummary.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedSortOption {
        case .dateNewest: return filtered.sorted { $0.createdAt > $1.createdAt }
        case .dateOldest: return filtered.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical: return filtered.sorted { $0.title < $1.title }
        case .confidence: return filtered.sorted { $0.confidence > $1.confidence }
        }
    }
    
    func deleteTopic(_ topic: Topic, from subject: Subject, context: ModelContext) {
        HapticService.shared.warning()
        subject.topics.removeAll { $0.id == topic.id }
        context.delete(topic)
    }
}
