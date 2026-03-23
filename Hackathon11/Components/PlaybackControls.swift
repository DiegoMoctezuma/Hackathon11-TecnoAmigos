// PlaybackControls.swift
// EchoStudy
// A11Y: Audio playback controls with full VoiceOver support

import SwiftUI

struct PlaybackControls: View {
    @Bindable var voiceEngine: VoiceEngine
    let text: String
    
    @State private var selectedSpeed: Float = 1.0
    
    private let speeds: [Float] = [0.75, 1.0, 1.25, 1.5, 2.0]
    
    var body: some View {
        VStack(spacing: 12) {
            // Main controls
            HStack(spacing: 24) {
                // Rewind
                Button {
                    HapticService.shared.light()
                    // Restart playback
                    voiceEngine.speak(text, priority: .immediate)
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                .accessibilityLabel("Retroceder al inicio")
                .accessibleTapTarget()
                
                // Play/Pause
                Button {
                    HapticService.shared.medium()
                    if voiceEngine.state == .speaking {
                        voiceEngine.pause()
                    } else {
                        voiceEngine.speak(text)
                    }
                } label: {
                    Image(systemName: voiceEngine.state == .speaking ? "pause.fill" : "play.fill")
                        .font(.title)
                        .symbolEffect(.bounce, value: voiceEngine.state)
                }
                .accessibilityLabel(voiceEngine.state == .speaking ? "Pausar lectura" : "Iniciar lectura")
                .accessibleTapTarget()
                
                // Stop
                Button {
                    HapticService.shared.light()
                    voiceEngine.interrupt()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .accessibilityLabel("Detener lectura")
                .accessibleTapTarget()
            }
            .foregroundStyle(ColorTheme.adaptiveText)
            
            // Speed selector
            HStack(spacing: 8) {
                Text("Velocidad:")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                ForEach(speeds, id: \.self) { speed in
                    Button {
                        HapticService.shared.selection()
                        selectedSpeed = speed
                        voiceEngine.speedRate = speed
                    } label: {
                        Text("\(speed, specifier: "%.2g")x")
                            .font(FontTheme.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(selectedSpeed == speed ? .white : ColorTheme.adaptiveText)
                            .background(selectedSpeed == speed ? ColorTheme.accentHex : Color.clear)
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Velocidad \(speed, specifier: "%.2g") equis")
                    .accessibilityAddTraits(selectedSpeed == speed ? .isSelected : [])
                }
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Controles de reproducción de audio")
    }
}
