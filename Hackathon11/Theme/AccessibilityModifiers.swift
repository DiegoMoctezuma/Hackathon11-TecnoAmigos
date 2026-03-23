// AccessibilityModifiers.swift
// EchoStudy
// A11Y: Custom modifiers ensuring consistent accessibility across the app

import SwiftUI

// MARK: - Accessible Tap Target Modifier

struct AccessibleTapTargetModifier: ViewModifier {
    let minSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}

// MARK: - Announce on Appear Modifier

struct AnnounceOnAppearModifier: ViewModifier {
    let message: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // A11Y: Post announcement for VoiceOver users
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AccessibilityNotification.Announcement(message).post()
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// A11Y: Ensures minimum 48x48pt touch target
    func accessibleTapTarget(minSize: CGFloat = 48) -> some View {
        modifier(AccessibleTapTargetModifier(minSize: minSize))
    }
    
    /// A11Y: Announces a message via VoiceOver when the view appears
    func announceOnAppear(_ message: String) -> some View {
        modifier(AnnounceOnAppearModifier(message: message))
    }
    
    /// A11Y: Makes an element a large, accessible button target
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .accessibleTapTarget()
    }
    
    /// A11Y: Makes an element an accessible header
    func accessibleHeader(_ label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
}
