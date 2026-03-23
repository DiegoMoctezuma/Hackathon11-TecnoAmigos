// LoadingStateView.swift
// EchoStudy
// A11Y: Loading state with descriptive text (not just spinner)

import SwiftUI

struct LoadingStateView: View {
    let message: String
    
    init(message: String = "Cargando...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(ColorTheme.accentHex)
                .accessibilityHidden(true) // A11Y: Text describes the state
            
            Text(message)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .announceOnAppear(message)
    }
}
