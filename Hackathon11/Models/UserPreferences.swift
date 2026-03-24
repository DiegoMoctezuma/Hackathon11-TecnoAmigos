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
    static let soundsEnabled = "echo_sounds_enabled"
    static let autoReadTopics = "echo_auto_read_topics"
    static let autoReadSpeed = "echo_auto_read_speed"
    static let contrastLevel = "echo_contrast_level"
    static let additionalTextSize = "echo_additional_text_size"
    static let voiceLanguage = "echo_voice_language"
    static let consentPhotos = "echo_consent_photos"
    static let consentText = "echo_consent_text"
    static let consentConversations = "echo_consent_conversations"
    static let consentQuizzes = "echo_consent_quizzes"
    static let consentFeedback = "echo_consent_feedback"
}
