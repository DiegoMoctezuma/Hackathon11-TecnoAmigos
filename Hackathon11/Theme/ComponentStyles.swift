// ComponentStyles.swift
// EchoStudy
// A11Y: All button/text field styles include accessibility traits and large targets

import SwiftUI

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontTheme.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minHeight: 48)
            .background(ColorTheme.accentHex.opacity(isEnabled ? 1.0 : 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontTheme.headline)
            .foregroundStyle(ColorTheme.accentHex)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minHeight: 48)
            .glassEffect(in: .rect(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Glass Text Field Style

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(FontTheme.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .glassEffect(in: .rect(cornerRadius: 12))
    }
}

// MARK: - Icon Button Style

struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    
    init(size: CGFloat = 48) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .glassEffect(in: .circle)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}
