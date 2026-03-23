// FloatingVoiceButton.swift
// EchoStudy
// A11Y: Persistent FAB for voice assistant access

import SwiftUI

struct FloatingVoiceButton: View {
    @State private var showAssistant = false
    @Environment(VoiceEngine.self) private var voiceEngine
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    HapticService.shared.medium()
                    showAssistant = true
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(ColorTheme.accentHex)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                // A11Y: Full description
                .accessibilityLabel("Asistente de voz")
                .accessibilityHint("Toca dos veces para hablar con EchoStudy")
                .accessibilityAddTraits(.isButton)
            }
        }
        .sheet(isPresented: $showAssistant) {
            VoiceAssistantView()
                .environment(voiceEngine)
        }
    }
}
