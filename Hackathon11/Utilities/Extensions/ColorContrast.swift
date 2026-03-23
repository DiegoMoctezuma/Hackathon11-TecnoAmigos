// ColorContrast.swift
// EchoStudy
// A11Y: Color contrast validation for WCAG compliance

import SwiftUI

extension Color {
    /// Returns the contrast ratio against another color
    func contrastRatio(against other: Color) -> Double {
        ColorTheme.contrastRatio(self, other)
    }
    
    /// Checks if this color meets WCAG AAA (7:1) against another
    func meetsAAA(against other: Color) -> Bool {
        ColorTheme.meetsAAAContrast(self, other)
    }
}
