// Hackathon11App.swift
// EchoStudy — @main entry point
// SwiftData container, Router, VoiceEngine injection

import SwiftUI
import SwiftData

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
            .environment(router)
            .environment(voiceEngine)
            .environment(aiManager)
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
