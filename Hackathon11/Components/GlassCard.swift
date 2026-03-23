// GlassCard.swift
// EchoStudy
// A11Y: Reusable glass card with accessibility grouping

import SwiftUI

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let accessibilityLabel: String
    @ViewBuilder let content: () -> Content
    
    init(
        cornerRadius: CGFloat = 20,
        accessibilityLabel: String = "",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
    }
}
