// FloatingVoiceButton.swift
// EchoStudy
// A11Y: Persistent FAB for voice assistant access

import SwiftUI

struct FloatingVoiceButton: View {
    @State private var showAssistant = false
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(AppRouter.self) private var router
    
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
                        .frame(width: 76, height: 76)
                        .background(ColorTheme.accentHex)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                }
                
                .padding(.bottom, 60)
                // A11Y: Full description
                .accessibilityLabel("Asistente de voz")
                .accessibilityHint("Toca dos veces para hablar con ARGOS")
                .accessibilityAddTraits(.isButton)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showAssistant) {
            VoiceAssistantView()
                .environment(voiceEngine)
                .environment(router)
        }
    }
}
