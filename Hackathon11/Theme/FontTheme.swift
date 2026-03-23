// FontTheme.swift
// EchoStudy
// A11Y: All fonts use Dynamic Type, minimum 17pt body, .rounded for titles

import SwiftUI

// MARK: - Font Theme

enum FontTheme {
    
    // MARK: - Accessible Font Factory
    static func accessibleFont(
        _ style: Font.TextStyle,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> Font {
        Font.system(style, design: design, weight: weight)
    }
    
    // MARK: - Title Fonts (Rounded design)
    static let largeTitle = accessibleFont(.largeTitle, weight: .bold, design: .rounded)
    static let title = accessibleFont(.title, weight: .semibold, design: .rounded)
    static let title2 = accessibleFont(.title2, weight: .semibold, design: .rounded)
    static let title3 = accessibleFont(.title3, weight: .medium, design: .rounded)
    
    // MARK: - Body Fonts (Default design)
    static let headline = accessibleFont(.headline, weight: .semibold)
    static let body = accessibleFont(.body, weight: .regular)
    static let callout = accessibleFont(.callout, weight: .regular)
    static let subheadline = accessibleFont(.subheadline, weight: .regular)
    static let footnote = accessibleFont(.footnote, weight: .regular)
    static let caption = accessibleFont(.caption, weight: .regular)
}

// MARK: - View Extension for Consistent Text Styling

extension View {
    func echoTitle() -> some View {
        self.font(FontTheme.largeTitle)
    }
    
    func echoBody() -> some View {
        self.font(FontTheme.body)
    }
    
    func echoHeadline() -> some View {
        self.font(FontTheme.headline)
    }
}
