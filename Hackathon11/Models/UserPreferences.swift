// UserPreferences.swift
// EchoStudy
// User preferences stored via @AppStorage

import Foundation

struct UserPreferences {
    var voiceSpeed: Float = 1.0
    var highContrast: Bool = false
    var hapticFeedback: Bool = true
    var autoReadResults: Bool = true
    var preferredVoiceId: String = ""
    var hasCompletedOnboarding: Bool = false
}

// MARK: - AppStorage Keys

enum PreferenceKeys {
    static let voiceSpeed = "echo_voice_speed"
    static let highContrast = "echo_high_contrast"
    static let hapticFeedback = "echo_haptic_feedback"
    static let autoReadResults = "echo_auto_read_results"
    static let preferredVoiceId = "echo_preferred_voice_id"
    static let hasCompletedOnboarding = "echo_has_completed_onboarding"
}
