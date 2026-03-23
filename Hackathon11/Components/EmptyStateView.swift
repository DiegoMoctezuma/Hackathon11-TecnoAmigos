// EmptyStateView.swift
// EchoStudy
// A11Y: Accessible empty state with icon, text, and CTA

import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        iconName: String = "tray",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 56))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ColorTheme.secondaryHex)
                .accessibilityHidden(true) // A11Y: Decorative
            
            Text(title)
                .font(FontTheme.title2)
                .foregroundStyle(ColorTheme.adaptiveText)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(message)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityHint("Toca para \(actionTitle.lowercased())")
            }
        }
        .padding(32)
        .announceOnAppear("\(title). \(message)")
    }
}
