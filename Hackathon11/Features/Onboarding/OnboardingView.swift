// OnboardingView.swift
// EchoStudy
// A11Y: 4-step onboarding narrated by voice

import SwiftUI

struct OnboardingView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var viewModel = OnboardingViewModel()
    
    private let pages: [(icon: String, title: String, description: String, narration: String)] = [
        (
            "waveform.and.mic",
            "Tu voz es la interfaz",
            "EchoStudy se controla con tu voz. Habla para buscar, preguntar, navegar y estudiar. Todo funciona sin necesidad de ver la pantalla.",
            "Bienvenido a EchoStudy. Esta app se controla con tu voz. Puedes hablar para buscar, preguntar, navegar y estudiar. Todo funciona sin necesidad de ver la pantalla."
        ),
        (
            "doc.text.viewfinder",
            "Sube cualquier material",
            "Fotos de pizarrones, PDFs, documentos. La IA extrae el texto, detecta temas y genera resúmenes que puedes escuchar.",
            "Puedes subir fotos de pizarrones, PDFs o documentos. La inteligencia artificial extrae el texto, detecta temas y genera resúmenes que puedes escuchar."
        ),
        (
            "brain.head.profile",
            "Estudia con IA",
            "Pide explicaciones alternativas, profundiza en temas, relaciona conceptos. EchoStudy es tu compañero de estudio paciente.",
            "Puedes pedir explicaciones alternativas, profundizar en temas y relacionar conceptos. EchoStudy es tu compañero de estudio paciente."
        ),
        (
            "questionmark.bubble",
            "Evalúate con quiz oral",
            "La IA genera preguntas sobre tus temas. Responde con voz y recibe feedback inmediato. Estudia de forma activa.",
            "La IA genera preguntas sobre tus temas. Responde con voz y recibe feedback inmediato. Comencemos."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // MARK: - Page Content
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    onboardingPage(index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 400)
            
            Spacer()
            
            // MARK: - Navigation
            VStack(spacing: 16) {
                // Voice speed calibration on last page
                if viewModel.isLastPage {
                    VStack(spacing: 8) {
                        Text("Velocidad de voz: \(viewModel.voiceSpeed, specifier: "%.1f")x")
                            .font(FontTheme.subheadline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        Slider(value: $viewModel.voiceSpeed, in: 0.5...2.0, step: 0.25)
                            .tint(ColorTheme.accentHex)
                            .accessibilityLabel("Velocidad de voz")
                            .accessibilityValue("\(viewModel.voiceSpeed, specifier: "%.1f") equis")
                            .onChange(of: viewModel.voiceSpeed) { _, newValue in
                                voiceEngine.speedRate = newValue
                                voiceEngine.speak("Esta es la velocidad seleccionada", priority: .immediate)
                            }
                    }
                    .padding(.horizontal, 32)
                }
                
                Button {
                    HapticService.shared.medium()
                    if viewModel.isLastPage {
                        voiceEngine.speedRate = viewModel.voiceSpeed
                        hasCompletedOnboarding = true
                    } else {
                        viewModel.nextPage()
                    }
                } label: {
                    Text(viewModel.isLastPage ? "Comenzar" : "Siguiente")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                .accessibilityHint(viewModel.isLastPage ? "Toca para comenzar a usar EchoStudy" : "Toca para ver la siguiente página")
                
                if !viewModel.isLastPage {
                    Button("Saltar") {
                        hasCompletedOnboarding = true
                    }
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .accessibilityLabel("Saltar introducción")
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
    }
    
    private func onboardingPage(index: Int) -> some View {
        let page = pages[index]
        return VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ColorTheme.accentHex)
                .symbolEffect(.bounce)
                .accessibilityHidden(true)
            
            Text(page.title)
                .font(FontTheme.title)
                .foregroundStyle(ColorTheme.adaptiveText)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(page.description)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Paso \(index + 1) de \(pages.count). \(page.title). \(page.description)")
    }
}

struct Onbo_pre: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
