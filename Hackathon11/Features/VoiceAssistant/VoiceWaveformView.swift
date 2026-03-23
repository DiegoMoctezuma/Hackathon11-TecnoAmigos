// VoiceWaveformView.swift
// EchoStudy
// A11Y: Animated waveform for voice activity visualization

import SwiftUI

struct VoiceWaveformView: View {
    let isActive: Bool
    let barCount: Int
    
    @State private var heights: [CGFloat] = []
    
    init(isActive: Bool, barCount: Int = 5) {
        self.isActive = isActive
        self.barCount = barCount
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorTheme.accentHex)
                    .frame(width: 4, height: heights.indices.contains(index) ? heights[index] : 8)
                    .animation(
                        .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: isActive
                    )
            }
        }
        .frame(height: 32)
        .onAppear { updateHeights() }
        .onChange(of: isActive) { _, _ in updateHeights() }
        // A11Y: Decorative element
        .accessibilityHidden(true)
    }
    
    private func updateHeights() {
        heights = (0..<barCount).map { _ in
            isActive ? CGFloat.random(in: 8...28) : 8
        }
    }
}
