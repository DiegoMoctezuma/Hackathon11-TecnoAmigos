// GlassModifiers.swift
// EchoStudy
// Liquid Glass modifiers using iOS 26+ native .glassEffect() API

import SwiftUI

// MARK: - Liquid Glass View Modifier

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - Liquid Glass Bar Modifier

struct LiquidGlassBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .glassEffect(in: .rect(cornerRadius: 16))
    }
}

// MARK: - Liquid Glass Floating Modifier (FABs)

struct LiquidGlassFloatingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .glassEffect(in: .capsule)
            .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
    
    func liquidGlassBar() -> some View {
        modifier(LiquidGlassBarModifier())
    }
    
    func liquidGlassFloating() -> some View {
        modifier(LiquidGlassFloatingModifier())
    }
}
