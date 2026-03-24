// OnboardingView.swift
// EchoStudy
// A11Y: 4-step onboarding narrated by voice + calibration + accessibility setup

import SwiftUI

struct OnboardingView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var viewModel = OnboardingViewModel()
    @State private var showCalibration = false
    @State private var showAccessibilitySetup = false
    
    private let pages: [(icon: String, title: String, description: String, narration: String)] = [
        (
            "graduationcap.fill",
            "Bienvenido a ARGOS",
            "Tu compañero de estudio accesible. Diseñado para que aprendas con tu voz, a tu ritmo.",
            "Bienvenido a ARGOS. Tu compañero de estudio accesible."
        ),
        (
            "camera.fill",
            "Sube fotos y documentos",
            "Sube fotos de pizarrones, PDFs o apuntes. La IA los convierte en resúmenes organizados por tema.",
            "Sube fotos de pizarrones, PDFs o apuntes. La IA los convierte en resúmenes organizados por tema."
        ),
        (
            "waveform.circle.fill",
            "Estudia a tu ritmo",
            "Escucha resúmenes, pregunta con tu voz, haz quizzes orales. Todo controlado por voz.",
            "Estudia a tu ritmo. Escucha resúmenes, pregunta con tu voz, haz quizzes orales."
        ),
        (
            "person.fill.checkmark",
            "Tú tienes el control",
            "Corrige la IA, elige el orden, aprende como quieras. EchoStudy se adapta a ti.",
            "Tú tienes el control. Corrige la IA, elige el orden, aprende como quieras."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Step Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= viewModel.currentPage
                              ? ColorTheme.accentHex
                              : ColorTheme.adaptiveTextSecondary.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Página \(viewModel.currentPage + 1) de \(pages.count)")
            
            Spacer()
            
            // MARK: - Page Content
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    onboardingPage(index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 420)
            
            Spacer()
            
            // MARK: - Navigation
            VStack(spacing: 16) {
                Button {
                    HapticService.shared.medium()
                    if viewModel.isLastPage {
                        showCalibration = true
                    } else {
                        viewModel.nextPage()
                    }
                } label: {
                    Text(viewModel.isLastPage ? "Configurar voz" : "Siguiente")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                .accessibilityHint(viewModel.isLastPage ? "Configura la velocidad de voz" : "Ir a la siguiente página")
                
                if !viewModel.isLastPage {
                    Button("Saltar") {
                        hasCompletedOnboarding = true
                    }
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .accessibilityLabel("Saltar introducción e ir al inicio")
                }
            }
            .padding(.bottom, 40)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .onChange(of: viewModel.currentPage) { _, newPage in
            voiceEngine.speak(pages[newPage].narration, priority: .immediate)
        }
        .onAppear {
            voiceEngine.speak(pages[0].narration, priority: .high)
        }
        .fullScreenCover(isPresented: $showCalibration) {
            VoiceCalibrationView(onComplete: {
                showCalibration = false
                showAccessibilitySetup = true
            })
        }
        .fullScreenCover(isPresented: $showAccessibilitySetup) {
            AccessibilitySetupView(onComplete: {
                showAccessibilitySetup = false
                hasCompletedOnboarding = true
            })
        }
    }
    
    private func onboardingPage(index: Int) -> some View {
        let page = pages[index]
        return VStack(spacing: 28) {
            Image(systemName: page.icon)
                .font(.system(size: 72))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ColorTheme.accentHex)
                .symbolEffect(.bounce, value: viewModel.currentPage)
                .accessibilityHidden(true)
            
            Text(page.title)
                .font(FontTheme.largeTitle)
                .foregroundStyle(ColorTheme.adaptiveText)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(page.description)
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Paso \(index + 1) de \(pages.count). \(page.title). \(page.description)")
    }
}
