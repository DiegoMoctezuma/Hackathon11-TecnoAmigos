// SubjectCardView.swift
// EchoStudy
// A11Y: Glass card with icon, name, topic count, last access.
// Long press → context menu: Rename, Change icon, Delete.

import SwiftUI

struct SubjectCardView: View {
    let subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon + topic count badge
            HStack {
                SubjectIcon(iconName: subject.iconName, colorHex: subject.colorHex, size: 44)
                
                Spacer()
                
                Text("\(subject.topics.count)")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .glassEffect(in: .capsule)
                    .accessibilityHidden(true)
            }
            
            // Name
            Text(subject.name)
                .font(FontTheme.headline)
                .foregroundStyle(ColorTheme.adaptiveText)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            // Metadata
            Text("\(subject.topics.count) temas")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            
            Text(subject.lastAccessedAt.accessibleRelativeString)
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: .rect(cornerRadius: 20))
        // A11Y: Combined accessible label
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(subject.name). \(subject.topics.count) temas. Último acceso: \(subject.lastAccessedAt.accessibleRelativeString)")
        .accessibilityHint("Toca para ver los temas de esta materia. Mantén presionado para más opciones.")
        .accessibilityAddTraits(.isButton)
    }
}
