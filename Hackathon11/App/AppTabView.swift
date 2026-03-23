// AppTabView.swift
// EchoStudy
// TabView with 4 tabs + floating voice button

import SwiftUI
import SwiftData

struct AppTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(VoiceEngine.self) private var voiceEngine
    
    var body: some View {
        @Bindable var router = router
        
        TabView(selection: $router.selectedTab) {
            // MARK: - Home Tab
            Tab(AppTab.home.rawValue, systemImage: AppTab.home.iconName, value: AppTab.home) {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route)
                        }
                }
            }
            .accessibilityLabel(AppTab.home.accessibilityLabel)
            
            // MARK: - Upload Tab
            Tab(AppTab.upload.rawValue, systemImage: AppTab.upload.iconName, value: AppTab.upload) {
                NavigationStack {
                    UploadMaterialView()
                }
            }
            .accessibilityLabel(AppTab.upload.accessibilityLabel)
            
            // MARK: - Quiz Tab
            Tab(AppTab.quiz.rawValue, systemImage: AppTab.quiz.iconName, value: AppTab.quiz) {
                NavigationStack {
                    QuizSetupView()
                }
            }
            .accessibilityLabel(AppTab.quiz.accessibilityLabel)
            
            // MARK: - Settings Tab
            Tab(AppTab.settings.rawValue, systemImage: AppTab.settings.iconName, value: AppTab.settings) {
                NavigationStack {
                    SettingsView()
                }
            }
            .accessibilityLabel(AppTab.settings.accessibilityLabel)
        }
        .overlay {
            FloatingVoiceButton()
        }
    }
    
    // MARK: - Navigation Destinations
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .subjectDetail(let subject):
            SubjectDetailView(subject: subject)
        case .topicDetail(let topic):
            TopicDetailView(topic: topic)
        case .uploadMaterialToSubject(let subject):
            UploadMaterialView(preselectedSubject: subject)
        case .quizResults(let session):
            QuizResultsView(session: session)
        case .voiceSettings:
            VoiceSettingsView()
        case .accessibilitySettings:
            AccessibilitySettingsView()
        case .dataPrivacy:
            DataPrivacyView()
        case .about:
            AboutView()
        default:
            EmptyView()
        }
    }
}
