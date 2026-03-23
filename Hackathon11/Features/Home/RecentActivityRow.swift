// RecentActivityRow.swift
// EchoStudy
// A11Y: Recent activity item showing processed materials or quizzes

import SwiftUI

// MARK: - Activity Item Model

struct ActivityItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let date: Date
    let type: ActivityType
    
    enum ActivityType {
        case materialProcessed
        case quizCompleted
        case conversationCreated
    }
}

// MARK: - Recent Activity Row

struct RecentActivityRow: View {
    let item: ActivityItem
    
    private var iconColor: Color {
        switch item.type {
        case .materialProcessed: return ColorTheme.secondaryHex
        case .quizCompleted: return ColorTheme.successHex
        case .conversationCreated: return ColorTheme.accentHex
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .glassEffect(in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .lineLimit(1)
                
                Text(item.subtitle)
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Date
            Text(item.date.accessibleRelativeString)
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .padding(.vertical, 4)
        // A11Y: Combine into single element
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.subtitle). \(item.date.accessibleRelativeString)")
    }
}
