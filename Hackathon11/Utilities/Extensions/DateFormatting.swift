// DateFormatting.swift
// EchoStudy
// A11Y: Accessible date formatting (e.g., "hace 2 horas")

import Foundation

extension Date {
    /// Returns a relative, accessible date string in Spanish
    var accessibleRelativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns a short date string
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
}
