// StringSpeech.swift
// EchoStudy
// String extensions for speech synthesis

import Foundation
import AVFoundation

extension String {
    /// Creates an AVSpeechUtterance from this string
    func toUtterance(rate: Float = AVSpeechUtteranceDefaultSpeechRate, language: String = "es-MX") -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: self)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.pitchMultiplier = 1.0
        return utterance
    }
}
