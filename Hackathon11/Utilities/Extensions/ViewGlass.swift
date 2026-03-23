// ViewGlass.swift
// EchoStudy
// Glass effect shortcut extensions

import SwiftUI

extension View {
    /// Shorthand for glass card styling with padding
    func glassCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
    }
}
