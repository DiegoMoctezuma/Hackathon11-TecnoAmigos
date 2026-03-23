// SubjectIcon.swift
// EchoStudy
// A11Y: Subject icon with color and SF Symbol

import SwiftUI

struct SubjectIcon: View {
    let iconName: String
    let colorHex: String
    let size: CGFloat
    
    init(iconName: String, colorHex: String, size: CGFloat = 44) {
        self.iconName = iconName
        self.colorHex = colorHex
        self.size = size
    }
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.5))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color(hex: colorHex))
            .frame(width: size, height: size)
            .glassEffect(in: .rect(cornerRadius: size * 0.25))
            .accessibilityHidden(true) // A11Y: Decorative, parent has label
    }
}
