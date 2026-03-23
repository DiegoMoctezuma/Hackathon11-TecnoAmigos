// VoiceButton.swift
// EchoStudy
// A11Y: Large microphone button with animated states

import SwiftUI

struct VoiceButton: View {
    let state: VoiceEngineState
    let action: () -> Void
    let size: CGFloat
    
    init(state: VoiceEngineState, size: CGFloat = 60, action: @escaping () -> Void) {
        self.state = state
        self.size = size
        self.action = action
    }
    
    @State private var pulseScale: CGFloat = 1.0
    
    private var iconName: String {
        switch state {
        case .idle: return "mic.fill"
        case .listening: return "waveform"
        case .processing: return "ellipsis"
        case .speaking: return "speaker.wave.3.fill"
        }
    }
    
    // A11Y: Dynamic label based on state
    private var accessibilityLabelText: String {
        switch state {
        case .idle: return "Activar micrófono"
        case .listening: return "Escuchando. Toca para detener"
        case .processing: return "Procesando tu mensaje"
        case .speaking: return "Hablando. Toca para interrumpir"
        }
    }
    
    var body: some View {
        Button(action: {
            HapticService.shared.medium()
            action()
        }) {
            ZStack {
                // Pulse animation rings for listening state
                if state == .listening {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(ColorTheme.accentHex.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                            .frame(width: size + CGFloat(index) * 16, height: size + CGFloat(index) * 16)
                            .scaleEffect(pulseScale)
                    }
                }
                
                Image(systemName: iconName)
                    .font(.system(size: size * 0.4))
                    .symbolEffect(.bounce, value: state)
                    .foregroundStyle(state == .listening ? ColorTheme.errorHex : .white)
                    .frame(width: size, height: size)
                    .background(
                        state == .listening ? ColorTheme.accentHex.opacity(0.2) : ColorTheme.accentHex
                    )
                    .clipShape(Circle())
                    .glassEffect(in: .circle)
            }
        }
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityAddTraits(.isButton)
        .accessibleTapTarget(minSize: size)
        .onChange(of: state) { _, newState in
            if newState == .listening {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
            } else {
                withAnimation {
                    pulseScale = 1.0
                }
            }
        }
    }
}
