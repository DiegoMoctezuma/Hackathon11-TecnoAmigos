// VoiceCommandParser.swift
// EchoStudy
// Parses voice commands from transcribed text

import Foundation

struct VoiceCommandParser {
    /// Parses a transcription string and returns the first detected command
    static func parse(_ text: String) -> VoiceCommand? {
        VoiceCommand.detect(in: text)
    }
    
    /// Removes command words from transcription to get clean input
    static func cleanTranscription(_ text: String) -> String {
        var cleaned = text.lowercased()
        for command in VoiceCommand.allCases {
            cleaned = cleaned.replacingOccurrences(of: command.rawValue, with: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
