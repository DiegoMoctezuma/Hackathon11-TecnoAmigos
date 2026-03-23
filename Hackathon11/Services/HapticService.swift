// HapticService.swift
// EchoStudy
// Centralized haptic feedback service

import UIKit

@Observable
final class HapticService {
    static let shared = HapticService()
    
    var isEnabled: Bool = true
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func light() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func medium() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func heavy() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
