// Hackathon11App.swift
// EchoStudy — @main entry point
// SwiftData container, Router, VoiceEngine injection

import SwiftUI
import SwiftData

// MARK: - A11Y: Force VoiceOver to speak in Spanish

/// Sets `accessibilityLanguage` on the UIKit hosting window so
/// VoiceOver reads every SwiftUI element in Spanish.
private struct SpanishAccessibilityBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.isHidden = true
        vc.view.accessibilityElementsHidden = true
        return vc
    }
    
    func updateUIViewController(_ vc: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let window = vc.view.window else { return }
            window.accessibilityLanguage = "es-MX"
            window.rootViewController?.view.accessibilityLanguage = "es-MX"
        }
    }
}

@main
struct Hackathon11App: App {
    @State private var router = AppRouter()
    @State private var voiceEngine = VoiceEngine.shared
    @State private var aiManager = AIServiceManager.shared
    
    @AppStorage(PreferenceKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    AppTabView()
                } else {
                    OnboardingView()
                }
            }
            .background { SpanishAccessibilityBridge() }
            .environment(router)
            .environment(voiceEngine)
            .environment(aiManager)
            .environment(\.locale, Locale(identifier: "es-MX"))
            .task {
                await voiceEngine.requestAuthorization()
            }
        }
        .modelContainer(for: [
            Subject.self,
            Topic.self,
            Subtopic.self,
            StudyMaterial.self,
            Conversation.self,
            ChatMessage.self,
            QuizSession.self,
            QuizQuestion.self,
            AIFeedback.self
        ])
    }
}
