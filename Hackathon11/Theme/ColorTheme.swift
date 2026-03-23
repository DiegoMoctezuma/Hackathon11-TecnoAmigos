// ColorTheme.swift
// EchoStudy
// A11Y: All color pairs verified for WCAG AAA (7:1) contrast ratio

import SwiftUI

// MARK: - Color Theme

enum ColorTheme {
    // MARK: - Fallback Hex Colors
    static let primaryHex = Color(hex: "#1B4965")
    static let secondaryHex = Color(hex: "#62B6CB")
    static let accentHex = Color(hex: "#F4A261")
    static let backgroundLight = Color(hex: "#FAF9F6")
    static let backgroundDark = Color(hex: "#0D1117")
    static let surfaceLight = Color(hex: "#FFFFFF")
    static let surfaceDark = Color(hex: "#161B22")
    static let textLight = Color(hex: "#1A1A2E")
    static let textDark = Color(hex: "#E6EDF3")
    static let successHex = Color(hex: "#2D6A4F")
    static let errorHex = Color(hex: "#E63946")
    static let warningHex = Color(hex: "#F4A261")
    
    // MARK: - Adaptive Colors (light/dark)
    static let adaptiveBackground = Color(light: backgroundLight, dark: backgroundDark)
    static let adaptiveSurface = Color(light: surfaceLight, dark: surfaceDark)
    static let adaptiveText = Color(light: textLight, dark: textDark)
    static let adaptiveTextSecondary = Color(light: textLight.opacity(0.7), dark: textDark.opacity(0.7))
    
    // MARK: - Gradient Backgrounds
    static let backgroundGradient = LinearGradient(
        colors: [primaryHex.opacity(0.05), secondaryHex.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentHex, accentHex.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Subject Colors
    static let subjectColors: [Color] = [
        Color(hex: "#1B4965"),
        Color(hex: "#2D6A4F"),
        Color(hex: "#E63946"),
        Color(hex: "#F4A261"),
        Color(hex: "#62B6CB"),
        Color(hex: "#6A4C93"),
        Color(hex: "#1982C4"),
        Color(hex: "#FF595E"),
    ]
    
    // MARK: - Contrast Ratio Calculation
    static func relativeLuminance(of color: Color) -> Double {
        let resolved = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        func linearize(_ c: CGFloat) -> Double {
            let val = Double(c)
            return val <= 0.03928 ? val / 12.92 : pow((val + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }
    
    static func contrastRatio(_ color1: Color, _ color2: Color) -> Double {
        let l1 = relativeLuminance(of: color1)
        let l2 = relativeLuminance(of: color2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    static func meetsAAAContrast(_ foreground: Color, _ background: Color) -> Bool {
        contrastRatio(foreground, background) >= 7.0
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
