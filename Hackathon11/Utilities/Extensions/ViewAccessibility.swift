// ViewAccessibility.swift
// EchoStudy
// A11Y: View extensions for VoiceOver announcements and accessible targets

import SwiftUI

extension View {
    /// A11Y: Announces text to VoiceOver
    func announceToVoiceOver(_ message: String) {
        AccessibilityNotification.Announcement(message).post()
    }
    
    /// A11Y: Ensures large touch target
    func largeTarget(size: CGFloat = 48) -> some View {
        self.frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}
