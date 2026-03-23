// AppRouter.swift
// EchoStudy
// Centralized navigation with NavigationPath

import SwiftUI

// MARK: - Route

enum Route: Hashable {
    case home
    case subjectDetail(Subject)
    case topicDetail(Topic)
    case uploadMaterial
    case uploadMaterialToSubject(Subject)
    case voiceAssistant
    case quizSetup
    case quizSession(Subject, [Topic])
    case quizResults(QuizSession)
    case settings
    case voiceSettings
    case accessibilitySettings
    case dataPrivacy
    case about
    case onboarding
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home: hasher.combine("home")
        case .subjectDetail(let s): hasher.combine("subject"); hasher.combine(s.id)
        case .topicDetail(let t): hasher.combine("topic"); hasher.combine(t.id)
        case .uploadMaterial: hasher.combine("upload")
        case .uploadMaterialToSubject(let s): hasher.combine("uploadTo"); hasher.combine(s.id)
        case .voiceAssistant: hasher.combine("voice")
        case .quizSetup: hasher.combine("quizSetup")
        case .quizSession(let s, let t): hasher.combine("quizSession"); hasher.combine(s.id); hasher.combine(t.map(\.id))
        case .quizResults(let q): hasher.combine("quizResults"); hasher.combine(q.id)
        case .settings: hasher.combine("settings")
        case .voiceSettings: hasher.combine("voiceSettings")
        case .accessibilitySettings: hasher.combine("a11ySettings")
        case .dataPrivacy: hasher.combine("privacy")
        case .about: hasher.combine("about")
        case .onboarding: hasher.combine("onboarding")
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - App Router

@Observable
@MainActor
final class AppRouter {
    var path = NavigationPath()
    var selectedTab: AppTab = .home
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - App Tab

enum AppTab: String, CaseIterable {
    case home = "Inicio"
    case upload = "Subir"
    case quiz = "Quiz"
    case settings = "Ajustes"
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .upload: return "arrow.up.doc.fill"
        case .quiz: return "questionmark.bubble.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .home: return "Inicio. Tus materias y actividad reciente"
        case .upload: return "Subir material. Foto, PDF o documento"
        case .quiz: return "Quiz oral. Autoevaluación por voz"
        case .settings: return "Ajustes. Voz, accesibilidad y datos"
        }
    }
}
