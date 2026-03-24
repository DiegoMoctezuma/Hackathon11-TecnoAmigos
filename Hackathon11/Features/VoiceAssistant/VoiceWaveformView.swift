// VoiceWaveformView.swift
// EchoStudy
// A11Y: Animated waveform driven by real microphone input level

import SwiftUI

struct VoiceWaveformView: View {
    let isActive: Bool
    /// Real audio level from VoiceEngine (0.0 – 1.0)
    var audioLevel: Float = 0.0
    let barCount: Int
    
    init(isActive: Bool, audioLevel: Float = 0.0, barCount: Int = 5) {
        self.isActive = isActive
        self.audioLevel = audioLevel
        self.barCount = barCount
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: !isActive)) { timeline in
            HStack(spacing: 4) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: 5, height: barHeight(for: index, date: timeline.date))
                }
            }
        }
        .frame(height: 32)
        .animation(.easeInOut(duration: 0.1), value: audioLevel)
        .animation(.easeInOut(duration: 0.15), value: isActive)
        // A11Y: Decorative element
        .accessibilityHidden(true)
    }
    
    /// Color shifts from accent to a brighter tone when audio is loud
    private var barColor: Color {
        guard isActive else { return ColorTheme.accentHex.opacity(0.4) }
        let level = CGFloat(audioLevel)
        return ColorTheme.accentHex.opacity(0.5 + level * 0.5)
    }
    
    // MARK: - Bar height driven by real audio level + sine offset
    
    private func barHeight(for index: Int, date: Date) -> CGFloat {
        guard isActive else { return 6 }
        
        // Base height from real microphone level
        let level = CGFloat(audioLevel)
        
        // Add a small sine offset per bar so they don't all move in unison
        let time = date.timeIntervalSinceReferenceDate
        let offset = Double(index) * 0.8
        let sine = sin(time * 3.0 + offset)
        let sineNorm = CGFloat((sine + 1.0) / 2.0) // 0...1
        
        // Combine: audio level controls amplitude, sine adds per-bar variation
        let height = 6 + level * 22 + sineNorm * 6
        return min(height, 32)
    }
}
