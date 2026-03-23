// HomeViewModel.swift
// EchoStudy

import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class HomeViewModel {
    var searchText: String = ""
    var showNewSubjectSheet: Bool = false
    var showRenameAlert: Bool = false
    var subjectToRename: Subject?
    
    func filteredSubjects(_ subjects: [Subject]) -> [Subject] {
        if searchText.isEmpty { return subjects }
        return subjects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func buildRecentActivity(subjects: [Subject], quizSessions: [QuizSession]) -> [ActivityItem] {
        var items: [ActivityItem] = []
        
        // Recent topics from materials
        for subject in subjects {
            for topic in subject.topics.prefix(3) {
                items.append(ActivityItem(
                    icon: "doc.text.fill",
                    title: topic.title,
                    subtitle: subject.name,
                    date: topic.createdAt,
                    type: .materialProcessed
                ))
            }
        }
        
        // Recent quiz sessions
        for session in quizSessions.prefix(3) {
            items.append(ActivityItem(
                icon: "questionmark.bubble.fill",
                title: "Quiz: \(session.score)/\(session.totalQuestions)",
                subtitle: session.subject?.name ?? "General",
                date: session.completedAt,
                type: .quizCompleted
            ))
        }
        
        // Sort by date descending
        return items.sorted { $0.date > $1.date }
    }
    
    func deleteSubject(_ subject: Subject, context: ModelContext) {
        HapticService.shared.warning()
        context.delete(subject)
    }
}
